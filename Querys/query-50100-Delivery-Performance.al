query 50100 "Delivery Performance"
{
    QueryType = Normal;

    elements
    {
        dataitem(PurchRcptHeader; "Purch. Rcpt. Header")
        {
            column(BuyFromVendorNo; "Buy-from Vendor No.") { }
            column(PostingDate; "Posting Date") { }

            dataitem(PurchRcptLine; "Purch. Rcpt. Line")
            {
                DataItemLink = "Document No." = PurchRcptHeader."No.";
                DataItemTableFilter = Type = const(Item);

                column(OrderNo; "Order No.") { }
                column(OrderLineNo; "Order Line No.") { }
                column(ReceivedQuantity; Quantity) { Method = Sum; }

                dataitem(PurchaseLine; "Purchase Line")
                {
                    DataItemLink = "Document No." = PurchRcptLine."Order No.",
                                 "Line No." = PurchRcptLine."Order Line No.";
                    DataItemTableFilter = "Document Type" = const(Order);

                    column(OrderedQuantity; Quantity) { Method = Sum; }

                    dataitem(ReturnShipmentLine; "Return Shipment Line")
                    {
                        DataItemLink = "Return Order No." = PurchaseLine."Document No.",
                                    "Return Order Line No." = PurchaseLine."Line No.";

                        column(ReturnedQty; Quantity) { Method = Sum; }
                    }
                }
            }
        }
    }
}