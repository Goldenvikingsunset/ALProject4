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
                field("Vendor No"; Rec."Vendor No")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the vendor number for this rating entry.';
                }
                field("Setup Code"; Rec."Setup Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the rating setup code used for this entry.';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date when this entry was posted.';
                }
                field("Document No"; Rec."Document No")
                {
                    ApplicationArea = All;
                    Caption = 'Order No.';
                    DrillDown = true;
                    Lookup = true;
                    ToolTip = 'Specifies the purchase order number for this entry.';

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
                    ToolTip = 'Specifies the posted purchase receipt number.';

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
                field("Schedule Score"; Rec."Schedule Score")
                {
                    ApplicationArea = All;
                    ToolTip = 'Shows the delivery schedule performance score.';
                }
                field("Quality Score"; Rec."Quality Score")
                {
                    ApplicationArea = All;
                    ToolTip = 'Shows the quality performance score.';
                }
                field("Quantity Score"; Rec."Quantity Score")
                {
                    ApplicationArea = All;
                    ToolTip = 'Shows the quantity accuracy score.';
                }
                field("Total Score"; Rec."Total Score")
                {
                    ApplicationArea = All;
                    ToolTip = 'Shows the overall weighted score.';
                }
                field(Rating; Rec.Rating)
                {
                    ApplicationArea = All;
                    ToolTip = 'Shows the letter rating based on the total score.';
                }
                field(Points; Rec.Points)
                {
                    ApplicationArea = All;
                    ToolTip = 'Shows the points earned for this entry.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ProcessHistorical)
            {
                ApplicationArea = All;
                Caption = 'Process Historical Data';
                Image = Process;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Process historical purchase receipts to create rating entries.';

                trigger OnAction()
                var
                    HistProcessor: Codeunit "Historical Rating Processor";
                    StartDate: Date;
                    EndDate: Date;
                begin
                    StartDate := CalcDate('<-1Y>', WorkDate());
                    EndDate := WorkDate();

                    if Confirm(StrSubstNo('Process historical transactions from %1 to %2?', StartDate, EndDate)) then
                        HistProcessor.ProcessHistoricalTransactions(StartDate, EndDate);
                end;
            }

        }

        area(Navigation)
        {
            action(ViewVendor)
            {
                ApplicationArea = All;
                Caption = 'View Vendor';
                Image = Vendor;
                Promoted = true;
                PromotedCategory = Process;
                RunObject = Page "Vendor Card";
                RunPageLink = "No." = field("Vendor No");
                ToolTip = 'View the vendor card for this entry.';
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.SetCurrentKey("Posting Date");
        Rec.Ascending(false);
    end;
}