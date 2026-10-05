namespace ManufacturingAdvanced.WIPControl;

page 85203 "MFG API Finish Proposal"
{
    PageType = API;
    APIPublisher = 'matr';
    APIGroup = 'mfgWip';
    APIVersion = 'v1.0';
    EntityName = 'finishProposal';
    EntitySetName = 'finishProposals';
    EntityCaption = 'Finish proposal';
    EntitySetCaption = 'Finish proposals';
    SourceTable = "MFG Finish Proposal";
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
                field(prodOrderNo; Rec."Prod. Order No.")
                {
                    Caption = 'Prod. order no.';
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
                field(finishedQuantity; Rec."Finished Quantity")
                {
                    Caption = 'Finished quantity';
                }
                field(lastOutputDate; Rec."Last Output Date")
                {
                    Caption = 'Last output date';
                }
                field(daysSinceOutput; Rec."Days Since Output")
                {
                    Caption = 'Days since output';
                }
                field(consumptionCost; Rec."Consumption Cost")
                {
                    Caption = 'Consumption cost';
                }
                field(capacityCost; Rec."Capacity Cost")
                {
                    Caption = 'Capacity cost';
                }
                field(outputCost; Rec."Output Cost")
                {
                    Caption = 'Output cost';
                }
                field(estWipAmount; Rec."Est. WIP Amount")
                {
                    Caption = 'Est. WIP amount';
                }
                field(status; Rec.Status)
                {
                    Caption = 'Status';
                }
                field(notes; Rec.Notes)
                {
                    Caption = 'Notes';
                }
                field(suggestedAt; Rec."Suggested At")
                {
                    Caption = 'Suggested at';
                }
            }
        }
    }
}
