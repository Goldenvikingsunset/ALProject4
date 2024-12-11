page 50104 "Vendor Rating History List"
{
    PageType = List;
    SourceTable = "Vendor Rating History";
    ApplicationArea = All;
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Vendor No"; Rec."Vendor No") { }
                field("Period Start Date"; Rec."Period Start Date") { }
                field("Period End Date"; Rec."Period End Date") { }
                field("Number of Orders"; Rec."Number of Orders") { }
                field("Average Schedule Score"; Rec."Average Schedule Score") { }
                field("Average Quality Score"; Rec."Average Quality Score") { }
                field("Average Quantity Score"; Rec."Average Quantity Score") { }
                field("Total Score"; Rec."Total Score") { }
                field(Rating; Rec.Rating) { }
                field("Total Points"; Rec."Total Points") { }
            }
        }
    }
}