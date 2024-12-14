page 50103 "Quantity Variance Setup List"
{
    PageType = List;
    SourceTable = "Quantity Variance Setup";
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
                field("Variance Percentage From"; Rec."Variance Percentage From") { }
                field("Variance Percentage To"; Rec."Variance Percentage To") { }
                field("Score"; Rec."Score") { }
                field("Points"; Rec."Points") { }
            }
        }
    }
}