namespace ManufacturingAdvanced.ShopFloor;

using ManufacturingAdvanced.Core;

page 85609 "MFG API Demo Shop Floor"
{
    PageType = API;
    APIPublisher = 'matr';
    APIGroup = 'demoShopFloor';
    APIVersion = 'v1.0';
    EntityName = 'demoShopFloor';
    EntitySetName = 'demoShopFloorSet';
    EntityCaption = 'Demo shop floor terminal';
    EntitySetCaption = 'Demo shop floor terminal';
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
    /// Seeds the shop floor terminal sample data and builds its configuration package. Idempotent. Posts nothing
    /// and does not switch the feature on.
    /// </summary>
    /// <param name="ActionContext">The OData action context.</param>
    [ServiceEnabled]
    procedure ImportDemoData(var ActionContext: WebServiceActionContext)
    var
        DemoShopFloor: Codeunit "MFG Demo Shop Floor";
    begin
        DemoShopFloor.Import();

        ActionContext.SetObjectType(ObjectType::Page);
        ActionContext.SetObjectId(Page::"MFG API Demo Shop Floor");
        ActionContext.AddEntityKey(Rec.FieldNo(SystemId), Rec.SystemId);
        ActionContext.SetResultCode(WebServiceActionResultCode::None);
    end;
}
