codeunit 50104 "Rating Entry Subscriber"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnAfterPostPurchaseDoc', '', false, false)]
    local procedure OnAfterPostPurchaseDoc(var PurchaseHeader: Record "Purchase Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        PurchRcpHdrNo: Code[20]; RetShptHdrNo: Code[20]; PurchInvHdrNo: Code[20]; PurchCrMemoHdrNo: Code[20])
    var
        PurchRcptHeader: Record "Purch. Rcpt. Header";
        VendorRatingEntry: Record "Vendor Rating Entry";
        RatingCalc: Codeunit "Rating Calculation";
        RatingMgt: Codeunit "Rating Management";
    begin
        if PurchRcpHdrNo <> '' then
            if PurchRcptHeader.Get(PurchRcpHdrNo) then begin
                // Create the entry first
                RatingMgt.CreateRatingEntry(PurchRcptHeader);

                // Find the newly created entry
                VendorRatingEntry.SetRange("Document No", PurchRcpHdrNo);
                if VendorRatingEntry.FindFirst() then
                    // Calculate scores for the specific entry
                    RatingCalc.CalculateEntryScores(VendorRatingEntry);
            end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Rating Calculation", 'OnAfterCalculateVendorRating', '', false, false)]
    local procedure OnAfterCalculateVendorRating(VendorNo: Code[20])
    var
        TierMgt: Codeunit "Vendor Tier Management";
    begin
        TierMgt.UpdateVendorTier(VendorNo);
    end;

}