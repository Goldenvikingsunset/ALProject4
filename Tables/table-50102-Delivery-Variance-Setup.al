table 50102 "Delivery Variance Setup"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No"; Integer) { AutoIncrement = true; }
        field(50100; "Setup Code"; Code[20])
        {
            Caption = 'Setup Code';
            TableRelation = "Vendor Rating Setup";
            DataClassification = CustomerContent;
        }
        field(2; "Days Late From"; Integer) { }
        field(3; "Days Late To"; Integer) { }
        field(4; "Score"; Decimal)
        {
            DecimalPlaces = 2;
            MinValue = 0;
            MaxValue = 100;
        }
        field(5; "Points"; Integer) { MinValue = 0; }
    }

    keys { key(SetupCode; "Setup Code", "Days Late From") { Clustered = true; } }
}