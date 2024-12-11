query 50100 "Delivery Performance"
{
    QueryType = Normal;

    elements
    {
        dataitem(PurchaseHeader; "Purchase Header")
        {
            DataItemTableFilter = "Document Type" = const(Order),
                                Status = const(Released);
            column(BuyFromVendorNo; "Buy-from Vendor No.") { }
            column(OrderNo; "No.") { }
            column(OrderDate; "Order Date") { }

            dataitem(PurchaseLine; "Purchase Line")
            {
                DataItemLink = "Document Type" = PurchaseHeader."Document Type",
                             "Document No." = PurchaseHeader."No.";
                DataItemTableFilter = Type = const(Item);
                column(LineNo; "Line No.") { }
                column(ItemNo; "No.") { }
                column(ExpectedReceiptDate; "Expected Receipt Date") { }
                column(OrderedQty; Quantity) { }
                column(ReceivedQty; "Quantity Received") { }
                column(OutstandingQty; "Outstanding Quantity") { }
                column(UnitOfMeasure; "Unit of Measure Code") { }
                column(PlannedReceiptDate; "Planned Receipt Date") { }
                column(PromisedReceiptDate; "Promised Receipt Date") { }
            }
        }
    }

    trigger OnBeforeOpen()
    begin
        SetFilter(OrderDate, '>=%1', CalcDate('<-1Y>', WorkDate()));
    end;
}