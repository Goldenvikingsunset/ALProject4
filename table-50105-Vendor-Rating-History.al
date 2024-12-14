table 50105 "Vendor Rating History"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No"; Integer)
        {
            AutoIncrement = true;
            DataClassification = SystemMetadata;
        }
        field(50100; "Setup Code"; Code[20])
        {
            Caption = 'Setup Code';
            TableRelation = "Vendor Rating Setup";
        }
        // Rest of fields remain same
        field(2; "Vendor No"; Code[20]) { TableRelation = Vendor; }
        field(3; "Period Start Date"; Date) { }
        field(4; "Period End Date"; Date) { }
        field(5; "Number of Orders"; Integer) { }
        field(50101; "Number of Deliveries"; Integer)
        {
            Caption = 'Number of Deliveries';
            Editable = false;
        }
        field(6; "Average Schedule Score"; Decimal) { DecimalPlaces = 2; }
        field(7; "Average Quality Score"; Decimal) { DecimalPlaces = 2; }
        field(8; "Average Quantity Score"; Decimal) { DecimalPlaces = 2; }
        field(9; "Total Score"; Decimal) { DecimalPlaces = 2; }
        field(10; "Rating"; Text[30]) { }
        field(11; "Total Points"; Integer) { }
    }

    keys
    {
        key(PK; "Entry No") { Clustered = true; }
        key(VendorPeriod; "Vendor No", "Period End Date") { }
    }
}