table 50100 "Vendor Rating Setup"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Setup Code"; Code[20])
        {
            Caption = 'Setup Code';
        }
        field(2; "Rating Type"; Enum "Rating Type")
        {
            Caption = 'Rating Type';
        }
        field(3; "Schedule Weight"; Decimal)
        {
            Caption = 'Schedule Weight';
            DecimalPlaces = 2;
            MinValue = 0;
            MaxValue = 1;
        }
        field(4; "Quality Weight"; Decimal)
        {
            Caption = 'Quality Weight';
            DecimalPlaces = 2;
            MinValue = 0;
            MaxValue = 1;
        }
        field(5; "Quantity Weight"; Decimal)
        {
            Caption = 'Quantity Weight';
            DecimalPlaces = 2;
            MinValue = 0;
            MaxValue = 1;
        }
        field(6; "Minimum Orders Required"; Integer)
        {
            Caption = 'Minimum Orders Required';
            MinValue = 1;
        }
        field(7; "Evaluation Period"; Enum "Evaluation Period")
        {
            Caption = 'Evaluation Period';
        }
        field(8; "Last Update DateTime"; DateTime)
        {
            Caption = 'Last Update DateTime';
            Editable = false;
        }
        field(9; "Enable Vendor Points"; Boolean)
        {
            Caption = 'Enable Vendor Points Scoring System';
        }
        field(50100; "Description"; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(50101; "Is Default"; Boolean)
        {
            Caption = 'Is Default Setup';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Is Default" then
                    SetOtherSetupsNonDefault();
            end;
        }
        // Benchmark Fields
        field(50160; "Avg Schedule Score"; Decimal)
        {
            Caption = 'Average Schedule Score';
            DecimalPlaces = 2;
            Editable = false;
        }
        field(50161; "Avg Quality Score"; Decimal)
        {
            Caption = 'Average Quality Score';
            DecimalPlaces = 2;
            Editable = false;
        }
        field(50162; "Avg Quantity Score"; Decimal)
        {
            Caption = 'Average Quantity Score';
            DecimalPlaces = 2;
            Editable = false;
        }
        field(50163; "Avg Total Score"; Decimal)
        {
            Caption = 'Average Total Score';
            DecimalPlaces = 2;
            Editable = false;
        }
        field(50164; "Total Vendors"; Integer)
        {
            Caption = 'Total Vendors';
            Editable = false;
        }
        field(50165; "Total Entries"; Integer)
        {
            Caption = 'Total Entries';
            Editable = false;
        }
        field(50166; "Last Benchmark Date"; DateTime)
        {
            Caption = 'Last Benchmark Update';
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Setup Code")
        {
            Clustered = true;
        }
    }

    local procedure SetOtherSetupsNonDefault()
    var
        VendorRatingSetup: Record "Vendor Rating Setup";
    begin
        VendorRatingSetup.SetFilter("Setup Code", '<>%1', "Setup Code");
        if VendorRatingSetup.FindSet() then
            repeat
                if VendorRatingSetup."Is Default" then begin
                    VendorRatingSetup."Is Default" := false;
                    VendorRatingSetup.Modify();
                end;
            until VendorRatingSetup.Next() = 0;
    end;
}