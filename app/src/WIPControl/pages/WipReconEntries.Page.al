namespace ManufacturingAdvanced.WIPControl;

page 85209 "MFG WIP Recon. Entries"
{
    PageType = List;
    ApplicationArea = MFGWIPControl;
    UsageCategory = History;
    SourceTable = "MFG WIP Recon. Entry";
    SourceTableView = sorting("Reconciled On") order(descending);
    Caption = 'WIP reconciliation history';
    Editable = false;
    AdditionalSearchTerms = 'WIP history, WIP account trend';

    layout
    {
        area(Content)
        {
            repeater(Entries)
            {
                field("Reconciled On"; Rec."Reconciled On")
                {
                }
                field("Prod. Order Status"; Rec."Prod. Order Status")
                {
                }
                field("Prod. Order No."; Rec."Prod. Order No.")
                {
                }
                field("Source No."; Rec."Source No.")
                {
                }
                field("Value WIP"; Rec."Value WIP")
                {
                }
                field("G/L WIP"; Rec."G/L WIP")
                {
                }
                field(Difference; Rec.Difference)
                {
                }
                field("Unposted Cost"; Rec."Unposted Cost")
                {
                }
                field(Status; Rec.Status)
                {
                }
                field("Reconciled At"; Rec."Reconciled At")
                {
                }
            }
        }
    }
}
