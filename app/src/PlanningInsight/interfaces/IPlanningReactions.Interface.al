namespace ManufacturingAdvanced.PlanningInsight;

interface "MFG IPlanningReactions"
{
    /// <summary>
    /// Reacts to Calculate Plan having finished for a planning worksheet batch.
    /// </summary>
    /// <param name="TemplateName">The worksheet template.</param>
    /// <param name="BatchName">The worksheet batch.</param>
    procedure OnAfterCalculatePlan(TemplateName: Code[10]; BatchName: Code[10]);
}
