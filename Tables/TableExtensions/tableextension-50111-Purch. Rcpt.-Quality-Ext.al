tableextension 50111 "Purch. Rcpt. Quality Ext" extends "Purch. Rcpt. Header"
{
    fields
    {
        field(50170; "Quality Score"; Decimal)
        {
            Caption = 'Quality Score';
            MinValue = 0;
            MaxValue = 100;
            DecimalPlaces = 2;
            DataClassification = CustomerContent;
        }
    }
}