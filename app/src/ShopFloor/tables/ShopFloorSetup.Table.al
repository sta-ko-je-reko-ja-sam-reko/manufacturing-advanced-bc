namespace ManufacturingAdvanced.ShopFloor;

using Microsoft.Manufacturing.Setup;

table 85600 "MFG Shop Floor Setup"
{
    Caption = 'Shop floor terminal setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary key';
            DataClassification = CustomerContent;
        }
        field(10; "MFG Enabled"; Boolean)
        {
            Caption = 'Enabled';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies whether the shop floor terminal is enabled. Turning this on shows the terminal and the related actions, and the session restarts so the change takes effect.';
        }
        field(20; "Post Run Time"; Boolean)
        {
            Caption = 'Post run time from the clock';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies whether the time between Start and Stop on an operation is posted as its run time with the next output reported for it.';
        }
        field(30; "Default Scrap Code"; Code[10])
        {
            Caption = 'Default scrap code';
            DataClassification = CustomerContent;
            TableRelation = Scrap;
            ToolTip = 'Specifies the scrap code proposed when an operator reports scrap.';
        }
        field(31; "Default Stop Code"; Code[10])
        {
            Caption = 'Default stop code';
            DataClassification = CustomerContent;
            TableRelation = Stop;
            ToolTip = 'Specifies the stop code proposed when an operator reports downtime.';
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }
}
