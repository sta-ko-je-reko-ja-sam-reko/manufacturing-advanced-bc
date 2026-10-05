namespace ManufacturingAdvanced.RefreshGuard;

using Microsoft.Manufacturing.Document;

codeunit 85407 "MFG Refresh Notification"
{
    Access = Public;

    var
        ChangesMsg: Label 'Refreshing production order %1 made %2 change(s) to its components or operations, including any you had entered by hand.', Comment = '%1 = the production order number, %2 = the number of changes';
        ShowChangesLbl: Label 'Show changes';
        RunNoTok: Label 'RunNo', Locked = true;

    /// <summary>
    /// Tells the user that a refresh changed the order, with an action that opens the changes.
    /// </summary>
    /// <param name="ProductionOrder">The order that was refreshed.</param>
    /// <param name="RunNo">The refresh run.</param>
    /// <param name="ChangeCount">The number of changes.</param>
    procedure Send(ProductionOrder: Record "Production Order"; RunNo: Integer; ChangeCount: Integer)
    var
        ChangesNotification: Notification;
    begin
        ChangesNotification.Id := CreateGuid();
        ChangesNotification.Message := StrSubstNo(ChangesMsg, ProductionOrder."No.", ChangeCount);
        ChangesNotification.Scope := NotificationScope::LocalScope;
        ChangesNotification.SetData(RunNoTok, Format(RunNo));
        ChangesNotification.AddAction(ShowChangesLbl, Codeunit::"MFG Refresh Notification", 'ShowChanges');
        ChangesNotification.Send();
    end;

    /// <summary>
    /// Opens the changes of the run the notification is about. Called by the notification action.
    /// </summary>
    /// <param name="ChangesNotification">The notification.</param>
    procedure ShowChanges(ChangesNotification: Notification)
    var
        Change: Record "MFG Refresh Change";
        RunNo: Integer;
    begin
        if not Evaluate(RunNo, ChangesNotification.GetData(RunNoTok)) then
            exit;
        Change.SetRange("Run No.", RunNo);
        Page.Run(Page::"MFG Refresh Changes", Change);
    end;
}
