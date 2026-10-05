namespace ManufacturingAdvanced.Preflight;

using Microsoft.Manufacturing.Document;

pageextension 85100 "MFG Firm Planned Prod. Order" extends "Firm Planned Prod. Order"
{
    actions
    {
        addlast(Processing)
        {
            action(MFGRunPreflight)
            {
                ApplicationArea = MFGPreflight;
                AccessByPermission = tabledata "MFG Preflight Setup" = R;
                Caption = 'Run pre-flight';
                ToolTip = 'Check this production order for problems that would stop or spoil its release, consumption or output, and show what was found.';
                Image = CheckRulesSyntax;

                trigger OnAction()
                var
                    Engine: Codeunit "MFG Preflight Engine";
                begin
                    Engine.RunInteractive(Rec);
                end;
            }
            action(MFGPreflightFindings)
            {
                ApplicationArea = MFGPreflight;
                AccessByPermission = tabledata "MFG Preflight Setup" = R;
                Caption = 'Pre-flight findings';
                ToolTip = 'View what the last pre-flight check found on this production order.';
                Image = ErrorLog;
                RunObject = page "MFG Preflight Findings";
                RunPageLink = "Prod. Order Status" = field(Status), "Prod. Order No." = field("No.");
            }
        }
    }
}
