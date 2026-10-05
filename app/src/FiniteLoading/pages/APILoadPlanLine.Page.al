namespace ManufacturingAdvanced.FiniteLoading;

page 85702 "MFG API Load Plan Line"
{
    PageType = API;
    APIPublisher = 'matr';
    APIGroup = 'mfgLoading';
    APIVersion = 'v1.0';
    EntityName = 'loadPlanLine';
    EntitySetName = 'loadPlanLines';
    EntityCaption = 'Load plan line';
    EntitySetCaption = 'Load plan lines';
    SourceTable = "MFG Load Plan Line";
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
                field(workCenterNo; Rec."Work Center No.")
                {
                    Caption = 'Work center no.';
                }
                field(sequenceNo; Rec."Sequence No.")
                {
                    Caption = 'Sequence';
                }
                field(prodOrderStatus; Rec."Prod. Order Status")
                {
                    Caption = 'Prod. order status';
                }
                field(prodOrderNo; Rec."Prod. Order No.")
                {
                    Caption = 'Prod. order no.';
                }
                field(operationNo; Rec."Operation No.")
                {
                    Caption = 'Operation no.';
                }
                field(description; Rec.Description)
                {
                    Caption = 'Description';
                }
                field(need; Rec.Need)
                {
                    Caption = 'Capacity need';
                }
                field(dueDate; Rec."Due Date")
                {
                    Caption = 'Due date';
                }
                field(currentStartingDate; Rec."Current Starting Date")
                {
                    Caption = 'Current starting date';
                }
                field(currentEndingDate; Rec."Current Ending Date")
                {
                    Caption = 'Current ending date';
                }
                field(plannedStartingDate; Rec."Planned Starting Date")
                {
                    Caption = 'Finite starting date';
                }
                field(plannedEndingDate; Rec."Planned Ending Date")
                {
                    Caption = 'Finite ending date';
                }
                field(fitsHorizon; Rec."Fits Horizon")
                {
                    Caption = 'Fits the horizon';
                }
                field(late; Rec.Late)
                {
                    Caption = 'Late';
                }
                field(daysLate; Rec."Days Late")
                {
                    Caption = 'Days late';
                }
                field(previousOperationNo; Rec."Previous Operation No.")
                {
                    Caption = 'Previous operation no.';
                }
                field(earliestStartDate; Rec."Earliest Start Date")
                {
                    Caption = 'Earliest start date';
                }
                field(writtenBack; Rec."Written Back")
                {
                    Caption = 'Applied to order';
                }
            }
        }
    }
}
