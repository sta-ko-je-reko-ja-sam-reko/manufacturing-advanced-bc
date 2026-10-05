# FEAT-STD-001 - Standard Cost Drift

Unit test plan. Automated in `MFG Cost Drift Tests` (codeunit 89009). Fixtures are inserted directly with fixed
`MFGD-*` keys; the roll-up source is switched off so the company's own items do not take part.

## TEST-01 — A purchase price beyond the tolerance is listed
- **Given** a purchased standard-cost item, standard 10, last bought at 12, tolerance 2 %
- **When** the drift is calculated
- **Then** listed from the purchase price, proposed 12, drift 2 and 20 %

**Automation:** `MFG Cost Drift Tests.APurchasePriceBeyondTheToleranceIsListed`

## TEST-02 — A drift within the tolerance is not listed
- **Given** an item 1 % off its standard, tolerance 2 %
- **When** the drift is calculated
- **Then** not listed

**Automation:** `MFG Cost Drift Tests.ADriftWithinTheToleranceIsNotListed`

## TEST-03 — An inactive source is not used
- **Given** the purchase price source inactive, and an item 20 % off
- **When** the drift is calculated
- **Then** not listed

**Automation:** `MFG Cost Drift Tests.AnInactiveSourceIsNotUsed`

## TEST-04 — Sending a line writes the worksheet
- **Given** the feature on and an item drifted to 12
- **When** its line is selected and sent
- **Then** the worksheet has the item with new standard cost 12, and the line is marked sent

**Automation:** `MFG Cost Drift Tests.SendingALineWritesTheWorksheet`

## TEST-05 — Sending is refused while the feature is off
- **Given** the feature off and a drifted item
- **When** its line is sent
- **Then** refused

**Automation:** `MFG Cost Drift Tests.SendingIsRefusedWhileTheFeatureIsOff`

## TEST-06 — Order variances are summed by type
- **Given** an order finished on the work date, output 100, material variance 5, capacity variance −2
- **When** the variances are calculated
- **Then** output 100, material 5, capacity −2, total 3, 3 %

**Automation:** `MFG Cost Drift Tests.OrderVariancesAreSummedByType`

## TEST-07 — Ensuring the sources keeps the user's choice
- **Given** the user switched a source off
- **When** the sources are ensured again
- **Then** three rows, and the source stays off

**Automation:** `MFG Cost Drift Tests.EnsureSourcesKeepsTheUsersChoice`

## TEST-08 — The feature registers a guided setup step
- **When** the feature is asked for its step
- **Then** step 50, with a toggle, opening the feature setup page

**Automation:** `MFG Cost Drift Tests.TheFeatureRegistersAGuidedSetupStep`

## TEST-09 — Importing sample data twice creates it once
- **When** the sample data is imported twice
- **Then** three sources, the worksheet, and the configuration package exist

**Automation:** `MFG Cost Drift Tests.ImportingSampleDataTwiceCreatesItOnce`

## TEST-10 — A price list price replaces the last purchase price (STD-002)
- **Given** an item with standard 10, last bought at 12, and an active purchase price of 15
- **When** the drift is calculated
- **Then** source Purchase price list, proposal 15

**Automation:** `MFG Cost Drift Tests.APriceListPriceReplacesTheLastPurchasePrice`

## TEST-11 — The item's own vendor price wins
- **Given** prices of 14 from the item's vendor and 11 from another
- **When** the drift is calculated
- **Then** proposal 14

**Automation:** `MFG Cost Drift Tests.TheItemsOwnVendorPriceWins`

## TEST-12 — Prices that do not apply today are ignored
- **Given** prices starting tomorrow, in a foreign currency, and from a minimum quantity of 10; last bought at 12
- **When** the drift is calculated
- **Then** source Last purchase price, proposal 12

**Automation:** `MFG Cost Drift Tests.PricesThatDoNotApplyTodayAreIgnored`

## TEST-13 — A price per box is converted to the base unit
- **Given** standard 5, a price of 100 per box of 10
- **When** the drift is calculated
- **Then** proposal 10

**Automation:** `MFG Cost Drift Tests.APricePerBoxIsConvertedToTheBaseUnit`
