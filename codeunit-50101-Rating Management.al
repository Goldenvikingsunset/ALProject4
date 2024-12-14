codeunit 50101 "Rating Management"
{
    procedure InitializeSetup()
    var
        VendorRatingSetup: Record "Vendor Rating Setup";
    begin
        // Default Setup
        if not VendorRatingSetup.Get('DEFAULT') then begin
            VendorRatingSetup.Init();
            VendorRatingSetup."Setup Code" := 'DEFAULT';
            VendorRatingSetup.Description := 'Default Rating Setup';
            VendorRatingSetup."Is Default" := true;
            VendorRatingSetup."Rating Type" := "Rating Type"::Percentage;
            VendorRatingSetup."Schedule Weight" := 0.4;
            VendorRatingSetup."Quality Weight" := 0.3;
            VendorRatingSetup."Quantity Weight" := 0.3;
            VendorRatingSetup."Minimum Orders Required" := 5;
            VendorRatingSetup."Evaluation Period" := "Evaluation Period"::Monthly;
            VendorRatingSetup."Enable Vendor Points" := true;
            VendorRatingSetup.Insert();
        end;

        // Manufacturing Setup
        if not VendorRatingSetup.Get('MANUFACTURING') then begin
            VendorRatingSetup.Init();
            VendorRatingSetup."Setup Code" := 'MANUFACTURING';
            VendorRatingSetup.Description := 'Manufacturing Vendors';
            VendorRatingSetup."Is Default" := false;
            VendorRatingSetup."Rating Type" := "Rating Type"::Percentage;
            VendorRatingSetup."Schedule Weight" := 0.5;  // Higher weight on schedule
            VendorRatingSetup."Quality Weight" := 0.3;
            VendorRatingSetup."Quantity Weight" := 0.2;
            VendorRatingSetup."Minimum Orders Required" := 10;
            VendorRatingSetup."Evaluation Period" := "Evaluation Period"::Monthly;
            VendorRatingSetup."Enable Vendor Points" := true;
            VendorRatingSetup.Insert();
        end;

        // Services Setup
        if not VendorRatingSetup.Get('SERVICES') then begin
            VendorRatingSetup.Init();
            VendorRatingSetup."Setup Code" := 'SERVICES';
            VendorRatingSetup.Description := 'Service Providers';
            VendorRatingSetup."Is Default" := false;
            VendorRatingSetup."Rating Type" := "Rating Type"::Percentage;
            VendorRatingSetup."Schedule Weight" := 0.2;
            VendorRatingSetup."Quality Weight" := 0.6;  // Higher weight on quality
            VendorRatingSetup."Quantity Weight" := 0.2;
            VendorRatingSetup."Minimum Orders Required" := 3;
            VendorRatingSetup."Evaluation Period" := "Evaluation Period"::Monthly;
            VendorRatingSetup."Enable Vendor Points" := true;
            VendorRatingSetup.Insert();
        end;

        // Supplies Setup
        if not VendorRatingSetup.Get('SUPPLIES') then begin
            VendorRatingSetup.Init();
            VendorRatingSetup."Setup Code" := 'SUPPLIES';
            VendorRatingSetup.Description := 'Office Supplies Vendors';
            VendorRatingSetup."Is Default" := false;
            VendorRatingSetup."Rating Type" := "Rating Type"::Percentage;
            VendorRatingSetup."Schedule Weight" := 0.33;
            VendorRatingSetup."Quality Weight" := 0.33;
            VendorRatingSetup."Quantity Weight" := 0.34;
            VendorRatingSetup."Minimum Orders Required" := 15;  // Higher minimum orders
            VendorRatingSetup."Evaluation Period" := "Evaluation Period"::Monthly;
            VendorRatingSetup."Enable Vendor Points" := true;
            VendorRatingSetup.Insert();
        end;
    end;

    procedure InitializeDefaultScales()
    var
        RatingScale: Record "Rating Scale Setup";
    begin
        if RatingScale.IsEmpty then begin
            // Default Percentage Ratings
            InsertRatingScale('DEFAULT', "Rating Type"::Percentage, 90, 100, 'A+', 100);
            InsertRatingScale('DEFAULT', "Rating Type"::Percentage, 80, 89.99, 'A', 90);
            InsertRatingScale('DEFAULT', "Rating Type"::Percentage, 70, 79.99, 'B', 80);
            InsertRatingScale('DEFAULT', "Rating Type"::Percentage, 60, 69.99, 'C', 70);
            InsertRatingScale('DEFAULT', "Rating Type"::Percentage, 0, 59.99, 'F', 0);

            // Manufacturing Ratings (stricter)
            InsertRatingScale('MANUFACTURING', "Rating Type"::Percentage, 95, 100, 'A+', 100);
            InsertRatingScale('MANUFACTURING', "Rating Type"::Percentage, 85, 94.99, 'A', 90);
            InsertRatingScale('MANUFACTURING', "Rating Type"::Percentage, 75, 84.99, 'B', 80);
            InsertRatingScale('MANUFACTURING', "Rating Type"::Percentage, 65, 74.99, 'C', 70);
            InsertRatingScale('MANUFACTURING', "Rating Type"::Percentage, 0, 64.99, 'F', 0);

            // Services Ratings (more lenient)
            InsertRatingScale('SERVICES', "Rating Type"::Percentage, 85, 100, 'A+', 100);
            InsertRatingScale('SERVICES', "Rating Type"::Percentage, 75, 84.99, 'A', 90);
            InsertRatingScale('SERVICES', "Rating Type"::Percentage, 65, 74.99, 'B', 80);
            InsertRatingScale('SERVICES', "Rating Type"::Percentage, 55, 64.99, 'C', 70);
            InsertRatingScale('SERVICES', "Rating Type"::Percentage, 0, 54.99, 'F', 0);

            // Supplies Ratings
            InsertRatingScale('SUPPLIES', "Rating Type"::Percentage, 90, 100, 'A+', 100);
            InsertRatingScale('SUPPLIES', "Rating Type"::Percentage, 80, 89.99, 'A', 90);
            InsertRatingScale('SUPPLIES', "Rating Type"::Percentage, 70, 79.99, 'B', 80);
            InsertRatingScale('SUPPLIES', "Rating Type"::Percentage, 60, 69.99, 'C', 70);
            InsertRatingScale('SUPPLIES', "Rating Type"::Percentage, 0, 59.99, 'F', 0);
        end;
    end;

    procedure InitializeDeliveryVariances()
    var
        DeliveryVar: Record "Delivery Variance Setup";
    begin
        if DeliveryVar.IsEmpty then begin
            // Default Delivery Variances
            InsertDeliveryVariance('DEFAULT', 0, 0, 100, 100);
            InsertDeliveryVariance('DEFAULT', 1, 2, 90, 90);
            InsertDeliveryVariance('DEFAULT', 3, 5, 70, 70);
            InsertDeliveryVariance('DEFAULT', 6, 999999, 0, 0);

            // Manufacturing (stricter delivery requirements)
            InsertDeliveryVariance('MANUFACTURING', 0, 0, 100, 100);
            InsertDeliveryVariance('MANUFACTURING', 1, 1, 80, 80);
            InsertDeliveryVariance('MANUFACTURING', 2, 3, 50, 50);
            InsertDeliveryVariance('MANUFACTURING', 4, 999999, 0, 0);

            // Services (more flexible delivery)
            InsertDeliveryVariance('SERVICES', 0, 2, 100, 100);
            InsertDeliveryVariance('SERVICES', 3, 5, 85, 85);
            InsertDeliveryVariance('SERVICES', 6, 10, 70, 70);
            InsertDeliveryVariance('SERVICES', 11, 999999, 0, 0);

            // Supplies
            InsertDeliveryVariance('SUPPLIES', 0, 1, 100, 100);
            InsertDeliveryVariance('SUPPLIES', 2, 3, 85, 85);
            InsertDeliveryVariance('SUPPLIES', 4, 7, 70, 70);
            InsertDeliveryVariance('SUPPLIES', 8, 999999, 0, 0);
        end;
    end;

    procedure InitializeQuantityVariances()
    var
        QuantityVar: Record "Quantity Variance Setup";
    begin
        if QuantityVar.IsEmpty then begin
            // Default Quantity Variances
            InsertQuantityVariance('DEFAULT', -2, 2, 100, 100);
            InsertQuantityVariance('DEFAULT', -10, -2.01, 90, 90);
            InsertQuantityVariance('DEFAULT', 2.01, 10, 90, 90);
            InsertQuantityVariance('DEFAULT', -25, -10.01, 70, 70);
            InsertQuantityVariance('DEFAULT', 10.01, 25, 70, 70);
            InsertQuantityVariance('DEFAULT', -100, -25.01, 0, 0);
            InsertQuantityVariance('DEFAULT', 25.01, 100, 0, 0);

            // Manufacturing (strict quantity requirements)
            InsertQuantityVariance('MANUFACTURING', -1, 1, 100, 100);
            InsertQuantityVariance('MANUFACTURING', -5, -1.01, 80, 80);
            InsertQuantityVariance('MANUFACTURING', 1.01, 5, 80, 80);
            InsertQuantityVariance('MANUFACTURING', -15, -5.01, 50, 50);
            InsertQuantityVariance('MANUFACTURING', 5.01, 15, 50, 50);
            InsertQuantityVariance('MANUFACTURING', -100, -15.01, 0, 0);
            InsertQuantityVariance('MANUFACTURING', 15.01, 100, 0, 0);

            // Services (more flexible quantities)
            InsertQuantityVariance('SERVICES', -5, 5, 100, 100);
            InsertQuantityVariance('SERVICES', -15, -5.01, 90, 90);
            InsertQuantityVariance('SERVICES', 5.01, 15, 90, 90);
            InsertQuantityVariance('SERVICES', -30, -15.01, 70, 70);
            InsertQuantityVariance('SERVICES', 15.01, 30, 70, 70);
            InsertQuantityVariance('SERVICES', -100, -30.01, 0, 0);
            InsertQuantityVariance('SERVICES', 30.01, 100, 0, 0);

            // Supplies
            InsertQuantityVariance('SUPPLIES', -3, 3, 100, 100);
            InsertQuantityVariance('SUPPLIES', -10, -3.01, 85, 85);
            InsertQuantityVariance('SUPPLIES', 3.01, 10, 85, 85);
            InsertQuantityVariance('SUPPLIES', -20, -10.01, 70, 70);
            InsertQuantityVariance('SUPPLIES', 10.01, 20, 70, 70);
            InsertQuantityVariance('SUPPLIES', -100, -20.01, 0, 0);
            InsertQuantityVariance('SUPPLIES', 20.01, 100, 0, 0);
        end;
    end;



    local procedure InsertRatingScale(SetupCode: Code[20]; RatingType: Enum "Rating Type"; ScoreFrom: Decimal; ScoreTo: Decimal; DisplayValue: Text[30]; Points: Integer)
    var
        RatingScale: Record "Rating Scale Setup";
    begin
        RatingScale.Init();
        RatingScale."Setup Code" := SetupCode;
        RatingScale."Rating Type" := RatingType;
        RatingScale."Score From" := ScoreFrom;
        RatingScale."Score To" := ScoreTo;
        RatingScale."Display Value" := DisplayValue;
        RatingScale."Points" := Points;
        RatingScale.Insert();
    end;

    local procedure InsertDeliveryVariance(SetupCode: Code[20]; DaysLateFrom: Integer; DaysLateTo: Integer; Score: Decimal; Points: Integer)
    var
        DeliveryVar: Record "Delivery Variance Setup";
    begin
        DeliveryVar.Init();
        DeliveryVar."Setup Code" := SetupCode;
        DeliveryVar."Days Late From" := DaysLateFrom;
        DeliveryVar."Days Late To" := DaysLateTo;
        DeliveryVar."Score" := Score;
        DeliveryVar."Points" := Points;
        DeliveryVar.Insert();
    end;

    local procedure InsertQuantityVariance(SetupCode: Code[20]; VarFrom: Decimal; VarTo: Decimal; Score: Decimal; Points: Integer)
    var
        QuantityVar: Record "Quantity Variance Setup";
    begin
        QuantityVar.Init();
        QuantityVar."Setup Code" := SetupCode;
        QuantityVar."Variance Percentage From" := VarFrom;
        QuantityVar."Variance Percentage To" := VarTo;
        QuantityVar."Score" := Score;
        QuantityVar."Points" := Points;
        QuantityVar.Insert();
    end;

    procedure ValidateWeights(SetupCode: Code[20])
    var
        VendorRatingSetup: Record "Vendor Rating Setup";
    begin
        if VendorRatingSetup.Get(SetupCode) then
            if Round(VendorRatingSetup."Schedule Weight" +
                    VendorRatingSetup."Quality Weight" +
                    VendorRatingSetup."Quantity Weight", 0.01) <> 1 then
                Error('Weights must sum to 1 for Setup %1', SetupCode);
    end;

    procedure ProcessPeriodEnd()
    var
        VendorRatingSetup: Record "Vendor Rating Setup";
        Vendor: Record Vendor;
        RatingCalc: Codeunit "Rating Calculation";
    begin
        VendorRatingSetup.Reset();
        if VendorRatingSetup.FindSet() then
            repeat
                // Get vendors for this setup
                Vendor.Reset();
                Vendor.SetRange("Rating Setup Code", VendorRatingSetup."Setup Code");
                if Vendor.FindSet() then
                    repeat
                        RatingCalc.CalculateVendorRating(
                            Vendor."No.",
                            Format(GetPeriodStartDate(VendorRatingSetup)) + '..' + Format(Today)
                        );
                    until Vendor.Next() = 0;
            until VendorRatingSetup.Next() = 0;
    end;

    procedure ScheduledUpdate()
    var
        VendorRatingSetup: Record "Vendor Rating Setup";
    begin
        if VendorRatingSetup.FindSet() then
            repeat
                ValidateWeights(VendorRatingSetup."Setup Code");
            until VendorRatingSetup.Next() = 0;

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
        if VendorRatingSetup.FindSet() then
            repeat
                VendorRatingSetup."Last Update DateTime" := CurrentDateTime;
                VendorRatingSetup.Modify();
            until VendorRatingSetup.Next() = 0;
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
        if not VendorRatingSetup.Get('DEFAULT') then
            exit(false);

        RatingScale.SetRange("Setup Code", 'DEFAULT');
        if not RatingScale.FindFirst() then
            exit(false);

        DeliveryVar.SetRange("Setup Code", 'DEFAULT');
        if not DeliveryVar.FindFirst() then
            exit(false);

        QuantityVar.SetRange("Setup Code", 'DEFAULT');
        if not QuantityVar.FindFirst() then
            exit(false);

        exit(true);
    end;

    procedure CopySetupConfiguration(FromSetupCode: Code[20]; ToSetupCode: Code[20])
    var
        FromVendorRatingSetup: Record "Vendor Rating Setup";
        ToVendorRatingSetup: Record "Vendor Rating Setup";
    begin
        if not FromVendorRatingSetup.Get(FromSetupCode) then
            Error('Source setup %1 not found', FromSetupCode);

        if ToVendorRatingSetup.Get(ToSetupCode) then
            Error('Setup %1 already exists', ToSetupCode);

        // Copy main setup
        ToVendorRatingSetup := FromVendorRatingSetup;
        ToVendorRatingSetup."Setup Code" := ToSetupCode;
        ToVendorRatingSetup."Is Default" := false;
        ToVendorRatingSetup.Insert();

        // Copy rating scales
        CopyRatingScales(FromSetupCode, ToSetupCode);

        // Copy delivery variances
        CopyDeliveryVariances(FromSetupCode, ToSetupCode);

        // Copy quantity variances
        CopyQuantityVariances(FromSetupCode, ToSetupCode);
    end;

    local procedure CopyRatingScales(FromSetupCode: Code[20]; ToSetupCode: Code[20])
    var
        FromRatingScale: Record "Rating Scale Setup";
        ToRatingScale: Record "Rating Scale Setup";
    begin
        FromRatingScale.SetRange("Setup Code", FromSetupCode);
        if FromRatingScale.FindSet() then
            repeat
                ToRatingScale := FromRatingScale;
                ToRatingScale."Setup Code" := ToSetupCode;
                ToRatingScale.Insert();
            until FromRatingScale.Next() = 0;
    end;

    local procedure CopyDeliveryVariances(FromSetupCode: Code[20]; ToSetupCode: Code[20])
    var
        FromDeliveryVar: Record "Delivery Variance Setup";
        ToDeliveryVar: Record "Delivery Variance Setup";
    begin
        FromDeliveryVar.SetRange("Setup Code", FromSetupCode);
        if FromDeliveryVar.FindSet() then
            repeat
                ToDeliveryVar := FromDeliveryVar;
                ToDeliveryVar."Setup Code" := ToSetupCode;
                ToDeliveryVar.Insert();
            until FromDeliveryVar.Next() = 0;
    end;

    local procedure CopyQuantityVariances(FromSetupCode: Code[20]; ToSetupCode: Code[20])
    var
        FromQuantityVar: Record "Quantity Variance Setup";
        ToQuantityVar: Record "Quantity Variance Setup";
    begin
        FromQuantityVar.SetRange("Setup Code", FromSetupCode);
        if FromQuantityVar.FindSet() then
            repeat
                ToQuantityVar := FromQuantityVar;
                ToQuantityVar."Setup Code" := ToSetupCode;
                ToQuantityVar.Insert();
            until FromQuantityVar.Next() = 0;
    end;
}