namespace ManufacturingAdvanced.Test;

using ManufacturingAdvanced.ShopFloor;

codeunit 89014 "MFG Test Shop Floor Posting" implements "MFG IShopFloorPosting"
{
    SingleInstance = true;

    var
        TempPosted: Record "MFG Shop Floor Event" temporary;

    procedure Post(ShopFloorEvent: Record "MFG Shop Floor Event")
    begin
        TempPosted := ShopFloorEvent;
        TempPosted."Entry No." := TempPosted.Count() + 1;
        TempPosted.Insert();
    end;

    procedure Reset()
    begin
        TempPosted.Reset();
        TempPosted.DeleteAll();
    end;

    procedure PostedCount(): Integer
    begin
        TempPosted.Reset();
        exit(TempPosted.Count());
    end;

    procedure LastPosted(var ShopFloorEvent: Record "MFG Shop Floor Event")
    begin
        TempPosted.Reset();
        TempPosted.FindLast();
        ShopFloorEvent := TempPosted;
    end;
}
