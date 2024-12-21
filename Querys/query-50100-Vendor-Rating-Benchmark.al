query 50101 "Vendor Rating Benchmark"
{
    QueryType = Normal;

    elements
    {
        dataitem(PurchRcptHeader; "Purch. Rcpt. Header")
        {
            column(BuyFromVendorNo; "Buy-from Vendor No.")
            {
            }
            column(PostingDate; "Posting Date")
            {
            }

            dataitem(Vendor; Vendor)
            {
                DataItemLink = "No." = PurchRcptHeader."Buy-from Vendor No.";
                SqlJoinType = InnerJoin;

                column(VendorName; Name)
                {
                }
                column(RatingSetupCode; "Rating Setup Code")
                {
                }

                dataitem(VendorRatingEntry; "Vendor Rating Entry")
                {
                    DataItemLink = "Vendor No" = Vendor."No.";
                    SqlJoinType = InnerJoin;

                    column(SetupCode; "Setup Code")
                    {
                    }
                    column(ScheduleScore; "Schedule Score")
                    {
                        Method = Average;
                        // Filter out zero scores
                        ColumnFilter = ScheduleScore = filter(> 0);
                    }
                    column(QualityScore; "Quality Score")
                    {
                        Method = Average;
                        // Filter out zero scores
                        ColumnFilter = QualityScore = filter(> 0);
                    }
                    column(QuantityScore; "Quantity Score")
                    {
                        Method = Average;
                        // Filter out zero scores
                        ColumnFilter = QuantityScore = filter(> 0);
                    }
                    column(TotalScore; "Total Score")
                    {
                        Method = Average;
                        // Filter out zero scores
                        ColumnFilter = TotalScore = filter(> 0);
                    }
                    column(EntryCount)
                    {
                        Method = Count;
                    }
                }
            }
        }
    }
}