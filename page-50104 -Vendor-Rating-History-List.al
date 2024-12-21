page 50104 "Vendor Rating History List"
{
    PageType = List;
    SourceTable = "Vendor Rating History";
    ApplicationArea = All;
    UsageCategory = Lists;

    AboutTitle = 'Vendor Rating History';
    AboutText = 'View vendor performance history showing trends in delivery, quality and quantity metrics over time. Historical data helps identify patterns and improvements in vendor performance.';

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Vendor No"; Rec."Vendor No")
                {
                    ApplicationArea = All;
                    AboutText = 'The vendor this performance history relates to.';
                }
                field("Setup Code"; Rec."Setup Code")
                {
                    ApplicationArea = All;
                }
                field("Period Start Date"; Rec."Period Start Date")
                {
                    ApplicationArea = All;
                    AboutText = 'Start of the evaluation period for these metrics.';
                }
                field("Period End Date"; Rec."Period End Date")
                {
                    ApplicationArea = All;
                }
                field("Number of Orders"; Rec."Number of Orders")
                {
                    ApplicationArea = All;
                    AboutText = 'Total purchase orders in this period.';
                }
                field("Number of Deliveries"; Rec."Number of Deliveries")
                {
                    ApplicationArea = All;
                    AboutText = 'Number of receipts posted in this period.';
                }
                field("Average Schedule Score"; Rec."Average Schedule Score")
                {
                    ApplicationArea = All;
                    AboutText = 'Average delivery timing performance for the period.';
                }
                field("Average Quality Score"; Rec."Average Quality Score")
                {
                    ApplicationArea = All;
                    AboutText = 'Average quality metrics for received items.';
                }
                field("Average Quantity Score"; Rec."Average Quantity Score")
                {
                    ApplicationArea = All;
                    AboutText = 'Average accuracy of delivered quantities.';
                }
                field("Total Score"; Rec."Total Score")
                {
                    ApplicationArea = All;
                    AboutText = 'Overall weighted performance score.';
                }
                field(Rating; Rec.Rating)
                {
                    ApplicationArea = All;
                    AboutText = 'Letter grade based on total score.';
                }
                field("Total Points"; Rec."Total Points")
                {
                    ApplicationArea = All;
                    AboutText = 'Points earned toward tier advancement.';
                }
            }
        }
    }
}