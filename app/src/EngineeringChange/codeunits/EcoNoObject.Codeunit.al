namespace ManufacturingAdvanced.EngineeringChange;

codeunit 85804 "MFG ECO No Object" implements "MFG IEcoObject"
{
    Access = Public;

    var
        ChooseTypeErr: Label 'Choose whether the line changes a production BOM or a routing first.';

    /// <summary>
    /// Refuses a number on a line without a type.
    /// </summary>
    /// <param name="EcoLine">The line.</param>
    procedure ValidateNo(var EcoLine: Record "MFG ECO Line")
    begin
        if EcoLine."No." <> '' then
            Error(ChooseTypeErr);
    end;

    /// <summary>
    /// Creates nothing.
    /// </summary>
    /// <param name="EcoLine">Ignored.</param>
    procedure CreateVersion(var EcoLine: Record "MFG ECO Line")
    begin
    end;

    /// <summary>
    /// Certifies nothing.
    /// </summary>
    /// <param name="EcoLine">Ignored.</param>
    /// <param name="EffectiveDate">Ignored.</param>
    procedure Certify(EcoLine: Record "MFG ECO Line"; EffectiveDate: Date)
    begin
    end;

    /// <summary>
    /// Finds no impact.
    /// </summary>
    /// <param name="EcoLine">Ignored.</param>
    /// <param name="TempImpact">Left untouched.</param>
    procedure CollectImpact(EcoLine: Record "MFG ECO Line"; var TempImpact: Record "MFG ECO Impact" temporary)
    begin
    end;

    /// <summary>
    /// Opens nothing.
    /// </summary>
    /// <param name="EcoLine">Ignored.</param>
    procedure OpenVersion(EcoLine: Record "MFG ECO Line")
    begin
    end;
}
