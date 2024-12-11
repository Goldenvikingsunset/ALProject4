table 50107 "Vendor Tier Setup"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Tier Code"; Code[20])
        {
            Caption = 'Tier Code';
        }
        field(2; "Description"; Text[100])
        {
            Caption = 'Description';
        }
        field(3; "Minimum Points"; Integer)
        {
            Caption = 'Minimum Points';
        }
        field(4; "Priority Level"; Integer)
        {
            Caption = 'Priority Level';
            MinValue = 1;
            MaxValue = 100;
        }
    }

    keys
    {
        key(PK; "Tier Code")
        {
            Clustered = true;
        }
        key(Points; "Minimum Points") { }
    }
}