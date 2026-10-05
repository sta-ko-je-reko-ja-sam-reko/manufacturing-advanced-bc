namespace ManufacturingAdvanced.RefreshGuard;

using Microsoft.Manufacturing.Document;

codeunit 85411 "MFG Refresh Operations" implements "MFG IRefreshObject"
{
    Access = Public;

    var
        SubjectLbl: Label 'Operation %1, routing %2', Comment = '%1 = the operation number, %2 = the routing number';
        WholeLineLbl: Label 'Whole line';

    /// <summary>
    /// Stores every routing line of the order as it is before the refresh.
    /// </summary>
    /// <param name="RunNo">The refresh run.</param>
    /// <param name="ProductionOrder">The order about to be refreshed.</param>
    procedure TakeSnapshot(RunNo: Integer; ProductionOrder: Record "Production Order")
    var
        ProdOrderRoutingLine: Record "Prod. Order Routing Line";
        Snapshot: Record "MFG Refresh Oper. Snapshot";
        EntryNo: Integer;
    begin
        FilterOperations(ProdOrderRoutingLine, ProductionOrder);
        if not ProdOrderRoutingLine.FindSet() then
            exit;

        repeat
            EntryNo += 1;
            Snapshot.Init();
            Snapshot."Run No." := RunNo;
            Snapshot."Entry No." := EntryNo;
            Snapshot."Routing No." := ProdOrderRoutingLine."Routing No.";
            Snapshot."Routing Reference No." := ProdOrderRoutingLine."Routing Reference No.";
            Snapshot."Operation No." := ProdOrderRoutingLine."Operation No.";
            Snapshot.Type := ProdOrderRoutingLine.Type;
            Snapshot."No." := ProdOrderRoutingLine."No.";
            Snapshot.Description := ProdOrderRoutingLine.Description;
            Snapshot."Setup Time" := ProdOrderRoutingLine."Setup Time";
            Snapshot."Run Time" := ProdOrderRoutingLine."Run Time";
            Snapshot."Routing Link Code" := ProdOrderRoutingLine."Routing Link Code";
            Snapshot.Insert();
        until ProdOrderRoutingLine.Next() = 0;
    end;

    /// <summary>
    /// Matches the routing lines after the refresh with the snapshot by routing reference, routing and
    /// operation number, and records every changed value, removed operation and added one. Setup time, run time
    /// and routing link can be restored; a change of work or machine centre, and a removed or added operation,
    /// are reported only, because re-planning them belongs to the planner.
    /// </summary>
    /// <param name="RunNo">The refresh run.</param>
    /// <param name="ProductionOrder">The order that was refreshed.</param>
    procedure Compare(RunNo: Integer; ProductionOrder: Record "Production Order")
    var
        ProdOrderRoutingLine: Record "Prod. Order Routing Line";
        Snapshot: Record "MFG Refresh Oper. Snapshot";
        Matched: List of [Integer];
    begin
        FilterOperations(ProdOrderRoutingLine, ProductionOrder);
        if ProdOrderRoutingLine.FindSet() then
            repeat
                Snapshot.SetRange("Run No.", RunNo);
                Snapshot.SetRange("Routing Reference No.", ProdOrderRoutingLine."Routing Reference No.");
                Snapshot.SetRange("Routing No.", ProdOrderRoutingLine."Routing No.");
                Snapshot.SetRange("Operation No.", ProdOrderRoutingLine."Operation No.");
                if Snapshot.FindFirst() then begin
                    Matched.Add(Snapshot."Entry No.");
                    CompareFields(RunNo, ProductionOrder, Snapshot, ProdOrderRoutingLine);
                end else
                    AddLineChange(RunNo, ProductionOrder, Enum::"MFG Refresh Change Type"::MFGAdded, ProdOrderRoutingLine."Routing Reference No.", ProdOrderRoutingLine."Routing No.", ProdOrderRoutingLine."Operation No.", 0);
            until ProdOrderRoutingLine.Next() = 0;

        Snapshot.Reset();
        Snapshot.SetRange("Run No.", RunNo);
        if Snapshot.FindSet() then
            repeat
                if not Matched.Contains(Snapshot."Entry No.") then
                    AddLineChange(RunNo, ProductionOrder, Enum::"MFG Refresh Change Type"::MFGRemoved, Snapshot."Routing Reference No.", Snapshot."Routing No.", Snapshot."Operation No.", Snapshot."Entry No.");
            until Snapshot.Next() = 0;
    end;

    /// <summary>
    /// Puts back a changed setup time, run time or routing link through the routing line's own validation.
    /// </summary>
    /// <param name="Change">The change to undo.</param>
    procedure Restore(Change: Record "MFG Refresh Change")
    var
        ProdOrderRoutingLine: Record "Prod. Order Routing Line";
        Snapshot: Record "MFG Refresh Oper. Snapshot";
        SnapshotRef: RecordRef;
        CurrentRef: RecordRef;
    begin
        if Change."Change Type" <> Change."Change Type"::MFGChanged then
            exit;

        Snapshot.Get(Change."Run No.", Change."Snapshot Entry No.");
        ProdOrderRoutingLine.Get(Change."Prod. Order Status", Change."Prod. Order No.", Change."Routing Reference No.", Change."Routing No.", Change."Operation No.");
        SnapshotRef.GetTable(Snapshot);
        CurrentRef.GetTable(ProdOrderRoutingLine);
        CurrentRef.Field(Change."Field No.").Validate(SnapshotRef.Field(Change."Field No.").Value());
        CurrentRef.Modify(true);
    end;

    /// <summary>
    /// Removes the operation snapshot of a run.
    /// </summary>
    /// <param name="RunNo">The refresh run.</param>
    procedure DeleteSnapshot(RunNo: Integer)
    var
        Snapshot: Record "MFG Refresh Oper. Snapshot";
    begin
        Snapshot.SetRange("Run No.", RunNo);
        Snapshot.DeleteAll();
    end;

    local procedure CompareFields(RunNo: Integer; ProductionOrder: Record "Production Order"; Snapshot: Record "MFG Refresh Oper. Snapshot"; ProdOrderRoutingLine: Record "Prod. Order Routing Line")
    var
        Change: Record "MFG Refresh Change";
        Engine: Codeunit "MFG Refresh Engine";
        SnapshotRef: RecordRef;
        CurrentRef: RecordRef;
        FieldNo: Integer;
    begin
        SnapshotRef.GetTable(Snapshot);
        CurrentRef.GetTable(ProdOrderRoutingLine);
        foreach FieldNo in ComparedFields() do
            if Format(SnapshotRef.Field(FieldNo).Value()) <> Format(CurrentRef.Field(FieldNo).Value()) then begin
                InitChange(Change, RunNo, ProductionOrder, Enum::"MFG Refresh Change Type"::MFGChanged, ProdOrderRoutingLine."Routing Reference No.", ProdOrderRoutingLine."Routing No.", ProdOrderRoutingLine."Operation No.");
                Change."Field No." := FieldNo;
                Change."Field Caption" := CopyStr(CurrentRef.Field(FieldNo).Caption(), 1, MaxStrLen(Change."Field Caption"));
                Change."Old Value" := CopyStr(Format(SnapshotRef.Field(FieldNo).Value()), 1, MaxStrLen(Change."Old Value"));
                Change."New Value" := CopyStr(Format(CurrentRef.Field(FieldNo).Value()), 1, MaxStrLen(Change."New Value"));
                Change."Snapshot Entry No." := Snapshot."Entry No.";
                Change.Restorable := RestorableFields().Contains(FieldNo);
                Engine.InsertChange(Change);
            end;
    end;

    local procedure AddLineChange(RunNo: Integer; ProductionOrder: Record "Production Order"; ChangeType: Enum "MFG Refresh Change Type"; RoutingReferenceNo: Integer; RoutingNo: Code[20]; OperationNo: Code[10]; SnapshotEntryNo: Integer)
    var
        Change: Record "MFG Refresh Change";
        Engine: Codeunit "MFG Refresh Engine";
    begin
        InitChange(Change, RunNo, ProductionOrder, ChangeType, RoutingReferenceNo, RoutingNo, OperationNo);
        Change."Field Caption" := CopyStr(WholeLineLbl, 1, MaxStrLen(Change."Field Caption"));
        Change."Snapshot Entry No." := SnapshotEntryNo;
        Change.Restorable := false;
        Engine.InsertChange(Change);
    end;

    local procedure InitChange(var Change: Record "MFG Refresh Change"; RunNo: Integer; ProductionOrder: Record "Production Order"; ChangeType: Enum "MFG Refresh Change Type"; RoutingReferenceNo: Integer; RoutingNo: Code[20]; OperationNo: Code[10])
    begin
        Change.Init();
        Change."Run No." := RunNo;
        Change.Kind := Change.Kind::MFGOperation;
        Change."Change Type" := ChangeType;
        Change."Prod. Order Status" := ProductionOrder.Status;
        Change."Prod. Order No." := ProductionOrder."No.";
        Change."Routing Reference No." := RoutingReferenceNo;
        Change."Routing No." := RoutingNo;
        Change."Operation No." := OperationNo;
        Change.Subject := CopyStr(StrSubstNo(SubjectLbl, OperationNo, RoutingNo), 1, MaxStrLen(Change.Subject));
    end;

    local procedure FilterOperations(var ProdOrderRoutingLine: Record "Prod. Order Routing Line"; ProductionOrder: Record "Production Order")
    begin
        ProdOrderRoutingLine.SetRange(Status, ProductionOrder.Status);
        ProdOrderRoutingLine.SetRange("Prod. Order No.", ProductionOrder."No.");
    end;

    local procedure ComparedFields() FieldNos: List of [Integer]
    var
        ProdOrderRoutingLine: Record "Prod. Order Routing Line";
    begin
        FieldNos.Add(ProdOrderRoutingLine.FieldNo(Type));
        FieldNos.Add(ProdOrderRoutingLine.FieldNo("No."));
        FieldNos.Add(ProdOrderRoutingLine.FieldNo("Setup Time"));
        FieldNos.Add(ProdOrderRoutingLine.FieldNo("Run Time"));
        FieldNos.Add(ProdOrderRoutingLine.FieldNo("Routing Link Code"));
    end;

    local procedure RestorableFields() FieldNos: List of [Integer]
    var
        ProdOrderRoutingLine: Record "Prod. Order Routing Line";
    begin
        FieldNos.Add(ProdOrderRoutingLine.FieldNo("Setup Time"));
        FieldNos.Add(ProdOrderRoutingLine.FieldNo("Run Time"));
        FieldNos.Add(ProdOrderRoutingLine.FieldNo("Routing Link Code"));
    end;
}
