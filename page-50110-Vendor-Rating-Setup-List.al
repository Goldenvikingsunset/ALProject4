page 50110 "Vendor Rating Setup List"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Vendor Rating Setup";
    CardPageId = "Vendor Rating Setup Card";
    Caption = 'Vendor Rating Setup List';

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Setup Code"; Rec."Setup Code")
                {
                    ApplicationArea = All;
                    DrillDown = true;
                    DrillDownPageId = "Vendor Rating Setup List";
                    Lookup = true;
                    LookupPageId = "Vendor Rating Setup List";

                    trigger OnDrillDown()
                    var
                        VendorRatingSetup: Record "Vendor Rating Setup";
                        VendorRatingSetupList: Page "Vendor Rating Setup List";
                    begin
                        VendorRatingSetup.Reset();
                        VendorRatingSetupList.SetTableView(VendorRatingSetup);
                        VendorRatingSetupList.Run();
                    end;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the description for this rating setup';
                }
                field("Is Default"; Rec."Is Default")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if this is the default rating setup';
                }
                field("Rating Type"; Rec."Rating Type")
                {
                    ApplicationArea = All;
                }
                field("Evaluation Period"; Rec."Evaluation Period")
                {
                    ApplicationArea = All;
                }
                field("Schedule Weight"; Rec."Schedule Weight")
                {
                    ApplicationArea = All;
                }
                field("Quality Weight"; Rec."Quality Weight")
                {
                    ApplicationArea = All;
                }
                field("Quantity Weight"; Rec."Quantity Weight")
                {
                    ApplicationArea = All;
                }
                field("Minimum Orders Required"; Rec."Minimum Orders Required")
                {
                    ApplicationArea = All;
                }
                field("Enable Vendor Points"; Rec."Enable Vendor Points")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}