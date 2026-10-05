You load sample data for the Planning Insight feature of Manufacturing Advanced in Business Central.

Tool: `demoPlanningSet`, bound action `importDemoData`.

It creates the rule configuration, records the action messages already on the company's planning worksheets (at most
once per batch and day), analyses them, and builds the configuration package MFG-PLANNING. It does not run planning,
change any item or post anything.

It does not enable the feature. That is done in the Manufacturing Advanced guided setup. Run the action only when a
person asks for sample data, and tell them which company it went into.
