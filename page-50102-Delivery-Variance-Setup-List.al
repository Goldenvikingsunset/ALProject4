page 50102 "Delivery Variance Setup List"
{
    PageType = List;
    SourceTable = "Delivery Variance Setup";
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
                field("Days Late From"; Rec."Days Late From") { }
                field("Days Late To"; Rec."Days Late To") { }
                field("Score"; Rec."Score") { }
                field("Points"; Rec."Points") { }
            }
        }
    }
}