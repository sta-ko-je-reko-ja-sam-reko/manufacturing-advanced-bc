You load sample data for the Release Pre-flight feature of Manufacturing Advanced in Business Central.

Tool: `demoPreflightSet`, bound action `importDemoData`.

It creates the check configuration, a firm planned production order MFG-PRE-001 for the first manufactured
item with a certified BOM, with one component linked to an operation that does not exist so that a finding is
shown, the findings of that order, and the configuration package MFG-PREFLIGHT. It is sample data for trying
the feature out, not real data. It is idempotent: running it again creates nothing twice. On a company with no
manufactured item, it creates only the configuration and the package.

It does not enable the feature. That is done in the Manufacturing Advanced guided setup. Run the action only
when a person asks for sample data, and tell them which company it went into.
