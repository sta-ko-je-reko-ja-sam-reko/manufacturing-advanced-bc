namespace ManufacturingAdvanced.EngineeringChange;

using ManufacturingAdvanced.Core;

page 85805 "MFG API ECO"
{
    PageType = API;
    APIPublisher = 'matr';
    APIGroup = 'mfgEco';
    APIVersion = 'v1.0';
    EntityName = 'engineeringChange';
    EntitySetName = 'engineeringChanges';
    EntityCaption = 'Engineering change order';
    EntitySetCaption = 'Engineering change orders';
    SourceTable = "MFG ECO Header";
    Extensible = false;
    DelayedInsert = true;
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
                    Editable = false;
                }
                field(number; Rec."No.")
                {
                    Caption = 'No.';
                    Editable = false;
                }
                field(description; Rec.Description)
                {
                    Caption = 'Description';
                }
                field(reason; Rec.Reason)
                {
                    Caption = 'Reason';
                }
                field(effectiveDate; Rec."Effective Date")
                {
                    Caption = 'Effective date';
                }
                field(status; Rec.Status)
                {
                    Caption = 'Status';
                    Editable = false;
                }
                field(requestedBy; Rec."Requested By")
                {
                    Caption = 'Requested by';
                    Editable = false;
                }
                field(approvedBy; Rec."Approved By")
                {
                    Caption = 'Approved by';
                    Editable = false;
                }
            }
        }
    }

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        FeatureMgt: Codeunit "MFG Feature Mgt.";
    begin
        FeatureMgt.CheckEnabled(Enum::"MFG Feature"::MFGEngineeringChange);
        exit(true);
    end;

    trigger OnModifyRecord(): Boolean
    var
        FeatureMgt: Codeunit "MFG Feature Mgt.";
    begin
        FeatureMgt.CheckEnabled(Enum::"MFG Feature"::MFGEngineeringChange);
        exit(true);
    end;

    /// <summary>
    /// Creates the new BOM and routing versions of this change, under development. The change must be open.
    /// </summary>
    /// <param name="ActionContext">The OData action context.</param>
    [ServiceEnabled]
    procedure CreateVersions(var ActionContext: WebServiceActionContext)
    var
        Engine: Codeunit "MFG ECO Engine";
    begin
        Engine.CreateVersions(Rec);
        SetResult(ActionContext);
    end;

    /// <summary>
    /// Sends this change for approval. Approval and implementation are done by people in Business Central, not
    /// through the API.
    /// </summary>
    /// <param name="ActionContext">The OData action context.</param>
    [ServiceEnabled]
    procedure SubmitForApproval(var ActionContext: WebServiceActionContext)
    var
        Engine: Codeunit "MFG ECO Engine";
    begin
        Engine.SubmitForApproval(Rec);
        SetResult(ActionContext);
    end;

    local procedure SetResult(var ActionContext: WebServiceActionContext)
    begin
        ActionContext.SetObjectType(ObjectType::Page);
        ActionContext.SetObjectId(Page::"MFG API ECO");
        ActionContext.AddEntityKey(Rec.FieldNo(SystemId), Rec.SystemId);
        ActionContext.SetResultCode(WebServiceActionResultCode::Get);
    end;
}
