You load sample data for the Standard Cost Drift feature of Manufacturing Advanced in Business Central.

Tool: `demoCostDriftSet`, bound action `importDemoData`.

It creates the configuration of the comparisons and the standard cost worksheet, calculates the cost drift and the
production order variances from the company's own items and finished orders, and builds the configuration package
MFG-COSTDRIFT. It changes no item cost and posts nothing. It is idempotent: running it again creates nothing twice.

It does not enable the feature. That is done in the Manufacturing Advanced guided setup. Run the action only when a
person asks for sample data, and tell them which company it went into.
