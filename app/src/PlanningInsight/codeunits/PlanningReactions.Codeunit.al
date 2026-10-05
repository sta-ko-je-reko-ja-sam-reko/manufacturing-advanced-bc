namespace ManufacturingAdvanced.PlanningInsight;

using ManufacturingAdvanced.Core;

codeunit 85503 "MFG Planning Reactions" implements "MFG IPlanningReactions"
{
    Access = Public;

    /// <summary>
    /// Records the batch's action messages after Calculate Plan when the feature is on and the setup asks for it.
    /// </summary>
    /// <param name="TemplateName">The worksheet template.</param>
    /// <param name="BatchName">The worksheet batch.</param>
    procedure OnAfterCalculatePlan(TemplateName: Code[10]; BatchName: Code[10])
    var
        Setup: Record "MFG Planning Setup";
        FeatureMgt: Codeunit "MFG Feature Mgt.";
        Engine: Codeunit "MFG Planning Engine";
    begin
        if not FeatureMgt.IsEnabled(Enum::"MFG Feature"::MFGPlanningInsight) then
            exit;
        Setup.SetLoadFields("Record After Planning");
        if not Setup.Get() then
            exit;
        if not Setup."Record After Planning" then
            exit;

        Engine.RecordRun(TemplateName, BatchName);
    end;
}
