You load sample data for the WIP Control feature of Manufacturing Advanced in Business Central.

Tool: `demoWipSet`, bound action `importDemoData`.

It creates the configuration of the checks before finishing, lists the company's own released production orders
whose output is complete as finish proposals, and builds the configuration package MFG-WIP. It posts nothing and
finishes nothing. It is idempotent: running it again creates nothing twice.

It does not enable the feature. That is done in the Manufacturing Advanced guided setup. Run the action only when a
person asks for sample data, and tell them which company it went into.
