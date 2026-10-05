namespace ManufacturingAdvanced.Core;

codeunit 85000 "MFG Setup Logic" implements "MFG ISetup"
{
    Access = Public;

    /// <summary>
    /// Ensures the single setup record exists, creating it if it does not.
    /// </summary>
    /// <param name="Setup">The setup record to materialise.</param>
    procedure EnsureExists(var Setup: Record "MFG Setup")
    begin
        Setup.Reset();
        if Setup.Get() then
            exit;

        Setup.Init();
        Setup.Insert(true);
    end;

    /// <summary>
    /// Determines whether the foundation setup has been completed.
    /// </summary>
    /// <returns>True when the foundation setup record is present.</returns>
    procedure IsComplete(): Boolean
    var
        Setup: Record "MFG Setup";
    begin
        Setup.SetLoadFields("Primary Key");
        exit(Setup.Get());
    end;
}
