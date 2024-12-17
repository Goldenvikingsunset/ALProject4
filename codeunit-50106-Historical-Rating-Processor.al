codeunit 50109 "Historical Rating Processor"
{
    procedure ProcessHistoricalTransactions(StartDate: Date; EndDate: Date)
    var
        PurchRcptHeader: Record "Purch. Rcpt. Header";
        RatingMgt: Codeunit "Rating Management";
        Window: Dialog;
        Counter: Integer;
        TotalCount: Integer;
    begin
        Window.Open('Processing Purchase Receipts\' +
                   'Receipt #\#1######\' +
                   'Processed: #2### of #3###');

        // Count total records for progress
        PurchRcptHeader.SetRange("Posting Date", StartDate, EndDate);
        TotalCount := PurchRcptHeader.Count;
        Window.Update(3, TotalCount);

        // Process each receipt
        if PurchRcptHeader.FindSet() then
            repeat
                Counter += 1;
                Window.Update(1, PurchRcptHeader."No.");
                Window.Update(2, Counter);

                // Skip if entry already exists
                if not EntryExists(PurchRcptHeader."No.") then
                    RatingMgt.CreateRatingEntry(PurchRcptHeader);

            until PurchRcptHeader.Next() = 0;

        Window.Close();
        Message('Processing complete. %1 receipts processed.', Counter);
    end;

    local procedure EntryExists(ReceiptNo: Code[20]): Boolean
    var
        VendorRatingEntry: Record "Vendor Rating Entry";
    begin
        VendorRatingEntry.SetRange("Receipt No", ReceiptNo);
        exit(not VendorRatingEntry.IsEmpty);
    end;
}