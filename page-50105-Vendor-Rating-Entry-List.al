page 50105 "Vendor Rating Entry List"
{
    PageType = List;
    SourceTable = "Vendor Rating Entry";
    ApplicationArea = All;
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Vendor No"; Rec."Vendor No") { }
                field("Posting Date"; Rec."Posting Date") { }
                field("Document No"; Rec."Document No") { }
                field("Schedule Score"; Rec."Schedule Score") { }
                field("Quality Score"; Rec."Quality Score") { }
                field("Quantity Score"; Rec."Quantity Score") { }
                field("Total Score"; Rec."Total Score") { }
                field(Rating; Rec.Rating) { }
                field(Points; Rec.Points) { }
            }
        }
    }
}