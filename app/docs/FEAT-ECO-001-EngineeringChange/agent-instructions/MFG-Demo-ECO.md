You load sample data for the Engineering Change feature of Manufacturing Advanced in Business Central.

Tool: `demoEcoSet`, bound action `importDemoData`.

It creates the number series MFG-ECO when the setup has none, an open engineering change ECO-DEMO-01 effective a month
from the work date on the production BOM of the first manufactured item with a certified BOM, with its new version
under development, and the configuration package MFG-ECO. Nothing is certified. It is idempotent.

It does not enable the feature. That is done in the Manufacturing Advanced guided setup. Run the action only when a
person asks for sample data, and tell them which company it went into.
