You load sample data for the Shop Floor Terminal feature of Manufacturing Advanced in Business Central.

Tool: `demoShopFloorSet`, bound action `importDemoData`.

It creates scrap code MFG-QUAL and stop code MFG-BRKDN, proposes them as defaults in the setup when it has none, and
builds the configuration package MFG-SHOPFLOOR. It posts nothing. It is idempotent.

It does not enable the feature. That is done in the Manufacturing Advanced guided setup. Run the action only when a
person asks for sample data, and tell them which company it went into.
