A comprehensive utility library for World of Warcraft addon development, providing reusable functions for string manipulation, table operations, color management, metadata handling, and more.

## Features

### Core Utilities (`Krowi_Util-1.0`)
- **Version Detection**: Automatic detection of WoW version (Mainline, Classic variants)
- **Table Operations**: Merge, copy, search, and manipulate tables
- **Nested Key Operations**: Safe access to deeply nested table values
- **Delayed Execution**: Timer-based function delays
- **Type Checking**: Complete set of type validation functions
- **LibStub Support**: Standard LibStub library structure for dependency management

### String Utilities (`Krowi_Strings-1.0`)
- **Variable Replacement**: Template-based string formatting with `{varName}` syntax
- **UI Helpers**: Reload requirement and default value text generation
- **String Extensions**: Methods added directly to the string type

### Color Management (`Krowi_Colors-1.0`)
- **Color Utilities**: Apply and remove color codes from text
- **RGB/Hex Conversion**: Convert between RGB percentages and hex values
- **Predefined Colors**: Quest difficulty colors (Green, Grey, Red, Orange, Yellow)
- **Item Quality Colors**: Poor, Common, Uncommon, Rare, Epic
- **Dynamic String Methods**: Auto-generated `SetColor*` methods for convenient styling

### Metadata Management (`Krowi_MetaData-1.0`)
- **Addon Information Extraction**: Parse TOC file metadata
- **Custom Field Support**: Discord, CurseForge, Wago, WoWInterface links
- **Version Tracking**: Automatic build and version concatenation

### Credits System (`Krowi_Credits-1.0`)
- **Contributor Recognition**: Formatted lists for special thanks, donations, and localizations
- **Class Coloring**: Automatic character class color formatting

### Additional Features
- **Minimap Icon Support** (`Icon.lua`): LibDBIcon integration with tooltip and click handling
- **Options Framework** (`Options/`): Profile management and AceConfig integration
- **Localization Support**: English, German, French, Chinese (Simplified)

## Usage Examples

### Basic Setup
```lua
local util = LibStub("Krowi_Util-1.0")
```

### String Variable Replacement
```lua
local text = util.Strings.ReplaceVars("Hello {name}, you have {count} items", {
    name = "Player",
    count = 5
})
-- Result: "Hello Player, you have 5 items"
```

### Color Management
```lua
local colors = util.Colors
local coloredText = colors.SetTextColor("Warning!", colors.Red)

-- Or use string method:
local epicText = ("Legendary Item"):SetColorEpic()
local greenText = ("Completed"):SetColorGreen()
```

### Table Operations
```lua
-- Safe nested access
local data = {player = {stats = {health = 100}}}
local health = util.SafeGet(data, {"player", "stats", "health"}) -- Returns 100
local missing = util.SafeGet(data, {"player", "items", "sword"}) -- Returns nil safely

-- Deep copy
local original = {a = 1, b = {c = 2}}
local copy = {}
util.DeepCopyTable(original, copy)

-- Delayed function execution
util.DelayFunction("myDelay", 2, function(msg) print(msg) end, "Hello after 2 seconds")
```

### Version Detection
```lua
if util.IsMainline then
    -- Retail-specific code (The War Within, Midnight)
elseif util.IsMistsClassic then
    -- Mists Classic-specific code
end
```

### Metadata Extraction
```lua
local metadata = util.Metadata.GetAddOnMetadata("YourAddon")
print(metadata.Title, metadata.Version, metadata.Author)
print(metadata.DiscordInviteLink, metadata.CurseForge)
```

## API Reference

### Core Utility Functions

| Function | Parameters | Returns | Description |
|----------|------------|---------|-------------|
| `ConcatTables` | `t1, t2` | table | Merges two tables (appends t2 to t1) |
| `DeepCopyTable` | `src, dest` | - | Deep copies all elements from src to dest |
| `ReadNestedKeys` | `tbl, keys` | any | Reads value from nested table using key array |
| `WriteNestedKeys` | `tbl, keys, value` | - | Writes value to nested table using key array |
| `SafeGet` | `source, path` | any | Safe nested access, returns nil if path invalid |
| `Enum` | `table` | table | Converts array to enum (modifies original) |
| `Enum2` | `table` | table | Converts array to enum (returns new table) |
| `StringSplitTable` | `delimiter, str` | table | Splits string into table by delimiter |
| `DelayFunction` | `name, delay, func, ...` | - | Executes function after delay with args |
| `TableRemoveByValue` | `table, value` | boolean | Removes element by value, returns success |
| `TableFindKeyByValue` | `table, value` | any | Returns key for given value |
| `InjectMetatable` | `tbl, meta` | table | Injects metatable into table |

### Type Checking Functions

| Function | Parameter | Returns | Description |
|----------|-----------|---------|-------------|
| `IsNil` | `value` | boolean | Checks if value is nil |
| `IsNumber` | `value` | boolean | Checks if value is number |
| `IsString` | `value` | boolean | Checks if value is string |
| `IsBoolean` | `value` | boolean | Checks if value is boolean |
| `IsTable` | `value` | boolean | Checks if value is table |
| `IsFunction` | `value` | boolean | Checks if value is function |
| `IsThread` | `value` | boolean | Checks if value is thread |
| `IsUserData` | `value` | boolean | Checks if value is userdata |

### String Utility Functions

| Function | Parameters | Returns | Description |
|----------|------------|---------|-------------|
| `Strings.ReplaceVars` | `str, vars` | string | Replaces `{key}` placeholders with values from vars table |
| `Strings.AddReloadRequired` | `str` | string | Appends reload requirement message |
| `Strings.AddDefaultValueText` | `str, startTbl, valuePath, values` | string | Appends default value information |

### Color Functions

| Function | Parameters | Returns | Description |
|----------|------------|---------|-------------|
| `Colors.SetTextColor` | `text, color` | string | Wraps text in color code |
| `Colors.RemoveColor` | `text` | string | Strips all color codes from text |
| `Colors.RGBPrct2HEX` | `r, g, b, a` | string | Converts RGB percentages (0-1) to hex string |

### Available Color Constants

**Quest Difficulty Colors:**
- `AddonBlue`, `Green`, `LightGreen`, `Grey`, `LightGrey`, `Red`, `LightRed`, `Orange`, `LightOrange`, `Yellow`, `White`

**Item Quality Colors:**
- `Poor`, `Common`, `Uncommon`, `Rare`, `Epic`

Each color is available as both RGB table (`*RGB`) and formatted string.

### String Color Methods
All colors automatically extend the string type:
```lua
("text"):SetColorRed()
("text"):SetColorEpic()
("text"):SetColorGreen()
-- etc. for all color constants
```

### Metadata Functions

| Function | Parameters | Returns | Description |
|----------|------------|---------|-------------|
| `Metadata.GetAddOnMetadata` | `addonName` | table | Returns comprehensive addon metadata |

**Returned Metadata Fields:**
- `AddonName`, `Title`, `Prefix`, `Acronym`, `Build`, `Version`, `BuildVersion`, `Author`, `Icon`
- `DiscordInviteLink`, `DiscordServerName`, `CurseForge`, `Wago`, `WoWInterface`

### Credits Functions

| Function | Parameters | Returns | Description |
|----------|------------|---------|-------------|
| `Credits.GetSpecialThanksAsTable` | - | table | Returns formatted array of special thanks |
| `Credits.GetDonationsAsTable` | - | table | Returns formatted array of donors |
| `Credits.GetLocalizationsAsTable` | - | table | Returns formatted array of translators |

### Version Detection Properties

| Property | Type | Description |
|----------|------|-------------|
| `IsMistsClassic` | boolean | True if running Mists of Pandaria Classic |
| `IsClassicWithAchievements` | boolean | True if Classic version with achievements |
| `IsTheWarWithin` | boolean | True if running The War Within expansion |
| `IsMidnight` | boolean | True if running Midnight expansion |
| `IsMainline` | boolean | True if running retail (The War Within or Midnight) |

## Use Cases
- Dynamic text generation for tooltips, messages, and UI elements
- Safe nested table navigation without nil reference errors
- Consistent color styling matching WoW's quest and item quality colors
- Version-specific feature implementation
- Reusable utility functions for common operations
- Addon metadata extraction and display
- Profile management and options configuration

## Requirements
- LibStub
- AceLocale-3.0
- AceConfig-3.0 (for options)
- AceConfigDialog-3.0 (for options UI)
- LibDBIcon-1.0 (for minimap icon)
- LibDataBroker-1.1 (for minimap icon)