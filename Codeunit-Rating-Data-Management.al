codeunit 50108 "Rating Data Management"
{

    procedure CreateHistoryEntry(VendorNo: Code[20]; StartDate: Date; EndDate: Date;
    EntryCount: Integer; AvgScheduleScore: Decimal; AvgQualityScore: Decimal;
    AvgQuantityScore: Decimal; TotalScore: Decimal; Rating: Text[30])
    var
        VendorRatingHistory: Record "Vendor Rating History";
        VendorRatingEntry: Record "Vendor Rating Entry";
        TotalPoints: Integer;
        AveragePoints: Integer;
        DeliveryCount: Integer;
        Vendor: Record Vendor;
    begin
        // Count entries - these are actual deliveries
        VendorRatingEntry.SetRange("Vendor No", VendorNo);
        VendorRatingEntry.SetRange("Posting Date", StartDate, EndDate);
        DeliveryCount := VendorRatingEntry.Count;

        // Use EntryCount for unique orders - this comes from order count
        VendorRatingHistory.Init();
        VendorRatingHistory."Vendor No" := VendorNo;
        if Vendor.Get(VendorNo) then
            VendorRatingHistory."Setup Code" := Vendor."Rating Setup Code"
        else
            VendorRatingHistory."Setup Code" := 'DEFAULT';

        VendorRatingHistory."Period Start Date" := StartDate;
        VendorRatingHistory."Period End Date" := EndDate;
        VendorRatingHistory."Number of Orders" := EntryCount;
        VendorRatingHistory."Number of Deliveries" := DeliveryCount;
        VendorRatingHistory."Average Schedule Score" := AvgScheduleScore;
        VendorRatingHistory."Average Quality Score" := AvgQualityScore;
        VendorRatingHistory."Average Quantity Score" := AvgQuantityScore;
        VendorRatingHistory."Total Score" := TotalScore;
        VendorRatingHistory.Rating := Rating;

        // Calculate points
        if VendorRatingEntry.FindSet() then
            repeat
                TotalPoints += VendorRatingEntry.Points;
            until VendorRatingEntry.Next() = 0;

        if DeliveryCount > 0 then
            AveragePoints := Round(TotalPoints / DeliveryCount, 1);

        VendorRatingHistory."Total Points" := AveragePoints;

        if not VendorRatingHistory.Insert() then
            VendorRatingHistory.Modify();
    end;

    procedure UpdateVendorRating(var Vendor: Record Vendor; NewScore: Decimal; StartDate: Date; EndDate: Date)
    var
        VendorRatingEntry: Record "Vendor Rating Entry";
        RatingScoreCalculator: Codeunit "Rating Score Calculation";
        VendorRatingHistory: Record "Vendor Rating History";
        TotalPoints: Integer;
        EntryCount: Integer;
        PeriodAveragePoints: Integer;
    begin
        // Calculate average points from entries for this period
        VendorRatingEntry.SetRange("Vendor No", Vendor."No.");
        VendorRatingEntry.SetRange("Posting Date", StartDate, EndDate);

        if VendorRatingEntry.FindSet() then
            repeat
                TotalPoints += VendorRatingEntry.Points;
            until VendorRatingEntry.Next() = 0;

        EntryCount := VendorRatingEntry.Count;

        if EntryCount > 0 then begin
            // Calculate period average points
            PeriodAveragePoints := Round(TotalPoints / EntryCount, 1);

            // Add period average to vendor's cumulative total
            Vendor.Validate("Current Points", Vendor."Current Points" + PeriodAveragePoints);
        end;

        // Validate and update fields in the Vendor record
        Vendor.Validate("Current Rating", RatingScoreCalculator.DetermineRating(NewScore, Vendor."Rating Setup Code"));
        Vendor.Validate("Last Evaluation Date", Today);
        Vendor.Validate("YTD Average Score", NewScore);
        Vendor.Validate("Trend Indicator", RatingScoreCalculator.CalculateTrend(Vendor."No."));

        // Calculate TotalPoints from Vendor Rating History
        TotalPoints := 0;
        VendorRatingHistory.SetRange("Vendor No", Vendor."No.");
        if VendorRatingHistory.FindSet() then
            repeat
                TotalPoints += VendorRatingHistory."Total Points";
            until VendorRatingHistory.Next() = 0;

        Vendor.Validate("Current Points", TotalPoints);

        // Perform a single Modify call for all changes
        Vendor.Modify(true);
    end;

    procedure DeductVendorPoints(var Vendor: Record Vendor; PointsToDeduct: Integer)
    begin
        if Vendor.Get(Vendor."No.") then begin
            Vendor.Validate("Current Points", Vendor."Current Points" - PointsToDeduct);
            Vendor.Modify(true);
        end;
    end;

    procedure ResetPeriodPoints(VendorNo: Code[20]; StartDate: Date; EndDate: Date)
    var
        VendorRatingHistory: Record "Vendor Rating History";
    begin
        // Just clear the existing history record for this period if it exists
        VendorRatingHistory.SetRange("Vendor No", VendorNo);
        VendorRatingHistory.SetRange("Period Start Date", StartDate);
        VendorRatingHistory.SetRange("Period End Date", EndDate);

        if VendorRatingHistory.FindFirst() then
            VendorRatingHistory.Delete();
    end;

    procedure ClearExistingHistory(VendorNo: Code[20]; StartDate: Date; EndDate: Date)
    var
        VendorRatingHistory: Record "Vendor Rating History";
    begin
        VendorRatingHistory.SetRange("Vendor No", VendorNo);
        VendorRatingHistory.SetRange("Period Start Date", StartDate);
        VendorRatingHistory.SetRange("Period End Date", EndDate);
        VendorRatingHistory.DeleteAll();
    end;

    procedure HasMinimumOrders(VendorNo: Code[20]; DateFilter: Text): Boolean
    var
        VendorRatingEntry: Record "Vendor Rating Entry";
        VendorRatingSetup: Record "Vendor Rating Setup";
        EntryCount: Integer;
    begin
        if not EnsureSetupExists() then
            exit(true);

        VendorRatingSetup.Get('DEFAULT');
        if VendorRatingSetup."Minimum Orders Required" <= 0 then
            exit(true);

        VendorRatingEntry.SetRange("Vendor No", VendorNo);
        VendorRatingEntry.SetFilter("Posting Date", DateFilter);
        EntryCount := VendorRatingEntry.Count;

        exit(EntryCount >= VendorRatingSetup."Minimum Orders Required");
    end;

    local procedure EnsureSetupExists(): Boolean
    var
        VendorRatingSetup: Record "Vendor Rating Setup";
    begin
        if not VendorRatingSetup.Get('DEFAULT') then begin
            VendorRatingSetup.Init();
            VendorRatingSetup."Setup Code" := 'DEFAULT';
            VendorRatingSetup."Rating Type" := VendorRatingSetup."Rating Type"::Percentage;
            exit(VendorRatingSetup.Insert());
        end;
        exit(true);
    end;
}