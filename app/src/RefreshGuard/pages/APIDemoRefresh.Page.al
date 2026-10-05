namespace ManufacturingAdvanced.RefreshGuard;

using ManufacturingAdvanced.Core;

page 85405 "MFG API Demo Refresh"
{
    PageType = API;
    APIPublisher = 'matr';
    APIGroup = 'demoRefreshGuard';
    APIVersion = 'v1.0';
    EntityName = 'demoRefreshGuard';
    EntitySetName = 'demoRefreshGuardSet';
    EntityCaption = 'Demo refresh protection';
    EntitySetCaption = 'Demo refresh protection';
    SourceTable = "MFG Demo Data";
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
                field(code; Rec.Code)
                {
                    Caption = 'Code';
                }
            }
        }
    }

    /// <summary>
    /// Seeds the refresh protection sample data and builds its configuration package. Idempotent. Does not
    /// switch the feature on.
    /// </summary>
    /// <param name="ActionContext">The OData action context.</param>
    [ServiceEnabled]
    procedure ImportDemoData(var ActionContext: WebServiceActionContext)
    var
        DemoRefresh: Codeunit "MFG Demo Refresh";
    begin
        DemoRefresh.Import();

        ActionContext.SetObjectType(ObjectType::Page);
        ActionContext.SetObjectId(Page::"MFG API Demo Refresh");
        ActionContext.AddEntityKey(Rec.FieldNo(SystemId), Rec.SystemId);
        ActionContext.SetResultCode(WebServiceActionResultCode::None);
    end;
}
