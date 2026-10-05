namespace ManufacturingAdvanced.WIPControl;

using ManufacturingAdvanced.Core;
using Microsoft.Manufacturing.Document;

page 85205 "MFG API WIP Order"
{
    PageType = API;
    APIPublisher = 'matr';
    APIGroup = 'mfgWip';
    APIVersion = 'v1.0';
    EntityName = 'wipOrder';
    EntitySetName = 'wipOrders';
    EntityCaption = 'Released production order';
    EntitySetCaption = 'Released production orders';
    SourceTable = "Production Order";
    SourceTableView = where(Status = const(Released));
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
                field(description; Rec.Description)
                {
                    Caption = 'Description';
                }
                field(sourceNo; Rec."Source No.")
                {
                    Caption = 'Source no.';
                }
                field(quantity; Rec.Quantity)
                {
                    Caption = 'Quantity';
                }
                field(startingDate; Rec."Starting Date")
                {
                    Caption = 'Starting date';
                }
                field(dueDate; Rec."Due Date")
                {
                    Caption = 'Due date';
                }
                field(locationCode; Rec."Location Code")
                {
                    Caption = 'Location code';
                }
            }
        }
    }

    /// <summary>
    /// Values this order's work in progress and runs the checks before finishing, creating or refreshing its
    /// finish proposal, which can then be read from finishProposals. Removes the proposal when the order's
    /// output is not complete. Changes nothing on the order.
    /// </summary>
    /// <param name="ActionContext">The OData action context.</param>
    [ServiceEnabled]
    procedure EvaluateFinish(var ActionContext: WebServiceActionContext)
    var
        FeatureMgt: Codeunit "MFG Feature Mgt.";
        Engine: Codeunit "MFG WIP Engine";
    begin
        FeatureMgt.CheckEnabled(Enum::"MFG Feature"::MFGWipControl);
        Engine.EvaluateOrder(Rec);
        SetResult(ActionContext);
    end;

    /// <summary>
    /// Finishes this order through the standard status change, after re-running the checks. Refused when the
    /// order's output is not complete or a blocking check finds something.
    /// </summary>
    /// <param name="ActionContext">The OData action context.</param>
    [ServiceEnabled]
    procedure FinishOrder(var ActionContext: WebServiceActionContext)
    var
        FeatureMgt: Codeunit "MFG Feature Mgt.";
        Engine: Codeunit "MFG WIP Engine";
    begin
        FeatureMgt.CheckEnabled(Enum::"MFG Feature"::MFGWipControl);
        Engine.FinishOrder(Rec);
        SetResult(ActionContext);
    end;

    /// <summary>
    /// Compares this order's WIP in the value entries with the WIP accounts in the general ledger and stores the
    /// result among the WIP reconciliation lines. Changes nothing on the order.
    /// </summary>
    /// <param name="ActionContext">The OData action context.</param>
    [ServiceEnabled]
    procedure ReconcileWip(var ActionContext: WebServiceActionContext)
    var
        FeatureMgt: Codeunit "MFG Feature Mgt.";
        Engine: Codeunit "MFG WIP Engine";
    begin
        FeatureMgt.CheckEnabled(Enum::"MFG Feature"::MFGWipControl);
        Engine.ReconcileOrder(Rec);
        SetResult(ActionContext);
    end;

    local procedure SetResult(var ActionContext: WebServiceActionContext)
    begin
        ActionContext.SetObjectType(ObjectType::Page);
        ActionContext.SetObjectId(Page::"MFG API WIP Order");
        ActionContext.AddEntityKey(Rec.FieldNo(SystemId), Rec.SystemId);
        ActionContext.SetResultCode(WebServiceActionResultCode::None);
    end;
}
