namespace ManufacturingAdvanced.FiniteLoading;

using ManufacturingAdvanced.Core;

page 85704 "MFG API Demo Loading"
{
    PageType = API;
    APIPublisher = 'matr';
    APIGroup = 'demoLoading';
    APIVersion = 'v1.0';
    EntityName = 'demoLoading';
    EntitySetName = 'demoLoadingSet';
    EntityCaption = 'Demo finite loading';
    EntitySetCaption = 'Demo finite loading';
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
    /// Seeds the finite loading sample data and builds its configuration package. Changes no production order and
    /// does not switch the feature on.
    /// </summary>
    /// <param name="ActionContext">The OData action context.</param>
    [ServiceEnabled]
    procedure ImportDemoData(var ActionContext: WebServiceActionContext)
    var
        DemoLoading: Codeunit "MFG Demo Loading";
    begin
        DemoLoading.Import();

        ActionContext.SetObjectType(ObjectType::Page);
        ActionContext.SetObjectId(Page::"MFG API Demo Loading");
        ActionContext.AddEntityKey(Rec.FieldNo(SystemId), Rec.SystemId);
        ActionContext.SetResultCode(WebServiceActionResultCode::None);
    end;
}
