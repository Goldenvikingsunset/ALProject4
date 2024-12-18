tableextension 50110 "Purchase Header Quality Ext" extends "Purchase Header"
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