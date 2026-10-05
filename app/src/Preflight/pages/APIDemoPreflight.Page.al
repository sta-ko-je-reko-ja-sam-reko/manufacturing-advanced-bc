namespace ManufacturingAdvanced.Preflight;

using ManufacturingAdvanced.Core;

page 85106 "MFG API Demo Preflight"
{
    PageType = API;
    APIPublisher = 'matr';
    APIGroup = 'demoPreflight';
    APIVersion = 'v1.0';
    EntityName = 'demoPreflight';
    EntitySetName = 'demoPreflightSet';
    EntityCaption = 'Demo release pre-flight';
    EntitySetCaption = 'Demo release pre-flight';
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
    /// Seeds the release pre-flight sample data and builds its configuration package. Idempotent. Does
    /// not switch the feature on.
    /// </summary>
    /// <param name="ActionContext">The OData action context.</param>
    [ServiceEnabled]
    procedure ImportDemoData(var ActionContext: WebServiceActionContext)
    var
        DemoPreflight: Codeunit "MFG Demo Preflight";
    begin
        DemoPreflight.Import();

        ActionContext.SetObjectType(ObjectType::Page);
        ActionContext.SetObjectId(Page::"MFG API Demo Preflight");
        ActionContext.AddEntityKey(Rec.FieldNo(SystemId), Rec.SystemId);
        ActionContext.SetResultCode(WebServiceActionResultCode::None);
    end;
}
