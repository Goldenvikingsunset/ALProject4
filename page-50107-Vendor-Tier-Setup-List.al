page 50107 "Vendor Tier Setup List"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "Vendor Tier Setup";
    Caption = 'Vendor Tier Setup';

    AboutTitle = 'Vendor Performance Tiers';
    AboutText = 'Configure tier levels that vendors can achieve based on their performance scores and points. Higher tiers typically receive priority consideration for new business opportunities.';

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
                    AboutText = 'Unique code for this tier level (e.g. BRONZE, SILVER, GOLD).';
                }
                field(Description; Rec."Description")
                {
                    ApplicationArea = All;
                    AboutText = 'Descriptive name explaining the tier level.';
                }
                field("Minimum Points"; Rec."Minimum Points")
                {
                    ApplicationArea = All;
                    AboutText = 'Points required to achieve this tier level. Higher tiers should require more points.';
                }
                field("Priority Level"; Rec."Priority Level")
                {
                    ApplicationArea = All;
                    AboutText = 'Numerical priority used for vendor selection and reporting (higher is better).';
                }
            }
        }
    }
}