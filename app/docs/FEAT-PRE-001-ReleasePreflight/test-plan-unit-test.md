# FEAT-PRE-001 - Release Pre-flight

Unit test plan. Automated in `MFG Preflight Tests` (codeunit 89002). Fixtures are inserted directly with
fixed `MFGT-*` keys, so no posting setup is needed.

## TEST-01 — A routing link without an operation is found
- **Given** a component with routing link `MFGT-L1` and no operation carrying it
- **When** the routing link check runs
- **Then** one finding names the component line

**Automation:** `MFG Preflight Tests.RoutingLinkWithoutOperationIsFound`

## TEST-02 — A routing link matched by an operation is not found
- **Given** the same component and an operation of its line with link `MFGT-L1`
- **When** the routing link check runs
- **Then** nothing is found

**Automation:** `MFG Preflight Tests.RoutingLinkMatchedByAnOperationIsNotFound`

## TEST-03 — A backflushed lot component without a lot is found
- **Given** a backward-flushed, lot-specific component with remaining quantity 5 and no lot
- **When** the flushing tracking check runs
- **Then** one finding

**Automation:** `MFG Preflight Tests.BackflushedLotComponentWithoutLotIsFound`

## TEST-04 — A lot assigned for the whole quantity is accepted
- **Given** the same component with lot `LOT-A` for 5
- **When** the check runs
- **Then** nothing is found

**Automation:** `MFG Preflight Tests.BackflushedLotComponentWithItsLotIsNotFound`

## TEST-05 — A partly assigned lot is found
- **Given** a forward-flushed lot component with a lot for 2 of 5
- **When** the check runs
- **Then** one finding

**Automation:** `MFG Preflight Tests.PartlyAssignedLotIsFound`

## TEST-06 — A manually flushed component is not checked
- **Given** a manually flushed lot component with no lot
- **When** the check runs
- **Then** nothing is found

**Automation:** `MFG Preflight Tests.ManuallyFlushedLotComponentIsNotChecked`

## TEST-07 — Missing bins at a bin-mandatory location are found
- **Given** an output line and a component without bins at a bin-mandatory location
- **When** the missing bin check runs
- **Then** two findings, one of them for the output

**Automation:** `MFG Preflight Tests.MissingBinsAtABinMandatoryLocationAreFound`

## TEST-08 — No bin is needed where bins are not mandatory
- **Given** the same order at a location that does not require bins
- **When** the check runs
- **Then** nothing is found

**Automation:** `MFG Preflight Tests.NoBinNeededWhereBinsAreNotMandatory`

## TEST-09 — An uncertified BOM is found, a certified one is not
- **Given** an order line calculated from a BOM under development
- **When** the design check runs, then the BOM is certified and it runs again
- **Then** one finding the first time, none the second

**Automation:** `MFG Preflight Tests.UncertifiedBomIsFoundAndCertifiedIsNot`

## TEST-10 — Ensuring the checks keeps the user's severity
- **Given** the checks exist and one was switched off
- **When** they are ensured again
- **Then** there are five rows and the switched-off check stays off

**Automation:** `MFG Preflight Tests.EnsureChecksCreatesEveryCheckAndKeepsTheUsersSeverity`

## TEST-11 — The engine skips an off check and applies a configured severity
- **Given** an order with a routing link problem
- **When** the check is off, then raised to Error
- **Then** no finding the first time, a finding with severity Error the second

**Automation:** `MFG Preflight Tests.TheEngineSkipsAnOffCheckAndAppliesAConfiguredSeverity`

## TEST-12 — Storing findings replaces the previous run
- **Given** an order with a problem
- **When** the checks run and are stored twice
- **Then** only the last run is stored, with the user who ran it

**Automation:** `MFG Preflight Tests.StoringFindingsReplacesThePreviousRun`

## TEST-13 — Nothing happens on release while the feature is off
- **Given** the feature off and an order with an error
- **When** the order is about to be released
- **Then** no error and nothing stored

**Automation:** `MFG Preflight Tests.NothingHappensOnReleaseWhileTheFeatureIsOff`

## TEST-14 — A release with an error is refused
- **Given** the feature on, blocking, and an order with an error
- **When** the order is about to be released
- **Then** the error says it cannot be released and names the order

**Automation:** `MFG Preflight Tests.ReleaseIsRefusedWhenAnErrorIsFound`

## TEST-15 — Other status changes are not checked
- **Given** the same order
- **When** it is about to change to Finished
- **Then** no error and nothing stored

**Automation:** `MFG Preflight Tests.OtherStatusChangesAreNotChecked`

## TEST-16 — Declining a warning stops the release
- **Given** the feature on, asking about warnings, and an order with a warning
- **When** the order is about to be released and the user declines
- **Then** the release stops with an empty error

**Automation:** `MFG Preflight Tests.DecliningAWarningStopsTheRelease`

## TEST-17 — An error only warns when blocking is off
- **Given** blocking off and an order with an error
- **When** the order is about to be released and the user accepts
- **Then** no error, and the finding is stored

**Automation:** `MFG Preflight Tests.AnErrorOnlyWarnsWhenBlockingIsOff`

## TEST-18 — The feature registers a guided setup step
- **When** the feature is asked for its step
- **Then** one step with a toggle that opens the feature setup page

**Automation:** `MFG Preflight Tests.TheFeatureRegistersAGuidedSetupStep`

## TEST-19 — Switching the feature on moves the fingerprint
- **Given** the feature off
- **When** it is switched on
- **Then** the enabled fingerprint changes and the facade reports the feature enabled

**Automation:** `MFG Preflight Tests.SwitchingTheFeatureOnMovesTheFingerprint`

## TEST-20 — Importing sample data twice creates it once
- **When** the sample data is imported twice
- **Then** five check rows, at most one sample order, and the configuration package exist

**Automation:** `MFG Preflight Tests.ImportingSampleDataTwiceCreatesItOnce`

## TEST-21 — A pick method without warehouse handling is found (PRE-002)
- **Given** a Pick + Backward component at a location with no warehouse handling for consumption
- **When** the flushing against warehouse handling check runs
- **Then** one finding

**Automation:** `MFG Preflight Tests.PickFlushingWithoutWarehouseHandlingIsFound`

## TEST-22 — Pick + Forward without a routing link is found
- **Given** at a location with optional warehouse picks, two Pick + Forward components, one with a routing link
- **When** the check runs
- **Then** only the one without a routing link is reported

**Automation:** `MFG Preflight Tests.PickForwardWithoutRoutingLinkIsFound`

## TEST-23 — Automatic flushing where the pick is mandatory is found
- **Given** at a location with mandatory warehouse picks, a backward, a forward and a Pick + Backward component
- **When** the check runs
- **Then** the backward and the forward one are reported, the picked one is not

**Automation:** `MFG Preflight Tests.AutomaticFlushingWhereThePickIsMandatoryIsFound`

## TEST-24 — Flushing that fits the warehouse is not found
- **Given** manual and backward components without warehouse handling, and Pick + Manual at an inventory pick location
- **When** the check runs
- **Then** nothing is reported

**Automation:** `MFG Preflight Tests.FlushingThatFitsTheWarehouseIsNotFound`
