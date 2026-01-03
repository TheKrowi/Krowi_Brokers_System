### Changed
- Codebase for upload

### Fixed (1.0.5)
- Krowi_PopupDialog reference

### Added (1.0.6)
- MenuBuilder: BindCallbacks utility function to eliminate callback boilerplate
- MenuBuilder: Default implementations for KeyIsTrue and KeyEqualsText using Krowi_Util
- Version constants (MAJOR, MINOR) exposed on all library objects
- Shared KROWI_MENU_LIBRARY_MINOR constant for consistent versioning across all files

### Changed (1.0.7)
- MenuBuilder: Fixed KeyEqualsText callback parameter order to match documentation (filters, keys, value)
- MenuBuilder: Updated CreateRadio methods to support custom value parameter separate from display text

### Added (1.0.7)
- MenuBuilder: CreateCustomCheckbox method for custom checkbox implementations
- MenuBuilder: CreateCustomRadio method for custom radio button implementations

### Added (1.0.8)
- MenuBuilder: CreateSubmenuRadio method for creating radio buttons in submenus with custom callbacks
- MenuBuilder: Generic CreateSelectDeselectAll method for flexible batch operations on any filter type
- MenuBuilder: Generic CreateSelectDeselectAllButtons method for creating Select All/Deselect All button pairs
- MenuBuilder: Generic OnAllSelect callback for handling batch select/deselect operations

### Changed (1.0.8)
- MenuBuilder: Removed verbose inline documentation, moved detailed API docs to Description.md
- MenuBuilder: Simplified section separators and removed redundant comments
- MenuBuilder: Standardized code formatting (consistent indentation, removed inconsistent semicolons)

### Removed (1.0.8)
- MenuBuilder: SetRewardsFilters callback (replaced by generic OnAllSelect)
- MenuBuilder: SetFactionFilters callback (replaced by generic OnAllSelect)
- MenuBuilder: CreateSelectDeselectAllRewards method (replaced by generic CreateSelectDeselectAll)
- MenuBuilder: CreateSelectDeselectAllFactions method (replaced by generic CreateSelectDeselectAll)