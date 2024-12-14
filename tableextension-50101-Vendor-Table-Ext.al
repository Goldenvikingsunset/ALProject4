tableextension 50106 "Vendor Table Ext" extends Vendor
{
    fields
    {
        field(50150; "Current Rating"; Text[30])
        {
            Caption = 'Current Rating';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(50151; "Current Points"; Integer)
        {
            Caption = 'Current Points';
            Editable = false; // It should not be editable since it's calculated
            FieldClass = FlowField;
            CalcFormula = Sum("Vendor Rating History"."Total Points" WHERE("Vendor No" = FIELD("No.")));
        }
        field(50152; "Last Evaluation Date"; Date)
        {
            Caption = 'Last Evaluation Date';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(50153; "YTD Average Score"; Decimal)
        {
            Caption = 'YTD Average Score';
            Editable = false; // It should not be editable since it's calculated
            FieldClass = FlowField;
            CalcFormula = average("Vendor Rating History"."Total Score" WHERE("Vendor No" = FIELD("No.")));
            DecimalPlaces = 2;
        }
        field(50154; "Trend Indicator"; Enum "Trend Indicator")
        {
            Caption = 'Trend Indicator';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(50155; "Current Tier Code"; Code[20])
        {
            Caption = 'Current Tier Code';
            TableRelation = "Vendor Tier Setup";
            Editable = false;
        }
        field(50156; "Next Tier Points Required"; Integer)
        {
            Caption = 'Points to Next Tier';
            Editable = false;
        }
        field(50158; "Rating Type"; Enum "Rating Type")
        {
            Caption = 'Rating Type';
            FieldClass = FlowField;
            CalcFormula = lookup("Vendor Rating Setup"."Rating Type" where("Setup Code" = field("Rating Setup Code")));
            TableRelation = "Vendor Rating Setup";
            Editable = true;
        }
        field(50159; "Rating Setup Code"; Code[20])
        {
            Caption = 'Rating Setup Code';
            DataClassification = CustomerContent;
            TableRelation = "Vendor Rating Setup"."Setup Code";  // Make sure this is properly set

            trigger OnValidate()
            begin
                if "Rating Setup Code" = '' then begin
                    SetDefaultRatingSetup();
                end;
            end;
        }
    }

    local procedure SetDefaultRatingSetup()
    var
        VendorRatingSetup: Record "Vendor Rating Setup";
    begin
        VendorRatingSetup.SetRange("Is Default", true);
        if VendorRatingSetup.FindFirst() then
            Validate("Rating Setup Code", VendorRatingSetup."Setup Code")
        else begin
            VendorRatingSetup.SetRange("Setup Code", 'DEFAULT');
            if VendorRatingSetup.FindFirst() then
                Validate("Rating Setup Code", 'DEFAULT');
        end;
    end;

    local procedure RecalculateVendorRating()
    var
        RatingCalc: Codeunit "Rating Calculation";
    begin
        RatingCalc.RecalculateVendorRating("No.");
    end;
}