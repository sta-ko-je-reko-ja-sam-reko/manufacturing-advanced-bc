namespace ManufacturingAdvanced.EngineeringChange;

using Microsoft.Foundation.NoSeries;

codeunit 85803 "MFG ECO Header Logic" implements "MFG IEcoHeader"
{
    Access = Public;

    var
        CannotDeleteErr: Label 'Engineering change %1 is %2 and cannot be deleted. Only an open or rejected change can be.', Comment = '%1 = the change number, %2 = its status';

    /// <summary>
    /// Numbers a new engineering change order from the number series in the setup when it has no number, and
    /// records who requested it and when.
    /// </summary>
    /// <param name="EcoHeader">The order being inserted.</param>
    procedure Trigger_OnInsert(var EcoHeader: Record "MFG ECO Header")
    var
        Setup: Record "MFG ECO Setup";
        NoSeries: Codeunit "No. Series";
    begin
        if EcoHeader."No." = '' then begin
            Setup.Get();
            Setup.TestField("ECO Nos.");
            EcoHeader."No." := NoSeries.GetNextNo(Setup."ECO Nos.", WorkDate());
        end;
        EcoHeader.Status := EcoHeader.Status::MFGOpen;
        EcoHeader."Requested By" := CopyStr(UserId(), 1, MaxStrLen(EcoHeader."Requested By"));
        EcoHeader."Requested At" := CurrentDateTime();
    end;

    /// <summary>
    /// Refuses to delete a change that is pending, approved or implemented, and deletes the lines of one that is
    /// open or rejected. The versions it created stay, because they belong to the BOM or routing.
    /// </summary>
    /// <param name="EcoHeader">The order being deleted.</param>
    procedure Trigger_OnDelete(var EcoHeader: Record "MFG ECO Header")
    var
        EcoLine: Record "MFG ECO Line";
    begin
        if not (EcoHeader.Status in [EcoHeader.Status::MFGOpen, EcoHeader.Status::MFGRejected]) then
            Error(CannotDeleteErr, EcoHeader."No.", EcoHeader.Status);

        EcoLine.SetRange("ECO No.", EcoHeader."No.");
        EcoLine.DeleteAll(true);
    end;
}
