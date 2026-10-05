namespace ManufacturingAdvanced.Core;

interface "MFG ISetup"
{
    /// <summary>
    /// Ensures the single foundation setup record exists, creating it if it does not.
    /// </summary>
    /// <param name="Setup">The setup record to materialise.</param>
    procedure EnsureExists(var Setup: Record "MFG Setup");

    /// <summary>
    /// Determines whether the foundation setup has been completed. The foundation holds no feature
    /// settings, because each feature owns its own, so the only question it can answer is whether the
    /// record every feature builds on exists.
    /// </summary>
    /// <returns>True when the foundation setup record is present.</returns>
    procedure IsComplete(): Boolean;
}
