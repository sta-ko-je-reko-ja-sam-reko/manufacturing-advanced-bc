namespace ManufacturingAdvanced.EngineeringChange;

interface "MFG IEcoObject"
{
    /// <summary>
    /// Checks that the line's number exists for this object type and fills its description.
    /// </summary>
    /// <param name="EcoLine">The line whose number was entered.</param>
    procedure ValidateNo(var EcoLine: Record "MFG ECO Line");

    /// <summary>
    /// Creates the new version the change will be made in, as a copy of the version in use, with status Under
    /// Development, and records its code on the line. Does nothing when the line already has one.
    /// </summary>
    /// <param name="EcoLine">The line.</param>
    procedure CreateVersion(var EcoLine: Record "MFG ECO Line");

    /// <summary>
    /// Certifies the line's new version, starting on the effective date, through the object's own validation.
    /// </summary>
    /// <param name="EcoLine">The line.</param>
    /// <param name="EffectiveDate">The date the new version takes effect.</param>
    procedure Certify(EcoLine: Record "MFG ECO Line"; EffectiveDate: Date);

    /// <summary>
    /// Adds every open production order line that uses the line's object to the impact buffer.
    /// </summary>
    /// <param name="EcoLine">The line.</param>
    /// <param name="TempImpact">The impact buffer.</param>
    procedure CollectImpact(EcoLine: Record "MFG ECO Line"; var TempImpact: Record "MFG ECO Impact" temporary);

    /// <summary>
    /// Opens the line's new version for editing.
    /// </summary>
    /// <param name="EcoLine">The line.</param>
    procedure OpenVersion(EcoLine: Record "MFG ECO Line");
}
