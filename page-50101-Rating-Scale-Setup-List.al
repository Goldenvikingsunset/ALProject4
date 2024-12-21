page 50101 "Rating Scale Setup List"
{
    PageType = List;
    SourceTable = "Rating Scale Setup";
    UsageCategory = Lists;
    ApplicationArea = All;

    AboutTitle = 'Configure Rating Scale Thresholds';
    AboutText = 'Define how numerical scores translate to letter grades and points. Each range determines when vendors achieve ratings like A+, A, B, etc. Consider your industry standards when setting these thresholds.';

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                AboutText = 'Create score ranges that align with your performance expectations. Ranges should not overlap and should cover all possible scores (0-100 for percentage ratings).';

                field("Setup Code"; Rec."Setup Code")
                {
                    ApplicationArea = All;
                    Importance = Standard;
                }
                field("Rating Type"; Rec."Rating Type")
                {
                    ApplicationArea = All;
                    AboutText = 'Matches your rating setup configuration. Percentage type uses 0-100 scale.';
                }
                field("Score From"; Rec."Score From")
                {
                    ApplicationArea = All;
                    AboutText = 'Start of the score range. Example: 90 for an A+ grade starting at 90%.';
                    Style = Favorable;
                }
                field("Score To"; Rec."Score To")
                {
                    ApplicationArea = All;
                    AboutText = 'End of the score range. Ensure no gaps between ranges.';
                    Style = Favorable;
                }
                field("Display Value"; Rec."Display Value")
                {
                    ApplicationArea = All;
                    AboutText = 'Letter grade or rating shown on vendor cards and reports. Common values: A+, A, B, C, F.';
                    Importance = Promoted;
                }
                field("Points"; Rec."Points")
                {
                    ApplicationArea = All;
                    AboutText = 'Points awarded for maintaining this rating. Higher ratings should award more points for tier advancement.';
                    Importance = Promoted;
                }
            }
        }
    }
}