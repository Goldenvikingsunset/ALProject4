codeunit 50100 "Rating Calculation"
{
    procedure CalculateVendorRating(VendorNo: Code[20]; DateFilter: Text)
    var
        VendorRatingEntry: Record "Vendor Rating Entry";
        VendorRatingSetup: Record "Vendor Rating Setup";
        RatingScoreCalculator: Codeunit "Rating Score Calculation";
        RatingDataManagement: Codeunit "Rating Data Management";
        VendorRecord: Record Vendor;
        TotalScore: Decimal;
        AverageScore: Decimal;
        EntryCount: Integer;
        StartDate: Date;
        EndDate: Date;
    begin
        // Get vendor and setup
        if not VendorRecord.Get(VendorNo) then
            Error('Vendor %1 not found', VendorNo);

        // Change from using DEFAULT to using vendor's setup code
        if not VendorRatingSetup.Get(VendorRecord."Rating Setup Code") then
            VendorRatingSetup.Get('DEFAULT');

        // Set period dates based on monthly evaluation
        EndDate := CalcDate('<CM>', WorkDate()); // End of current month
        StartDate := CalcDate('<-CM>', EndDate); // Start of current month

        // Reset points for this period before recalculating
        RatingDataManagement.ResetPeriodPoints(VendorNo, StartDate, EndDate);

        // Clear existing history for this period
        RatingDataManagement.ClearExistingHistory(VendorNo, StartDate, EndDate);

        // Calculate scores for entries in period
        VendorRatingEntry.Reset();
        VendorRatingEntry.SetRange("Vendor No", VendorNo);
        VendorRatingEntry.SetRange("Posting Date", StartDate, EndDate);
        EntryCount := VendorRatingEntry.Count;

        if EntryCount < VendorRatingSetup."Minimum Orders Required" then
            Error('Minimum orders requirement not met. Found %1, Required %2',
                EntryCount, VendorRatingSetup."Minimum Orders Required");

        // Calculate average scores
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
        EndDate := WorkDate();
        StartDate := CalcDate('<-1M>', EndDate);

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
        // Remove the CalcFields since it's a regular field now
        // VendorRecord.CalcFields("Rating Setup Code");  // Remove this line

        if not VendorRatingSetup.Get(VendorRecord."Rating Setup Code") then
            VendorRatingSetup.Get('DEFAULT');

        if VendorRatingEntry.FindSet() then
            repeat
                TotalScheduleScore += VendorRatingEntry."Schedule Score";
                TotalQualityScore += VendorRatingEntry."Quality Score";
                TotalQuantityScore += VendorRatingEntry."Quantity Score";
            until VendorRatingEntry.Next() = 0;

        // Calculate weighted averages
        WeightedScore := (TotalScheduleScore / EntryCount * VendorRatingSetup."Schedule Weight") +
                        (TotalQualityScore / EntryCount * VendorRatingSetup."Quality Weight") +
                        (TotalQuantityScore / EntryCount * VendorRatingSetup."Quantity Weight");

        WeightedScore := Round(WeightedScore, 0.01);

        // Update vendor
        VendorRecord."Current Rating" := RatingScoreCalculator.DetermineRating(WeightedScore, VendorRecord."Rating Setup Code");
        VendorRecord."Last Evaluation Date" := Today;
        VendorRecord."YTD Average Score" := WeightedScore;
        VendorRecord."Trend Indicator" := RatingScoreCalculator.CalculateTrend(VendorNo);
        VendorRecord.Modify(true);

        // Create history entry
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
        ScheduleScore: Decimal;
        QualityScore: Decimal;
        QuantityScore: Decimal;
        TotalScore: Decimal;
        Vendor: Record Vendor;
    begin
        // Set correct Setup Code first
        if Vendor.Get(VendorRatingEntry."Vendor No") then
            VendorRatingEntry."Setup Code" := Vendor."Rating Setup Code";

        if VendorRatingEntry."Setup Code" = '' then
            VendorRatingEntry."Setup Code" := 'DEFAULT';

        // Get the correct setup based on entry's Setup Code
        if not VendorRatingSetup.Get(VendorRatingEntry."Setup Code") then
            VendorRatingSetup.Get('DEFAULT');

        // Calculate Schedule Score
        ScheduleScore := RatingScoreCalculator.CalculateScheduleScore(VendorRatingEntry."Document No");
        VendorRatingEntry."Schedule Score" := ScheduleScore;

        // Calculate Quality Score
        QualityScore := RatingScoreCalculator.CalculateQualityScore(
            VendorRatingEntry."Vendor No",
            Format(VendorRatingEntry."Posting Date", 0, '<Year4>-<Month,2>-<Day,2>')
        );
        VendorRatingEntry."Quality Score" := QualityScore;

        // Calculate Quantity Score
        QuantityScore := RatingScoreCalculator.CalculateQuantityScore(VendorRatingEntry."Document No");
        VendorRatingEntry."Quantity Score" := QuantityScore;

        // Calculate weighted total score
        TotalScore := (ScheduleScore * VendorRatingSetup."Schedule Weight") +
                     (QualityScore * VendorRatingSetup."Quality Weight") +
                     (QuantityScore * VendorRatingSetup."Quantity Weight");

        Message('Scores - Schedule: %1, Quality: %2, Quantity: %3, Total: %4',
            ScheduleScore, QualityScore, QuantityScore, TotalScore);

        VendorRatingEntry."Total Score" := Round(TotalScore, 0.01);
        VendorRatingEntry.Rating := RatingScoreCalculator.DetermineRating(TotalScore, VendorRatingEntry."Setup Code");
        RatingScoreCalculator.CalculateEntryPoints(VendorRatingEntry);

        VendorRatingEntry."Evaluation Completed" := true;
        VendorRatingEntry.Modify();
    end;

    local procedure GetDateFilterRange(DateFilter: Text; var StartDate: Date; var EndDate: Date): Boolean
    var
        DateStrings: List of [Text];
    begin
        if not DateFilter.Contains('..') then
            exit(false);

        DateStrings := DateFilter.Split('..');
        if DateStrings.Count <> 2 then
            exit(false);

        exit(
            Evaluate(StartDate, DateStrings.Get(1)) and
            Evaluate(EndDate, DateStrings.Get(2))
        );
    end;

    local procedure ValidateDateRange(var StartDate: Date; var EndDate: Date)
    begin
        if EndDate > WorkDate() then
            EndDate := WorkDate();
        if StartDate > EndDate then
            StartDate := EndDate;
    end;

}