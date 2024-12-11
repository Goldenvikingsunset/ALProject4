codeunit 50101 "Rating Management"
{
    procedure InitializeSetup()
    var
        VendorRatingSetup: Record "Vendor Rating Setup";
    begin
        if not VendorRatingSetup.Get('DEFAULT') then begin
            VendorRatingSetup.Init();
            VendorRatingSetup."Setup Code" := 'DEFAULT';
            VendorRatingSetup."Rating Type" := "Rating Type"::Percentage;
            VendorRatingSetup."Schedule Weight" := 0.4;
            VendorRatingSetup."Quality Weight" := 0.3;
            VendorRatingSetup."Quantity Weight" := 0.3;
            VendorRatingSetup."Minimum Orders Required" := 5;
            VendorRatingSetup."Evaluation Period" := "Evaluation Period"::Monthly;
            VendorRatingSetup."Enable Vendor Points" := true;
            VendorRatingSetup.Insert();
        end;
    end;

    procedure InitializeDefaultScales()
    var
        RatingScale: Record "Rating Scale Setup";
    begin
        if not RatingScale.FindSet() then begin
            // Percentage-based ratings
            InsertRatingScale("Rating Type"::Percentage, 90, 100, 'A+', 100);
            InsertRatingScale("Rating Type"::Percentage, 80, 89.99, 'A', 90);
            InsertRatingScale("Rating Type"::Percentage, 70, 79.99, 'B', 80);
            InsertRatingScale("Rating Type"::Percentage, 60, 69.99, 'C', 70);
            InsertRatingScale("Rating Type"::Percentage, 0, 59.99, 'F', 0);
        end;
    end;

    procedure InitializeDeliveryVariances()
    var
        DeliveryVar: Record "Delivery Variance Setup";
    begin
        if not DeliveryVar.FindSet() then begin
            InsertDeliveryVariance(0, 0, 100, 100);
            InsertDeliveryVariance(1, 2, 90, 90);
            InsertDeliveryVariance(3, 5, 70, 70);
            InsertDeliveryVariance(6, 999999, 0, 0);
        end;
    end;

    procedure InitializeQuantityVariances()
    var
        QuantityVar: Record "Quantity Variance Setup";
    begin
        if not QuantityVar.FindSet() then begin
            // Perfect delivery or acceptable split delivery
            InsertQuantityVariance(-2, 2, 100, 100);    // Complete delivery within 2%

            // Standard variance range
            InsertQuantityVariance(-10, -2.01, 90, 90); // Slight under-delivery
            InsertQuantityVariance(2.01, 10, 90, 90);   // Slight over-delivery

            // Significant variance
            InsertQuantityVariance(-25, -10.01, 70, 70); // Material under-delivery
            InsertQuantityVariance(10.01, 25, 70, 70);   // Material over-delivery

            // Critical variance
            InsertQuantityVariance(-100, -25.01, 0, 0);  // Severe under-delivery
            InsertQuantityVariance(25.01, 100, 0, 0);    // Severe over-delivery
        end;
    end;



    local procedure InsertRatingScale(RatingType: Enum "Rating Type"; ScoreFrom: Decimal; ScoreTo: Decimal; DisplayValue: Text[30]; Points: Integer)
    var
        RatingScale: Record "Rating Scale Setup";
    begin
        RatingScale.Init();
        RatingScale."Rating Type" := RatingType;
        RatingScale."Score From" := ScoreFrom;
        RatingScale."Score To" := ScoreTo;
        RatingScale."Display Value" := DisplayValue;
        RatingScale."Points" := Points;
        RatingScale.Insert();
    end;

    local procedure InsertDeliveryVariance(DaysLateFrom: Integer; DaysLateTo: Integer; Score: Decimal; Points: Integer)
    var
        DeliveryVar: Record "Delivery Variance Setup";
    begin
        DeliveryVar.Init();
        DeliveryVar."Days Late From" := DaysLateFrom;
        DeliveryVar."Days Late To" := DaysLateTo;
        DeliveryVar."Score" := Score;
        DeliveryVar."Points" := Points;
        DeliveryVar.Insert();
    end;

    local procedure InsertQuantityVariance(VarFrom: Decimal; VarTo: Decimal; Score: Decimal; Points: Integer)
    var
        QuantityVar: Record "Quantity Variance Setup";
    begin
        QuantityVar.Init();
        QuantityVar."Variance Percentage From" := VarFrom;
        QuantityVar."Variance Percentage To" := VarTo;
        QuantityVar."Score" := Score;
        QuantityVar."Points" := Points;
        QuantityVar.Insert();
    end;

    procedure ValidateWeights()
    var
        VendorRatingSetup: Record "Vendor Rating Setup";
    begin
        VendorRatingSetup.Get();
        if Round(VendorRatingSetup."Schedule Weight" +
                VendorRatingSetup."Quality Weight" +
                VendorRatingSetup."Quantity Weight", 0.01) <> 1 then
            Error('Weights must sum to 1');
    end;

    procedure ProcessPeriodEnd()
    var
        VendorRatingSetup: Record "Vendor Rating Setup";
        Vendor: Record Vendor;
        RatingCalc: Codeunit "Rating Calculation";
        StartDate: Date;
    begin
        VendorRatingSetup.Get();
        StartDate := GetPeriodStartDate(VendorRatingSetup);

        if Vendor.FindSet() then
            repeat
                RatingCalc.CalculateVendorRating(
                    Vendor."No.",
                    Format(StartDate) + '..' + Format(Today)
                );
            until Vendor.Next() = 0;
    end;

    procedure ScheduledUpdate()
    begin
        ValidateWeights();
        ProcessPeriodEnd();
        UpdateLastRunDateTime();
    end;

    procedure ResetRatings()
    var
        VendorRatingEntry: Record "Vendor Rating Entry";
        VendorRatingHistory: Record "Vendor Rating History";
        VendorTierManagement: Codeunit "Vendor Tier Management";
    begin
        VendorRatingEntry.DeleteAll();
        VendorRatingHistory.DeleteAll();
        InitializeSetup();
        InitializeDefaultScales();
        InitializeDeliveryVariances();
        InitializeQuantityVariances();
    end;



    local procedure GetPeriodStartDate(VendorRatingSetup: Record "Vendor Rating Setup"): Date
    begin
        case VendorRatingSetup."Evaluation Period" of
            "Evaluation Period"::Daily:
                exit(CalcDate('<-1D>', Today));
            "Evaluation Period"::Weekly:
                exit(CalcDate('<-1W>', Today));
            "Evaluation Period"::Monthly:
                exit(CalcDate('<-1M>', Today));
        end;
    end;

    local procedure UpdateLastRunDateTime()
    var
        VendorRatingSetup: Record "Vendor Rating Setup";
    begin
        VendorRatingSetup.Get();
        VendorRatingSetup."Last Update DateTime" := CurrentDateTime;
        VendorRatingSetup.Modify();
    end;

    procedure CreateRatingEntry(PurchRcptHeader: Record "Purch. Rcpt. Header")
    var
        VendorRatingEntry: Record "Vendor Rating Entry";
        PurchOrder: Record "Purchase Header";
        PurchRcptLine: Record "Purch. Rcpt. Line";
        PurchOrderLine: Record "Purchase Line";
    begin
        PurchRcptLine.SetRange("Document No.", PurchRcptHeader."No.");
        if PurchRcptLine.FindFirst() then begin
            VendorRatingEntry.Init();
            VendorRatingEntry."Vendor No" := PurchRcptHeader."Buy-from Vendor No.";
            VendorRatingEntry."Document No" := PurchRcptHeader."No.";
            VendorRatingEntry."Posting Date" := PurchRcptHeader."Posting Date";

            if PurchOrder.Get(PurchOrder."Document Type"::Order, PurchRcptLine."Order No.") then
                VendorRatingEntry."Expected Date" := PurchOrder."Expected Receipt Date";

            if PurchOrderLine.Get(PurchOrderLine."Document Type"::Order,
                                PurchRcptLine."Order No.",
                                PurchRcptLine."Order Line No.") then
                VendorRatingEntry."Ordered Quantity" := PurchOrderLine.Quantity;

            VendorRatingEntry."Received Quantity" := PurchRcptLine.Quantity;
            VendorRatingEntry."Actual Date" := PurchRcptHeader."Posting Date";
            VendorRatingEntry.Insert(true);
        end;
    end;

    procedure EnsureSetupExists()
    begin
        if not SetupExists() then begin
            InitializeSetup();
            InitializeDefaultScales();
            InitializeDeliveryVariances();
            InitializeQuantityVariances();
        end;
    end;

    local procedure SetupExists(): Boolean
    var
        VendorRatingSetup: Record "Vendor Rating Setup";
        RatingScale: Record "Rating Scale Setup";
        DeliveryVar: Record "Delivery Variance Setup";
        QuantityVar: Record "Quantity Variance Setup";
    begin
        exit(
            VendorRatingSetup.Get('DEFAULT') and
            RatingScale.FindFirst() and
            DeliveryVar.FindFirst() and
            QuantityVar.FindFirst()
        );
    end;
}