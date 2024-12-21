page 50100 "Vendor Rating Setup Card"
{
    PageType = Card;
    SourceTable = "Vendor Rating Setup";
    UsageCategory = Administration;
    ApplicationArea = All;
    InsertAllowed = true;
    ModifyAllowed = true;
    DeleteAllowed = true;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field("Setup Code"; Rec."Setup Code")
                {
                    ApplicationArea = All;
                    DrillDown = true;
                    DrillDownPageId = "Vendor Rating Setup List";
                    Lookup = true;
                    LookupPageId = "Vendor Rating Setup List";

                    trigger OnDrillDown()
                    var
                        VendorRatingSetup: Record "Vendor Rating Setup";
                        VendorRatingSetupList: Page "Vendor Rating Setup List";
                    begin
                        VendorRatingSetup.Reset();
                        VendorRatingSetupList.SetTableView(VendorRatingSetup);
                        VendorRatingSetupList.Run();
                    end;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the description for this rating setup';
                }
                field("Is Default"; Rec."Is Default")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if this is the default rating setup';
                }
                field("Rating Type"; Rec."Rating Type")
                {
                    ApplicationArea = All;
                    Editable = true;
                }
                field("Evaluation Period"; Rec."Evaluation Period")
                {
                    ApplicationArea = All;
                    Editable = true;
                }
            }

            group(Weights)
            {
                Caption = 'Weights';
                field("Schedule Weight"; Rec."Schedule Weight")
                {
                    ApplicationArea = All;
                    Editable = true;
                }
                field("Quality Weight"; Rec."Quality Weight")
                {
                    ApplicationArea = All;
                    Editable = true;
                }
                field("Quantity Weight"; Rec."Quantity Weight")
                {
                    ApplicationArea = All;
                    Editable = true;
                }
            }

            group(Settings)
            {
                Caption = 'Settings';
                field("Minimum Orders Required"; Rec."Minimum Orders Required")
                {
                    ApplicationArea = All;
                    Editable = true;
                }
                field("Enable Vendor Points"; Rec."Enable Vendor Points")
                {
                    ApplicationArea = All;
                    Editable = true;
                }
            }

            group(Benchmarks)
            {
                Caption = 'Benchmark Statistics';

                field("Avg Schedule Score"; Rec."Avg Schedule Score")
                {
                    ApplicationArea = All;
                    Caption = 'Average Schedule Score';
                    StyleExpr = ScheduleStyle;
                    ToolTip = 'Shows the average schedule performance score across all vendors in this setup';
                }
                field("Avg Quality Score"; Rec."Avg Quality Score")
                {
                    ApplicationArea = All;
                    Caption = 'Average Quality Score';
                    StyleExpr = QualityStyle;
                    ToolTip = 'Shows the average quality score across all vendors in this setup';
                }
                field("Avg Quantity Score"; Rec."Avg Quantity Score")
                {
                    ApplicationArea = All;
                    Caption = 'Average Quantity Score';
                    StyleExpr = QuantityStyle;
                    ToolTip = 'Shows the average quantity accuracy score across all vendors in this setup';
                }
                field("Avg Total Score"; Rec."Avg Total Score")
                {
                    ApplicationArea = All;
                    Caption = 'Average Total Score';
                    StyleExpr = TotalStyle;
                    ToolTip = 'Shows the average overall performance score across all vendors in this setup';
                }
                field("Total Vendors"; Rec."Total Vendors")
                {
                    ApplicationArea = All;
                    ToolTip = 'Shows the total number of vendors using this rating setup';
                }
                field("Total Entries"; Rec."Total Entries")
                {
                    ApplicationArea = All;
                    ToolTip = 'Shows the total number of rating entries for this setup';
                }
                field("Last Benchmark Date"; Rec."Last Benchmark Date")
                {
                    ApplicationArea = All;
                    Caption = 'Last Updated';
                    ToolTip = 'Shows when the benchmark data was last updated';
                }
            }
        }
    }

    actions
    {
        area(Navigation)
        {
            group(RelatedSetup)
            {
                Caption = 'Related Setup';
                Image = Setup;

                action(UpdateBenchmarks)
                {
                    ApplicationArea = All;
                    Caption = 'Update Benchmarks';
                    Image = Refresh;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ToolTip = 'Update the benchmark data for this rating setup';

                    trigger OnAction()
                    var
                        BenchmarkMgt: Codeunit "Benchmark Management";
                    begin
                        BenchmarkMgt.UpdateBenchmarks(Rec."Setup Code");
                        CurrPage.Update(false);
                    end;
                }

                action(RatingScales)
                {
                    ApplicationArea = All;
                    Caption = 'Rating Scales';
                    Image = SetupList;
                    RunObject = Page "Rating Scale Setup List";
                    RunPageLink = "Setup Code" = field("Setup Code");
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                }

                action(DeliveryVariances)
                {
                    ApplicationArea = All;
                    Caption = 'Delivery Variances';
                    Image = SetupList;
                    RunObject = Page "Delivery Variance Setup List";
                    RunPageLink = "Setup Code" = field("Setup Code");
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                }

                action(QuantityVariances)
                {
                    ApplicationArea = All;
                    Caption = 'Quantity Variances';
                    Image = SetupList;
                    RunObject = Page "Quantity Variance Setup List";
                    RunPageLink = "Setup Code" = field("Setup Code");
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                }

                action(RatingHistory)
                {
                    ApplicationArea = All;
                    Caption = 'Rating History';
                    Image = History;
                    RunObject = Page "Vendor Rating History List";
                    RunPageLink = "Setup Code" = field("Setup Code");
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                }

                action(RatingEntries)
                {
                    ApplicationArea = All;
                    Caption = 'Rating Entries';
                    Image = List;
                    RunObject = Page "Vendor Rating Entry List";
                    RunPageLink = "Setup Code" = field("Setup Code");
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                }

                action(VendorTiers)
                {
                    ApplicationArea = All;
                    Caption = 'Vendor Tiers';
                    Image = CustomerRating;
                    RunObject = Page "Vendor Tier Setup List";
                    RunPageLink = "Setup Code" = field("Setup Code");
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                }
            }
        }
    }

    var
        ScheduleStyle: Text;
        QualityStyle: Text;
        QuantityStyle: Text;
        TotalStyle: Text;

    trigger OnAfterGetRecord()
    begin
        SetStyles();
    end;

    local procedure SetStyles()
    begin
        ScheduleStyle := GetScoreStyle(Rec."Avg Schedule Score");
        QualityStyle := GetScoreStyle(Rec."Avg Quality Score");
        QuantityStyle := GetScoreStyle(Rec."Avg Quantity Score");
        TotalStyle := GetScoreStyle(Rec."Avg Total Score");
    end;

    local procedure GetScoreStyle(Score: Decimal): Text
    begin
        if Score >= 90 then
            exit('Favorable')
        else if Score >= 70 then
            exit('Ambiguous')
        else
            exit('Unfavorable');
    end;
}
