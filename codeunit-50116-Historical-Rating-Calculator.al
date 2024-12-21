codeunit 50116 "Historical Rating Calculator"
{
    procedure CalculateHistoricalRatings(VendorNo: Code[20]; StartFromDate: Date)
    var
        VendorRatingSetup: Record "Vendor Rating Setup";
        RatingCalc: Codeunit "Rating Calculation";
        Vendor: Record Vendor;
        PeriodStartDate: Date;
        PeriodEndDate: Date;
        Window: Dialog;
        DateFilter: Text;
        Counter: Integer;
    begin
        if not Vendor.Get(VendorNo) then
            Error('Vendor %1 not found', VendorNo);

        // Get vendor's rating setup
        if not VendorRatingSetup.Get(Vendor."Rating Setup Code") then
            VendorRatingSetup.Get('DEFAULT');

        Window.Open('Calculating Historical Ratings\' +
                   'Period: #1############\' +
                   'Processed: #2### periods');

        // Initialize first period
        PeriodEndDate := CalcDate('<CM>', StartFromDate);  // End of first month
        Counter := 0;

        // Process until we reach current month
        while PeriodEndDate <= CalcDate('<CM>', WorkDate()) do begin
            case VendorRatingSetup."Evaluation Period" of
                "Evaluation Period"::Monthly:
                    begin
                        PeriodStartDate := CalcDate('<-CM>', PeriodEndDate);  // Start of current month
                        PeriodEndDate := CalcDate('<CM>', PeriodEndDate);     // End of current month
                    end;
                "Evaluation Period"::Weekly:
                    begin
                        PeriodStartDate := CalcDate('<-CW>', PeriodEndDate);  // Start of current week
                        PeriodEndDate := CalcDate('<CW>', PeriodEndDate);     // End of current week
                    end;
                "Evaluation Period"::Daily:
                    begin
                        PeriodStartDate := PeriodEndDate;
                        PeriodEndDate := PeriodStartDate;
                    end;
            end;

            Counter += 1;
            Window.Update(1, StrSubstNo('%1 to %2', PeriodStartDate, PeriodEndDate));
            Window.Update(2, Counter);

            // Calculate rating for this period
            DateFilter := Format(PeriodStartDate) + '..' + Format(PeriodEndDate);
            RatingCalc.CalculateVendorRating(VendorNo, DateFilter);

            // Move to next period
            case VendorRatingSetup."Evaluation Period" of
                "Evaluation Period"::Monthly:
                    PeriodEndDate := CalcDate('<1M>', PeriodEndDate);
                "Evaluation Period"::Weekly:
                    PeriodEndDate := CalcDate('<1W>', PeriodEndDate);
                "Evaluation Period"::Daily:
                    PeriodEndDate := CalcDate('<1D>', PeriodEndDate);
            end;
        end;

        Window.Close();
        Message('Historical rating calculation complete.\%1 periods processed.', Counter);
    end;
}