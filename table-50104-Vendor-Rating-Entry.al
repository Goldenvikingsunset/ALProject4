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
        field(50100; "Setup Code"; Code[20])
        {
            Caption = 'Setup Code';
            TableRelation = "Vendor Rating Setup";

            // Get the setup code from the vendor when creating the entry
            trigger OnValidate()
            var
                Vendor: Record Vendor;
            begin
                if Vendor.Get("Vendor No") then
                    "Setup Code" := Vendor."Rating Setup Code";
            end;
        }
        // Rest of fields remain same
        field(2; "Vendor No"; Code[20]) { TableRelation = Vendor; }
        field(3; "Posting Date"; Date) { }
        field(4; "Document Type"; Enum "Purchase Document Type") { }
        field(5; "Document No"; Code[20])
        {
            Caption = 'Order No.';
            TableRelation = "Purchase Header"."No." where("Document Type" = const(Order));

            trigger OnLookup()
            var
                PurchaseHeader: Record "Purchase Header";
                PurchaseOrder: Page "Purchase Order";
            begin
                if PurchaseHeader.Get(PurchaseHeader."Document Type"::Order, Rec."Document No") then begin
                    PurchaseOrder.SetRecord(PurchaseHeader);
                    PurchaseOrder.Run();
                end;
            end;
        }
        field(6; "Receipt No"; Code[20])
        {
            Caption = 'Receipt No.';
            TableRelation = "Purch. Rcpt. Header";

            trigger OnLookup()
            var
                PurchRcptHeader: Record "Purch. Rcpt. Header";
                PostedPurchReceipt: Page "Posted Purchase Receipt";
            begin
                if PurchRcptHeader.Get(Rec."Receipt No") then begin
                    PostedPurchReceipt.SetRecord(PurchRcptHeader);
                    PostedPurchReceipt.Run();
                end;
            end;
        }
        // 
        field(7; "Expected Date"; Date) { }
        field(8; "Actual Date"; Date) { }
        field(9; "Ordered Quantity"; Decimal) { DecimalPlaces = 0 : 5; }
        field(10; "Received Quantity"; Decimal) { DecimalPlaces = 0 : 5; }
        field(11; "Schedule Score"; Decimal) { DecimalPlaces = 2; }
        field(12; "Quality Score"; Decimal) { DecimalPlaces = 2; }
        field(13; "Quantity Score"; Decimal) { DecimalPlaces = 2; }
        field(14; "Total Score"; Decimal) { DecimalPlaces = 2; }
        field(15; "Rating"; Text[30]) { }
        field(16; "Points"; Integer) { }
        field(17; "Evaluation Completed"; Boolean) { }
    }

    keys
    {
        key(PK; "Entry No") { Clustered = true; }
        key(VendorPosting; "Vendor No", "Posting Date") { }
        key(Document; "Document No") { }
        key(Receipt; "Receipt No") { }
    }
}
