table 50101 "Rating Scale Setup"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No"; Integer) { AutoIncrement = true; }
        field(2; "Rating Type"; Enum "Rating Type") { }
        field(3; "Score From"; Decimal)
        {
            DecimalPlaces = 2;
            MinValue = 0;
            MaxValue = 100;
        }
        field(4; "Score To"; Decimal)
        {
            DecimalPlaces = 2;
            MinValue = 0;
            MaxValue = 100;
        }
        field(5; "Display Value"; Text[30]) { }
        field(6; "Points"; Integer) { MinValue = 0; }
    }

    keys { key(PK; "Entry No") { Clustered = true; } }
}
