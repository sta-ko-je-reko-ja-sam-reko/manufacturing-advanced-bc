namespace ManufacturingAdvanced.Core;

table 85003 "MFG Activities Cue"
{
    Caption = 'Production activities';
    DataClassification = SystemMetadata;
    TableType = Temporary;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary key';
        }
        field(10; "Preflight Errors"; Integer)
        {
            Caption = 'Pre-flight errors';
            Editable = false;
            ToolTip = 'Specifies the number of pre-flight findings with severity Error that are still stored on production orders.';
        }
        field(20; "Orders Ready to Finish"; Integer)
        {
            Caption = 'Orders ready to finish';
            Editable = false;
            ToolTip = 'Specifies the number of released production orders whose output is complete and that nothing stops from being finished.';
        }
        field(21; "WIP to Investigate"; Integer)
        {
            Caption = 'WIP to investigate';
            Editable = false;
            ToolTip = 'Specifies the number of production orders whose WIP differs from the general ledger for no known reason.';
        }
        field(30; "Changes to Restore"; Integer)
        {
            Caption = 'Refresh changes to restore';
            Editable = false;
            ToolTip = 'Specifies the number of changes refreshes made that can still be restored.';
        }
        field(40; "Cost Drift Lines"; Integer)
        {
            Caption = 'Standard costs drifted';
            Editable = false;
            ToolTip = 'Specifies the number of items whose standard cost has drifted and has not been sent to the standard cost worksheet.';
        }
        field(50; "Items with Planning Advice"; Integer)
        {
            Caption = 'Items with planning advice';
            Editable = false;
            ToolTip = 'Specifies the number of items for which planning insight advises a change of planning parameters.';
        }
        field(60; "Operations Running"; Integer)
        {
            Caption = 'Operations running';
            Editable = false;
            ToolTip = 'Specifies the number of operations started on the shop floor terminal and not stopped yet.';
        }
        field(70; "ECOs Pending Approval"; Integer)
        {
            Caption = 'Changes pending approval';
            Editable = false;
            ToolTip = 'Specifies the number of engineering changes waiting for approval.';
        }
        field(71; "ECOs to Implement"; Integer)
        {
            Caption = 'Changes to implement';
            Editable = false;
            ToolTip = 'Specifies the number of approved engineering changes that are not implemented yet.';
        }
        field(80; "Late Operations"; Integer)
        {
            Caption = 'Late operations';
            Editable = false;
            ToolTip = 'Specifies the number of operations in the finite load plan that finish after their order is due or do not fit the horizon.';
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }

    /// <summary>
    /// Makes sure the single in-memory row the activities part binds to exists.
    /// </summary>
    internal procedure InitCue()
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
    end;
}
