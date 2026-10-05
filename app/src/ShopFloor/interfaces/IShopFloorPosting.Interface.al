namespace ManufacturingAdvanced.ShopFloor;

interface "MFG IShopFloorPosting"
{
    /// <summary>
    /// Posts what an operator reported: output with its scrap and run time, or downtime. Errors when the posting
    /// fails, so that nothing is recorded as posted that was not.
    /// </summary>
    /// <param name="ShopFloorEvent">The event to post; its order, line, operation, quantities, codes and minutes are set.</param>
    procedure Post(ShopFloorEvent: Record "MFG Shop Floor Event");
}
