namespace ManufacturingAdvanced.Test;

using ManufacturingAdvanced.Core;

codeunit 89001 "MFG Test Setup Logic" implements "MFG ISetup"
{
    SingleInstance = true;

    var
        EnsureExistsCalls: Integer;

    procedure EnsureExists(var Setup: Record "MFG Setup")
    begin
        EnsureExistsCalls += 1;
    end;

    procedure IsComplete(): Boolean
    begin
        exit(true);
    end;

    procedure Reset()
    begin
        EnsureExistsCalls := 0;
    end;

    procedure GetEnsureExistsCalls(): Integer
    begin
        exit(EnsureExistsCalls);
    end;
}
