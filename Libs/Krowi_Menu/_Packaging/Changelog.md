# Changelog
All notable changes to this project will be documented in this file.

## 1.0.8 - 2025-12-29
### Added
- MenuBuilder: CreateSubmenuRadio method for creating radio buttons in submenus with custom callbacks
- MenuBuilder: Generic CreateSelectDeselectAll method for flexible batch operations on any filter type
- MenuBuilder: Generic CreateSelectDeselectAllButtons method for creating Select All/Deselect All button pairs
- MenuBuilder: Generic OnAllSelect callback for handling batch select/deselect operations

### Changed
- MenuBuilder: Removed verbose inline documentation, moved detailed API docs to Description.md
- MenuBuilder: Simplified section separators and removed redundant comments
- MenuBuilder: Standardized code formatting (consistent indentation, removed inconsistent semicolons)

### Removed
- MenuBuilder: SetRewardsFilters callback (replaced by generic OnAllSelect)
- MenuBuilder: SetFactionFilters callback (replaced by generic OnAllSelect)
- MenuBuilder: CreateSelectDeselectAllRewards method (replaced by generic CreateSelectDeselectAll)
- MenuBuilder: CreateSelectDeselectAllFactions method (replaced by generic CreateSelectDeselectAll)

## 1.0.7 - 2025-12-29
### Changed
- MenuBuilder: Fixed KeyEqualsText callback parameter order to match documentation (filters, keys, value)
- MenuBuilder: Updated CreateRadio methods to support custom value parameter separate from display text

### Added
- MenuBuilder: CreateCustomCheckbox method for custom checkbox implementations
- MenuBuilder: CreateCustomRadio method for custom radio button implementations

## 1.0.6 - 2025-12-28
### Added
- MenuBuilder: BindCallbacks utility function to eliminate callback boilerplate
- MenuBuilder: Default implementations for KeyIsTrue and KeyEqualsText using Krowi_Util
- Version constants (MAJOR, MINOR) exposed on all library objects
- Shared KROWI_MENU_LIBRARY_MINOR constant for consistent versioning across all files

## 1.0.5 - 2025-12-08
### Fixed
- Krowi_PopupDialog reference

## 1.0.4 - 2025-12-07
### Changed
- Codebase for upload