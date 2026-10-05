namespace ManufacturingAdvanced.EngineeringChange;

using ManufacturingAdvanced.Core;

page 85806 "MFG API ECO Line"
{
    PageType = API;
    APIPublisher = 'matr';
    APIGroup = 'mfgEco';
    APIVersion = 'v1.0';
    EntityName = 'engineeringChangeLine';
    EntitySetName = 'engineeringChangeLines';
    EntityCaption = 'Engineering change line';
    EntitySetCaption = 'Engineering change lines';
    SourceTable = "MFG ECO Line";
    Extensible = false;
    DelayedInsert = true;

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
                field(ecoNo; Rec."ECO No.")
                {
                    Caption = 'ECO no.';
                }
                field(lineNo; Rec."Line No.")
                {
                    Caption = 'Line no.';
                }
                field(objectType; Rec."Object Type")
                {
                    Caption = 'Type';
                }
                field(number; Rec."No.")
                {
                    Caption = 'No.';
                }
                field(description; Rec.Description)
                {
                    Caption = 'Description';
                    Editable = false;
                }
                field(changeDescription; Rec."Change Description")
                {
                    Caption = 'What changes';
                }
                field(newVersionCode; Rec."New Version Code")
                {
                    Caption = 'New version';
                    Editable = false;
                }
            }
        }
    }

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        CheckWritable();
        exit(true);
    end;

    trigger OnModifyRecord(): Boolean
    begin
        CheckWritable();
        exit(true);
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        CheckWritable();
        exit(true);
    end;

    var
        NotOpenErr: Label 'Engineering change %1 is not open, so its lines cannot be changed.', Comment = '%1 = the change number';

    local procedure CheckWritable()
    var
        EcoHeader: Record "MFG ECO Header";
        FeatureMgt: Codeunit "MFG Feature Mgt.";
    begin
        FeatureMgt.CheckEnabled(Enum::"MFG Feature"::MFGEngineeringChange);
        EcoHeader.SetLoadFields(Status);
        EcoHeader.Get(Rec."ECO No.");
        if EcoHeader.Status <> EcoHeader.Status::MFGOpen then
            Error(NotOpenErr, Rec."ECO No.");
    end;
}
