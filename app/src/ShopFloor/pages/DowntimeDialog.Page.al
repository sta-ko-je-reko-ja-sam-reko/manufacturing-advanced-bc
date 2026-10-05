namespace ManufacturingAdvanced.ShopFloor;

using Microsoft.Manufacturing.Document;
using Microsoft.Manufacturing.Setup;

page 85603 "MFG Downtime Dialog"
{
    PageType = StandardDialog;
    ApplicationArea = MFGShopFloor;
    UsageCategory = None;
    Caption = 'Report downtime';

    layout
    {
        area(Content)
        {
            field(Minutes; Minutes)
            {
                Caption = 'Minutes';
                ToolTip = 'Specifies how many minutes the operation stood still.';
                DecimalPlaces = 0 : 2;
                MinValue = 0;
            }
            field(StopCode; StopCode)
            {
                Caption = 'Stop code';
                ToolTip = 'Specifies why the operation stood still.';
                TableRelation = Stop;
            }
        }
    }

    trigger OnOpenPage()
    var
        Setup: Record "MFG Shop Floor Setup";
    begin
        Setup.SetLoadFields("Default Stop Code");
        if Setup.Get() then
            StopCode := Setup."Default Stop Code";
    end;

    var
        Minutes: Decimal;
        StopCode: Code[10];

    /// <summary>
    /// Reports what was entered for an operation.
    /// </summary>
    /// <param name="ProdOrderRoutingLine">The operation.</param>
    internal procedure ReportFor(ProdOrderRoutingLine: Record "Prod. Order Routing Line")
    var
        Engine: Codeunit "MFG Shop Floor Engine";
    begin
        Engine.ReportDowntime(ProdOrderRoutingLine, Minutes, StopCode);
    end;
}
