codeunit 50105 "Query Test"
{
    procedure TestQualityRating(VendorNo: Code[20])
    var
        QualityQuery: Query "Quality Rating";
    begin
        QualityQuery.SetRange(BuyFromVendorNo, VendorNo);
        QualityQuery.Open();

        while QualityQuery.Read() do
            Message('Vendor: %1\Total Received: %2\Total Returned: %3',
                QualityQuery.BuyFromVendorNo,
                QualityQuery.TotalReceived,
                QualityQuery.TotalReturned);
    end;

    procedure TestDeliveryPerformance(VendorNo: Code[20])
    var
        DeliveryQuery: Query "Delivery Performance";
    begin
        DeliveryQuery.SetRange(BuyFromVendorNo, VendorNo);
        DeliveryQuery.Open();

        while DeliveryQuery.Read() do
            Message('Document: %1\Expected: %2\Ordered: %3\Received: %4',
                DeliveryQuery.OrderNo,
                DeliveryQuery.ExpectedReceiptDate,
                DeliveryQuery.OrderedQty,
                DeliveryQuery.ReceivedQty);
    end;
}