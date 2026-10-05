namespace ManufacturingAdvanced.ShopFloor;

using Microsoft.Manufacturing.Document;

page 85606 "MFG API Shop Floor Operation"
{
    PageType = API;
    APIPublisher = 'matr';
    APIGroup = 'mfgShopFloor';
    APIVersion = 'v1.0';
    EntityName = 'shopFloorOperation';
    EntitySetName = 'shopFloorOperations';
    EntityCaption = 'Open operation';
    EntitySetCaption = 'Open operations';
    SourceTable = "Prod. Order Routing Line";
    SourceTableView = where(Status = const(Released), "Routing Status" = filter(<> Finished));
    Extensible = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Records)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'Id';
                }
                field(prodOrderNo; Rec."Prod. Order No.")
                {
                    Caption = 'Prod. order no.';
                }
                field(routingReferenceNo; Rec."Routing Reference No.")
                {
                    Caption = 'Routing reference no.';
                }
                field(routingNo; Rec."Routing No.")
                {
                    Caption = 'Routing no.';
                }
                field(operationNo; Rec."Operation No.")
                {
                    Caption = 'Operation no.';
                }
                field(description; Rec.Description)
                {
                    Caption = 'Description';
                }
                field(type; Rec.Type)
                {
                    Caption = 'Type';
                }
                field(number; Rec."No.")
                {
                    Caption = 'No.';
                }
                field(workCenterNo; Rec."Work Center No.")
                {
                    Caption = 'Work center no.';
                }
                field(routingStatus; Rec."Routing Status")
                {
                    Caption = 'Routing status';
                }
                field(startingDateTime; Rec."Starting Date-Time")
                {
                    Caption = 'Starting date-time';
                }
                field(endingDateTime; Rec."Ending Date-Time")
                {
                    Caption = 'Ending date-time';
                }
            }
        }
    }

    /// <summary>
    /// Starts the clock on this operation for the calling user.
    /// </summary>
    /// <param name="ActionContext">The OData action context.</param>
    [ServiceEnabled]
    procedure Start(var ActionContext: WebServiceActionContext)
    var
        Engine: Codeunit "MFG Shop Floor Engine";
    begin
        Engine.StartOperation(Rec);
        SetResult(ActionContext);
    end;

    /// <summary>
    /// Stops the calling user's clock on this operation.
    /// </summary>
    /// <param name="ActionContext">The OData action context.</param>
    [ServiceEnabled]
    procedure Stop(var ActionContext: WebServiceActionContext)
    var
        Engine: Codeunit "MFG Shop Floor Engine";
    begin
        Engine.StopOperation(Rec);
        SetResult(ActionContext);
    end;

    /// <summary>
    /// Reports and posts output on this operation. Posting is immediate and is undone only by a correcting entry.
    /// </summary>
    /// <param name="ActionContext">The OData action context.</param>
    /// <param name="outputQuantity">The good quantity.</param>
    /// <param name="scrapQuantity">The scrapped quantity.</param>
    /// <param name="scrapCode">Why it was scrapped.</param>
    [ServiceEnabled]
    procedure ReportOutput(var ActionContext: WebServiceActionContext; outputQuantity: Decimal; scrapQuantity: Decimal; scrapCode: Code[10])
    var
        Engine: Codeunit "MFG Shop Floor Engine";
    begin
        Engine.ReportOperationOutput(Rec, outputQuantity, scrapQuantity, scrapCode);
        SetResult(ActionContext);
    end;

    /// <summary>
    /// Reports and posts downtime on this operation.
    /// </summary>
    /// <param name="ActionContext">The OData action context.</param>
    /// <param name="minutes">How long it stood still.</param>
    /// <param name="stopCode">Why it stood still.</param>
    [ServiceEnabled]
    procedure ReportDowntime(var ActionContext: WebServiceActionContext; minutes: Decimal; stopCode: Code[10])
    var
        Engine: Codeunit "MFG Shop Floor Engine";
    begin
        Engine.ReportDowntime(Rec, minutes, stopCode);
        SetResult(ActionContext);
    end;

    local procedure SetResult(var ActionContext: WebServiceActionContext)
    begin
        ActionContext.SetObjectType(ObjectType::Page);
        ActionContext.SetObjectId(Page::"MFG API Shop Floor Operation");
        ActionContext.AddEntityKey(Rec.FieldNo(SystemId), Rec.SystemId);
        ActionContext.SetResultCode(WebServiceActionResultCode::None);
    end;
}
