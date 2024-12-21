page 50103 "Quantity Variance Setup List"
{
    PageType = List;
    SourceTable = "Quantity Variance Setup";
    UsageCategory = Lists;
    ApplicationArea = All;

    AboutTitle = 'Quantity Variance Scoring';
    AboutText = 'Configure how differences between ordered and received quantities affect vendor scores. Set percentage ranges and corresponding scores for over/under deliveries.';

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
                field("Variance Percentage From"; Rec."Variance Percentage From")
                {
                    ApplicationArea = All;
                    AboutText = 'Starting percentage for this variance range. Use negative for under-delivery, positive for over-delivery.';
                }
                field("Variance Percentage To"; Rec."Variance Percentage To")
                {
                    ApplicationArea = All;
                    AboutText = 'Ending percentage for this variance range. Ensure ranges cover all possible variances.';
                }
                field("Score"; Rec."Score")
                {
                    ApplicationArea = All;
                    AboutText = 'Score given when quantity variance falls within this range (0-100).';
                }
                field("Points"; Rec."Points")
                {
                    ApplicationArea = All;
                    AboutText = 'Points awarded for deliveries within this variance range.';
                }
            }
        }
    }
}