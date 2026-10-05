namespace ManufacturingAdvanced.CostDrift;

enum 85300 "MFG Drift Source Type" implements "MFG IDriftSource"
{
    Caption = 'Cost drift source';
    Extensible = true;
    DefaultImplementation = "MFG IDriftSource" = "MFG Drift No Source";

    value(0; MFGNone)
    {
        Caption = 'None';
    }
    value(1; MFGRollUp)
    {
        Caption = 'BOM and routing roll-up';
        Implementation = "MFG IDriftSource" = "MFG Drift Roll-up";
    }
    value(2; MFGPurchasePrice)
    {
        Caption = 'Last purchase price';
        Implementation = "MFG IDriftSource" = "MFG Drift Purchase Price";
    }
    value(3; MFGPriceList)
    {
        Caption = 'Purchase price list';
        Implementation = "MFG IDriftSource" = "MFG Drift Price List";
    }
}
