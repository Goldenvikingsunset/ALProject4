pageextension 50108 "Vendor List Ext" extends "Vendor List"
{
    layout
    {
        addafter("Location Code")
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
            field("Current Tier Code"; Rec."Current Tier Code")
            {
                Caption = 'Current Tier Code';
                ApplicationArea = All;
                Editable = false;
            }
            field("Next Tier Points Required"; Rec."Next Tier Points Required")
            {
                Caption = 'Points to Next Tier';
                ApplicationArea = All;
                Editable = false;
            }
            field("Rating Setup Code"; Rec."Rating Setup Code")
            {
                Caption = 'Rating Setup Code';
                ApplicationArea = All;
                Editable = false;
            }
        }


        addfirst(factboxes)
        {
            part("VendorRatingPart"; "Vendor Rating FactBox")
            {
                ApplicationArea = All;
                SubPageLink = "No." = field("No.");
            }
        }
    }
}