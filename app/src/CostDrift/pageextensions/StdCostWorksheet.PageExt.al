namespace ManufacturingAdvanced.CostDrift;

using Microsoft.Manufacturing.StandardCost;

pageextension 85300 "MFG Std. Cost Worksheet" extends "Standard Cost Worksheet"
{
    actions
    {
        addlast(Processing)
        {
            action(MFGCostDrift)
            {
                ApplicationArea = MFGCostDrift;
                AccessByPermission = tabledata "MFG Cost Drift Setup" = R;
                Caption = 'Standard cost drift';
                ToolTip = 'See which standard-cost items have drifted from their BOM, routing or purchase price, and send them to this worksheet.';
                Image = CalculateCost;
                RunObject = page "MFG Cost Drift";
            }
        }
    }
}
