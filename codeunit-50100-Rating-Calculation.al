codeunit 50100 "Rating Calculation"
{
    procedure CalculateVendorRating(VendorNo: Code[20]; DateFilter: Text)
    var
        VendorRatingEntry: Record "Vendor Rating Entry";
        VendorRatingSetup: Record "Vendor Rating Setup";
        VendorRecord: Record Vendor;
        RatingDataManagement: Codeunit "Rating Data Management";
        EntryCount: Integer;
        StartDate: Date;
        EndDate: Date;
    begin
        if not VendorRecord.Get(VendorNo) then
            Error('Vendor %1 not found', VendorNo);

        VendorRatingSetup := GetVendorSetup(VendorRecord."Rating Setup Code");
        GetEvaluationDateRange(StartDate, EndDate);  // Using our helper regardless of DateFilter

        RatingDataManagement.ResetPeriodPoints(VendorNo, StartDate, EndDate);
        RatingDataManagement.ClearExistingHistory(VendorNo, StartDate, EndDate);

        VendorRatingEntry.Reset();
        VendorRatingEntry.SetRange("Vendor No", VendorNo);
        VendorRatingEntry.SetRange("Posting Date", StartDate, EndDate);
        EntryCount := VendorRatingEntry.Count;

        if EntryCount < VendorRatingSetup."Minimum Orders Required" then
            Error('Minimum orders requirement not met. Found %1, Required %2',
                EntryCount, VendorRatingSetup."Minimum Orders Required");

        CalcAverageScores(
            VendorRatingEntry,
            StartDate,
            EndDate,
            EntryCount,
            VendorNo,
            VendorRecord
        );
        OnAfterCalculateVendorRating(VendorNo);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCalculateVendorRating(VendorNo: Code[20])
    begin
    end;

    procedure RecalculateVendorRating(VendorNo: Code[20])
    var
        StartDate: Date;
        EndDate: Date;
        RatingDataManagement: Codeunit "Rating Data Management";
    begin
        GetEvaluationDateRange(StartDate, EndDate);
        RatingDataManagement.ClearExistingHistory(VendorNo, StartDate, EndDate);
        CalculateVendorRating(VendorNo, Format(StartDate) + '..' + Format(EndDate));
    end;

    local procedure CalcAverageScores(
    var VendorRatingEntry: Record "Vendor Rating Entry";
    StartDate: Date;
    EndDate: Date;
    EntryCount: Integer;
    VendorNo: Code[20];
    var VendorRecord: Record Vendor)
    var
        VendorRatingSetup: Record "Vendor Rating Setup";
        RatingScoreCalculator: Codeunit "Rating Score Calculation";
        RatingDataManagement: Codeunit "Rating Data Management";
        TotalScheduleScore: Decimal;
        TotalQualityScore: Decimal;
        TotalQuantityScore: Decimal;
        WeightedScore: Decimal;
    begin
        VendorRatingSetup := GetVendorSetup(VendorRecord."Rating Setup Code");

        if VendorRatingEntry.FindSet() then
            repeat
                TotalScheduleScore += VendorRatingEntry."Schedule Score";
                TotalQualityScore += VendorRatingEntry."Quality Score";
                TotalQuantityScore += VendorRatingEntry."Quantity Score";
            until VendorRatingEntry.Next() = 0;

        WeightedScore := CalculateWeightedScore(
            TotalScheduleScore / EntryCount,
            TotalQualityScore / EntryCount,
            TotalQuantityScore / EntryCount,
            VendorRatingSetup
        );
        WeightedScore := Round(WeightedScore, 0.01);

        VendorRecord."Current Rating" := RatingScoreCalculator.DetermineRating(WeightedScore, VendorRecord."Rating Setup Code");
        VendorRecord."Last Evaluation Date" := Today;
        VendorRecord."YTD Average Score" := WeightedScore;
        VendorRecord."Trend Indicator" := RatingScoreCalculator.CalculateTrend(VendorNo);
        VendorRecord.Modify(true);

        RatingDataManagement.CreateHistoryEntry(
            VendorNo,
            StartDate,
            EndDate,
            EntryCount,
            Round(TotalScheduleScore / EntryCount, 0.01),
            Round(TotalQualityScore / EntryCount, 0.01),
            Round(TotalQuantityScore / EntryCount, 0.01),
            WeightedScore,
            VendorRecord."Current Rating"
        );
    end;

    procedure CalculateEntryScores(var VendorRatingEntry: Record "Vendor Rating Entry")
    var
        VendorRatingSetup: Record "Vendor Rating Setup";
        RatingScoreCalculator: Codeunit "Rating Score Calculation";
        PurchRcptHeader: Record "Purch. Rcpt. Header";
        ScheduleScore: Decimal;
        QuantityScore: Decimal;
        TotalScore: Decimal;
    begin
        VendorRatingSetup := GetVendorSetup(GetVendorSetupCode(VendorRatingEntry."Vendor No"));
        VendorRatingEntry."Setup Code" := VendorRatingSetup."Setup Code";

        ScheduleScore := RatingScoreCalculator.CalculateScheduleScore(VendorRatingEntry."Receipt No");
        VendorRatingEntry."Schedule Score" := ScheduleScore;

        if PurchRcptHeader.Get(VendorRatingEntry."Receipt No") then
            VendorRatingEntry."Quality Score" := PurchRcptHeader."Quality Score"
        else
            VendorRatingEntry."Quality Score" := 0;

        QuantityScore := RatingScoreCalculator.CalculateQuantityScore(VendorRatingEntry."Receipt No");
        VendorRatingEntry."Quantity Score" := QuantityScore;

        TotalScore := CalculateWeightedScore(
            ScheduleScore,
            VendorRatingEntry."Quality Score",
            QuantityScore,
            VendorRatingSetup
        );

        VendorRatingEntry."Total Score" := Round(TotalScore, 0.01);
        VendorRatingEntry.Rating := RatingScoreCalculator.DetermineRating(TotalScore, VendorRatingEntry."Setup Code");
        RatingScoreCalculator.CalculateEntryPoints(VendorRatingEntry);

        VendorRatingEntry."Evaluation Completed" := true;
        VendorRatingEntry.Modify();
    end;

    local procedure GetVendorSetup(SetupCode: Code[20]) VendorRatingSetup: Record "Vendor Rating Setup"
    begin
        if not VendorRatingSetup.Get(SetupCode) then
            VendorRatingSetup.Get('DEFAULT');
    end;

    local procedure GetVendorSetupCode(VendorNo: Code[20]): Code[20]
    var
        Vendor: Record Vendor;
    begin
        if Vendor.Get(VendorNo) then
            exit(Vendor."Rating Setup Code");
        exit('DEFAULT');
    end;

    local procedure CalculateWeightedScore(
        ScheduleScore: Decimal;
        QualityScore: Decimal;
        QuantityScore: Decimal;
        VendorRatingSetup: Record "Vendor Rating Setup"): Decimal
    begin
        exit(
            (ScheduleScore * VendorRatingSetup."Schedule Weight") +
            (QualityScore * VendorRatingSetup."Quality Weight") +
            (QuantityScore * VendorRatingSetup."Quantity Weight")
        );
    end;

    local procedure GetEvaluationDateRange(var StartDate: Date; var EndDate: Date)
    begin
        EndDate := CalcDate('<CM>', WorkDate());
        StartDate := CalcDate('<-CM>', EndDate);
    end;
}