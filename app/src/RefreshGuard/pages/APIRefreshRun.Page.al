namespace ManufacturingAdvanced.RefreshGuard;

page 85403 "MFG API Refresh Run"
{
    PageType = API;
    APIPublisher = 'matr';
    APIGroup = 'mfgRefreshGuard';
    APIVersion = 'v1.0';
    EntityName = 'refreshRun';
    EntitySetName = 'refreshRuns';
    EntityCaption = 'Refresh run';
    EntitySetCaption = 'Refresh runs';
    SourceTable = "MFG Refresh Run";
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
                field(runNo; Rec."Run No.")
                {
                    Caption = 'Run no.';
                }
                field(prodOrderStatus; Rec."Prod. Order Status")
                {
                    Caption = 'Prod. order status';
                }
                field(prodOrderNo; Rec."Prod. Order No.")
                {
                    Caption = 'Prod. order no.';
                }
                field(refreshedAt; Rec."Refreshed At")
                {
                    Caption = 'Refreshed at';
                }
                field(refreshedBy; Rec."Refreshed By")
                {
                    Caption = 'Refreshed by';
                }
                field(source; Rec.Source)
                {
                    Caption = 'Source';
                }
                field(changes; Rec.Changes)
                {
                    Caption = 'Changes';
                }
                field(openChanges; Rec."Open Changes")
                {
                    Caption = 'Open changes';
                }
            }
        }
    }
}
