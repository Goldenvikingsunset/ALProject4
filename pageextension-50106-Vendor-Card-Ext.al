pageextension 50106 "Vendor Card Ext" extends "Vendor Card"
{
    layout
    {
        addafter(General)
        {
            group(VendorRating)
            {

                Caption = 'Vendor Rating';
                field("Rating Setup Code"; Rec."Rating Setup Code")
                {
                    ApplicationArea = All;
                    TableRelation = "Vendor Rating Setup"."Setup Code";  // Ensure proper table relation
                    LookupPageId = "Vendor Rating Setup List";

                    trigger OnValidate()
                    begin
                        CurrPage.Update(true);
                    end;
                }
                field("Current Rating"; Rec."Current Rating")
                {
                    ApplicationArea = All;
                }
                field("Current Points"; Rec."Current Points")
                {
                    ApplicationArea = All;
                    DrillDown = true;

                    trigger OnDrillDown()
                    var
                        VendorRatingEntry: Record "Vendor Rating Entry";
                        VendorRatingEntryPage: Page "Vendor Rating Entry List";
                    begin
                        VendorRatingEntry.SetRange("Vendor No", Rec."No.");
                        VendorRatingEntryPage.SetTableView(VendorRatingEntry);
                        VendorRatingEntryPage.Run();
                    end;
                }
                field("Last Evaluation Date"; Rec."Last Evaluation Date")
                {
                    ApplicationArea = All;
                }
                field("YTD Average Score"; Rec."YTD Average Score")
                {
                    ApplicationArea = All;
                    DrillDown = true;

                    trigger OnDrillDown()
                    var
                        VendorRatingHistory: Record "Vendor Rating History";
                        VendorRatingHistoryPage: Page "Vendor Rating History List";
                    begin
                        VendorRatingHistory.SetRange("Vendor No", Rec."No.");
                        VendorRatingHistoryPage.SetTableView(VendorRatingHistory);
                        VendorRatingHistoryPage.Run();
                    end;
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
                    VendorRatingSetup: Record "Vendor Rating Setup";
                    StartDate: Date;
                    EndDate: Date;
                begin
                    // Get vendor's rating setup
                    if not VendorRatingSetup.Get(Rec."Rating Setup Code") then
                        VendorRatingSetup.Get('DEFAULT');

                    EndDate := Today;

                    case VendorRatingSetup."Evaluation Period" of
                        "Evaluation Period"::Daily:
                            StartDate := CalcDate('<-1D>', EndDate);
                        "Evaluation Period"::Weekly:
                            StartDate := CalcDate('<-1W>', EndDate);
                        "Evaluation Period"::Monthly:
                            StartDate := CalcDate('<-1M>', EndDate);
                    end;

                    RatingCalc.CalculateVendorRating(
                        Rec."No.",
                        Format(StartDate) + '..' + Format(EndDate)
                    );
                end;
            }
        }
    }
}