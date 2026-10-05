namespace ManufacturingAdvanced.RefreshGuard;

page 85404 "MFG API Refresh Change"
{
    PageType = API;
    APIPublisher = 'matr';
    APIGroup = 'mfgRefreshGuard';
    APIVersion = 'v1.0';
    EntityName = 'refreshChange';
    EntitySetName = 'refreshChanges';
    EntityCaption = 'Refresh change';
    EntitySetCaption = 'Refresh changes';
    SourceTable = "MFG Refresh Change";
    Extensible = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Records)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'Id';
                }
                field(runNo; Rec."Run No.")
                {
                    Caption = 'Run no.';
                }
                field(entryNo; Rec."Entry No.")
                {
                    Caption = 'Entry no.';
                }
                field(prodOrderStatus; Rec."Prod. Order Status")
                {
                    Caption = 'Prod. order status';
                }
                field(prodOrderNo; Rec."Prod. Order No.")
                {
                    Caption = 'Prod. order no.';
                }
                field(kind; Rec.Kind)
                {
                    Caption = 'Kind';
                }
                field(changeType; Rec."Change Type")
                {
                    Caption = 'Change type';
                }
                field(subject; Rec.Subject)
                {
                    Caption = 'Subject';
                }
                field(fieldCaption; Rec."Field Caption")
                {
                    Caption = 'Field';
                }
                field(oldValue; Rec."Old Value")
                {
                    Caption = 'Before refresh';
                }
                field(newValue; Rec."New Value")
                {
                    Caption = 'After refresh';
                }
                field(restorable; Rec.Restorable)
                {
                    Caption = 'Restorable';
                }
                field(restored; Rec.Restored)
                {
                    Caption = 'Restored';
                }
            }
        }
    }

    /// <summary>
    /// Puts back what the refresh changed for this change: the value from before the refresh, a removed
    /// component, or the removal of an added component. Refused when the change is not restorable, is already
    /// restored, or the feature is off.
    /// </summary>
    /// <param name="ActionContext">The OData action context.</param>
    [ServiceEnabled]
    procedure Restore(var ActionContext: WebServiceActionContext)
    var
        Engine: Codeunit "MFG Refresh Engine";
    begin
        Engine.Restore(Rec);

        ActionContext.SetObjectType(ObjectType::Page);
        ActionContext.SetObjectId(Page::"MFG API Refresh Change");
        ActionContext.AddEntityKey(Rec.FieldNo(SystemId), Rec.SystemId);
        ActionContext.SetResultCode(WebServiceActionResultCode::Get);
    end;
}
