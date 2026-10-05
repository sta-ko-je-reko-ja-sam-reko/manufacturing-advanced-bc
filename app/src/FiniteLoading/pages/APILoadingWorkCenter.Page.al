namespace ManufacturingAdvanced.FiniteLoading;

using Microsoft.Manufacturing.WorkCenter;

page 85703 "MFG API Loading Work Center"
{
    PageType = API;
    APIPublisher = 'matr';
    APIGroup = 'mfgLoading';
    APIVersion = 'v1.0';
    EntityName = 'loadingWorkCenter';
    EntitySetName = 'loadingWorkCenters';
    EntityCaption = 'Work center';
    EntitySetCaption = 'Work centers';
    SourceTable = "Work Center";
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
                field(number; Rec."No.")
                {
                    Caption = 'No.';
                }
                field(name; Rec.Name)
                {
                    Caption = 'Name';
                }
                field(capacity; Rec.Capacity)
                {
                    Caption = 'Capacity';
                }
                field(efficiency; Rec.Efficiency)
                {
                    Caption = 'Efficiency';
                }
                field(unitOfMeasureCode; Rec."Unit of Measure Code")
                {
                    Caption = 'Unit of measure code';
                }
            }
        }
    }

    /// <summary>
    /// Builds this work center's finite load plan, which can then be read from loadPlanLines. Changes no production
    /// order.
    /// </summary>
    /// <param name="ActionContext">The OData action context.</param>
    [ServiceEnabled]
    procedure CalculateLoad(var ActionContext: WebServiceActionContext)
    var
        Engine: Codeunit "MFG Loading Engine";
    begin
        Engine.Calculate(Rec."No.");

        ActionContext.SetObjectType(ObjectType::Page);
        ActionContext.SetObjectId(Page::"MFG API Loading Work Center");
        ActionContext.AddEntityKey(Rec.FieldNo(SystemId), Rec.SystemId);
        ActionContext.SetResultCode(WebServiceActionResultCode::Get);
    end;

    /// <summary>
    /// Applies this work center's calculated load plan to the production orders: every operation that fits the
    /// horizon is moved to its planned starting date. Refused unless the setup allows it.
    /// </summary>
    /// <param name="ActionContext">The OData action context.</param>
    [ServiceEnabled]
    procedure ApplyLoadPlan(var ActionContext: WebServiceActionContext)
    var
        Engine: Codeunit "MFG Loading Engine";
    begin
        Engine.ApplyPlan(Rec."No.");

        ActionContext.SetObjectType(ObjectType::Page);
        ActionContext.SetObjectId(Page::"MFG API Loading Work Center");
        ActionContext.AddEntityKey(Rec.FieldNo(SystemId), Rec.SystemId);
        ActionContext.SetResultCode(WebServiceActionResultCode::Get);
    end;
}
