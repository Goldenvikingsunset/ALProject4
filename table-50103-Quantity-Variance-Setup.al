table 50103 "Quantity Variance Setup"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No"; Integer) { AutoIncrement = true; }
        field(2; "Variance Percentage From"; Decimal)
        {
            DecimalPlaces = 2;
            MinValue = -100;
        }
        field(3; "Variance Percentage To"; Decimal)
        {
            DecimalPlaces = 2;
            MaxValue = 100;
        }
        field(4; "Score"; Decimal)
        {
            DecimalPlaces = 2;
            MinValue = 0;
            MaxValue = 100;
        }
        field(5; "Points"; Integer) { MinValue = 0; }
    }

    keys { key(PK; "Entry No") { Clustered = true; } }
}