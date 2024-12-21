codeunit 50111 "Benchmark Management"
{
    procedure UpdateBenchmarks(SetupCode: Code[20])
    var
        VendorRatingSetup: Record "Vendor Rating Setup";
        VendorRatingEntry: Record "Vendor Rating Entry";
        Vendor: Record Vendor;
        ScheduleTotal, QualityTotal, QuantityTotal, TotalScoreTotal : Decimal;
        ScheduleCount, QualityCount, QuantityCount, TotalScoreCount : Integer;
        Window: Dialog;
    begin
        Window.Open('Updating benchmarks for #1##############');
        Window.Update(1, SetupCode);

        if not VendorRatingSetup.Get(SetupCode) then
            exit;

        // Clear previous values
        ClearBenchmarkValues(VendorRatingSetup);

        // Get entries from last year
        VendorRatingEntry.SetRange("Setup Code", SetupCode);
        VendorRatingEntry.SetFilter("Posting Date", '%1..%2', CalcDate('<-1Y>', Today), Today);

        if VendorRatingEntry.FindSet() then
            repeat
                // Schedule Score
                if VendorRatingEntry."Schedule Score" > 0 then begin
                    ScheduleTotal += VendorRatingEntry."Schedule Score";
                    ScheduleCount += 1;
                end;

                // Quality Score
                if VendorRatingEntry."Quality Score" > 0 then begin
                    QualityTotal += VendorRatingEntry."Quality Score";
                    QualityCount += 1;
                end;

                // Quantity Score
                if VendorRatingEntry."Quantity Score" > 0 then begin
                    QuantityTotal += VendorRatingEntry."Quantity Score";
                    QuantityCount += 1;
                end;

                // Total Score
                if VendorRatingEntry."Total Score" > 0 then begin
                    TotalScoreTotal += VendorRatingEntry."Total Score";
                    TotalScoreCount += 1;
                end;
            until VendorRatingEntry.Next() = 0;

        // Update setup record with benchmark data
        VendorRatingSetup."Avg Schedule Score" := GetAverageScore(ScheduleTotal, ScheduleCount);
        VendorRatingSetup."Avg Quality Score" := GetAverageScore(QualityTotal, QualityCount);
        VendorRatingSetup."Avg Quantity Score" := GetAverageScore(QuantityTotal, QuantityCount);
        VendorRatingSetup."Avg Total Score" := GetAverageScore(TotalScoreTotal, TotalScoreCount);
        VendorRatingSetup."Total Entries" := VendorRatingEntry.Count;

        // Count total vendors in this setup
        Vendor.SetRange("Rating Setup Code", SetupCode);
        VendorRatingSetup."Total Vendors" := Vendor.Count;

        VendorRatingSetup."Last Benchmark Date" := CurrentDateTime;
        VendorRatingSetup.Modify();

        Window.Close();
    end;

    local procedure GetAverageScore(Total: Decimal; Count: Integer): Decimal
    begin
        if Count = 0 then
            exit(0);
        exit(Round(Total / Count, 0.01));
    end;

    local procedure ClearBenchmarkValues(var VendorRatingSetup: Record "Vendor Rating Setup")
    begin
        VendorRatingSetup."Avg Schedule Score" := 0;
        VendorRatingSetup."Avg Quality Score" := 0;
        VendorRatingSetup."Avg Quantity Score" := 0;
        VendorRatingSetup."Avg Total Score" := 0;
        VendorRatingSetup."Total Entries" := 0;
        VendorRatingSetup."Total Vendors" := 0;
        VendorRatingSetup.Modify();
    end;

    procedure UpdateAllBenchmarks()
    var
        VendorRatingSetup: Record "Vendor Rating Setup";
    begin
        if VendorRatingSetup.FindSet() then
            repeat
                UpdateBenchmarks(VendorRatingSetup."Setup Code");
            until VendorRatingSetup.Next() = 0;
    end;
}