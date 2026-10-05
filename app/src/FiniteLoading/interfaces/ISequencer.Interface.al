namespace ManufacturingAdvanced.FiniteLoading;

interface "MFG ISequencer"
{
    /// <summary>
    /// Numbers the load plan lines of one work center in the order they are loaded onto its capacity, by setting
    /// their sequence number from 1 upward.
    /// </summary>
    /// <param name="LoadPlanLine">The load plan lines, filtered on the work center.</param>
    procedure Sequence(var LoadPlanLine: Record "MFG Load Plan Line");
}
