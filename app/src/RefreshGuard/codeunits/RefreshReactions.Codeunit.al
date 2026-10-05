namespace ManufacturingAdvanced.RefreshGuard;

using ManufacturingAdvanced.Core;
using Microsoft.Manufacturing.Document;

codeunit 85403 "MFG Refresh Reactions" implements "MFG IRefreshReactions"
{
    Access = Public;

    /// <summary>
    /// Takes the snapshot of an order about to be refreshed. Does nothing while the feature is off.
    /// </summary>
    /// <param name="ProductionOrder">The order.</param>
    procedure OnBeforeRefresh(var ProductionOrder: Record "Production Order")
    var
        FeatureMgt: Codeunit "MFG Feature Mgt.";
        Engine: Codeunit "MFG Refresh Engine";
        Session: Codeunit "MFG Refresh Session";
    begin
        if not FeatureMgt.IsEnabled(Enum::"MFG Feature"::MFGRefreshGuard) then
            exit;

        Session.Remember(ProductionOrder, Engine.BeginRun(ProductionOrder));
    end;

    /// <summary>
    /// Compares the refreshed order with its snapshot and, when the refresh changed something and the setup
    /// asks for it, tells the user. Does nothing while the feature is off or when no snapshot was taken.
    /// </summary>
    /// <param name="ProductionOrder">The order.</param>
    procedure OnAfterRefresh(var ProductionOrder: Record "Production Order")
    var
        Setup: Record "MFG Refresh Setup";
        FeatureMgt: Codeunit "MFG Feature Mgt.";
        Engine: Codeunit "MFG Refresh Engine";
        Session: Codeunit "MFG Refresh Session";
        RefreshNotification: Codeunit "MFG Refresh Notification";
        RunNo: Integer;
        ChangeCount: Integer;
    begin
        if not FeatureMgt.IsEnabled(Enum::"MFG Feature"::MFGRefreshGuard) then
            exit;
        if not Session.Take(ProductionOrder, RunNo) then
            exit;

        ChangeCount := Engine.CompleteRun(ProductionOrder, RunNo);
        if ChangeCount = 0 then
            exit;

        Setup.SetLoadFields("Notify on Changes");
        if Setup.Get() then
            if Setup."Notify on Changes" and GuiAllowed() then
                RefreshNotification.Send(ProductionOrder, RunNo, ChangeCount);
    end;
}
