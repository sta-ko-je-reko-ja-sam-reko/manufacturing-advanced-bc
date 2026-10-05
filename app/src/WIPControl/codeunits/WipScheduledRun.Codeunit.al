namespace ManufacturingAdvanced.WIPControl;

codeunit 85214 "MFG WIP Scheduled Run"
{
    Access = Public;

    /// <summary>
    /// Run by the job queue: suggests the finish proposals and reconciles WIP with the general ledger.
    /// </summary>
    trigger OnRun()
    var
        Engine: Codeunit "MFG WIP Engine";
    begin
        Engine.RunScheduled();
    end;
}
