codeunit 50104 "Rating Score Calculation"
{
    procedure CalculateScheduleScore(DocumentNo: Code[20]): Decimal
    var
        PurchRcptHeader: Record "Purch. Rcpt. Header";
        PurchRcptLine: Record "Purch. Rcpt. Line";
        DeliveryVariance: Record "Delivery Variance Setup";
        Vendor: Record Vendor;
        DaysLate: Integer;
    begin
        if not PurchRcptHeader.Get(DocumentNo) then
            exit(0);

        // Get vendor's setup code
        if Vendor.Get(PurchRcptHeader."Buy-from Vendor No.") then
            DeliveryVariance.SetRange("Setup Code", Vendor."Rating Setup Code")
        else
            DeliveryVariance.SetRange("Setup Code", 'DEFAULT');

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

    procedure CalculateQuantityScore(DocumentNo: Code[20]): Decimal
    var
        PurchRcptLine: Record "Purch. Rcpt. Line";
        PurchLine: Record "Purchase Line";
        QuantityVarianceSetup: Record "Quantity Variance Setup";
        Vendor: Record Vendor;
        VariancePercentage: Decimal;
    begin
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

        // Get vendor's setup code
        if Vendor.Get(PurchRcptLine."Buy-from Vendor No.") then
            QuantityVarianceSetup.SetRange("Setup Code", Vendor."Rating Setup Code")
        else
            QuantityVarianceSetup.SetRange("Setup Code", 'DEFAULT');

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

    procedure DetermineRating(Score: Decimal; SetupCode: Code[20]): Text[30]
    var
        RatingScale: Record "Rating Scale Setup";
        VendorRatingSetup: Record "Vendor Rating Setup";
    begin
        if not VendorRatingSetup.Get(SetupCode) then
            SetupCode := 'DEFAULT';

        RatingScale.SetRange("Setup Code", SetupCode);
        RatingScale.SetFilter("Score From", '<=%1', Score);
        RatingScale.SetFilter("Score To", '>=%1', Score);

        if RatingScale.FindFirst() then
            exit(RatingScale."Display Value");
        exit('');
    end;

    procedure CalculateEntryPoints(var VendorRatingEntry: Record "Vendor Rating Entry")
    var
        RatingScale: Record "Rating Scale Setup";
        VendorRatingSetup: Record "Vendor Rating Setup";
    begin
        // Get setup code
        if VendorRatingEntry."Setup Code" = '' then begin
            if not VendorRatingSetup.Get('DEFAULT') then
                exit;
            VendorRatingEntry."Setup Code" := 'DEFAULT';
        end;

        RatingScale.SetRange("Setup Code", VendorRatingEntry."Setup Code");
        RatingScale.SetFilter("Score From", '<=%1', VendorRatingEntry."Total Score");
        RatingScale.SetFilter("Score To", '>=%1', VendorRatingEntry."Total Score");

        if RatingScale.FindFirst() then
            VendorRatingEntry.Points := RatingScale.Points;

        VendorRatingEntry.Modify(true);
    end;

    procedure CalculateHistoryPoints(VendorRatingHistory: Record "Vendor Rating History"): Integer
    var
        RatingScale: Record "Rating Scale Setup";
        VendorRatingSetup: Record "Vendor Rating Setup";
        Vendor: Record Vendor;
    begin
        if not Vendor.Get(VendorRatingHistory."Vendor No") then
            exit(0);

        if not VendorRatingSetup.Get(Vendor."Rating Setup Code") then
            VendorRatingSetup.Get('DEFAULT');

        RatingScale.Reset();
        RatingScale.SetRange("Setup Code", Vendor."Rating Setup Code");
        RatingScale.SetRange("Rating Type", VendorRatingSetup."Rating Type");
        RatingScale.SetFilter("Score From", '<=%1', VendorRatingHistory."Total Score");
        RatingScale.SetFilter("Score To", '>=%1', VendorRatingHistory."Total Score");

        if RatingScale.FindFirst() then
            exit(RatingScale.Points);

        exit(0);
    end;

    procedure CalculateTrend(VendorNo: Code[20]): Enum "Trend Indicator"
    var
        VendorRatingHistory: Record "Vendor Rating History";
        PrevScore, CurrentScore : Decimal;
        Threshold: Decimal;
    begin
        Threshold := 10; // Increased from 5 to 10 points for less sensitivity

        VendorRatingHistory.SetRange("Vendor No", VendorNo);
        VendorRatingHistory.SetCurrentKey("Vendor No", "Period End Date");

        if VendorRatingHistory.FindLast() then begin
            CurrentScore := VendorRatingHistory."Total Score";

            if VendorRatingHistory.Next(-1) <> 0 then begin
                PrevScore := VendorRatingHistory."Total Score";

                // Only flag as declining/improving if difference exceeds threshold AND
                // the change puts them in a different grade band (A+/A/B etc)
                if (CurrentScore - PrevScore) > Threshold then
                    exit("Trend Indicator"::Improving)
                else if (PrevScore - CurrentScore) > Threshold then
                    exit("Trend Indicator"::Declining);
            end;
        end;

        exit("Trend Indicator"::Stable);
    end;

}