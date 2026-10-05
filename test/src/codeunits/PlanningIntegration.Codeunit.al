namespace ManufacturingAdvanced.Test;

using ManufacturingAdvanced.PlanningInsight;
using Microsoft.Inventory.Item;
using System.TestLibraries.Utilities;

codeunit 89012 "MFG Planning Integration"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Library Assert";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryPlanning: Codeunit "Library - Planning";

    [Test]
    procedure CalculatePlanRecordsItsActionMessages()
    var
        Item: Record Item;
        PlanningMessage: Record "MFG Planning Message";
    begin
        // [GIVEN] Planning insight is on, and an item with a reorder point and no inventory
        SetFeature(true);
        LibraryInventory.CreateItem(Item);
        Item.Validate("Reordering Policy", Item."Reordering Policy"::"Fixed Reorder Qty.");
        Item.Validate("Reorder Point", 10);
        Item.Validate("Reorder Quantity", 20);
        Item.Modify(true);

        // [WHEN] Calculate Plan runs on the planning worksheet for the item
        Item.SetRange("No.", Item."No.");
        LibraryPlanning.CalcRegenPlanForPlanWksh(Item, WorkDate(), CalcDate('<+1M>', WorkDate()));

        // [THEN] Its New action message was recorded
        PlanningMessage.SetRange("Item No.", Item."No.");
        PlanningMessage.SetRange("Action Message", PlanningMessage."Action Message"::New);
        Assert.RecordIsNotEmpty(PlanningMessage);
    end;

    local procedure SetFeature(Enabled: Boolean)
    var
        Setup: Record "MFG Planning Setup";
        FeatureSetup: Codeunit "MFG Planning Feature Setup";
    begin
        FeatureSetup.EnsureSetup(Setup);
        Setup."MFG Enabled" := Enabled;
        Setup."Record After Planning" := true;
        Setup.Modify(true);
    end;
}
