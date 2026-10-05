namespace ManufacturingAdvanced.Test;

using ManufacturingAdvanced.WIPControl;
using Microsoft.Manufacturing.Document;

codeunit 89006 "MFG Test WIP Valuation" implements "MFG IWipValuation"
{
    procedure Calculate(ProductionOrder: Record "Production Order"; var Proposal: Record "MFG Finish Proposal")
    begin
        Proposal."Consumption Cost" := 0;
        Proposal."Capacity Cost" := 0;
        Proposal."Output Cost" := 0;
        Proposal."Est. WIP Amount" := 999;
        Proposal."Last Output Date" := WorkDate();
    end;
}
