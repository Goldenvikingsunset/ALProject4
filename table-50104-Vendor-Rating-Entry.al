table 50104 "Vendor Rating Entry"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No"; Integer)
        {
            AutoIncrement = true;
            DataClassification = SystemMetadata;
        }
        // Rest of fields remain same
        field(2; "Vendor No"; Code[20]) { TableRelation = Vendor; }
        field(3; "Posting Date"; Date) { }
        field(4; "Document Type"; Enum "Purchase Document Type") { }
        field(5; "Document No"; Code[20]) { }
        field(6; "Expected Date"; Date) { }
        field(7; "Actual Date"; Date) { }
        field(8; "Ordered Quantity"; Decimal) { DecimalPlaces = 0 : 5; }
        field(9; "Received Quantity"; Decimal) { DecimalPlaces = 0 : 5; }
        field(10; "Schedule Score"; Decimal) { DecimalPlaces = 2; }
        field(11; "Quality Score"; Decimal) { DecimalPlaces = 2; }
        field(12; "Quantity Score"; Decimal) { DecimalPlaces = 2; }
        field(13; "Total Score"; Decimal) { DecimalPlaces = 2; }
        field(14; "Rating"; Text[30]) { }
        field(15; "Points"; Integer) { }
        field(16; "Evaluation Completed"; Boolean) { }
    }

    keys
    {
        key(PK; "Entry No") { Clustered = true; }
        key(VendorPosting; "Vendor No", "Posting Date") { }
        key(Document; "Document No") { }
    }
}
