namespace ManufacturingAdvanced.PlanningInsight;

using ManufacturingAdvanced.Core;

page 85508 "MFG API Demo Planning"
{
    PageType = API;
    APIPublisher = 'matr';
    APIGroup = 'demoPlanning';
    APIVersion = 'v1.0';
    EntityName = 'demoPlanning';
    EntitySetName = 'demoPlanningSet';
    EntityCaption = 'Demo planning insight';
    EntitySetCaption = 'Demo planning insight';
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
    /// Seeds the planning insight sample data and builds its configuration package. Records the action messages
    /// already on the company's planning worksheets and analyses them. Does not run planning and does not switch
    /// the feature on.
    /// </summary>
    /// <param name="ActionContext">The OData action context.</param>
    [ServiceEnabled]
    procedure ImportDemoData(var ActionContext: WebServiceActionContext)
    var
        DemoPlanning: Codeunit "MFG Demo Planning";
    begin
        DemoPlanning.Import();

        ActionContext.SetObjectType(ObjectType::Page);
        ActionContext.SetObjectId(Page::"MFG API Demo Planning");
        ActionContext.AddEntityKey(Rec.FieldNo(SystemId), Rec.SystemId);
        ActionContext.SetResultCode(WebServiceActionResultCode::None);
    end;
}
