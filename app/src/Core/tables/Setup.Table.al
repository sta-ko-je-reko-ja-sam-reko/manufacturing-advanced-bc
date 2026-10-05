namespace ManufacturingAdvanced.Core;

table 85000 "MFG Setup"
{
    Caption = 'Manufacturing advanced setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary key';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }

    var
        ILogic: Interface "MFG ISetup";
        ILogicDefined: Boolean;

    /// <summary>
    /// Ensures the single setup record exists and positions this record on it.
    /// </summary>
    procedure EnsureExists()
    begin
        Logic().EnsureExists(Rec);
    end;

    /// <summary>
    /// Determines whether the foundation setup has been completed.
    /// </summary>
    /// <returns>True when the foundation setup record is present.</returns>
    procedure IsComplete(): Boolean
    begin
        exit(Logic().IsComplete());
    end;

    /// <summary>
    /// Injects an alternative implementation of the setup logic, for tests and dependent apps.
    /// </summary>
    /// <param name="Implementation">The implementation to use instead of the default.</param>
    procedure Define(Implementation: Interface "MFG ISetup")
    begin
        ILogic := Implementation;
        ILogicDefined := true;
    end;

    local procedure Logic(): Interface "MFG ISetup"
    var
        DefaultLogic: Codeunit "MFG Setup Logic";
    begin
        if not ILogicDefined then
            Define(DefaultLogic);
        exit(ILogic);
    end;
}
