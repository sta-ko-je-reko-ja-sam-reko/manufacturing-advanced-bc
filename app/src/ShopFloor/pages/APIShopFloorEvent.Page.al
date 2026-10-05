namespace ManufacturingAdvanced.ShopFloor;

page 85607 "MFG API Shop Floor Event"
{
    PageType = API;
    APIPublisher = 'matr';
    APIGroup = 'mfgShopFloor';
    APIVersion = 'v1.0';
    EntityName = 'shopFloorEvent';
    EntitySetName = 'shopFloorEvents';
    EntityCaption = 'Shop floor event';
    EntitySetCaption = 'Shop floor events';
    SourceTable = "MFG Shop Floor Event";
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
                field(eventType; Rec."Event Type")
                {
                    Caption = 'Event type';
                }
                field(prodOrderNo; Rec."Prod. Order No.")
                {
                    Caption = 'Prod. order no.';
                }
                field(prodOrderLineNo; Rec."Prod. Order Line No.")
                {
                    Caption = 'Prod. order line no.';
                }
                field(operationNo; Rec."Operation No.")
                {
                    Caption = 'Operation no.';
                }
                field(itemNo; Rec."Item No.")
                {
                    Caption = 'Item no.';
                }
                field(outputQuantity; Rec."Output Quantity")
                {
                    Caption = 'Output quantity';
                }
                field(scrapQuantity; Rec."Scrap Quantity")
                {
                    Caption = 'Scrap quantity';
                }
                field(scrapCode; Rec."Scrap Code")
                {
                    Caption = 'Scrap code';
                }
                field(runMinutes; Rec."Run Minutes")
                {
                    Caption = 'Run minutes';
                }
                field(stopMinutes; Rec."Stop Minutes")
                {
                    Caption = 'Stop minutes';
                }
                field(stopCode; Rec."Stop Code")
                {
                    Caption = 'Stop code';
                }
                field(reportedAt; Rec."Reported At")
                {
                    Caption = 'Reported at';
                }
                field(reportedBy; Rec."Reported By")
                {
                    Caption = 'Reported by';
                }
            }
        }
    }
}
