namespace ManufacturingAdvanced.Core;

using ManufacturingAdvanced.CostDrift;
using ManufacturingAdvanced.EngineeringChange;
using ManufacturingAdvanced.FiniteLoading;
using ManufacturingAdvanced.PlanningInsight;
using ManufacturingAdvanced.Preflight;
using ManufacturingAdvanced.RefreshGuard;
using ManufacturingAdvanced.ShopFloor;
using ManufacturingAdvanced.WIPControl;
using Microsoft.Manufacturing.Document;
using Microsoft.Manufacturing.MachineCenter;
using Microsoft.Manufacturing.ProductionBOM;
using Microsoft.Manufacturing.Routing;
using Microsoft.Manufacturing.WorkCenter;

page 85004 "MFG Production Manager RC"
{
    PageType = RoleCenter;
    Caption = 'Production manager';

    layout
    {
        area(RoleCenter)
        {
            part(Activities; "MFG Production Activities")
            {
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        area(Embedding)
        {
            action(ReleasedOrders)
            {
                Caption = 'Released production orders';
                ApplicationArea = Manufacturing;
                RunObject = page "Released Production Orders";
                ToolTip = 'Open the released production orders.';
            }
            action(FirmPlannedOrders)
            {
                Caption = 'Firm planned production orders';
                ApplicationArea = Manufacturing;
                RunObject = page "Firm Planned Prod. Orders";
                ToolTip = 'Open the firm planned production orders.';
            }
            action(ProductionBOMs)
            {
                Caption = 'Production BOMs';
                ApplicationArea = Manufacturing;
                RunObject = page "Production BOM List";
                ToolTip = 'Open the production BOMs.';
            }
            action(Routings)
            {
                Caption = 'Routings';
                ApplicationArea = Manufacturing;
                RunObject = page "Routing List";
                ToolTip = 'Open the routings.';
            }
            action(WorkCenters)
            {
                Caption = 'Work centers';
                ApplicationArea = Manufacturing;
                RunObject = page "Work Center List";
                ToolTip = 'Open the work centers.';
            }
            action(MachineCenters)
            {
                Caption = 'Machine centers';
                ApplicationArea = Manufacturing;
                RunObject = page "Machine Center List";
                ToolTip = 'Open the machine centers.';
            }
        }
        area(Sections)
        {
            group(ReleaseSection)
            {
                Caption = 'Release and refresh';

                action(PreflightFindings)
                {
                    Caption = 'Pre-flight findings';
                    ApplicationArea = MFGPreflight;
                    RunObject = page "MFG Preflight Findings";
                    ToolTip = 'Open what the checks before release found on production orders.';
                }
                action(RefreshRuns)
                {
                    Caption = 'Production order refreshes';
                    ApplicationArea = MFGRefreshGuard;
                    RunObject = page "MFG Refresh Runs";
                    ToolTip = 'Open the refreshes that changed production orders, and restore what you want back.';
                }
            }
            group(ShopSection)
            {
                Caption = 'Shop floor and capacity';

                action(ShopFloorTerminal)
                {
                    Caption = 'Shop floor terminal';
                    ApplicationArea = MFGShopFloor;
                    RunObject = page "MFG Shop Floor Terminal";
                    ToolTip = 'Start and stop operations and report output and downtime.';
                }
                action(ShopFloorSessions)
                {
                    Caption = 'Shop floor sessions';
                    ApplicationArea = MFGShopFloor;
                    RunObject = page "MFG Shop Floor Sessions";
                    ToolTip = 'Open the operations started and stopped on the terminal.';
                }
                action(LoadPlan)
                {
                    Caption = 'Finite load plan';
                    ApplicationArea = MFGFiniteLoading;
                    RunObject = page "MFG Load Plan";
                    ToolTip = 'See when each open operation can really be done, given the capacity.';
                }
            }
            group(FinishSection)
            {
                Caption = 'Finishing and cost';

                action(FinishProposals)
                {
                    Caption = 'Finish proposals';
                    ApplicationArea = MFGWIPControl;
                    RunObject = page "MFG Finish Proposals";
                    ToolTip = 'Open the released production orders that should be finished.';
                }
                action(WipReconciliation)
                {
                    Caption = 'WIP reconciliation';
                    ApplicationArea = MFGWIPControl;
                    RunObject = page "MFG WIP Reconciliation";
                    ToolTip = 'Compare each order''s work in progress with the general ledger.';
                }
                action(CostDrift)
                {
                    Caption = 'Standard cost drift';
                    ApplicationArea = MFGCostDrift;
                    RunObject = page "MFG Cost Drift";
                    ToolTip = 'Open the items whose standard cost has drifted.';
                }
                action(OrderVariances)
                {
                    Caption = 'Order variances';
                    ApplicationArea = MFGCostDrift;
                    RunObject = page "MFG Order Variances";
                    ToolTip = 'Open the variances of finished production orders.';
                }
            }
            group(EngineeringSection)
            {
                Caption = 'Engineering and planning';

                action(EngineeringChanges)
                {
                    Caption = 'Engineering changes';
                    ApplicationArea = MFGEngineeringChange;
                    RunObject = page "MFG ECO List";
                    ToolTip = 'Open the engineering change orders.';
                }
                action(PlanningInsights)
                {
                    Caption = 'Item planning insights';
                    ApplicationArea = MFGPlanningInsight;
                    RunObject = page "MFG Item Planning Insights";
                    ToolTip = 'Open the advice on planning parameters per item.';
                }
            }
        }
        area(Processing)
        {
            action(GuidedSetup)
            {
                Caption = 'Manufacturing advanced setup';
                ApplicationArea = All;
                RunObject = page "MFG Setup Hub";
                Image = Setup;
                ToolTip = 'Switch the Manufacturing Advanced features on and off, one step per feature.';
            }
        }
    }
}
