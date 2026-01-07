### Added
- Added option to limit the number of addon lines shown in tooltip (configurable from 10-100 or unlimited)
- "Max Shown" submenu under AddOn options with presets: Unlimited, 10, 20, ..., 100
- "... and X more" indicator displayed when addons are hidden from view
- All memory and CPU totals are still calculated correctly regardless of display limit

### Changed
- Moved to defaults merging pattern for saved variables to ensure new options are added for existing installations
- Added LoadSavedVariablesFirst flag to TOC for proper initialization order
- Updated Krowi_Brokers library to version 1.0.5