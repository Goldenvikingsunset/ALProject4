codeunit 50100 "Rating Calculation"
{
    procedure CalculateVendorRating(VendorNo: Code[20]; DateFilter: Text)
    var
        VendorRatingEntry: Record "Vendor Rating Entry";
        VendorRatingSetup: Record "Vendor Rating Setup";
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

        if not VendorRatingSetup.Get('DEFAULT') then
            Error('Vendor Rating Setup not found');

        // Set period dates based on monthly evaluation
        EndDate := CalcDate('<CM>', WorkDate()); // End of current month
        StartDate := CalcDate('<-CM>', EndDate); // Start of current month

        // Reset points for this period before recalculating
        ResetPeriodPoints(VendorNo, StartDate, EndDate);

        // Clear existing history for this period
        ClearExistingHistory(VendorNo, StartDate, EndDate);

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
    begin
        EndDate := WorkDate();
        StartDate := CalcDate('<-1M>', EndDate);

        ClearExistingHistory(VendorNo, StartDate, EndDate);
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
        TotalScheduleScore: Decimal;
        TotalQualityScore: Decimal;
        TotalQuantityScore: Decimal;
        WeightedScore: Decimal;
    begin
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
        VendorRecord."Current Rating" := DetermineRating(WeightedScore);
        VendorRecord."Last Evaluation Date" := Today;
        VendorRecord."YTD Average Score" := WeightedScore;
        VendorRecord."Trend Indicator" := CalculateTrend(VendorNo);
        VendorRecord.Modify(true);

        // Create history entry
        CreateHistoryEntry(
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

    procedure CreateRatingEntry(PurchRcptHeader: Record "Purch. Rcpt. Header")
    var
        VendorRatingEntry: Record "Vendor Rating Entry";
        PurchOrderHeader: Record "Purchase Header";
        PurchRcptLine: Record "Purch. Rcpt. Line";
        PurchOrderLine: Record "Purchase Line";
    begin
        PurchRcptLine.SetRange("Document No.", PurchRcptHeader."No.");
        if not PurchRcptLine.FindFirst() then
            exit;

        if PurchOrderHeader.Get(PurchOrderHeader."Document Type"::Order, PurchRcptLine."Order No.") then;

        VendorRatingEntry.Init();
        VendorRatingEntry."Vendor No" := PurchRcptHeader."Buy-from Vendor No.";
        VendorRatingEntry."Document No" := PurchRcptHeader."No.";
        VendorRatingEntry."Document Type" := PurchOrderHeader."Document Type"::Order;
        VendorRatingEntry."Posting Date" := PurchRcptHeader."Posting Date";
        VendorRatingEntry."Expected Date" := PurchOrderHeader."Expected Receipt Date";
        VendorRatingEntry."Actual Date" := PurchRcptHeader."Posting Date";

        if PurchOrderLine.Get(PurchOrderLine."Document Type"::Order,
                            PurchRcptLine."Order No.",
                            PurchRcptLine."Order Line No.") then
            VendorRatingEntry."Ordered Quantity" := PurchOrderLine.Quantity;

        VendorRatingEntry."Received Quantity" := PurchRcptLine.Quantity;
        VendorRatingEntry.Insert(true);
    end;

    procedure CalculateEntryScores(var VendorRatingEntry: Record "Vendor Rating Entry")
    var
        VendorRatingSetup: Record "Vendor Rating Setup";
        ScheduleScore: Decimal;
        QualityScore: Decimal;
        QuantityScore: Decimal;
        TotalScore: Decimal;
    begin
        if not EnsureSetupExists() then
            exit;

        VendorRatingSetup.Get('DEFAULT');

        // Calculate Schedule Score
        ScheduleScore := CalculateScheduleScore(VendorRatingEntry."Document No");
        VendorRatingEntry."Schedule Score" := ScheduleScore;

        // Calculate Quality Score - using posting date as date filter
        QualityScore := CalculateQualityScore(
            VendorRatingEntry."Vendor No",
            Format(VendorRatingEntry."Posting Date", 0, '<Year4>-<Month,2>-<Day,2>')
        );
        VendorRatingEntry."Quality Score" := QualityScore;

        // Calculate Quantity Score
        QuantityScore := CalculateQuantityScore(VendorRatingEntry."Document No");
        VendorRatingEntry."Quantity Score" := QuantityScore;

        // Calculate weighted total score
        TotalScore := (ScheduleScore * VendorRatingSetup."Schedule Weight") +
                     (QualityScore * VendorRatingSetup."Quality Weight") +
                     (QuantityScore * VendorRatingSetup."Quantity Weight");

        Message('Scores - Schedule: %1, Quality: %2, Quantity: %3, Total: %4',
                ScheduleScore, QualityScore, QuantityScore, TotalScore);

        VendorRatingEntry."Total Score" := Round(TotalScore, 0.01);
        VendorRatingEntry.Rating := DetermineRating(TotalScore);
        CalculateEntryPoints(VendorRatingEntry);

        VendorRatingEntry."Evaluation Completed" := true;
        VendorRatingEntry.Modify();
    end;

    local procedure CalculateScheduleScore(DocumentNo: Code[20]): Decimal
    var
        PurchRcptHeader: Record "Purch. Rcpt. Header";
        PurchRcptLine: Record "Purch. Rcpt. Line";
        DeliveryVariance: Record "Delivery Variance Setup";
        DaysLate: Integer;
    begin
        if not PurchRcptHeader.Get(DocumentNo) then
            exit(0);

        PurchRcptLine.SetRange("Document No.", DocumentNo);
        if not PurchRcptLine.FindFirst() then
            exit(0);

        // Calculate days late (negative means early)
        DaysLate := PurchRcptHeader."Posting Date" - PurchRcptLine."Expected Receipt Date";

        // Perfect score for on-time or early deliveries
        if DaysLate <= 0 then
            exit(100);

        // For late deliveries, find applicable score from setup
        DeliveryVariance.SetFilter("Days Late From", '<=%1', DaysLate);
        DeliveryVariance.SetFilter("Days Late To", '>=%1', DaysLate);

        if DeliveryVariance.FindFirst() then
            exit(DeliveryVariance.Score)
        else
            exit(0);
    end;

    local procedure CalculateQualityScore(VendorNo: Code[20]; DateFilter: Text): Decimal
    var
        ReturnShipmentLine: Record "Return Shipment Line";
        PurchRcptLine: Record "Purch. Rcpt. Line";
        QualityVarianceSetup: Record "Quantity Variance Setup";
        TotalReceived: Decimal;
        TotalReturned: Decimal;
        ReturnPercentage: Decimal;
    begin
        // Get total received for this vendor in the period
        PurchRcptLine.Reset();
        PurchRcptLine.SetRange("Buy-from Vendor No.", VendorNo);
        PurchRcptLine.SetFilter("Posting Date", DateFilter);
        PurchRcptLine.CalcSums(Quantity);
        TotalReceived := PurchRcptLine.Quantity;

        if TotalReceived = 0 then
            exit(0);

        // Get total returns for this vendor in the period
        ReturnShipmentLine.Reset();
        ReturnShipmentLine.SetRange("Buy-from Vendor No.", VendorNo);
        ReturnShipmentLine.SetFilter("Posting Date", DateFilter);
        ReturnShipmentLine.CalcSums(Quantity);
        TotalReturned := ReturnShipmentLine.Quantity;

        if TotalReturned = 0 then
            exit(100);  // No returns = perfect score

        // Calculate return percentage
        ReturnPercentage := (TotalReturned / TotalReceived) * 100;

        // Find applicable score from setup
        QualityVarianceSetup.Reset();
        QualityVarianceSetup.SetFilter("Variance Percentage From", '<=%1', ReturnPercentage);
        QualityVarianceSetup.SetFilter("Variance Percentage To", '>=%1', ReturnPercentage);

        if QualityVarianceSetup.FindFirst() then
            exit(QualityVarianceSetup.Score)
        else
            exit(0);
    end;

    local procedure CalculateQuantityScore(DocumentNo: Code[20]): Decimal
    var
        PurchRcptLine: Record "Purch. Rcpt. Line";
        PurchLine: Record "Purchase Line";
        QuantityVarianceSetup: Record "Quantity Variance Setup";
        VariancePercentage: Decimal;
    begin
        // Get receipt line
        PurchRcptLine.SetRange("Document No.", DocumentNo);
        if not PurchRcptLine.FindFirst() then
            exit(0);

        // Find original purchase order line
        if not PurchLine.Get(PurchLine."Document Type"::Order,
                            PurchRcptLine."Order No.",
                            PurchRcptLine."Order Line No.") then
            exit(0);

        if PurchLine.Quantity = 0 then
            exit(0);

        // Calculate variance percentage
        VariancePercentage := 100 * (PurchRcptLine.Quantity - PurchLine.Quantity)
                             / PurchLine.Quantity;

        // Find applicable score from setup
        QuantityVarianceSetup.SetFilter("Variance Percentage From", '<=%1', VariancePercentage);
        QuantityVarianceSetup.SetFilter("Variance Percentage To", '>=%1', VariancePercentage);

        if QuantityVarianceSetup.FindFirst() then
            exit(QuantityVarianceSetup.Score)
        else
            exit(0);
    end;

    local procedure UpdateVendorRating(var Vendor: Record Vendor; NewScore: Decimal; StartDate: Date; EndDate: Date)
    var
        VendorRatingEntry: Record "Vendor Rating Entry";
        VendorRatingHistory: Record "Vendor Rating History";
        TotalPoints: Integer;
        EntryCount: Integer;
        PeriodAveragePoints: Integer;
    begin
        // Calculate average points from entries for this period
        VendorRatingEntry.SetRange("Vendor No", Vendor."No.");
        VendorRatingEntry.SetRange("Posting Date", StartDate, EndDate);

        if VendorRatingEntry.FindSet() then
            repeat
                TotalPoints += VendorRatingEntry.Points;
            until VendorRatingEntry.Next() = 0;

        EntryCount := VendorRatingEntry.Count;

        if EntryCount > 0 then begin
            // Calculate period average points
            PeriodAveragePoints := Round(TotalPoints / EntryCount, 1);

            // Add period average to vendor's cumulative total
            Vendor.Validate("Current Points", Vendor."Current Points" + PeriodAveragePoints);
        end;

        // Validate and update fields in the Vendor record
        Vendor.Validate("Current Rating", DetermineRating(NewScore));
        Vendor.Validate("Last Evaluation Date", Today);
        Vendor.Validate("YTD Average Score", NewScore);
        Vendor.Validate("Trend Indicator", CalculateTrend(Vendor."No."));

        // Calculate TotalPoints from Vendor Rating History
        TotalPoints := 0;
        VendorRatingHistory.SetRange("Vendor No", Vendor."No.");
        if VendorRatingHistory.FindSet() then
            repeat
                TotalPoints += VendorRatingHistory."Total Points";
            until VendorRatingHistory.Next() = 0;

        Vendor.Validate("Current Points", TotalPoints);

        // Perform a single Modify call for all changes
        Vendor.Modify(true);
    end;

    procedure DeductVendorPoints(var Vendor: Record Vendor; PointsToDeduct: Integer)
    begin
        if Vendor.Get(Vendor."No.") then begin
            Vendor.Validate("Current Points", Vendor."Current Points" - PointsToDeduct);
            Vendor.Modify(true);
        end;
    end;

    procedure ResetPeriodPoints(VendorNo: Code[20]; StartDate: Date; EndDate: Date)
    var
        VendorRatingHistory: Record "Vendor Rating History";
    begin
        // Just clear the existing history record for this period if it exists
        VendorRatingHistory.SetRange("Vendor No", VendorNo);
        VendorRatingHistory.SetRange("Period Start Date", StartDate);
        VendorRatingHistory.SetRange("Period End Date", EndDate);

        if VendorRatingHistory.FindFirst() then
            VendorRatingHistory.Delete();
    end;

    local procedure CreateHistoryEntry(
    VendorNo: Code[20];
    StartDate: Date;
    EndDate: Date;
    EntryCount: Integer;
    AvgScheduleScore: Decimal;
    AvgQualityScore: Decimal;
    AvgQuantityScore: Decimal;
    TotalScore: Decimal;
    Rating: Text[30])
    var
        VendorRatingHistory: Record "Vendor Rating History";
        VendorRatingEntry: Record "Vendor Rating Entry";
        TotalPoints: Integer;
    begin
        VendorRatingHistory.Init();
        VendorRatingHistory."Vendor No" := VendorNo;
        VendorRatingHistory."Period Start Date" := StartDate;
        VendorRatingHistory."Period End Date" := EndDate;
        VendorRatingHistory."Number of Orders" := EntryCount;
        VendorRatingHistory."Average Schedule Score" := AvgScheduleScore;
        VendorRatingHistory."Average Quality Score" := AvgQualityScore;
        VendorRatingHistory."Average Quantity Score" := AvgQuantityScore;
        VendorRatingHistory."Total Score" := TotalScore;
        VendorRatingHistory.Rating := Rating;

        // Calculate average points from entries
        VendorRatingEntry.SetRange("Vendor No", VendorNo);
        VendorRatingEntry.SetRange("Posting Date", StartDate, EndDate);
        if VendorRatingEntry.FindSet() then
            repeat
                TotalPoints += VendorRatingEntry.Points;
            until VendorRatingEntry.Next() = 0;

        if EntryCount > 0 then
            VendorRatingHistory."Total Points" := Round(TotalPoints / EntryCount, 1);

        if not VendorRatingHistory.Insert() then
            VendorRatingHistory.Modify();
    end;

    local procedure CalculateTrend(VendorNo: Code[20]): Enum "Trend Indicator"
    var
        VendorRatingHistory: Record "Vendor Rating History";
        PrevScore, CurrentScore : Decimal;
        Threshold: Decimal;
    begin
        Threshold := 5;

        VendorRatingHistory.SetRange("Vendor No", VendorNo);
        VendorRatingHistory.SetCurrentKey("Vendor No", "Period End Date");

        if VendorRatingHistory.FindLast() then begin
            CurrentScore := VendorRatingHistory."Total Score";

            if VendorRatingHistory.Next(-1) <> 0 then begin
                PrevScore := VendorRatingHistory."Total Score";

                if (CurrentScore - PrevScore) > Threshold then
                    exit("Trend Indicator"::Improving);
                if (PrevScore - CurrentScore) > Threshold then
                    exit("Trend Indicator"::Declining);
            end;
        end;

        exit("Trend Indicator"::Stable);
    end;

    local procedure HasMinimumOrders(VendorNo: Code[20]; DateFilter: Text): Boolean
    var
        VendorRatingEntry: Record "Vendor Rating Entry";
        VendorRatingSetup: Record "Vendor Rating Setup";
        EntryCount: Integer;
    begin
        if not EnsureSetupExists() then
            exit(true);

        VendorRatingSetup.Get('DEFAULT');
        if VendorRatingSetup."Minimum Orders Required" <= 0 then
            exit(true);

        VendorRatingEntry.SetRange("Vendor No", VendorNo);
        VendorRatingEntry.SetFilter("Posting Date", DateFilter);
        EntryCount := VendorRatingEntry.Count;

        exit(EntryCount >= VendorRatingSetup."Minimum Orders Required");
    end;

    local procedure DetermineRating(Score: Decimal): Text[30]
    var
        RatingScale: Record "Rating Scale Setup";
        VendorRatingSetup: Record "Vendor Rating Setup";
    begin
        if not EnsureSetupExists() then
            exit('');

        VendorRatingSetup.Get('DEFAULT');

        RatingScale.SetRange("Rating Type", VendorRatingSetup."Rating Type");
        RatingScale.SetFilter("Score From", '<=%1', Score);
        RatingScale.SetFilter("Score To", '>=%1', Score);

        if RatingScale.FindFirst() then
            exit(RatingScale."Display Value");
        exit('');
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

    local procedure EnsureSetupExists(): Boolean
    var
        VendorRatingSetup: Record "Vendor Rating Setup";
    begin
        if not VendorRatingSetup.Get('DEFAULT') then begin
            VendorRatingSetup.Init();
            VendorRatingSetup."Setup Code" := 'DEFAULT';
            VendorRatingSetup."Rating Type" := VendorRatingSetup."Rating Type"::Percentage;
            exit(VendorRatingSetup.Insert());
        end;
        exit(true);
    end;

    local procedure CalculateEntryPoints(var VendorRatingEntry: Record "Vendor Rating Entry")
    var
        RatingScale: Record "Rating Scale Setup";
    begin
        RatingScale.SetFilter("Score From", '<=%1', VendorRatingEntry."Total Score");
        RatingScale.SetFilter("Score To", '>=%1', VendorRatingEntry."Total Score");

        if RatingScale.FindFirst() then
            VendorRatingEntry.Points := RatingScale.Points;
    end;

    local procedure CalculateHistoryPoints(VendorRatingHistory: Record "Vendor Rating History"): Integer
    var
        RatingScale: Record "Rating Scale Setup";
        VendorRatingSetup: Record "Vendor Rating Setup";
    begin
        if not VendorRatingSetup.Get('DEFAULT') then
            exit(0);

        RatingScale.Reset();
        RatingScale.SetRange("Rating Type", VendorRatingSetup."Rating Type");
        RatingScale.SetFilter("Score From", '<=%1', VendorRatingHistory."Total Score");
        RatingScale.SetFilter("Score To", '>=%1', VendorRatingHistory."Total Score");

        if RatingScale.FindFirst() then
            exit(RatingScale.Points);

        exit(0);
    end;

    local procedure ClearExistingHistory(VendorNo: Code[20]; StartDate: Date; EndDate: Date)
    var
        VendorRatingHistory: Record "Vendor Rating History";
    begin
        VendorRatingHistory.SetRange("Vendor No", VendorNo);
        VendorRatingHistory.SetRange("Period Start Date", StartDate);
        VendorRatingHistory.SetRange("Period End Date", EndDate);
        VendorRatingHistory.DeleteAll();
    end;
}