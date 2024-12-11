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
    }

    keys
    {
        key(PK; "Setup Code")
        {
            Clustered = true;
        }
    }
}