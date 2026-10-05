namespace ManufacturingAdvanced.WIPControl;

using ManufacturingAdvanced.Core;

page 85206 "MFG API Demo WIP"
{
    PageType = API;
    APIPublisher = 'matr';
    APIGroup = 'demoWip';
    APIVersion = 'v1.0';
    EntityName = 'demoWip';
    EntitySetName = 'demoWipSet';
    EntityCaption = 'Demo WIP control';
    EntitySetCaption = 'Demo WIP control';
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
    /// Seeds the WIP control sample data and builds its configuration package. Idempotent. Posts nothing and
    /// does not switch the feature on.
    /// </summary>
    /// <param name="ActionContext">The OData action context.</param>
    [ServiceEnabled]
    procedure ImportDemoData(var ActionContext: WebServiceActionContext)
    var
        DemoWip: Codeunit "MFG Demo WIP";
    begin
        DemoWip.Import();

        ActionContext.SetObjectType(ObjectType::Page);
        ActionContext.SetObjectId(Page::"MFG API Demo WIP");
        ActionContext.AddEntityKey(Rec.FieldNo(SystemId), Rec.SystemId);
        ActionContext.SetResultCode(WebServiceActionResultCode::None);
    end;
}
