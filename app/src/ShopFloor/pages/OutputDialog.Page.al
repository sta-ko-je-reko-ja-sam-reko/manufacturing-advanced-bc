namespace ManufacturingAdvanced.ShopFloor;

using Microsoft.Manufacturing.Document;
using Microsoft.Manufacturing.Setup;

page 85602 "MFG Output Dialog"
{
    PageType = StandardDialog;
    ApplicationArea = MFGShopFloor;
    UsageCategory = None;
    Caption = 'Report output';

    layout
    {
        area(Content)
        {
            field(OutputQuantity; OutputQuantity)
            {
                Caption = 'Good quantity';
                ToolTip = 'Specifies the quantity that came out good.';
                DecimalPlaces = 0 : 5;
                MinValue = 0;
            }
            field(ScrapQuantity; ScrapQuantity)
            {
                Caption = 'Scrap quantity';
                ToolTip = 'Specifies the quantity that was scrapped.';
                DecimalPlaces = 0 : 5;
                MinValue = 0;
            }
            field(ScrapCode; ScrapCode)
            {
                Caption = 'Scrap code';
                ToolTip = 'Specifies why the quantity was scrapped.';
                TableRelation = Scrap;
            }
        }
    }

    trigger OnOpenPage()
    var
        Setup: Record "MFG Shop Floor Setup";
    begin
        Setup.SetLoadFields("Default Scrap Code");
        if Setup.Get() then
            ScrapCode := Setup."Default Scrap Code";
    end;

    var
        OutputQuantity: Decimal;
        ScrapQuantity: Decimal;
        ScrapCode: Code[10];

    /// <summary>
    /// Reports what was entered for an operation.
    /// </summary>
    /// <param name="ProdOrderRoutingLine">The operation.</param>
    internal procedure ReportFor(ProdOrderRoutingLine: Record "Prod. Order Routing Line")
    var
        Engine: Codeunit "MFG Shop Floor Engine";
    begin
        Engine.ReportOperationOutput(ProdOrderRoutingLine, OutputQuantity, ScrapQuantity, ScrapCode);
    end;

    /// <summary>
    /// Reports what was entered for a production order line without a routing.
    /// </summary>
    /// <param name="ProdOrderLine">The production order line.</param>
    internal procedure ReportForLine(ProdOrderLine: Record "Prod. Order Line")
    var
        Engine: Codeunit "MFG Shop Floor Engine";
    begin
        Engine.ReportLineOutput(ProdOrderLine, OutputQuantity, ScrapQuantity, ScrapCode);
    end;
}
