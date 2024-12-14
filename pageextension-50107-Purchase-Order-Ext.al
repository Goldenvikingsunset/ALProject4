pageextension 50107 "Purchase Order Ext" extends "Purchase Order"
{
    layout
    {
        addfirst(factboxes)
        {
            part("VendorRatingPart"; "Vendor Rating FactBox")
            {
                ApplicationArea = All;
                SubPageLink = "No." = field("Buy-from Vendor No.");
            }
        }
    }
}