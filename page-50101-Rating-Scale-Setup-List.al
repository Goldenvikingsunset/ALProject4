page 50101 "Rating Scale Setup List"
{
    PageType = List;
    SourceTable = "Rating Scale Setup";
    UsageCategory = Lists;
    ApplicationArea = All;

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
                field("Rating Type"; Rec."Rating Type") { }
                field("Score From"; Rec."Score From") { }
                field("Score To"; Rec."Score To") { }
                field("Display Value"; Rec."Display Value") { }
                field("Points"; Rec."Points") { }
            }
        }
    }
}