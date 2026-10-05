namespace ManufacturingAdvanced.RefreshGuard;

using Microsoft.Manufacturing.Document;

codeunit 85412 "MFG Refresh Lines" implements "MFG IRefreshObject"
{
    Access = Public;

    var
        SubjectLbl: Label 'Line %1, item %2', Comment = '%1 = the production order line number, %2 = the item number';
        WholeLineLbl: Label 'Whole line';
        KeyTok: Label '%1|%2', Locked = true;

    /// <summary>
    /// Stores every line of the order as it is before the refresh, numbering lines of the same item and variant
    /// so each can be matched after the refresh, which recreates the lines.
    /// </summary>
    /// <param name="RunNo">The refresh run.</param>
    /// <param name="ProductionOrder">The order about to be refreshed.</param>
    procedure TakeSnapshot(RunNo: Integer; ProductionOrder: Record "Production Order")
    var
        ProdOrderLine: Record "Prod. Order Line";
        Snapshot: Record "MFG Refresh Line Snapshot";
        Occurrences: Dictionary of [Text, Integer];
        EntryNo: Integer;
    begin
        FilterLines(ProdOrderLine, ProductionOrder);
        if not ProdOrderLine.FindSet() then
            exit;

        repeat
            EntryNo += 1;
            Snapshot.Init();
            Snapshot."Run No." := RunNo;
            Snapshot."Entry No." := EntryNo;
            Snapshot."Line No." := ProdOrderLine."Line No.";
            Snapshot.Occurrence := NextOccurrence(Occurrences, ProdOrderLine);
            Snapshot."Item No." := ProdOrderLine."Item No.";
            Snapshot."Variant Code" := ProdOrderLine."Variant Code";
            Snapshot.Description := ProdOrderLine.Description;
            Snapshot."Location Code" := ProdOrderLine."Location Code";
            Snapshot."Bin Code" := ProdOrderLine."Bin Code";
            Snapshot.Quantity := ProdOrderLine.Quantity;
            Snapshot."Due Date" := ProdOrderLine."Due Date";
            Snapshot."Production BOM No." := ProdOrderLine."Production BOM No.";
            Snapshot."Routing No." := ProdOrderLine."Routing No.";
            Snapshot."Unit of Measure Code" := ProdOrderLine."Unit of Measure Code";
            Snapshot."Production BOM Version Code" := ProdOrderLine."Production BOM Version Code";
            Snapshot."Routing Version Code" := ProdOrderLine."Routing Version Code";
            Snapshot.Insert();
        until ProdOrderLine.Next() = 0;
    end;

    /// <summary>
    /// Matches the lines after the refresh with the snapshot by item, variant and occurrence, and records every
    /// changed value, every removed line and every added one. Quantity, location, bin and due date can be
    /// restored; a changed BOM, routing or unit of measure, and an added or removed line, are reported only.
    /// </summary>
    /// <param name="RunNo">The refresh run.</param>
    /// <param name="ProductionOrder">The order that was refreshed.</param>
    procedure Compare(RunNo: Integer; ProductionOrder: Record "Production Order")
    var
        ProdOrderLine: Record "Prod. Order Line";
        Snapshot: Record "MFG Refresh Line Snapshot";
        Occurrences: Dictionary of [Text, Integer];
        Matched: List of [Integer];
    begin
        FilterLines(ProdOrderLine, ProductionOrder);
        if ProdOrderLine.FindSet() then
            repeat
                Snapshot.SetRange("Run No.", RunNo);
                Snapshot.SetRange("Item No.", ProdOrderLine."Item No.");
                Snapshot.SetRange("Variant Code", ProdOrderLine."Variant Code");
                Snapshot.SetRange(Occurrence, NextOccurrence(Occurrences, ProdOrderLine));
                if Snapshot.FindFirst() then begin
                    Matched.Add(Snapshot."Entry No.");
                    CompareFields(RunNo, ProductionOrder, Snapshot, ProdOrderLine);
                end else
                    AddLineChange(RunNo, ProductionOrder, Enum::"MFG Refresh Change Type"::MFGAdded, ProdOrderLine."Line No.", ProdOrderLine."Item No.", 0);
            until ProdOrderLine.Next() = 0;

        Snapshot.Reset();
        Snapshot.SetRange("Run No.", RunNo);
        if Snapshot.FindSet() then
            repeat
                if not Matched.Contains(Snapshot."Entry No.") then
                    AddLineChange(RunNo, ProductionOrder, Enum::"MFG Refresh Change Type"::MFGRemoved, Snapshot."Line No.", Snapshot."Item No.", Snapshot."Entry No.");
            until Snapshot.Next() = 0;
    end;

    /// <summary>
    /// Puts back a changed quantity, location, bin or due date through the line's own validation, which also
    /// updates the line's components.
    /// </summary>
    /// <param name="Change">The change to undo.</param>
    procedure Restore(Change: Record "MFG Refresh Change")
    var
        ProdOrderLine: Record "Prod. Order Line";
        Snapshot: Record "MFG Refresh Line Snapshot";
        SnapshotRef: RecordRef;
        CurrentRef: RecordRef;
    begin
        if Change."Change Type" <> Change."Change Type"::MFGChanged then
            exit;

        Snapshot.Get(Change."Run No.", Change."Snapshot Entry No.");
        ProdOrderLine.Get(Change."Prod. Order Status", Change."Prod. Order No.", Change."Current Line No.");
        SnapshotRef.GetTable(Snapshot);
        CurrentRef.GetTable(ProdOrderLine);
        CurrentRef.Field(Change."Field No.").Validate(SnapshotRef.Field(SnapshotFieldNo(Change."Field No.")).Value());
        CurrentRef.Modify(true);
    end;

    /// <summary>
    /// Removes the line snapshot of a run.
    /// </summary>
    /// <param name="RunNo">The refresh run.</param>
    procedure DeleteSnapshot(RunNo: Integer)
    var
        Snapshot: Record "MFG Refresh Line Snapshot";
    begin
        Snapshot.SetRange("Run No.", RunNo);
        Snapshot.DeleteAll();
    end;

    local procedure CompareFields(RunNo: Integer; ProductionOrder: Record "Production Order"; Snapshot: Record "MFG Refresh Line Snapshot"; ProdOrderLine: Record "Prod. Order Line")
    var
        Change: Record "MFG Refresh Change";
        Engine: Codeunit "MFG Refresh Engine";
        SnapshotRef: RecordRef;
        CurrentRef: RecordRef;
        FieldNo: Integer;
    begin
        SnapshotRef.GetTable(Snapshot);
        CurrentRef.GetTable(ProdOrderLine);
        foreach FieldNo in ComparedFields() do
            if Format(SnapshotRef.Field(SnapshotFieldNo(FieldNo)).Value()) <> Format(CurrentRef.Field(FieldNo).Value()) then begin
                InitChange(Change, RunNo, ProductionOrder, Enum::"MFG Refresh Change Type"::MFGChanged, ProdOrderLine."Line No.", ProdOrderLine."Item No.");
                Change."Field No." := FieldNo;
                Change."Field Caption" := CopyStr(CurrentRef.Field(FieldNo).Caption(), 1, MaxStrLen(Change."Field Caption"));
                Change."Old Value" := CopyStr(Format(SnapshotRef.Field(SnapshotFieldNo(FieldNo)).Value()), 1, MaxStrLen(Change."Old Value"));
                Change."New Value" := CopyStr(Format(CurrentRef.Field(FieldNo).Value()), 1, MaxStrLen(Change."New Value"));
                Change."Snapshot Entry No." := Snapshot."Entry No.";
                Change."Current Line No." := ProdOrderLine."Line No.";
                Change.Restorable := RestorableFields().Contains(FieldNo);
                Engine.InsertChange(Change);
            end;
    end;

    local procedure AddLineChange(RunNo: Integer; ProductionOrder: Record "Production Order"; ChangeType: Enum "MFG Refresh Change Type"; LineNo: Integer; ItemNo: Code[20]; SnapshotEntryNo: Integer)
    var
        Change: Record "MFG Refresh Change";
        Engine: Codeunit "MFG Refresh Engine";
    begin
        InitChange(Change, RunNo, ProductionOrder, ChangeType, LineNo, ItemNo);
        Change."Field Caption" := CopyStr(WholeLineLbl, 1, MaxStrLen(Change."Field Caption"));
        Change."Snapshot Entry No." := SnapshotEntryNo;
        if ChangeType = Enum::"MFG Refresh Change Type"::MFGAdded then
            Change."Current Line No." := LineNo;
        Change.Restorable := false;
        Engine.InsertChange(Change);
    end;

    local procedure InitChange(var Change: Record "MFG Refresh Change"; RunNo: Integer; ProductionOrder: Record "Production Order"; ChangeType: Enum "MFG Refresh Change Type"; LineNo: Integer; ItemNo: Code[20])
    begin
        Change.Init();
        Change."Run No." := RunNo;
        Change.Kind := Change.Kind::MFGLine;
        Change."Change Type" := ChangeType;
        Change."Prod. Order Status" := ProductionOrder.Status;
        Change."Prod. Order No." := ProductionOrder."No.";
        Change."Prod. Order Line No." := LineNo;
        Change.Subject := CopyStr(StrSubstNo(SubjectLbl, LineNo, ItemNo), 1, MaxStrLen(Change.Subject));
    end;

    local procedure FilterLines(var ProdOrderLine: Record "Prod. Order Line"; ProductionOrder: Record "Production Order")
    begin
        ProdOrderLine.SetRange(Status, ProductionOrder.Status);
        ProdOrderLine.SetRange("Prod. Order No.", ProductionOrder."No.");
    end;

    local procedure NextOccurrence(var Occurrences: Dictionary of [Text, Integer]; ProdOrderLine: Record "Prod. Order Line"): Integer
    var
        OccurrenceKey: Text;
        Occurrence: Integer;
    begin
        OccurrenceKey := StrSubstNo(KeyTok, ProdOrderLine."Item No.", ProdOrderLine."Variant Code");
        if Occurrences.Get(OccurrenceKey, Occurrence) then;
        Occurrence += 1;
        Occurrences.Set(OccurrenceKey, Occurrence);
        exit(Occurrence);
    end;

    local procedure ComparedFields() FieldNos: List of [Integer]
    var
        ProdOrderLine: Record "Prod. Order Line";
    begin
        FieldNos.Add(ProdOrderLine.FieldNo(Quantity));
        FieldNos.Add(ProdOrderLine.FieldNo("Location Code"));
        FieldNos.Add(ProdOrderLine.FieldNo("Bin Code"));
        FieldNos.Add(ProdOrderLine.FieldNo("Due Date"));
        FieldNos.Add(ProdOrderLine.FieldNo("Unit of Measure Code"));
        FieldNos.Add(ProdOrderLine.FieldNo("Production BOM No."));
        FieldNos.Add(ProdOrderLine.FieldNo("Production BOM Version Code"));
        FieldNos.Add(ProdOrderLine.FieldNo("Routing No."));
        FieldNos.Add(ProdOrderLine.FieldNo("Routing Version Code"));
    end;

    /// <summary>
    /// The snapshot mirrors the field numbers of the production order line, except for the version codes, whose
    /// numbers lie outside this app's ID range.
    /// </summary>
    local procedure SnapshotFieldNo(LineFieldNo: Integer): Integer
    var
        ProdOrderLine: Record "Prod. Order Line";
        Snapshot: Record "MFG Refresh Line Snapshot";
    begin
        case LineFieldNo of
            ProdOrderLine.FieldNo("Production BOM Version Code"):
                exit(Snapshot.FieldNo("Production BOM Version Code"));
            ProdOrderLine.FieldNo("Routing Version Code"):
                exit(Snapshot.FieldNo("Routing Version Code"));
        end;
        exit(LineFieldNo);
    end;

    local procedure RestorableFields() FieldNos: List of [Integer]
    var
        ProdOrderLine: Record "Prod. Order Line";
    begin
        FieldNos.Add(ProdOrderLine.FieldNo(Quantity));
        FieldNos.Add(ProdOrderLine.FieldNo("Location Code"));
        FieldNos.Add(ProdOrderLine.FieldNo("Bin Code"));
        FieldNos.Add(ProdOrderLine.FieldNo("Due Date"));
    end;
}
