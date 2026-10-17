# CLAUDE.md

Krowi's Brokers [System] (prefix `KrowiBSY`, acronym `KBSY`) is a World of Warcraft LibDataBroker addon in Lua 5.1 that puts FPS, latency and bandwidth on a broker bar and lists every loaded addon's memory and CPU use in its tooltip. The workspace-wide rules (tooling traps, the game loop, taint, git, release safety, how Krowi wants choices presented) load from `../CLAUDE.md` and `Krowi_ClaudeKit/WowAddons.md`; this file adds only what is specific to this repo.

There is no build, lint or test step: the game is the test harness. The `krowi` plugin (enabled in `.claude/settings.json`) syntax-checks every edited `.lua` with Lua 5.1 and guards the known tooling traps. The repo is public, but `.claude/settings.json` points at the private kit by absolute path, so the plugin loads only on Krowi's machine; that is intended.

## Clients and loading

- One TOC, `Krowi_Brokers_System.toc`, for every client: `## Interface: 120000, 110207, 50503, 20505, 11508` (Retail 12.0 and 11.2.7, Mists Classic, TBC Anniversary, Classic Era). The repo has no client-specific code; the differences live in the libraries.
- `## SavedVariables: KrowiBSY_Options, KrowiBSY_SavedData` (account-wide) with `## LoadSavedVariablesFirst: 1`, so the saved values exist when the code runs: `Krowi_Brokers_System.lua:3-41` merges `defaultOptions` into `KrowiBSY_Options` key by key at file scope. A new option is a new default there; a new saved variable must be added to the TOC line or it is lost on logout. There are no migrations.
- Load order is the TOC: `Libs\Files.xml` (Krowi_Util, the bundled CallbackHandler-1.0 and LibDataBroker-1.1, Krowi_Menu, Krowi_Brokers, then `Libs.lua`), `Localization\Files.xml` (`enUS.lua`, `Shared.lua`), `System.lua`, `Tooltip.lua`, `Menu.lua`, `Krowi_Brokers_System.lua`. A file only sees what earlier files defined, and a new `.lua` must be listed in the TOC or a `Files.xml`.
- There is no `ADDON_LOADED` handler: the main file does everything at load (`Krowi_Brokers_System.lua:281-293`). It calls `addon.System.Init()` and `addon.RefreshDisplayConfiguration()`, then `addon.Broker:InitBroker(...)`, which calls `addon.Menu.Init()` and `addon.Tooltip.Init()` and creates the LDB object as `addon.LDB`, and registers `PLAYER_ENTERING_WORLD`. Its first firing starts a 1 s `C_Timer.NewTicker` that calls `addon.LDB:Update()`.

## Libraries

- Submodules under `Libs/`: `Krowi_Util`, `Krowi_Menu`, `Krowi_Brokers` (develop and release them in `../Krowi_Libraries/<lib>`, never here). Bundled, not submodules: CallbackHandler-1.0 and LibDataBroker-1.1. Krowi_Util embeds LibStub, AceLocale and the same CallbackHandler and LibDataBroker minors.
- `Libs/Libs.lua` calls `KROWI_LIBMAN:NewAddon(...)`, which sets `addon.Util` (Krowi_Util), `addon.MenuBuilder` (Krowi_Menu: Blizzard's `MenuUtil` on Retail, a `UIDropDownMenu` frame on Classic), `addon.Broker` (Krowi_Brokers), `addon.Metadata` (TOC fields) and `addon.Localization`.
- `Krowi_Brokers` is shared with Krowi_Brokers_Time and Krowi_Brokers_Currency; a change there usually means releasing all three. Only the first copy loaded runs (`Krowi_Brokers_2`, minor 0), and its single frame `Krowi_Brokers_HelperFrame` hands every event any of these addons registered to every handler (`Libs/Krowi_Brokers/Krowi_Brokers.lua:58-79`), so `OnEvent` must check the event name. It also adds `addon.Menu.CreateElvUIOptionsMenu` and `CreateTitanOptionsMenu`, which `Menu.lua` calls last.

## Architecture

- `System.lua` (`addon.System`): FPS minimum, maximum and average since login, sampled on every broker update and never reset after `Init`; `GetNetStats`; and `GetAllAddOnStats`, which calls `UpdateAddOnMemoryUsage` (and `UpdateAddOnCPUUsage` when the `scriptProfile` CVar is on), collects memory, CPU and the change since the previous call for every loaded addon into reused tables, and sorts them by `AddOnSortBy`.
- `Krowi_Brokers_System.lua`: defaults, colour thresholds (FPS relative to the `maxFPS`/`targetFPS` CVars, latency at 150, 300 and 500 ms) and the broker text. `addon.RefreshDisplayConfiguration()` builds one format pattern and a stat list from the options, and `addon.GetDisplayText()` fills it. Every menu change goes through `addon.Menu.RefreshBroker()`, which rebuilds the pattern and updates the text.
- `Tooltip.lua`: title, FPS, network, the addon list (capped by `MaxAddOnsShown`; holding Shift, Alt or Ctrl flips memory, CPU or increases) and click hints. `OnEnter` redraws it once a second through an `OnUpdate`, and `OnLeave` removes that script.
- `Menu.lua`: the right-click menu, built with `addon.MenuBuilder`; checkboxes and radios write straight into `KrowiBSY_Options`.
- Clicks: left runs `collectgarbage('collect')`, Ctrl+Shift+left flips the `scriptProfile` CVar and calls `ReloadUI()`, right opens the menu.

## Taint-sensitive areas

The tooltip fills Blizzard's shared `GameTooltip` (`Tooltip.lua:234-252`; `OnLeave` hides it). `OnEnter` and `OnLeave` set and clear the `OnUpdate` script of the display's frame (`Krowi_Brokers_System.lua:252` and `262`); that frame belongs to the display addon (Titan Panel, ElvUI, Bazooka), so an `OnUpdate` of its own is replaced. The click handler calls `SetCVar` and `ReloadUI()`. None of the APIs this addon reads (`GetFramerate`, `GetNetStats`, `GetAddOnMemoryUsage`, `GetAddOnCPUUsage`, `C_AddOns`, the streaming status) returns secret values in the 12.1.5 API documentation. Run the `krowi:taint-reviewer` agent after changing the tooltip, the click handler or the event handling.

The baseline review (2026-10-17) found one hazard plausible on Retail 12.x but could not confirm it from source: filling `GameTooltip` from addon code can run Blizzard's widget-set cleanup tainted, the LayoutFrame "secret number value" class of WoWUIBugs #811, and this addon does it once a second while hovered. A private tooltip, ideally one Krowi_Brokers provides for every broker, removes it; an own ticker cancelled in `OnLeave` would also stop overwriting the display frame's `OnUpdate`.

## Localization

`Localization/enUS.lua` and `Shared.lua`, no other locales, so every client shows English. The code is above the `AUTOGENTOKEN` marker (line 4) and the CurseForge export below it; every release replaces everything below the marker with a fresh export. New strings go below the marker, and Krowi has to add them on the CurseForge localization page too (`Shared.lua:1` links it), or the next release drops them. The stat labels `Min`, `Avg`, `Max`, `Current`, `Home`, `World`, `In`, `Out` and the latency labels `MS` and `Latency` are looked up through variables (`AddStatItem`, `LatencyLabelType`); they are not unused. `Shared.lua` sets `addon.L` last.

## Code style

Match the file you are editing:

- Tabs for indentation, except `Libs/Libs.lua` and `system.GetNetStats` (`System.lua:50-55`), which use 4 spaces. Single quotes, except in the CurseForge export. No semicolons.
- Line 1 is `local addonName, addon = ...` in the main file and `local _, addon = ...` elsewhere (`Localization/Shared.lua` opens with its CurseForge link), with no banner above it. A module file makes a local table and publishes it (`local tooltip = {}`, then `addon.Tooltip = tooltip`); its functions are `module.Name` in PascalCase, helpers `local function PascalCase`, locals camelCase. Plain comments mark sections (`-- FPS Tracking`).
- The code that runs every second keeps its scratch variables as file-level locals and reuses tables to avoid garbage (`Tooltip.lua:36-49`, `System.lua:64-72`); keep it that way.
- CRLF on disk (LF in git, `core.autocrlf=true`), no BOM, no final newline.
- `.vscode/settings.json` lists the globals the Lua language server accepts (`Lua.diagnostics.globals`); add a new WoW global there.

## Testing in game

`.vscode/settings.json` fsdeploys on every save (`deployWorkspaceOnSave`) to `_retail_`, `_classic_`, `_classic_era_`, `_ptr_` and `_classic_era_ptr_`. Its nodes exclude `.claude` and `docs` (and `References`, which does not exist), so a save no longer copies a worktree's files into the AddOns folder, but it still redeploys the main checkout over a worktree deploy. Before an in-game check, run the kit's `Deploy.ps1 -WhatIf` and deploy, then `/reload` and `Read-GameErrors.ps1` (see `WowAddons.md`, Closing the loop with the game). The addon needs a broker display: Titan Panel is installed on every client, ElvUI on Classic, Era and the PTR. Hover for the tooltip (with Shift, Alt and Ctrl) and right-click for the menu; Ctrl+Shift+left-click toggles CPU profiling and reloads the UI.

## Git and release

- `main` is the only branch, and both the integration and the release branch: Releases 1.0, 2.0 and 3.0 are commits and tags on `main`. Branch from `main` and open PRs against it.
- Release only with the plugin's `krowi:release` skill; releases are cut on `main`. Uploads are `--stability stable`: every GitHub release so far is a full release.

## Known debt (verified 2026-10-17)

- The TOC's Interface numbers trail the clients (12.1.5, 5.5.4, 2.5.6 and 1.15.9 in wow-ui-source), and 110207 is a Retail version that no longer exists (`Krowi_Brokers_System.toc:1`).
- The TOC claims TBC Anniversary (20505), but `.vscode/settings.json` has no `_anniversary_` node and the addon is not installed in that client.
- `KrowiBSY_SavedData` is created (`Krowi_Brokers_System.lua:43`) and never used.
- While the client streams files, the network section adds two blank lines in a row (`Tooltip.lua:210` and `213`).
- `Libs/Files.xml:4-5` loads the bundled CallbackHandler-1.0 and LibDataBroker-1.1 after Krowi_Util has loaded the same minors, so LibStub ignores them.
- Leftovers: `Localization/Shared.lua:4` sets a local `L` it never uses, and `.vscode/settings.json` lists the global `Krowi_Brokers_EventFrame`, a frame that no longer exists.