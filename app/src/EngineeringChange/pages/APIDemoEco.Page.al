namespace ManufacturingAdvanced.EngineeringChange;

using ManufacturingAdvanced.Core;

page 85807 "MFG API Demo ECO"
{
    PageType = API;
    APIPublisher = 'matr';
    APIGroup = 'demoEco';
    APIVersion = 'v1.0';
    EntityName = 'demoEco';
    EntitySetName = 'demoEcoSet';
    EntityCaption = 'Demo engineering change';
    EntitySetCaption = 'Demo engineering change';
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
    /// Seeds the engineering change sample data and builds its configuration package. Idempotent. Certifies
    /// nothing and does not switch the feature on.
    /// </summary>
    /// <param name="ActionContext">The OData action context.</param>
    [ServiceEnabled]
    procedure ImportDemoData(var ActionContext: WebServiceActionContext)
    var
        DemoEco: Codeunit "MFG Demo ECO";
    begin
        DemoEco.Import();

        ActionContext.SetObjectType(ObjectType::Page);
        ActionContext.SetObjectId(Page::"MFG API Demo ECO");
        ActionContext.AddEntityKey(Rec.FieldNo(SystemId), Rec.SystemId);
        ActionContext.SetResultCode(WebServiceActionResultCode::None);
    end;
}
