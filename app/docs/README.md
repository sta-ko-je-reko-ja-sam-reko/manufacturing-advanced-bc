# Documentation

| Folder / file | Content |
|---|---|
| [architecture.md](architecture.md) | How the foundation and the switchable features fit together; polymorphic logic, APIs, MCP, configuration packages |
| [modules.md](modules.md) | Candidate modules, what standard BC does today, what is out of scope because Microsoft ships it, and the object ID allocation |
| [roadmap.md](roadmap.md) | The order the features are built in, and why |
| [getting-started-english.md](getting-started-english.md) | End-user guide: the master index, one link per feature as it ships |
| [privacy.md](privacy.md) | What the app stores and sends |
| `FEAT-CORE-001-Foundation/` | Setup record, guided setup, feature facade, shared helpers |
| `FEAT-PRE-001-ReleasePreflight/` | Checks before release: routing links, flushing and item tracking, production bins, certified designs |
| `FEAT-WIP-001-WIPControl/` | Finish proposals for released orders with complete output: WIP valuation, checks before finishing, batch finish |
| `FEAT-RFP-001-RefreshProtection/` | Snapshot, comparison and restore around Refresh Production Order, for components and operations |
| `FEAT-STD-001-StandardCostDrift/` | Standard cost drift against roll-up and purchase price, standard cost worksheet, order variances by type |
| `FEAT-<AREA>-<NNN>-<Title>/` | One folder per feature: technical documentation, test plans, getting started, agent instructions |

## Conventions for a feature folder

- `technical-documentation.md` and `getting-started-english.md` are required; `test-plan-unit-test.md` and
  `test-plan-integration-test.md` whenever the feature has tests, which is always.
- The H1 of every file is exactly `# {MARK} - {Title}`, for example `# FEAT-PRE-001 - Release Pre-flight`.
- Getting-started pages are for end users: refer to things by the caption on screen, never by object
  names, IDs or code.
- A feature that creates MCP configurations keeps one agent-instructions file per configuration in
  `agent-instructions/`.

The app supports English only (`supportedLocales` en-US), so each feature has an English getting-started
page and no locale copy.
