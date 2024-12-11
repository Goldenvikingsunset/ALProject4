page 50100 "Vendor Rating Setup Card"
{
    PageType = Card;
    SourceTable = "Vendor Rating Setup";
    UsageCategory = Administration;
    ApplicationArea = All;
    InsertAllowed = true;
    ModifyAllowed = true;
    DeleteAllowed = true;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field("Setup Code"; Rec."Setup Code")
                {
                    ApplicationArea = All;
                    Editable = true;
                }
                field("Rating Type"; Rec."Rating Type")
                {
                    ApplicationArea = All;
                    Editable = true;
                }
                field("Evaluation Period"; Rec."Evaluation Period")
                {
                    ApplicationArea = All;
                    Editable = true;
                }
            }

            group(Weights)
            {
                Caption = 'Weights';
                field("Schedule Weight"; Rec."Schedule Weight")
                {
                    ApplicationArea = All;
                    Editable = true;
                }
                field("Quality Weight"; Rec."Quality Weight")
                {
                    ApplicationArea = All;
                    Editable = true;
                }
                field("Quantity Weight"; Rec."Quantity Weight")
                {
                    ApplicationArea = All;
                    Editable = true;
                }
            }

            group(Settings)
            {
                Caption = 'Settings';
                field("Minimum Orders Required"; Rec."Minimum Orders Required")
                {
                    ApplicationArea = All;
                    Editable = true;
                }
                field("Enable Vendor Points"; Rec."Enable Vendor Points")
                {
                    ApplicationArea = All;
                    Editable = true;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Initialize)
            {
                ApplicationArea = All;
                Caption = 'Initialize Setup';
                Image = Setup;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    RatingMgmt: Codeunit "Rating Management";
                begin
                    RatingMgmt.InitializeSetup();
                    RatingMgmt.InitializeDefaultScales();
                    RatingMgmt.InitializeDeliveryVariances();
                    RatingMgmt.InitializeQuantityVariances();
                end;
            }
        }

        area(Navigation)
        {
            group(RelatedSetup)
            {
                Caption = 'Related Setup';
                Image = Setup;

                action(RatingScales)
                {
                    ApplicationArea = All;
                    Caption = 'Rating Scales';
                    Image = SetupList;
                    RunObject = Page "Rating Scale Setup List";
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                }

                action(DeliveryVariances)
                {
                    ApplicationArea = All;
                    Caption = 'Delivery Variances';
                    Image = SetupList;
                    RunObject = Page "Delivery Variance Setup List";
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                }

                action(QuantityVariances)
                {
                    ApplicationArea = All;
                    Caption = 'Quantity Variances';
                    Image = SetupList;
                    RunObject = Page "Quantity Variance Setup List";
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                }

                action(RatingHistory)
                {
                    ApplicationArea = All;
                    Caption = 'Rating History';
                    Image = History;
                    RunObject = Page "Vendor Rating History List";
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                }

                action(RatingEntries)
                {
                    ApplicationArea = All;
                    Caption = 'Rating Entries';
                    Image = List;
                    RunObject = Page "Vendor Rating Entry List";
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                }
                action(VendorTiers)
                {
                    ApplicationArea = All;
                    Caption = 'Vendor Tiers';
                    Image = CustomerRating;
                    RunObject = Page "Vendor Tier Setup List";
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                }
            }
        }
    }
}