namespace ManufacturingAdvanced.Test;

using ManufacturingAdvanced.WIPControl;
using Microsoft.Manufacturing.Document;

codeunit 89021 "MFG Test GL WIP Source" implements "MFG IGLWipSource"
{
    var
        GLWip: Decimal;
        Unposted: Decimal;

    procedure SetAmounts(NewGLWip: Decimal; NewUnposted: Decimal)
    begin
        GLWip := NewGLWip;
        Unposted := NewUnposted;
    end;

    procedure GLWipAmount(ProductionOrder: Record "Production Order"): Decimal
    begin
        exit(GLWip);
    end;

    procedure UnpostedCost(ProductionOrder: Record "Production Order"): Decimal
    begin
        exit(Unposted);
    end;
}
