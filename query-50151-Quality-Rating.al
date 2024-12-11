query 50101 "Quality Rating"
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
                DataItemLink = "Document No." = PurchRcptHeader."No."; // Ensure "No." exists in Purch. Rcpt. Header
                column(TotalReceived; Quantity) { Method = Sum; }

                dataitem(ReturnReceiptLine; "Return Receipt Line")
                {
                    // Replace these with the actual field names from the "Return Receipt Line" table
                    DataItemLink = "Document No." = PurchRcptLine."Document No.";
                    column(TotalReturned; Quantity) { Method = Sum; }
                }
            }
        }
    }
}