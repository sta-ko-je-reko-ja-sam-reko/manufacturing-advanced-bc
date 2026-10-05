namespace ManufacturingAdvanced.EngineeringChange;

page 85802 "MFG ECO Card"
{
    PageType = Document;
    ApplicationArea = MFGEngineeringChange;
    UsageCategory = None;
    SourceTable = "MFG ECO Header";
    Caption = 'Engineering change order';

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                Editable = IsOpen;

                field("No."; Rec."No.")
                {
                    Editable = false;
                }
                field(Description; Rec.Description)
                {
                }
                field(Reason; Rec.Reason)
                {
                    MultiLine = true;
                }
                field("Effective Date"; Rec."Effective Date")
                {
                }
                field(Status; Rec.Status)
                {
                }
            }
            part(EcoLines; "MFG ECO Subform")
            {
                Caption = 'Lines';
                SubPageLink = "ECO No." = field("No.");
                Editable = IsOpen;
                UpdatePropagation = Both;
            }
            group(Approval)
            {
                Caption = 'Approval';

                field("Requested By"; Rec."Requested By")
                {
                }
                field("Requested At"; Rec."Requested At")
                {
                }
                field("Approved By"; Rec."Approved By")
                {
                }
                field("Approved At"; Rec."Approved At")
                {
                }
                field("Implemented At"; Rec."Implemented At")
                {
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(CreateVersions)
            {
                Caption = 'Create versions';
                ToolTip = 'Create, for each line, the new version of the BOM or routing as a copy of the version in use, under development, ready to be edited.';
                Image = CopyBOM;

                trigger OnAction()
                var
                    Engine: Codeunit "MFG ECO Engine";
                begin
                    Engine.CreateVersions(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(Submit)
            {
                Caption = 'Send for approval';
                ToolTip = 'Send the change for approval. Every line needs its new version, and the effective date must be set.';
                Image = SendApprovalRequest;

                trigger OnAction()
                var
                    Engine: Codeunit "MFG ECO Engine";
                begin
                    Engine.SubmitForApproval(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(Approve)
            {
                Caption = 'Approve';
                ToolTip = 'Approve the change.';
                Image = Approve;

                trigger OnAction()
                var
                    Engine: Codeunit "MFG ECO Engine";
                begin
                    Engine.Approve(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(Reject)
            {
                Caption = 'Reject';
                ToolTip = 'Reject the change.';
                Image = Reject;

                trigger OnAction()
                var
                    Engine: Codeunit "MFG ECO Engine";
                begin
                    Engine.Reject(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(Reopen)
            {
                Caption = 'Reopen';
                ToolTip = 'Put a pending or rejected change back to open, so it can be edited.';
                Image = ReOpen;

                trigger OnAction()
                var
                    Engine: Codeunit "MFG ECO Engine";
                begin
                    Engine.Reopen(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(Implement)
            {
                Caption = 'Implement';
                ToolTip = 'Certify every new version, starting on the effective date. Production orders refreshed from that date on use them.';
                Image = ReleaseDoc;

                trigger OnAction()
                var
                    Engine: Codeunit "MFG ECO Engine";
                begin
                    if not Confirm(ImplementQst, false, Rec."No.", Rec."Effective Date") then
                        exit;
                    Engine.Implement(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(Impact)
            {
                Caption = 'Impact';
                ToolTip = 'See the open production orders that use the BOMs and routings this change touches.';
                Image = Track;

                trigger OnAction()
                var
                    TempImpact: Record "MFG ECO Impact" temporary;
                    Engine: Codeunit "MFG ECO Engine";
                begin
                    Engine.GetImpact(Rec, TempImpact);
                    Page.Run(Page::"MFG ECO Impact", TempImpact);
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                actionref(CreateVersionsRef; CreateVersions)
                {
                }
                actionref(SubmitRef; Submit)
                {
                }
                actionref(ImpactRef; Impact)
                {
                }
            }
            group(Category_Approve)
            {
                Caption = 'Approve';

                actionref(ApproveRef; Approve)
                {
                }
                actionref(RejectRef; Reject)
                {
                }
                actionref(ReopenRef; Reopen)
                {
                }
                actionref(ImplementRef; Implement)
                {
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        IsOpen := Rec.Status = Rec.Status::MFGOpen;
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        IsOpen := true;
    end;

    var
        IsOpen: Boolean;
        ImplementQst: Label 'Certify the new versions of engineering change %1, starting on %2?', Comment = '%1 = the change number, %2 = the effective date';
}
