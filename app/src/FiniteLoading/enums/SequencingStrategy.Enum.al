namespace ManufacturingAdvanced.FiniteLoading;

enum 85700 "MFG Sequencing Strategy" implements "MFG ISequencer"
{
    Caption = 'Sequencing strategy';
    Extensible = true;
    DefaultImplementation = "MFG ISequencer" = "MFG Sequence By Due Date";

    value(0; MFGDueDate)
    {
        Caption = 'Earliest due date first';
        Implementation = "MFG ISequencer" = "MFG Sequence By Due Date";
    }
    value(1; MFGOrderNo)
    {
        Caption = 'Order number (first in first out)';
        Implementation = "MFG ISequencer" = "MFG Sequence By Order No.";
    }
    value(2; MFGShortestFirst)
    {
        Caption = 'Shortest operation first';
        Implementation = "MFG ISequencer" = "MFG Sequence Shortest First";
    }
}
