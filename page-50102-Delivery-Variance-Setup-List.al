page 50102 "Delivery Variance Setup List"
{
    PageType = List;
    SourceTable = "Delivery Variance Setup";
    UsageCategory = Lists;
    ApplicationArea = All;

    AboutTitle = 'Delivery Performance Scoring';
    AboutText = 'Define how delivery timing affects vendor scores. Set up ranges for early, on-time, and late deliveries with corresponding scores and points. Early or on-time deliveries typically earn maximum points, with decreasing scores for later deliveries.';

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                AboutText = 'Create non-overlapping delivery ranges. Ensure all possible delivery scenarios are covered, from early deliveries (negative days) to maximum acceptable delays.';

                field("Setup Code"; Rec."Setup Code")
                {
                    ApplicationArea = All;
                    Importance = Standard;
                }
                field("Days Late From"; Rec."Days Late From")
                {
                    ApplicationArea = All;
                    AboutText = 'Start of delivery variance range. Use negative numbers for early deliveries, 0 for on-time, positive for late.';
                    Style = Favorable;
                }
                field("Days Late To"; Rec."Days Late To")
                {
                    ApplicationArea = All;
                    AboutText = 'End of delivery variance range. Ensure ranges connect without gaps to cover all scenarios.';
                    Style = Favorable;
                }
                field("Score"; Rec."Score")
                {
                    ApplicationArea = All;
                    AboutText = 'Score awarded for deliveries in this range (0-100). Consider your supply chain tolerance when setting scores.';
                    Importance = Promoted;
                }
                field("Points"; Rec."Points")
                {
                    ApplicationArea = All;
                    AboutText = 'Points earned for deliveries in this range. Higher points encourage consistent on-time delivery performance.';
                    Importance = Promoted;
                }
            }
        }
    }
}