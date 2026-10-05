namespace ManufacturingAdvanced.WIPControl;

using Microsoft.Manufacturing.Document;

codeunit 85203 "MFG WIP Finish Order"
{
    Access = Internal;
    TableNo = "Production Order";

    trigger OnRun()
    var
        Setup: Record "MFG WIP Setup";
        ProdOrderStatusManagement: Codeunit "Prod. Order Status Management";
    begin
        Setup.SetLoadFields("Update Unit Cost");
        if not Setup.Get() then
            Clear(Setup);

        ProdOrderStatusManagement.ChangeProdOrderStatus(Rec, Rec.Status::Finished, WorkDate(), Setup."Update Unit Cost");
    end;
}
