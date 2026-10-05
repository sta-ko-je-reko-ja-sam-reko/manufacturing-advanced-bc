namespace ManufacturingAdvanced.EngineeringChange;

table 85801 "MFG ECO Header"
{
    Caption = 'Engineering change order';
    DataClassification = CustomerContent;
    LookupPageId = "MFG ECO List";
    DrillDownPageId = "MFG ECO List";

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the number of the engineering change order.';
        }
        field(10; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies what the change is.';
        }
        field(11; Reason; Text[250])
        {
            Caption = 'Reason';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies why the change is made.';
        }
        field(20; Status; Enum "MFG ECO Status")
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
            Editable = false;
            ToolTip = 'Specifies where the change is: open, pending approval, approved, implemented or rejected.';
        }
        field(21; "Effective Date"; Date)
        {
            Caption = 'Effective date';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the date from which the new BOM and routing versions are used.';
        }
        field(30; "Requested By"; Code[50])
        {
            Caption = 'Requested by';
            DataClassification = EndUserIdentifiableInformation;
            Editable = false;
            ToolTip = 'Specifies the user who created the change.';
        }
        field(31; "Requested At"; DateTime)
        {
            Caption = 'Requested at';
            DataClassification = CustomerContent;
            Editable = false;
            ToolTip = 'Specifies when the change was created.';
        }
        field(32; "Approved By"; Code[50])
        {
            Caption = 'Approved by';
            DataClassification = EndUserIdentifiableInformation;
            Editable = false;
            ToolTip = 'Specifies the user who approved or rejected the change.';
        }
        field(33; "Approved At"; DateTime)
        {
            Caption = 'Approved at';
            DataClassification = CustomerContent;
            Editable = false;
            ToolTip = 'Specifies when the change was approved or rejected.';
        }
        field(34; "Implemented At"; DateTime)
        {
            Caption = 'Implemented at';
            DataClassification = CustomerContent;
            Editable = false;
            ToolTip = 'Specifies when the new versions were certified.';
        }
        field(40; Lines; Integer)
        {
            Caption = 'Lines';
            FieldClass = FlowField;
            CalcFormula = count("MFG ECO Line" where("ECO No." = field("No.")));
            Editable = false;
            ToolTip = 'Specifies how many BOMs and routings the change touches.';
        }
    }

    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin
        Logic().Trigger_OnInsert(Rec);
    end;

    trigger OnDelete()
    begin
        Logic().Trigger_OnDelete(Rec);
    end;

    var
        ILogic: Interface "MFG IEcoHeader";
        ILogicDefined: Boolean;

    /// <summary>
    /// Injects an alternative implementation of the order's logic, for tests and dependent apps.
    /// </summary>
    /// <param name="Implementation">The implementation to use instead of the default.</param>
    procedure Define(Implementation: Interface "MFG IEcoHeader")
    begin
        ILogic := Implementation;
        ILogicDefined := true;
    end;

    local procedure Logic(): Interface "MFG IEcoHeader"
    var
        DefaultLogic: Codeunit "MFG ECO Header Logic";
    begin
        if not ILogicDefined then
            Define(DefaultLogic);
        exit(ILogic);
    end;
}
