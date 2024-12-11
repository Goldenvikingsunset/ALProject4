page 50106 "Vendor Rating FactBox"
{
    PageType = ListPart;
    SourceTable = Vendor;
    Caption = 'Vendor Rating';

    layout
    {
        area(Content)
        {
            field("Current Rating"; Rec."Current Rating")
            {
                ApplicationArea = All;
            }
            field("Current Points"; Rec."Current Points")
            {
                ApplicationArea = All;
            }
            field("Last Evaluation Date"; Rec."Last Evaluation Date")
            {
                ApplicationArea = All;
            }
            field("YTD Average Score"; Rec."YTD Average Score")
            {
                ApplicationArea = All;
            }
            field("Trend Indicator"; Rec."Trend Indicator")
            {
                ApplicationArea = All;
            }
        }
    }
}
