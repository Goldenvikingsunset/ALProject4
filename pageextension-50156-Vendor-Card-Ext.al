pageextension 50106 "Vendor Card Ext" extends "Vendor Card"
{
    layout
    {
        addafter(General)
        {
            group(VendorRating)
            {
                Caption = 'Vendor Rating';
                field("Current Rating"; Rec."Current Rating")
                {
                    ApplicationArea = All;
                }
                field("Current Points"; Rec."Current Points")
                {
                    ApplicationArea = All;
                }
                field("Last Evaluation Date"; Rec."Last Evaluation Date")
                {
                    ApplicationArea = All;
                }
                field("YTD Average Score"; Rec."YTD Average Score")
                {
                    ApplicationArea = All;
                }
                field("Trend Indicator"; Rec."Trend Indicator")
                {
                    ApplicationArea = All;
                }
                field("Current Tier Code"; rec."Current Tier Code")
                {
                    Caption = 'Current Tier Code';
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Next Tier Points Required"; rec."Next Tier Points Required")
                {
                    Caption = 'Points to Next Tier';
                    ApplicationArea = All;
                    Editable = false;
                }
            }
        }
    }

    actions
    {
        addafter("F&unctions")
        {
            action(CalculateRating)
            {
                ApplicationArea = All;
                Caption = 'Calculate Rating';
                Image = Calculate;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;

                trigger OnAction()
                var
                    RatingCalc: Codeunit "Rating Calculation";
                begin
                    RatingCalc.CalculateVendorRating(
                        Rec."No.",
                        Format(CalcDate('<-30D>', Today)) + '..' + Format(Today)
                    );
                end;
            }
            action(TestQueries)
            {
                ApplicationArea = All;
                Caption = 'Test Queries';
                Image = TestDatabase;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;

                trigger OnAction()
                var
                    QueryTest: Codeunit "Query Test";
                begin
                    QueryTest.TestQualityRating(Rec."No.");
                    QueryTest.TestDeliveryPerformance(Rec."No.");
                end;
            }
        }
    }
}