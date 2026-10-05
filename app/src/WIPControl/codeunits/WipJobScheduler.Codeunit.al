namespace ManufacturingAdvanced.WIPControl;

using System.Threading;

codeunit 85215 "MFG WIP Job Scheduler"
{
    Access = Public;

    var
        DailyFormulaTok: Label '<1D>', Locked = true;

    /// <summary>
    /// Schedules the daily WIP run on the job queue, unless it is scheduled already.
    /// </summary>
    /// <param name="StartingTime">The time of day the run starts.</param>
    procedure Schedule(StartingTime: Time)
    var
        JobQueueEntry: Record "Job Queue Entry";
        NextRunDateFormula: DateFormula;
        BlankRecordId: RecordId;
    begin
        if IsScheduled() then
            exit;
        Evaluate(NextRunDateFormula, DailyFormulaTok);
        JobQueueEntry.ScheduleRecurrentJobQueueEntryWithRunDateFormula(
            JobQueueEntry."Object Type to Run"::Codeunit, Codeunit::"MFG WIP Scheduled Run", BlankRecordId, '', 3,
            NextRunDateFormula, StartingTime);
    end;

    /// <summary>
    /// Returns whether a job queue entry runs the daily WIP run.
    /// </summary>
    /// <returns>True when it is scheduled.</returns>
    procedure IsScheduled(): Boolean
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        exit(JobQueueEntry.FindJobQueueEntry(JobQueueEntry."Object Type to Run"::Codeunit, Codeunit::"MFG WIP Scheduled Run"));
    end;

    /// <summary>
    /// Removes the job queue entries of the daily WIP run.
    /// </summary>
    procedure Unschedule()
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"MFG WIP Scheduled Run");
        JobQueueEntry.DeleteAll(true);
    end;
}
