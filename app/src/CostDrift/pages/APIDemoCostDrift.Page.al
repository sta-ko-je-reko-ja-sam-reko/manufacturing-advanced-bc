namespace ManufacturingAdvanced.CostDrift;

using ManufacturingAdvanced.Core;

page 85307 "MFG API Demo Cost Drift"
{
    PageType = API;
    APIPublisher = 'matr';
    APIGroup = 'demoCostDrift';
    APIVersion = 'v1.0';
    EntityName = 'demoCostDrift';
    EntitySetName = 'demoCostDriftSet';
    EntityCaption = 'Demo standard cost drift';
    EntitySetCaption = 'Demo standard cost drift';
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
    /// Seeds the standard cost drift sample data and builds its configuration package. Idempotent. Changes no
    /// item cost, posts nothing and does not switch the feature on.
    /// </summary>
    /// <param name="ActionContext">The OData action context.</param>
    [ServiceEnabled]
    procedure ImportDemoData(var ActionContext: WebServiceActionContext)
    var
        DemoCostDrift: Codeunit "MFG Demo Cost Drift";
    begin
        DemoCostDrift.Import();

        ActionContext.SetObjectType(ObjectType::Page);
        ActionContext.SetObjectId(Page::"MFG API Demo Cost Drift");
        ActionContext.AddEntityKey(Rec.FieldNo(SystemId), Rec.SystemId);
        ActionContext.SetResultCode(WebServiceActionResultCode::None);
    end;
}
