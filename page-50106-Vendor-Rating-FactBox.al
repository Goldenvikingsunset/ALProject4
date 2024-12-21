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

                field("Rating Setup Code"; Rec."Rating Setup Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies which rating setup to use for this vendor';
                }
                field("Current Tier Code"; Rec."Current Tier Code")
                {
                    ApplicationArea = All;
                    StyleExpr = RatingStyle;
                }
                field("Current Rating"; Rec."Current Rating")
                {
                    ApplicationArea = All;
                    StyleExpr = RatingStyle;
                }

                field("Trend Indicator"; Rec."Trend Indicator")
                {
                    ApplicationArea = All;
                    StyleExpr = PointsStyle;
                }

                group(Benchmarks)
                {
                    Caption = 'Performance vs Benchmark';

                    field(ScheduleComparison; ScheduleComparisonText)
                    {
                        Caption = 'Schedule';
                        ApplicationArea = All;
                        ToolTip = 'Shows how this vendor''s schedule score compares to the benchmark';
                        StyleExpr = ScheduleComparisonStyle;
                    }
                    field(ScheduleTrend; ScheduleTrendIcon)
                    {
                        Caption = 'Schedule Trend';
                        ApplicationArea = All;
                        ToolTip = 'Shows the trend of schedule score compared to the benchmark';
                    }

                    field(QualityComparison; QualityComparisonText)
                    {
                        Caption = 'Quality';
                        ApplicationArea = All;
                        ToolTip = 'Shows how this vendor''s quality score compares to the benchmark';
                        StyleExpr = QualityComparisonStyle;
                    }
                    field(QualityTrend; QualityTrendIcon)
                    {
                        Caption = 'Quality Trend';
                        ApplicationArea = All;
                        ToolTip = 'Shows the trend of quality score compared to the benchmark';
                    }

                    field(QuantityComparison; QuantityComparisonText)
                    {
                        Caption = 'Quantity';
                        ApplicationArea = All;
                        ToolTip = 'Shows how this vendor''s quantity score compares to the benchmark';
                        StyleExpr = QuantityComparisonStyle;
                    }
                    field(QuantityTrend; QuantityTrendIcon)
                    {
                        Caption = 'Quantity Trend';
                        ApplicationArea = All;
                        ToolTip = 'Shows the trend of quantity score compared to the benchmark';
                    }

                    field(TotalComparison; TotalComparisonText)
                    {
                        Caption = 'Overall';
                        ApplicationArea = All;
                        ToolTip = 'Shows how this vendor''s total score compares to the benchmark';
                        StyleExpr = TotalComparisonStyle;
                    }
                    field(TotalTrend; TotalTrendIcon)
                    {
                        Caption = 'Overall Trend';
                        ApplicationArea = All;
                        ToolTip = 'Shows the trend of overall score compared to the benchmark';
                    }
                }
            }
        }
    }

    var
        RatingStyle: Text;
        PointsStyle: Text;
        ScheduleComparisonText: Text;
        QualityComparisonText: Text;
        QuantityComparisonText: Text;
        TotalComparisonText: Text;
        ScheduleComparisonStyle: Text;
        QualityComparisonStyle: Text;
        QuantityComparisonStyle: Text;
        TotalComparisonStyle: Text;
        ScheduleTrendIcon: Text;
        QualityTrendIcon: Text;
        QuantityTrendIcon: Text;
        TotalTrendIcon: Text;

    trigger OnAfterGetRecord()
    begin
        SetStyles();

        // Prepare comparison texts
        ScheduleComparisonText := GetScoreComparison(GetVendorScore('Schedule'), GetBenchmarkScore('Schedule'));
        QualityComparisonText := GetScoreComparison(GetVendorScore('Quality'), GetBenchmarkScore('Quality'));
        QuantityComparisonText := GetScoreComparison(GetVendorScore('Quantity'), GetBenchmarkScore('Quantity'));
        TotalComparisonText := GetScoreComparison(GetVendorScore('Total'), GetBenchmarkScore('Total'));

        // Prepare comparison styles
        ScheduleComparisonStyle := GetComparisonStyle(GetVendorScore('Schedule'), GetBenchmarkScore('Schedule'));
        QualityComparisonStyle := GetComparisonStyle(GetVendorScore('Quality'), GetBenchmarkScore('Quality'));
        QuantityComparisonStyle := GetComparisonStyle(GetVendorScore('Quantity'), GetBenchmarkScore('Quantity'));
        TotalComparisonStyle := GetComparisonStyle(GetVendorScore('Total'), GetBenchmarkScore('Total'));

        // Prepare trend icons
        ScheduleTrendIcon := GetTrendIcon(GetVendorScore('Schedule'), GetBenchmarkScore('Schedule'));
        QualityTrendIcon := GetTrendIcon(GetVendorScore('Quality'), GetBenchmarkScore('Quality'));
        QuantityTrendIcon := GetTrendIcon(GetVendorScore('Quantity'), GetBenchmarkScore('Quantity'));
        TotalTrendIcon := GetTrendIcon(GetVendorScore('Total'), GetBenchmarkScore('Total'));
    end;

    local procedure GetVendorScore(ScoreType: Text): Decimal
    var
        VendorRatingEntry: Record "Vendor Rating Entry";
        Score: Decimal;
        Count: Integer;
    begin
        VendorRatingEntry.SetRange("Vendor No", Rec."No.");
        VendorRatingEntry.SetRange("Setup Code", Rec."Rating Setup Code");
        VendorRatingEntry.SetFilter("Posting Date", '%1..%2', CalcDate('<-3M>', WorkDate()), WorkDate());

        if VendorRatingEntry.FindSet() then
            repeat
                Count += 1;
                case ScoreType of
                    'Schedule':
                        Score += VendorRatingEntry."Schedule Score";
                    'Quality':
                        Score += VendorRatingEntry."Quality Score";
                    'Quantity':
                        Score += VendorRatingEntry."Quantity Score";
                    'Total':
                        Score += VendorRatingEntry."Total Score";
                end;
            until VendorRatingEntry.Next() = 0;

        if Count > 0 then
            exit(Round(Score / Count, 0.01));
        exit(0);
    end;

    local procedure GetBenchmarkScore(ScoreType: Text): Decimal
    var
        BenchmarkSetup: Record "Vendor Rating Setup";
    begin
        if BenchmarkSetup.Get(Rec."Rating Setup Code") then
            case ScoreType of
                'Schedule':
                    exit(BenchmarkSetup."Avg Schedule Score");
                'Quality':
                    exit(BenchmarkSetup."Avg Quality Score");
                'Quantity':
                    exit(BenchmarkSetup."Avg Quantity Score");
                'Total':
                    exit(BenchmarkSetup."Avg Total Score");
            end;
        exit(0);
    end;

    local procedure GetScoreComparison(VendorScore: Decimal; BenchmarkScore: Decimal): Text
    begin
        if BenchmarkScore = 0 then
            exit('No benchmark data');

        exit(StrSubstNo('%1 vs %2 BM',
            Format(VendorScore, 0, '<Precision,2:2><Standard Format,0>'),
            Format(BenchmarkScore, 0, '<Precision,2:2><Standard Format,0>')));
    end;

    local procedure GetComparisonStyle(VendorScore: Decimal; BenchmarkScore: Decimal): Text
    begin
        if BenchmarkScore = 0 then
            exit('Standard');

        if VendorScore > BenchmarkScore + 3 then
            exit('Favorable');
        if VendorScore < BenchmarkScore - 3 then
            exit('Unfavorable');
        exit('StrongAccent');
    end;

    local procedure GetTrendIcon(VendorScore: Decimal; BenchmarkScore: Decimal): Text
    begin
        if BenchmarkScore = 0 then
            exit('⏺'); // No benchmark data
        if VendorScore > BenchmarkScore + 3 then
            exit('⬆'); // Favorable trend
        if VendorScore < BenchmarkScore - 3 then
            exit('⬇'); // Unfavorable trend
        exit('➡'); // Neutral trend
    end;

    local procedure SetStyles()
    begin
        case Rec."Current Rating" of
            'A+', 'A':
                RatingStyle := 'Favorable';
            'B':
                RatingStyle := 'Ambiguous';
            else
                RatingStyle := 'Unfavorable';
        end;

        if Rec."Current Points" >= 2000 then
            PointsStyle := 'Favorable'
        else if Rec."Current Points" >= 1000 then
            PointsStyle := 'StrongAccent'
        else if Rec."Current Points" >= 500 then
            PointsStyle := 'Attention'
        else
            PointsStyle := 'Standard';
    end;
}