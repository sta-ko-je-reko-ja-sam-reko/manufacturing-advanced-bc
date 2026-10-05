namespace ManufacturingAdvanced.Preflight;

using ManufacturingAdvanced.Core;
using Microsoft.Manufacturing.Document;

page 85105 "MFG API Preflight Order"
{
    PageType = API;
    APIPublisher = 'matr';
    APIGroup = 'mfgPreflight';
    APIVersion = 'v1.0';
    EntityName = 'preflightOrder';
    EntitySetName = 'preflightOrders';
    EntityCaption = 'Production order to check';
    EntitySetCaption = 'Production orders to check';
    SourceTable = "Production Order";
    SourceTableView = where(Status = filter(Planned | "Firm Planned" | Released));
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
                field(status; Rec.Status)
                {
                    Caption = 'Status';
                }
                field(number; Rec."No.")
                {
                    Caption = 'No.';
                }
                field(description; Rec.Description)
                {
                    Caption = 'Description';
                }
                field(sourceType; Rec."Source Type")
                {
                    Caption = 'Source type';
                }
                field(sourceNo; Rec."Source No.")
                {
                    Caption = 'Source no.';
                }
                field(quantity; Rec.Quantity)
                {
                    Caption = 'Quantity';
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
    /// Runs the pre-flight checks on this production order and stores the findings, which can then be
    /// read from preflightFindings. Changes nothing on the order itself.
    /// </summary>
    /// <param name="ActionContext">The OData action context.</param>
    [ServiceEnabled]
    procedure RunPreflight(var ActionContext: WebServiceActionContext)
    var
        TempFinding: Record "MFG Preflight Finding" temporary;
        FeatureMgt: Codeunit "MFG Feature Mgt.";
        Engine: Codeunit "MFG Preflight Engine";
    begin
        FeatureMgt.CheckEnabled(Enum::"MFG Feature"::MFGPreflight);
        Engine.RunAndStore(Rec, TempFinding);

        ActionContext.SetObjectType(ObjectType::Page);
        ActionContext.SetObjectId(Page::"MFG API Preflight Order");
        ActionContext.AddEntityKey(Rec.FieldNo(SystemId), Rec.SystemId);
        ActionContext.SetResultCode(WebServiceActionResultCode::Get);
    end;
}
