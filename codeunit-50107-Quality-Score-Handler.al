codeunit 50110 "Quality Score Handler"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnBeforePostPurchaseDoc', '', false, false)]
    local procedure OnBeforePostPurchaseDoc(var PurchaseHeader: Record "Purchase Header"; PreviewMode: Boolean)
    var
        QualityScorePage: Page "Quality Score Entry";
    begin
        if PreviewMode then
            exit;

        if PurchaseHeader."Document Type" <> PurchaseHeader."Document Type"::Order then
            exit;

        // Show quality score entry page
        if QualityScorePage.RunModal() = Action::OK then
            PurchaseHeader."Quality Score" := QualityScorePage.GetQualityScore();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnAfterPurchRcptHeaderInsert', '', false, false)]
    local procedure OnAfterCopyPurchOrderToPurchRcpt(var PurchRcptHeader: Record "Purch. Rcpt. Header"; var PurchaseHeader: Record "Purchase Header")
    begin
        // Copy quality score to posted receipt
        PurchRcptHeader."Quality Score" := PurchaseHeader."Quality Score";
        PurchRcptHeader.Modify();

        // Clear quality score from purchase order
        PurchaseHeader."Quality Score" := 0;
        PurchaseHeader.Modify();
    end;
}