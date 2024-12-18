page 50111 "Quality Score Entry"
{
    PageType = StandardDialog;
    Caption = 'Enter Quality Score';

    layout
    {
        area(Content)
        {
            group(ScoreEntry)
            {
                Caption = 'Quality Assessment';

                field(QualityScore; QualityScore)
                {
                    ApplicationArea = All;
                    Caption = 'Quality Score (0-100)';
                    ToolTip = 'Enter a quality score between 0 and 100';

                    trigger OnValidate()
                    begin
                        if (QualityScore < 0) or (QualityScore > 100) then
                            Error('Quality Score must be between 0 and 100');
                    end;
                }
            }
        }
    }

    var
        QualityScore: Decimal;

    procedure GetQualityScore(): Decimal
    begin
        exit(QualityScore);
    end;
}