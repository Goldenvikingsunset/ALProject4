page 50106 "Vendor Rating FactBox"
{
    PageType = ListPart;
    SourceTable = Vendor;
    Caption = 'Vendor Rating';

    layout
    {
        area(Content)
        {
            group(VendorRating)
            {
                Caption = 'Vendor Rating';
                fixed(RatingInfo)
                {
                    group(Values)
                    {
                        field("Rating Setup Code"; Rec."Rating Setup Code")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Specifies which rating setup to use for this vendor';
                        }
                        field("Current Rating"; Rec."Current Rating")
                        {
                            ApplicationArea = All;
                            StyleExpr = RatingStyle;
                        }
                        field("Current Points"; Rec."Current Points")
                        {
                            ApplicationArea = All;
                            StyleExpr = PointsStyle;
                        }
                        field("Current Tier Code"; Rec."Current Tier Code")
                        {
                            ApplicationArea = All;
                            StyleExpr = TierStyle;
                        }
                        field("Last Evaluation Date"; Rec."Last Evaluation Date")
                        {
                            ApplicationArea = All;
                            StyleExpr = DateStyle;
                        }
                        field("YTD Average Score"; Rec."YTD Average Score")
                        {
                            ApplicationArea = All;
                            StyleExpr = ScoreStyle;
                            DecimalPlaces = 2;
                        }
                        field("Trend Indicator"; Rec."Trend Indicator")
                        {
                            ApplicationArea = All;
                            StyleExpr = TrendStyle;
                        }
                        field("Points to Next Tier"; Rec."Next Tier Points Required")
                        {
                            ApplicationArea = All;
                            StyleExpr = 'Ambiguous';
                        }

                    }
                }
            }
        }
    }

    var
        RatingStyle: Text;
        PointsStyle: Text;
        TierStyle: Text;
        DateStyle: Text;
        ScoreStyle: Text;
        TrendStyle: Text;

    trigger OnAfterGetCurrRecord()
    begin
        if Rec.IsEmpty then
            exit;

        SetStyles();
    end;

    local procedure SetStyles()
    begin
        // Rating Style
        case Rec."Current Rating" of
            'A+', 'A':
                RatingStyle := 'Favorable';
            'B':
                RatingStyle := 'Ambiguous';
            else
                RatingStyle := 'Unfavorable';
        end;

        // Points Style
        Rec.CalcFields("Current Points");
        if Rec."Current Points" >= 2000 then
            PointsStyle := 'Favorable'
        else if Rec."Current Points" >= 1000 then
            PointsStyle := 'StrongAccent'
        else if Rec."Current Points" >= 500 then
            PointsStyle := 'Attention'
        else
            PointsStyle := 'Standard';

        // Tier Style
        case Rec."Current Tier Code" of
            'PLATINUM':
                TierStyle := 'StrongAccent';
            'GOLD':
                TierStyle := 'Favorable';
            'SILVER':
                TierStyle := 'Attention';
            else
                TierStyle := 'Standard';
        end;

        // Date Style
        if Rec."Last Evaluation Date" < CalcDate('<-1M>', WorkDate()) then
            DateStyle := 'Unfavorable'
        else if Rec."Last Evaluation Date" < CalcDate('<-7D>', WorkDate()) then
            DateStyle := 'Attention'
        else
            DateStyle := 'Favorable';

        // Score Style
        Rec.CalcFields("YTD Average Score");
        if Rec."YTD Average Score" >= 90 then
            ScoreStyle := 'Favorable'
        else if Rec."YTD Average Score" >= 80 then
            ScoreStyle := 'Attention'
        else
            ScoreStyle := 'Unfavorable';

        // Trend Style
        case Rec."Trend Indicator" of
            "Trend Indicator"::Improving:
                TrendStyle := 'Favorable';
            "Trend Indicator"::Stable:
                TrendStyle := 'Ambiguous';
            "Trend Indicator"::Declining:
                TrendStyle := 'Unfavorable';
        end;
    end;
}