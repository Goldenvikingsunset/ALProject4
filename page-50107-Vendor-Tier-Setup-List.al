page 50107 "Vendor Tier Setup List"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Vendor Tier Setup";
    Caption = 'Vendor Tier Setup';

    layout
    {
        area(Content)
        {
            repeater(Group)

            {
                field("Setup Code"; Rec."Setup Code")
                {
                    ApplicationArea = All;
                }
                field("Tier Code"; Rec."Tier Code")
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field("Minimum Points"; Rec."Minimum Points")
                {
                    ApplicationArea = All;
                }
                field("Priority Level"; Rec."Priority Level")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}