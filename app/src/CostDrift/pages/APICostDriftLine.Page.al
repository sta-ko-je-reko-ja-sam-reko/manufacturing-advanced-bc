namespace ManufacturingAdvanced.CostDrift;

page 85304 "MFG API Cost Drift Line"
{
    PageType = API;
    APIPublisher = 'matr';
    APIGroup = 'mfgCostDrift';
    APIVersion = 'v1.0';
    EntityName = 'costDriftLine';
    EntitySetName = 'costDriftLines';
    EntityCaption = 'Cost drift line';
    EntitySetCaption = 'Cost drift lines';
    SourceTable = "MFG Cost Drift Line";
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
                field(itemNo; Rec."Item No.")
                {
                    Caption = 'Item no.';
                }
                field(description; Rec.Description)
                {
                    Caption = 'Description';
                }
                field(source; Rec.Source)
                {
                    Caption = 'Source';
                }
                field(replenishmentSystem; Rec."Replenishment System")
                {
                    Caption = 'Replenishment system';
                }
                field(currentStandardCost; Rec."Current Standard Cost")
                {
                    Caption = 'Current standard cost';
                }
                field(proposedStandardCost; Rec."Proposed Standard Cost")
                {
                    Caption = 'Proposed standard cost';
                }
                field(driftAmount; Rec."Drift Amount")
                {
                    Caption = 'Drift amount';
                }
                field(driftPercent; Rec."Drift %")
                {
                    Caption = 'Drift %';
                }
                field(lastUnitCostCalcDate; Rec."Last Unit Cost Calc. Date")
                {
                    Caption = 'Last cost calculation';
                }
                field(transferred; Rec.Transferred)
                {
                    Caption = 'Sent to worksheet';
                }
                field(calculatedAt; Rec."Calculated At")
                {
                    Caption = 'Calculated at';
                }
            }
        }
    }

    /// <summary>
    /// Sends this drift line to the standard cost worksheet named in the setup. Changes no item cost: the
    /// worksheet still has to be implemented. Refused while the feature is off.
    /// </summary>
    /// <param name="ActionContext">The OData action context.</param>
    [ServiceEnabled]
    procedure SendToWorksheet(var ActionContext: WebServiceActionContext)
    var
        Engine: Codeunit "MFG Cost Drift Engine";
    begin
        Engine.TransferLine(Rec);

        ActionContext.SetObjectType(ObjectType::Page);
        ActionContext.SetObjectId(Page::"MFG API Cost Drift Line");
        ActionContext.AddEntityKey(Rec.FieldNo(SystemId), Rec.SystemId);
        ActionContext.SetResultCode(WebServiceActionResultCode::Get);
    end;
}
