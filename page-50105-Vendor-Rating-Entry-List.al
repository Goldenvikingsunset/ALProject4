page 50105 "Vendor Rating Entry List"
{
    PageType = List;
    SourceTable = "Vendor Rating Entry";
    ApplicationArea = All;
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Vendor No"; Rec."Vendor No") { }
                field("Setup Code"; Rec."Setup Code")
                {
                    ApplicationArea = All;
                }
                field("Posting Date"; Rec."Posting Date") { }
                field("Document No"; Rec."Document No")
                {
                    ApplicationArea = All;
                    Caption = 'Order No.';
                    DrillDown = true;
                    Lookup = true;

                    trigger OnDrillDown()
                    var
                        PurchHeader: Record "Purchase Header";
                        PurchOrder: Page "Purchase Order";
                    begin
                        if PurchHeader.Get(PurchHeader."Document Type"::Order, Rec."Document No") then begin
                            PurchOrder.SetRecord(PurchHeader);
                            PurchOrder.Run();
                        end;
                    end;
                }
                field("Receipt No"; Rec."Receipt No")
                {
                    ApplicationArea = All;
                    DrillDown = true;
                    Lookup = true;

                    trigger OnDrillDown()
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
                field("Schedule Score"; Rec."Schedule Score") { }
                field("Quality Score"; Rec."Quality Score") { }
                field("Quantity Score"; Rec."Quantity Score") { }
                field("Total Score"; Rec."Total Score") { }
                field(Rating; Rec.Rating) { }
                field(Points; Rec.Points) { }
            }
        }

    }

}
