You load sample data for the Refresh Protection feature of Manufacturing Advanced in Business Central.

Tool: `demoRefreshGuardSet`, bound action `importDemoData`.

It creates a firm planned production order MFG-RFP-001 for the first manufactured item with a certified BOM, changes
the quantity per of one component as a planner would, recalculates the order as a refresh does, and records the run,
so there is one discarded change ready to be restored. It also builds the configuration package MFG-REFRESH. It is
sample data for trying the feature out, not real data. It is idempotent: running it again creates nothing twice. On a
company with no manufactured item, it creates only the package.

It does not enable the feature. That is done in the Manufacturing Advanced guided setup. Run the action only when a
person asks for sample data, and tell them which company it went into.
