namespace ManufacturingAdvanced.RefreshGuard;

using Microsoft.Manufacturing.Document;

codeunit 85410 "MFG Refresh Components" implements "MFG IRefreshObject"
{
    Access = Public;

    var
        SubjectLbl: Label 'Component %1, line %2', Comment = '%1 = the component item number, %2 = the production order line number';
        WholeLineLbl: Label 'Whole line';
        KeyTok: Label '%1|%2|%3', Locked = true;

    /// <summary>
    /// Stores every component of the order as it is before the refresh, numbering components of the same
    /// item and variant on the same line so each can be matched after the refresh.
    /// </summary>
    /// <param name="RunNo">The refresh run.</param>
    /// <param name="ProductionOrder">The order about to be refreshed.</param>
    procedure TakeSnapshot(RunNo: Integer; ProductionOrder: Record "Production Order")
    var
        ProdOrderComponent: Record "Prod. Order Component";
        Snapshot: Record "MFG Refresh Comp. Snapshot";
        Occurrences: Dictionary of [Text, Integer];
        EntryNo: Integer;
    begin
        FilterComponents(ProdOrderComponent, ProductionOrder);
        if not ProdOrderComponent.FindSet() then
            exit;

        repeat
            EntryNo += 1;
            Snapshot.Init();
            Snapshot."Run No." := RunNo;
            Snapshot."Entry No." := EntryNo;
            Snapshot."Prod. Order Line No." := ProdOrderComponent."Prod. Order Line No.";
            Snapshot.Occurrence := NextOccurrence(Occurrences, ProdOrderComponent);
            Snapshot."Component Line No." := ProdOrderComponent."Line No.";
            Snapshot."Item No." := ProdOrderComponent."Item No.";
            Snapshot.Description := ProdOrderComponent.Description;
            Snapshot."Unit of Measure Code" := ProdOrderComponent."Unit of Measure Code";
            Snapshot."Routing Link Code" := ProdOrderComponent."Routing Link Code";
            Snapshot."Scrap %" := ProdOrderComponent."Scrap %";
            Snapshot."Variant Code" := ProdOrderComponent."Variant Code";
            Snapshot."Flushing Method" := ProdOrderComponent."Flushing Method";
            Snapshot."Location Code" := ProdOrderComponent."Location Code";
            Snapshot."Bin Code" := ProdOrderComponent."Bin Code";
            Snapshot."Quantity per" := ProdOrderComponent."Quantity per";
            Snapshot.Insert();
        until ProdOrderComponent.Next() = 0;
    end;

    /// <summary>
    /// Matches the components after the refresh with the snapshot by line, item, variant and occurrence, and
    /// records every changed value, every removed component and every added one. All of them are restorable.
    /// </summary>
    /// <param name="RunNo">The refresh run.</param>
    /// <param name="ProductionOrder">The order that was refreshed.</param>
    procedure Compare(RunNo: Integer; ProductionOrder: Record "Production Order")
    var
        ProdOrderComponent: Record "Prod. Order Component";
        Snapshot: Record "MFG Refresh Comp. Snapshot";
        Occurrences: Dictionary of [Text, Integer];
        Matched: List of [Integer];
    begin
        FilterComponents(ProdOrderComponent, ProductionOrder);
        if ProdOrderComponent.FindSet() then
            repeat
                Snapshot.SetRange("Run No.", RunNo);
                Snapshot.SetRange("Prod. Order Line No.", ProdOrderComponent."Prod. Order Line No.");
                Snapshot.SetRange("Item No.", ProdOrderComponent."Item No.");
                Snapshot.SetRange("Variant Code", ProdOrderComponent."Variant Code");
                Snapshot.SetRange(Occurrence, NextOccurrence(Occurrences, ProdOrderComponent));
                if Snapshot.FindFirst() then begin
                    Matched.Add(Snapshot."Entry No.");
                    CompareFields(RunNo, ProductionOrder, Snapshot, ProdOrderComponent);
                end else
                    AddLineChange(RunNo, ProductionOrder, Enum::"MFG Refresh Change Type"::MFGAdded, ProdOrderComponent."Prod. Order Line No.", ProdOrderComponent."Item No.", 0, ProdOrderComponent."Line No.");
            until ProdOrderComponent.Next() = 0;

        Snapshot.Reset();
        Snapshot.SetRange("Run No.", RunNo);
        if Snapshot.FindSet() then
            repeat
                if not Matched.Contains(Snapshot."Entry No.") then
                    AddLineChange(RunNo, ProductionOrder, Enum::"MFG Refresh Change Type"::MFGRemoved, Snapshot."Prod. Order Line No.", Snapshot."Item No.", Snapshot."Entry No.", 0);
            until Snapshot.Next() = 0;
    end;

    /// <summary>
    /// Puts back a changed value, re-creates a removed component from the snapshot, or deletes a component the
    /// refresh added. Every value goes through the component's own validation.
    /// </summary>
    /// <param name="Change">The change to undo.</param>
    procedure Restore(Change: Record "MFG Refresh Change")
    begin
        case Change."Change Type" of
            Change."Change Type"::MFGChanged:
                RestoreValue(Change);
            Change."Change Type"::MFGRemoved:
                RecreateComponent(Change);
            Change."Change Type"::MFGAdded:
                DeleteComponent(Change);
        end;
    end;

    /// <summary>
    /// Removes the component snapshot of a run.
    /// </summary>
    /// <param name="RunNo">The refresh run.</param>
    procedure DeleteSnapshot(RunNo: Integer)
    var
        Snapshot: Record "MFG Refresh Comp. Snapshot";
    begin
        Snapshot.SetRange("Run No.", RunNo);
        Snapshot.DeleteAll();
    end;

    local procedure CompareFields(RunNo: Integer; ProductionOrder: Record "Production Order"; Snapshot: Record "MFG Refresh Comp. Snapshot"; ProdOrderComponent: Record "Prod. Order Component")
    var
        Change: Record "MFG Refresh Change";
        Engine: Codeunit "MFG Refresh Engine";
        SnapshotRef: RecordRef;
        CurrentRef: RecordRef;
        FieldNo: Integer;
    begin
        SnapshotRef.GetTable(Snapshot);
        CurrentRef.GetTable(ProdOrderComponent);
        foreach FieldNo in ComparedFields() do
            if Format(SnapshotRef.Field(FieldNo).Value()) <> Format(CurrentRef.Field(FieldNo).Value()) then begin
                InitChange(Change, RunNo, ProductionOrder, Enum::"MFG Refresh Change Type"::MFGChanged, ProdOrderComponent."Prod. Order Line No.", ProdOrderComponent."Item No.");
                Change."Field No." := FieldNo;
                Change."Field Caption" := CopyStr(CurrentRef.Field(FieldNo).Caption(), 1, MaxStrLen(Change."Field Caption"));
                Change."Old Value" := CopyStr(Format(SnapshotRef.Field(FieldNo).Value()), 1, MaxStrLen(Change."Old Value"));
                Change."New Value" := CopyStr(Format(CurrentRef.Field(FieldNo).Value()), 1, MaxStrLen(Change."New Value"));
                Change."Snapshot Entry No." := Snapshot."Entry No.";
                Change."Current Line No." := ProdOrderComponent."Line No.";
                Engine.InsertChange(Change);
            end;
    end;

    local procedure AddLineChange(RunNo: Integer; ProductionOrder: Record "Production Order"; ChangeType: Enum "MFG Refresh Change Type"; ProdOrderLineNo: Integer; ItemNo: Code[20]; SnapshotEntryNo: Integer; CurrentLineNo: Integer)
    var
        Change: Record "MFG Refresh Change";
        Engine: Codeunit "MFG Refresh Engine";
    begin
        InitChange(Change, RunNo, ProductionOrder, ChangeType, ProdOrderLineNo, ItemNo);
        Change."Field Caption" := CopyStr(WholeLineLbl, 1, MaxStrLen(Change."Field Caption"));
        Change."Snapshot Entry No." := SnapshotEntryNo;
        Change."Current Line No." := CurrentLineNo;
        Engine.InsertChange(Change);
    end;

    local procedure InitChange(var Change: Record "MFG Refresh Change"; RunNo: Integer; ProductionOrder: Record "Production Order"; ChangeType: Enum "MFG Refresh Change Type"; ProdOrderLineNo: Integer; ItemNo: Code[20])
    begin
        Change.Init();
        Change."Run No." := RunNo;
        Change.Kind := Change.Kind::MFGComponent;
        Change."Change Type" := ChangeType;
        Change."Prod. Order Status" := ProductionOrder.Status;
        Change."Prod. Order No." := ProductionOrder."No.";
        Change."Prod. Order Line No." := ProdOrderLineNo;
        Change.Subject := CopyStr(StrSubstNo(SubjectLbl, ItemNo, ProdOrderLineNo), 1, MaxStrLen(Change.Subject));
        Change.Restorable := true;
    end;

    local procedure RestoreValue(Change: Record "MFG Refresh Change")
    var
        ProdOrderComponent: Record "Prod. Order Component";
        Snapshot: Record "MFG Refresh Comp. Snapshot";
        SnapshotRef: RecordRef;
        CurrentRef: RecordRef;
    begin
        Snapshot.Get(Change."Run No.", Change."Snapshot Entry No.");
        ProdOrderComponent.Get(Change."Prod. Order Status", Change."Prod. Order No.", Change."Prod. Order Line No.", Change."Current Line No.");
        SnapshotRef.GetTable(Snapshot);
        CurrentRef.GetTable(ProdOrderComponent);
        CurrentRef.Field(Change."Field No.").Validate(SnapshotRef.Field(Change."Field No.").Value());
        CurrentRef.Modify(true);
    end;

    local procedure RecreateComponent(Change: Record "MFG Refresh Change")
    var
        ProdOrderComponent: Record "Prod. Order Component";
        LastComponent: Record "Prod. Order Component";
        Snapshot: Record "MFG Refresh Comp. Snapshot";
    begin
        Snapshot.Get(Change."Run No.", Change."Snapshot Entry No.");

        LastComponent.SetRange(Status, Change."Prod. Order Status");
        LastComponent.SetRange("Prod. Order No.", Change."Prod. Order No.");
        LastComponent.SetRange("Prod. Order Line No.", Snapshot."Prod. Order Line No.");
        LastComponent.SetLoadFields("Line No.");
        if LastComponent.FindLast() then;

        ProdOrderComponent.Init();
        ProdOrderComponent.Status := Change."Prod. Order Status";
        ProdOrderComponent."Prod. Order No." := Change."Prod. Order No.";
        ProdOrderComponent."Prod. Order Line No." := Snapshot."Prod. Order Line No.";
        ProdOrderComponent."Line No." := LastComponent."Line No." + 10000;
        ProdOrderComponent.Validate("Item No.", Snapshot."Item No.");
        ProdOrderComponent.Validate("Variant Code", Snapshot."Variant Code");
        ProdOrderComponent.Validate("Unit of Measure Code", Snapshot."Unit of Measure Code");
        ProdOrderComponent.Validate("Quantity per", Snapshot."Quantity per");
        ProdOrderComponent.Validate("Scrap %", Snapshot."Scrap %");
        ProdOrderComponent.Validate("Location Code", Snapshot."Location Code");
        if Snapshot."Bin Code" <> '' then
            ProdOrderComponent.Validate("Bin Code", Snapshot."Bin Code");
        ProdOrderComponent.Validate("Flushing Method", Snapshot."Flushing Method");
        ProdOrderComponent.Validate("Routing Link Code", Snapshot."Routing Link Code");
        ProdOrderComponent.Insert(true);
    end;

    local procedure DeleteComponent(Change: Record "MFG Refresh Change")
    var
        ProdOrderComponent: Record "Prod. Order Component";
    begin
        if ProdOrderComponent.Get(Change."Prod. Order Status", Change."Prod. Order No.", Change."Prod. Order Line No.", Change."Current Line No.") then
            ProdOrderComponent.Delete(true);
    end;

    local procedure FilterComponents(var ProdOrderComponent: Record "Prod. Order Component"; ProductionOrder: Record "Production Order")
    begin
        ProdOrderComponent.SetRange(Status, ProductionOrder.Status);
        ProdOrderComponent.SetRange("Prod. Order No.", ProductionOrder."No.");
    end;

    local procedure NextOccurrence(var Occurrences: Dictionary of [Text, Integer]; ProdOrderComponent: Record "Prod. Order Component"): Integer
    var
        OccurrenceKey: Text;
        Occurrence: Integer;
    begin
        OccurrenceKey := StrSubstNo(KeyTok, ProdOrderComponent."Prod. Order Line No.", ProdOrderComponent."Item No.", ProdOrderComponent."Variant Code");
        if Occurrences.Get(OccurrenceKey, Occurrence) then;
        Occurrence += 1;
        Occurrences.Set(OccurrenceKey, Occurrence);
        exit(Occurrence);
    end;

    local procedure ComparedFields() FieldNos: List of [Integer]
    var
        ProdOrderComponent: Record "Prod. Order Component";
    begin
        FieldNos.Add(ProdOrderComponent.FieldNo("Quantity per"));
        FieldNos.Add(ProdOrderComponent.FieldNo("Unit of Measure Code"));
        FieldNos.Add(ProdOrderComponent.FieldNo("Scrap %"));
        FieldNos.Add(ProdOrderComponent.FieldNo("Location Code"));
        FieldNos.Add(ProdOrderComponent.FieldNo("Bin Code"));
        FieldNos.Add(ProdOrderComponent.FieldNo("Flushing Method"));
        FieldNos.Add(ProdOrderComponent.FieldNo("Routing Link Code"));
    end;
}
