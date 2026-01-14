# Changelog
All notable changes to this project will be documented in this file.

## 3.0 - 2026-01-14
### Added
- Support for WoW 12.0.0 (Midnight)
- Library rework changes integrated (dev note: this change affects all addons and is a preparation for a better unified system for long term support)

## 2.0 - 2026-01-07
### Added
- Added option to limit the number of addon lines shown in tooltip (configurable from 10-100 or unlimited)
- "Max Shown" submenu under AddOn options with presets: Unlimited, 10, 20, ..., 100
- "... and X more" indicator displayed when addons are hidden from view
- All memory and CPU totals are still calculated correctly regardless of display limit

### Changed
- Moved to defaults merging pattern for saved variables to ensure new options are added for existing installations
- Added LoadSavedVariablesFirst flag to TOC for proper initialization order
- Updated Krowi_Brokers library to version 1.0.5

## 1.0 - 2026-01-04
### Added
- Initial release
- FPS tracking with current, minimum, maximum, and average statistics
- Network monitoring: home and world latency, bandwidth usage
- Addon resource tracking: memory and CPU usage per addon
- Customizable display options for all metrics
- Color-coded performance thresholds
- Flexible label and decimal precision settings
- Right-click menu for quick access to settings
- Left-click to trigger garbage collection
- Ctrl+Shift+Left-Click to toggle CPU profiling (requires UI reload)
- Tooltip shows modifier key hints for toggling memory/CPU/increase display
- Organized menu structure with submenus for each category
- Reverse sort option for addon list
- Flexible modifier key controls: Shift (memory), Alt (CPU), Ctrl (increases)