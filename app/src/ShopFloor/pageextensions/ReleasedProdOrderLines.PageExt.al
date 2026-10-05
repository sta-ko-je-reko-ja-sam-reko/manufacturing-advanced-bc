namespace ManufacturingAdvanced.ShopFloor;

using Microsoft.Manufacturing.Document;

pageextension 85600 "MFG Released Prod. Order Lines" extends "Released Prod. Order Lines"
{
    actions
    {
        addlast(Processing)
        {
            action(MFGReportOutput)
            {
                ApplicationArea = MFGShopFloor;
                AccessByPermission = tabledata "MFG Shop Floor Setup" = R;
                Caption = 'Report output';
                ToolTip = 'Report the good and scrapped quantity of the selected line. It is posted straight away. For a line with a routing, use the shop floor terminal to report per operation.';
                Image = OutputJournal;

                trigger OnAction()
                var
                    OutputDialog: Page "MFG Output Dialog";
                begin
                    if OutputDialog.RunModal() <> Action::OK then
                        exit;
                    OutputDialog.ReportForLine(Rec);
                end;
            }
        }
    }
}
