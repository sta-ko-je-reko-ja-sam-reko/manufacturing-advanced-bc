# Manufacturing Advanced — BC AL Extension (Greenfield)

A from-scratch Business Central AL extension adding **guardrails** (checks on the standard production
flows) and **capabilities** to the manufacturing module. It is a new implementation, not a Navision/NAV
port, and it has **no customer**: the scope in `app/docs/modules.md` is a hypothesis. **This repository is
public.**

## Authoritative rules live elsewhere — read them first

This project follows the owner's private BC conventions, wired in locally as directory junctions
(gitignored) that **override this file** if the two disagree:

| Need | File |
|---|---|
| Coding standards (naming, namespaces, cops, labels, **no custom publishers** §4b) | `.bc-conventions/instructions/02-al-coding-standards.md` |
| Folder + file naming | `.bc-conventions/instructions/03-source-folder-layout.md` |
| Per-object-type authoring guide | `.bc-conventions/al-object-types/<type>.md` |
| Polymorphic table logic (**mandatory**) | `.bc-conventions/al-object-types/_patterns/polymorphic-table-logic.md` |
| Feature setup + `Enabled` toggle + application area | `.bc-conventions/al-object-types/_patterns/feature-setup-and-toggle.md` |
| Assisted setup hub + wizard | `.bc-conventions/al-object-types/_patterns/assisted-setup-orchestration.md` |
| API pages, one API group per feature | `.bc-conventions/al-object-types/_patterns/api-pages.md` |
| Demo data, import APIs, configuration packages | `.bc-conventions/al-object-types/_patterns/demo-data-and-import-apis.md` |
| MCP configurations + agent instructions | `.bc-conventions/al-object-types/_patterns/mcp-configuration-instructions.md` |
| Event subscriber proxies | `.bc-conventions/al-object-types/_members/event-subscribers.md` |
| Testing | `.bc-conventions/instructions/05-testing-standards.md` |
| Greenfield feature workflow | `.greenfield/instructions/02-feature-workflow.md` |
| Definition of done | `.greenfield/checklists/feature-ready.md` |

`.bc-conventions` points at the base (customer-project) template and `.greenfield` at the greenfield template
of the conventions repository:

```powershell
cmd /c mklink /J .bc-conventions <conventions>\bc-customer-project-template
cmd /c mklink /J .greenfield     <conventions>\bc-greenfield-template
```

A clone without them cannot build (`tools/build.ps1` needs the shared ruleset).

**Public-repo rule:** never commit content of the private conventions (no copied guides, no ruleset copy, no
repository name) and nothing from the owner's private product repositories.

## Project-specific values

| What | Value |
|---|---|
| App | `Manufacturing Advanced`, publisher `matr`; tests `Manufacturing Advanced Tests` |
| Affix | `MFG` (`app/AppSourceCop.json`, `test/AppSourceCop.json`) |
| Namespace root | `ManufacturingAdvanced.<Feature>` — `Core`, then one per feature folder; tests `ManufacturingAdvanced.Test` |
| Object IDs | app `85000..88999`, test `89000..89999` — block 8 of the owner's ID range registry; per-module sub-blocks of 100 in `app/docs/modules.md`. Never use IDs outside the block |
| Feature marks | `FEAT-CORE-001`, `FEAT-PRE-001`, `FEAT-WIP-001`, `FEAT-RFP-001`, `FEAT-STD-001`, `FEAT-PLN-001`, `FEAT-SFT-001`, `FEAT-ECO-001`, `FEAT-FCL-001` |
| API | publisher `matr`, version `v1.0`, one group per feature (`mfgPreflight`, `mfgWip`, …), demo importers in `demo<Feature>` |
| BC target | **29.0** W1 (`application` 29.0.0.0, runtime 18.0), artifact `sandbox/29.0.54011.55616/w1` |
| Dependencies | Base and System Applications only. Production tables are in the Base Application; Microsoft's *Manufacturing* app is a licensing shell |
| Out of scope | Subcontracting and Quality Management: Microsoft ships both as apps in BC 29. Guardrails must still work when they are installed |
| Distribution | Per-tenant extension, `target: Cloud` |
| Language | English only (`supportedLocales` en-US) |

## Environment

| | |
|---|---|
| Dev container | `bc29loc` — BC 29.0.54011.55616 W1, shared with the owner's other apps, which all install side by side |
| Auth | NavUserPassword (`"authentication": "UserPassword"` in `launch.json`) |
| Dev endpoint | `http://bc29loc:7049/BC/dev`, web client `http://bc29loc/BC/?tenant=default` |

`app/.vscode/launch.json` and `test/.vscode/launch.json` are committed and target bc29loc (no credentials).

## Building and testing

```powershell
powershell -ExecutionPolicy Bypass -File tools\build.ps1            # app + test
powershell -ExecutionPolicy Bypass -File tools\build.ps1 -Project app
```

`tools\build.ps1` checks that every object is in a permission set, refreshes `.alpackages` from the artifact
cache, compiles with CodeCop, UICop, AppSourceCop and PerTenantExtensionCop using `mfg.ruleset.json` (which
includes the shared ruleset), then copies the fresh app package into `test/.alpackages`. **Zero errors and zero
warnings** is the bar. `tools\test.ps1` publishes both packages to bc29loc and runs the test app; it needs
BcContainerHelper, an elevated PowerShell and the container credentials, so **the owner runs it**.

## Reading Microsoft's code

Read Microsoft objects from the symbols or from the source archive in the artifact cache
(`platform/Applications/BaseApp/Source/Base Application.Source.zip`; production objects are under
`Manufacturing/`). Never assume an event name or signature. Hooks already confirmed in BC 29:
`Prod. Order Status Management` `OnBeforeChangeStatusOnProdOrder` / `OnAfterChangeStatusOnProdOrder`;
`Refresh Production Order` `OnBeforeCalcRoutingsOrComponents` / `OnAfterRefreshProdOrder`;
`Calculate Prod. Order` `OnBeforeCalculate` / `OnAfterCalculate`.

## Git

- Branch per change, created with `git checkout -b <branch> --no-track origin/main`; push with
  `git push -u origin <branch>`; open a PR to `main`. **Only the owner merges PRs.**
- `main` is protected by the ruleset *Protect main*: pull request with one code-owner approval (`.github/CODEOWNERS`),
  squash merge only, linear history, no force push or deletion.
- Git identity and the `gh` credential helper are repo-local (global config is kept empty).
