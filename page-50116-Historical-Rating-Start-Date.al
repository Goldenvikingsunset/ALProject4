report 50100 "Calculate Historical Ratings"
{
    Caption = 'Calculate Historical Vendor Ratings';
    ProcessingOnly = true;
    UseRequestPage = true;

    dataset
    {
        dataitem(Vendor; Vendor)
        {
            DataItemTableView = sorting("No.");
            RequestFilterFields = "No.", "Rating Setup Code";

            trigger OnPreDataItem()
            begin
                Window.Open(
                    'Processing Historical Ratings\' +
                    'Vendor: #1################\' +
                    'Period: #2################\' +
                    'Processed Periods: #3###');
                PeriodsProcessed := 0;
            end;

            trigger OnAfterGetRecord()
            var
                RatingDataMgt: Codeunit "Rating Data Management";
                VendorRatingEntry: Record "Vendor Rating Entry";
                PeriodStartDate: Date;
                PeriodEndDate: Date;
                EntryCount: Integer;
                ScheduleTotal: Decimal;
                QualityTotal: Decimal;
                QuantityTotal: Decimal;
                TotalScore: Decimal;
                Rating: Text[30];
                RatingScoreCalc: Codeunit "Rating Score Calculation";
            begin
                Window.Update(1, "No.");

                // Initialize first period
                PeriodStartDate := DMY2Date(1, Date2DMY(FromDate, 2), Date2DMY(FromDate, 3)); // First day of month
                PeriodEndDate := CalcDate('<CM>', PeriodStartDate); // Last day of month

                // Process until we reach end date
                while PeriodEndDate <= ToDate do begin
                    Window.Update(2, StrSubstNo('%1 to %2', PeriodStartDate, PeriodEndDate));

                    // Clear existing history for this period if option selected
                    if ClearExisting then
                        RatingDataMgt.ClearExistingHistory("No.", PeriodStartDate, PeriodEndDate);

                    // Get entries for this period
                    VendorRatingEntry.SetRange("Vendor No", "No.");
                    VendorRatingEntry.SetRange("Posting Date", PeriodStartDate, PeriodEndDate);

                    if not VendorRatingEntry.IsEmpty then begin
                        Clear(ScheduleTotal);
                        Clear(QualityTotal);
                        Clear(QuantityTotal);
                        Clear(EntryCount);

                        if VendorRatingEntry.FindSet() then
                            repeat
                                EntryCount += 1;
                                ScheduleTotal += VendorRatingEntry."Schedule Score";
                                QualityTotal += VendorRatingEntry."Quality Score";
                                QuantityTotal += VendorRatingEntry."Quantity Score";
                            until VendorRatingEntry.Next() = 0;

                        // Calculate averages
                        if EntryCount > 0 then begin
                            ScheduleTotal := Round(ScheduleTotal / EntryCount, 0.01);
                            QualityTotal := Round(QualityTotal / EntryCount, 0.01);
                            QuantityTotal := Round(QuantityTotal / EntryCount, 0.01);

                            // Calculate total score using weights from setup
                            GetWeightedScore(
                                "Rating Setup Code",
                                ScheduleTotal,
                                QualityTotal,
                                QuantityTotal,
                                TotalScore);

                            // Get rating based on total score
                            Rating := RatingScoreCalc.DetermineRating(TotalScore, "Rating Setup Code");

                            // Create history entry
                            RatingDataMgt.CreateHistoryEntry(
                                "No.",
                                PeriodStartDate,
                                PeriodEndDate,
                                EntryCount,  // Number of Orders
                                ScheduleTotal,
                                QualityTotal,
                                QuantityTotal,
                                TotalScore,
                                Rating);

                            PeriodsProcessed += 1;
                            Window.Update(3, PeriodsProcessed);
                        end;
                    end;

                    // Move to next period
                    PeriodStartDate := CalcDate('<1M>', PeriodStartDate);
                    PeriodEndDate := CalcDate('<CM>', PeriodStartDate);
                end;
            end;

            trigger OnPostDataItem()
            begin
                Window.Close();
                Message('Historical rating calculation complete.\Periods Processed: %1', PeriodsProcessed);
            end;
        }
    }

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(Options)
                {
                    Caption = 'Date Options';
                    field(FromDate; FromDate)
                    {
                        ApplicationArea = All;
                        Caption = 'From Date';
                        ToolTip = 'Specify the start date for historical calculations';
                    }
                    field(ToDate; ToDate)
                    {
                        ApplicationArea = All;
                        Caption = 'To Date';
                        ToolTip = 'Specify the end date for historical calculations';

                        trigger OnValidate()
                        begin
                            if ToDate < FromDate then
                                Error('To Date cannot be before From Date');
                        end;
                    }
                    field(ClearExisting; ClearExisting)
                    {
                        ApplicationArea = All;
                        Caption = 'Clear Existing History';
                        ToolTip = 'Enable to clear existing history entries before processing';
                    }
                }
            }
        }

        trigger OnOpenPage()
        begin
            if FromDate = 0D then
                FromDate := DMY2Date(1, 1, 2023);  // January 1st, 2023
            if ToDate = 0D then
                ToDate := CalcDate('<CM>', WorkDate());  // Last day of current month
            ClearExisting := true;  // Set default value here
        end;
    }

    local procedure GetWeightedScore(SetupCode: Code[20]; ScheduleScore: Decimal; QualityScore: Decimal; QuantityScore: Decimal; var TotalScore: Decimal)
    var
        VendorRatingSetup: Record "Vendor Rating Setup";
    begin
        if not VendorRatingSetup.Get(SetupCode) then
            VendorRatingSetup.Get('DEFAULT');

        TotalScore := Round(
            (ScheduleScore * VendorRatingSetup."Schedule Weight") +
            (QualityScore * VendorRatingSetup."Quality Weight") +
            (QuantityScore * VendorRatingSetup."Quantity Weight"),
            0.01);
    end;

    var
        FromDate: Date;
        ToDate: Date;
        Window: Dialog;
        ClearExisting: Boolean;
        PeriodsProcessed: Integer;
}