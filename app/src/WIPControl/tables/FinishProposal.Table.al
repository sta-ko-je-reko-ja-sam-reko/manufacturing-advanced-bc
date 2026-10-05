namespace ManufacturingAdvanced.WIPControl;

using Microsoft.Inventory.Item;
using Microsoft.Manufacturing.Document;

table 85202 "MFG Finish Proposal"
{
    Caption = 'Finish proposal';
    DataClassification = CustomerContent;
    LookupPageId = "MFG Finish Proposals";
    DrillDownPageId = "MFG Finish Proposals";

    fields
    {
        field(1; "Prod. Order No."; Code[20])
        {
            Caption = 'Prod. order no.';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the released production order whose output is complete.';
            TableRelation = "Production Order"."No." where(Status = const(Released));
        }
        field(10; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the description of the production order.';
        }
        field(11; "Source No."; Code[20])
        {
            Caption = 'Source no.';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the item the order produces.';
            TableRelation = Item;
        }
        field(12; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            ToolTip = 'Specifies the quantity the order was for.';
        }
        field(13; "Finished Quantity"; Decimal)
        {
            Caption = 'Finished quantity';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            ToolTip = 'Specifies the quantity that has been output.';
        }
        field(20; "Last Output Date"; Date)
        {
            Caption = 'Last output date';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the posting date of the last output on the order.';
        }
        field(21; "Days Since Output"; Integer)
        {
            Caption = 'Days since output';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies how many days the order has stayed released since its last output, counted to the work date.';
        }
        field(30; "Consumption Cost"; Decimal)
        {
            Caption = 'Consumption cost';
            DataClassification = CustomerContent;
            AutoFormatType = 1;
            AutoFormatExpression = '';
            ToolTip = 'Specifies the cost of the components consumed by the order so far.';
        }
        field(31; "Capacity Cost"; Decimal)
        {
            Caption = 'Capacity cost';
            DataClassification = CustomerContent;
            AutoFormatType = 1;
            AutoFormatExpression = '';
            ToolTip = 'Specifies the cost of the capacity posted on the order so far.';
        }
        field(32; "Output Cost"; Decimal)
        {
            Caption = 'Output cost';
            DataClassification = CustomerContent;
            AutoFormatType = 1;
            AutoFormatExpression = '';
            ToolTip = 'Specifies the cost at which the output has been valued so far, actual and expected.';
        }
        field(33; "Est. WIP Amount"; Decimal)
        {
            Caption = 'Est. WIP amount';
            DataClassification = CustomerContent;
            AutoFormatType = 1;
            AutoFormatExpression = '';
            ToolTip = 'Specifies the estimated value still held as work in progress: consumption plus capacity minus output. It settles only when the order is finished and costs are adjusted.';
        }
        field(40; Status; Enum "MFG Finish Proposal Status")
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies whether the order can be finished from here, is blocked by a check, was finished, or failed to finish.';
        }
        field(41; Notes; Text[250])
        {
            Caption = 'Notes';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies what the checks found, or why finishing failed.';
        }
        field(42; Selected; Boolean)
        {
            Caption = 'Selected';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies whether the order is finished when you choose Finish selected.';
        }
        field(50; "Suggested At"; DateTime)
        {
            Caption = 'Suggested at';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies when the proposal was last calculated.';
        }
    }

    keys
    {
        key(PK; "Prod. Order No.")
        {
            Clustered = true;
        }
    }
}
