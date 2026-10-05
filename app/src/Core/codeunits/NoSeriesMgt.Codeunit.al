namespace ManufacturingAdvanced.Core;

using Microsoft.Foundation.NoSeries;

codeunit 85007 "MFG No. Series Mgt."
{
    Access = Public;

    /// <summary>
    /// Creates a number series if it does not exist yet, and answers its code either way. Knowing how to
    /// make a series is foundation work; knowing which series a feature needs is not, so every feature
    /// asks for its own and the foundation never learns their names.
    /// </summary>
    /// <param name="SeriesCode">The code of the series.</param>
    /// <param name="SeriesDescription">What the series is for, shown on the number series list.</param>
    /// <param name="StartingNo">The first number the series gives out.</param>
    /// <param name="EndingNo">The last number the series gives out.</param>
    /// <returns>The code of the series, whether it was created now or already existed.</returns>
    procedure EnsureSeries(SeriesCode: Text; SeriesDescription: Text; StartingNo: Text; EndingNo: Text): Code[20]
    var
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
        SeriesCodeValue: Code[20];
    begin
        SeriesCodeValue := CopyStr(SeriesCode, 1, MaxStrLen(NoSeries.Code));

        NoSeries.SetLoadFields(Code);
        if NoSeries.Get(SeriesCodeValue) then
            exit(SeriesCodeValue);

        Clear(NoSeries);
        NoSeries.Init();
        NoSeries.Code := SeriesCodeValue;
        NoSeries.Description := CopyStr(SeriesDescription, 1, MaxStrLen(NoSeries.Description));
        NoSeries."Default Nos." := true;
        NoSeries.Insert(true);

        NoSeriesLine.Init();
        NoSeriesLine."Series Code" := NoSeries.Code;
        NoSeriesLine."Line No." := 10000;
        NoSeriesLine."Starting No." := CopyStr(StartingNo, 1, MaxStrLen(NoSeriesLine."Starting No."));
        NoSeriesLine."Ending No." := CopyStr(EndingNo, 1, MaxStrLen(NoSeriesLine."Ending No."));
        NoSeriesLine.Insert(true);

        exit(SeriesCodeValue);
    end;
}
