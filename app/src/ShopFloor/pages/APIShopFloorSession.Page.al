namespace ManufacturingAdvanced.ShopFloor;

page 85608 "MFG API Shop Floor Session"
{
    PageType = API;
    APIPublisher = 'matr';
    APIGroup = 'mfgShopFloor';
    APIVersion = 'v1.0';
    EntityName = 'shopFloorSession';
    EntitySetName = 'shopFloorSessions';
    EntityCaption = 'Shop floor session';
    EntitySetCaption = 'Shop floor sessions';
    SourceTable = "MFG Shop Floor Session";
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
                field(entryNo; Rec."Entry No.")
                {
                    Caption = 'Entry no.';
                }
                field(prodOrderNo; Rec."Prod. Order No.")
                {
                    Caption = 'Prod. order no.';
                }
                field(operationNo; Rec."Operation No.")
                {
                    Caption = 'Operation no.';
                }
                field(workCenterNo; Rec."Work Center No.")
                {
                    Caption = 'Work center no.';
                }
                field(itemNo; Rec."Item No.")
                {
                    Caption = 'Item no.';
                }
                field(operator; Rec.Operator)
                {
                    Caption = 'Operator';
                }
                field(startedAt; Rec."Started At")
                {
                    Caption = 'Started at';
                }
                field(stoppedAt; Rec."Stopped At")
                {
                    Caption = 'Stopped at';
                }
                field(status; Rec.Status)
                {
                    Caption = 'Status';
                }
                field(minutes; Rec.Minutes)
                {
                    Caption = 'Minutes';
                }
                field(runTimePosted; Rec."Run Time Posted")
                {
                    Caption = 'Run time posted';
                }
            }
        }
    }
}
