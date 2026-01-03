A lightweight menu library for World of Warcraft addon development that simplifies creating dropdown menus with support for titles, separators, nested items, and custom styling.

## Features

### Menu System (`Krowi_Menu-1.0`)
- **Simple API**: Easy-to-use methods for building menus programmatically
- **Flexible Menu Items**: Support for titles, separators, checkable items, and disabled states
- **Nested Menus**: Create hierarchical menu structures with children
- **Custom Styling**: Control menu positioning, frame strata, and frame levels
- **Selection State**: Track and refresh selected menu items
- **LibStub Support**: Standard LibStub library structure for dependency management

### Menu Item Builder (`Krowi_MenuItem-1.0`)
- **Item Creation**: Build menu items with custom properties
- **External Links**: Integration with popup dialogs for displaying external links
- **Child Items**: Support for nested menu structures
- **Flexible Options**: Checkable, disabled, and title items

### Menu Utilities (`Krowi_MenuUtil-1.0`)
- **Cross-Version Compatibility**: Unified API for both modern (Mainline) and Classic WoW versions
- **Automatic Detection**: Detects game version and uses appropriate menu system
- **Simplified Interface**: Consistent methods across all WoW versions

### Menu Builder (`Krowi_MenuBuilder-1.0`)
- **High-Level Abstraction**: Simplified API for building complex menus with checkboxes, radio buttons, and filters
- **Callback-Based Architecture**: Flexible callback system for handling menu interactions and state management
- **Smart Defaults**: Automatic integration with `Krowi_Util-1.0` for common operations (KeyIsTrue, KeyEqualsText)
- **Callback Helper**: `BindCallbacks` utility eliminates boilerplate when binding object methods to callbacks
- **Build Version Filters**: Built-in support for creating hierarchical version filter menus with Select/Deselect All
- **Cross-Version Support**: Unified API that works seamlessly on both Modern (Mainline) and Classic WoW
- **Instance-Based**: Create multiple independent menu builders with isolated state and configurations
- **Type Safety**: Full parameter validation with helpful error messages

## Usage Examples

### Basic Menu Setup

```lua
local menu = LibStub("Krowi_Menu-1.0");
local pages = {}; -- Table with data

menu:Clear(); -- Reset menu

menu:AddFull({Text = "View Pages", IsTitle = true});
for i, _ in next, pages do
  menu:AddFull({
    Text = (pages[i].IsViewed and "" or "|T132049:0|t") .. pages[i].SubTitle,
    Func = function()
      -- Some function here
    end
  });
end

menu:Open();
```

### Advanced Example with Nested Menus

```lua
local menu = LibStub("Krowi_Menu-1.0");
local menuItem = LibStub("Krowi_MenuItem-1.0");

menu:Clear();

-- Create a parent item with children
local parent = menuItem:New({Text = "Settings"});
parent:AddFull({
  Text = "Enable Feature",
  Checked = true,
  Func = function() print("Feature toggled") end
});
parent:AddSeparator();
parent:AddFull({
  Text = "Reset to Defaults",
  Func = function() print("Reset") end
});

menu:Add(parent);
menu:Open("cursor");
```

### MenuBuilder Example

```lua
local MenuBuilder = LibStub("Krowi_MenuBuilder-1.0")

-- Configure MenuBuilder with callbacks using BindCallbacks helper
local config = {
    callbacks = MenuBuilder.BindCallbacks(self, {
        GetCheckBoxStateText = "GetCheckBoxStateText",
        KeyIsTrue = "KeyIsTrue",
        OnCheckboxSelect = "OnCheckboxSelect",
        KeyEqualsText = "KeyEqualsText",
        OnRadioSelect = "OnRadioSelect"
    }),
    translations = {
        ["Select All"] = "Select All",
        ["Deselect All"] = "Deselect All",
        ["Version"] = "Version"
    }
}

local builder = MenuBuilder:New(config)

-- Modern WoW: Setup menu on a dropdown button
if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
    builder:SetupMenuForModern(myDropdownButton)
    
    -- Define the menu structure
    function builder:CreateMenu()
        local menu = self:GetMenu()
        self:CreateTitle(menu, "Filter Options")
        self:CreateCheckbox(menu, "Show Completed", filters, {"Completed"})
        self:CreateCheckbox(menu, "Show In Progress", filters, {"InProgress"})
        self:CreateDivider(menu)
        
        local sortMenu = self:CreateSubmenuButton(menu, "Sort By")
        self:CreateRadio(sortMenu, "Name", filters, {"SortBy"}, "name")
        self:CreateRadio(sortMenu, "Date", filters, {"SortBy"}, "date")
    end
else
    -- Classic WoW: Show menu manually
    function builder:CreateMenu()
        local menu = self:GetMenu()
        self:CreateTitle(menu, "Filter Options")
        self:CreateCheckbox(menu, "Show Completed", filters, {"Completed"})
        self:CreateCheckbox(menu, "Show In Progress", filters, {"InProgress"})
        self:CreateDivider(menu)
        
        local sortMenu = self:CreateSubmenuButton(menu, "Sort By")
        self:CreateRadio(sortMenu, "Name", filters, {"SortBy"}, "name")
        self:CreateRadio(sortMenu, "Date", filters, {"SortBy"}, "date")
        self:AddChildMenu(menu, sortMenu)
    end
    
    -- Show the menu when needed
    builder:Show(frameAnchor, 0, 0)
end
```

### Callback Implementation Example

```lua
-- Example object that implements menu callbacks
local MyAddon = {}

function MyAddon:GetCheckBoxStateText(text, filters, keys)
    -- Add visual indicators to checkbox text
    local isChecked = self:KeyIsTrue(filters, keys)
    return (isChecked and "|cFF00FF00✓ |r" or "|cFF808080○ |r") .. text
end

function MyAddon:KeyIsTrue(filters, keys)
    -- Read nested keys from filters table (auto-provided if Krowi_Util-1.0 is available)
    local value = filters
    for _, key in ipairs(keys) do
        value = value[key]
        if value == nil then return false end
    end
    return value == true
end

function MyAddon:OnCheckboxSelect(filters, keys)
    -- Toggle the filter value
    local value = filters
    for i = 1, #keys - 1 do
        value = value[keys[i]]
    end
    local finalKey = keys[#keys]
    value[finalKey] = not value[finalKey]
    
    -- Refresh UI
    self:UpdateDisplay()
end

function MyAddon:KeyEqualsText(filters, keys, text)
    -- Check if filter equals specific value
    local value = filters
    for _, key in ipairs(keys) do
        value = value[key]
        if value == nil then return false end
    end
    return value == text
end

function MyAddon:OnRadioSelect(filters, keys, value)
    -- Set the filter to selected value
    local filterTable = filters
    for i = 1, #keys - 1 do
        filterTable = filterTable[keys[i]]
    end
    filterTable[keys[#keys]] = value
    
    -- Refresh UI
    self:UpdateDisplay()
end
```

## API Reference

### Krowi_Menu-1.0

#### Creating a Menu
```lua
local menu = LibStub("Krowi_Menu-1.0")
```

#### Menu Functions

| Function | Parameters | Description |
|----------|------------|-------------|
| `Clear()` | - | Resets the menu, removing all items |
| `Add(item)` | `item` (MenuItem) | Adds a converted menu item to the menu |
| `AddFull(info)` | `info` (table) | Creates and adds a menu item from info table |
| `AddTitle(text)` | `text` (string) | Adds a title item to the menu |
| `AddSeparator()` | - | Adds a separator line to the menu |
| `Open(anchor, offsetX, offsetY, point, relativePoint, frameStrata, frameLevel)` | See below | Opens and displays the menu |
| `Toggle(...)` | Same as Open | Toggles menu visibility (opens if closed, closes if open) |
| `Close()` | - | Closes the menu if it's currently open |
| `SetSelectedName(name)` | `name` (string) | Sets the selected menu item by name and refreshes display |
| `GetSelectedName(frame)` | `frame` (frame) | Returns the currently selected item name |

#### Open() Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `anchor` | string/frame | "cursor" | Anchor point for menu positioning |
| `offsetX` | number | 0 | Horizontal offset |
| `offsetY` | number | 0 | Vertical offset |
| `point` | string | nil | Point on menu frame |
| `relativePoint` | string | nil | Point on anchor frame |
| `frameStrata` | string | "FULLSCREEN_DIALOG" | Frame strata level |
| `frameLevel` | number | nil | Frame level (auto-raised if strata set without level) |

#### Menu Item Info Table

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `Text` | string | "INFO TEXT" | Display text for the menu item |
| `Checked` | boolean | nil | Whether the item is checked |
| `Func` | function | nil | Function to call when item is clicked |
| `IsTitle` | boolean | nil | Whether this item is a title (non-clickable) |
| `Disabled` | boolean | nil | Whether the item is disabled |
| `IsNotRadio` | boolean | nil | Use checkbox instead of radio button |
| `NotCheckable` | boolean | true | Whether the item can be checked/unchecked |
| `KeepShownOnClick` | boolean | nil | Keep menu open after clicking this item |
| `IgnoreAsMenuSelection` | boolean | nil | Don't update selection state when checked |
| `Children` | table | nil | Array of child menu items for nested menus |
| `IsSeparator` | boolean | nil | Whether this item is a separator line |

### Krowi_MenuItem-1.0

#### Creating Menu Items
```lua
local menuItem = LibStub("Krowi_MenuItem-1.0")
```

#### MenuItem Functions

| Function | Parameters | Returns | Description |
|----------|------------|---------|-------------|
| `New(info, hideOnClick)` | `info` (table/string), `hideOnClick` (boolean) | MenuItem | Creates a new menu item. If info is string, uses it as Text |
| `Add(item)` | `item` (MenuItem) | MenuItem | Adds a child item to this menu item |
| `AddFull(info)` | `info` (table) | MenuItem | Creates and adds a child from info table |
| `AddTitle(text)` | `text` (string) | - | Adds a title child to this menu item |
| `AddSeparator()` | - | MenuItem | Adds a separator child to this menu item |

### Krowi_MenuUtil-1.0

#### Creating Utilities Instance
```lua
local menuUtil = LibStub("Krowi_MenuUtil-1.0")
```

#### MenuUtil Functions

| Function | Parameters | Description |
|----------|------------|-------------|
| `CreateTitle(menu, text)` | `menu` (menu), `text` (string) | Creates a title in the menu (adapts to game version) |
| `CreateButton(menu, text, func, isEnabled)` | `menu` (menu), `text` (string), `func` (function), `isEnabled` (boolean) | Creates a menu button (adapts to game version) |
| `CreateDivider(menu)` | `menu` (menu) | Creates a divider/separator (adapts to game version) |
| `AddChildMenu(menu, child)` | `menu` (menu), `child` (MenuItem) | Adds a child to the menu (Classic only) |
| `CreateButtonAndAdd(menu, text, func, isEnabled)` | `menu` (menu), `text` (string), `func` (function), `isEnabled` (boolean) | Creates and adds a button in one call |

**Note:** MenuUtil automatically detects whether the game is running Mainline or Classic and uses the appropriate menu system. On Mainline, it uses the modern menu API. On Classic versions, it uses the `Krowi_MenuItem-1.0` library.

### Krowi_MenuBuilder-1.0

#### Creating a MenuBuilder Instance
```lua
local MenuBuilder = LibStub("Krowi_MenuBuilder-1.0")
local builder = MenuBuilder:New(config)
```

#### Configuration Object

The configuration object passed to `MenuBuilder:New(config)` supports the following fields:

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `callbacks` | table | Yes | Table of callback functions for menu interactions (see Callback Reference below) |
| `translations` | table | No | Table of localized strings. Defaults: `["Select All"]`, `["Deselect All"]`, `["Version"]` |
| `uniqueTag` | string | No | Unique identifier for this instance. Auto-generated from instance address if not provided |

**Example Configuration:**
```lua
local config = {
    callbacks = {
        GetCheckBoxStateText = function(text, filters, keys) return text end,
        KeyIsTrue = function(filters, keys) return false end,
        OnCheckboxSelect = function(filters, keys, ...) end,
        KeyEqualsText = function(filters, keys, value) return false end,
        OnRadioSelect = function(filters, keys, value, ...) end,
        -- Optional version filter callbacks
        IsMinorVersionChecked = function(filters, minor) return false end,
        OnMinorVersionSelect = function(filters, minor) end,
        IsMajorVersionChecked = function(filters, major) return false end,
        OnMajorVersionSelect = function(filters, major) end,
        OnAllVersionsSelect = function(filters, value) end,
        CreateBuildVersionFilterGroups = function(version, filters, menuBuilder) end
    },
    translations = {
        ["Select All"] = "Select All",
        ["Deselect All"] = "Deselect All",
        ["Version"] = "Version"
    },
    uniqueTag = "MyAddonMenu"
}
```

#### Callback Reference

MenuBuilder uses callbacks to interact with your addon's data and respond to user interactions. Callbacks are optional unless specified as required.

**Checkbox Callbacks:**

| Callback | Parameters | Returns | Required | Description |
|----------|------------|---------|----------|-------------|
| `GetCheckBoxStateText` | `text, filters, keys` | string | No | Modifies checkbox text based on state. Default: returns text unchanged |
| `KeyIsTrue` | `filters, keys` | boolean | No* | Checks if a nested key is true. Default: uses `Krowi_Util.ReadNestedKeys` if available |
| `OnCheckboxSelect` | `filters, keys, ...` | void | Yes | Called when checkbox is clicked. Varargs are custom data passed to `CreateCheckbox` |

**Radio Button Callbacks:**

| Callback | Parameters | Returns | Required | Description |
|----------|------------|---------|----------|-------------|
| `KeyEqualsText` | `filters, keys, value` | boolean | No* | Checks if nested key equals value. Default: uses `Krowi_Util.ReadNestedKeys` if available |
| `OnRadioSelect` | `filters, keys, value, ...` | void | Yes | Called when radio button is selected. Varargs are custom data passed to `CreateRadio` |

**Build Version Filter Callbacks (Optional - only needed if using `CreateBuildVersionFilter`):**

| Callback | Parameters | Returns | Description |
|----------|------------|---------|-------------|
| `IsMinorVersionChecked` | `filters, minor` | boolean | Returns whether all patches in minor version are checked |
| `OnMinorVersionSelect` | `filters, minor` | void | Called when minor version checkbox is toggled |
| `IsMajorVersionChecked` | `filters, major` | boolean | Returns whether all versions in major version are checked |
| `OnMajorVersionSelect` | `filters, major` | void | Called when major version checkbox is toggled |
| `OnAllVersionsSelect` | `filters, value` | void | Called when Select All / Deselect All is clicked |
| `CreateBuildVersionFilterGroups` | `version, filters, menuBuilder` | void | Builds the version filter menu structure. Called by `CreateBuildVersionFilter` |

**General Callbacks:**

| Callback | Parameters | Returns | Description |
|----------|------------|---------|-------------|
| `OnAllSelect` | `filters, keys, value` | void | Called by `CreateSelectDeselectAll` for batch operations. Used by `CreateSelectDeselectAllButtons` |

**Notes:**
- *`KeyIsTrue` and `KeyEqualsText` have smart defaults if `Krowi_Util-1.0` library is available
- `keys` parameter is always an array representing nested path, e.g., `{"Filters", "ShowCompleted"}`
- `filters` is your addon's filter data structure
- Varargs (`...`) allow passing custom context to callbacks

#### MenuBuilder Utility Functions

| Function | Parameters | Returns | Description |
|----------|------------|---------|-------------|
| `BindCallbacks(obj, methodNames)` | `obj` (table), `methodNames` (table) | table | Creates callback table by binding object methods. `methodNames` maps callback names to method names on the object |

**Example:**
```lua
-- Instead of manually creating callbacks like this:
local config = {
    callbacks = {
        OnCheckboxSelect = function(filters, keys, ...)
            return MyAddon:OnCheckboxSelect(filters, keys, ...)
        end,
        OnRadioSelect = function(filters, keys, value, ...)
            return MyAddon:OnRadioSelect(filters, keys, value, ...)
        end
    }
}

-- Use BindCallbacks to eliminate boilerplate:
local config = {
    callbacks = MenuBuilder.BindCallbacks(MyAddon, {
        OnCheckboxSelect = "OnCheckboxSelect",
        OnRadioSelect = "OnRadioSelect"
    })
}
```

#### MenuBuilder Methods

#### MenuBuilder Methods

**Menu Management:**

| Function | Parameters | Description |
|----------|------------|-------------|
| `GetMenu()` | - | Returns the current menu object (Modern: MenuProxy, Classic: Krowi_Menu) |
| `Show(anchor, offsetX, offsetY)` | `anchor` (frame), `offsetX` (number), `offsetY` (number) | **Classic only**: Shows menu at anchor. **Modern**: No-op (use SetupMenuForModern) |
| `ShowPopup(createFunc, anchor, offsetX, offsetY)` | `createFunc` (function), `anchor` (frame), `offsetX` (number), `offsetY` (number) | Shows standalone popup menu. Calls `createFunc(builder)` to build menu structure |
| `Close()` | - | **Classic only**: Closes the menu. **Modern**: No-op (auto-managed) |
| `SetupMenuForModern(button)` | `button` (frame with SetupMenu) | **Modern only**: Configures dropdown button. Requires button to have `SetupMenu` method (WowStyle1FilterDropdownMixin) |

**Menu Building:**

All methods support optional `menu` parameter. If omitted, uses `GetMenu()`.

| Function | Parameters | Description |
|----------|------------|-------------|
| `CreateTitle(menu, text)` | `menu`, `text` (string) | Creates non-clickable title header |
| `CreateDivider(menu)` | `menu` | Creates separator line |
| `CreateCheckbox(menu, text, filters, keys, ...)` | `menu`, `text` (string), `filters` (table), `keys` (array), varargs | Creates checkbox. `keys` is path to value in filters. Varargs passed to `OnCheckboxSelect` callback |
| `CreateCustomCheckbox(menu, text, isCheckedFunc, onClickFunc)` | `menu`, `text` (string), `isCheckedFunc` (function), `onClickFunc` (function) | Creates checkbox with direct callback functions, bypassing standard callback system |
| `CreateRadio(menu, text, filters, keys, value, ...)` | `menu`, `text` (string), `filters` (table), `keys` (array), `value` (any), varargs | Creates radio button. `value` is stored when selected (defaults to text). Varargs passed to `OnRadioSelect` |
| `CreateCustomRadio(menu, text, isSelectedFunc, onClickFunc)` | `menu`, `text` (string), `isSelectedFunc` (function), `onClickFunc` (function) | Creates radio button with direct callbacks, bypassing standard callback system |
| `CreateSubmenuButton(menu, text, func, isEnabled)` | `menu`, `text` (string), `func` (function), `isEnabled` (boolean) | Creates button that opens submenu. **Modern**: Returns submenu. **Classic**: Returns MenuItem |
| `CreateSubmenuRadio(menu, text, isSelectedFunc, onClickFunc, isEnabled)` | `menu`, `text` (string), `isSelectedFunc` (function), `onClickFunc` (function), `isEnabled` (boolean) | Creates radio button in submenu with custom callbacks |
| `AddChildMenu(menu, child)` | `menu`, `child` (menu/MenuItem) | **Classic only**: Adds child menu to parent. **Modern**: No-op (auto-managed) |
| `CreateButtonAndAdd(menu, text, func, isEnabled)` | `menu`, `text` (string), `func` (function), `isEnabled` (boolean) | **Modern**: Same as `CreateSubmenuButton`. **Classic**: Creates and adds button in one call |

**Specialized Menu Builders:**

| Function | Parameters | Description |
|----------|------------|-------------|
| `CreateBuildVersionFilter(filters, menu)` | `filters` (table), `menu` | Creates build/patch version filter submenu. Requires version filter callbacks |
| `CreateSelectDeselectAllVersions(version, filters)` | `version` (menu), `filters` (table) | Adds Select All / Deselect All buttons for version filters |
| `CreateSelectDeselectAll(menu, text, filters, keys, value, callback)` | `menu`, `text` (string), `filters` (table), `keys` (array), `value` (boolean), `callback` (function) | Creates button for batch select/deselect. `callback` defaults to `OnAllSelect` |
| `CreateSelectDeselectAllButtons(menu, filters, keys, callback)` | `menu`, `filters` (table), `keys` (array), `callback` (function) | Creates both Select All and Deselect All buttons |
| `CreateMinorVersionGroup(majorGroup, filters, major, minor)` | `majorGroup` (menu), `filters` (table), `major` (table), `minor` (table) | Creates minor version checkbox (e.g., "11.0.x"). Used internally by version filters |
| `CreateMajorVersionGroup(version, filters, major)` | `version` (menu), `filters` (table), `major` (table) | Creates major version checkbox (e.g., "11.x.x"). Used internally by version filters |

**Important Notes:**
- **Modern vs Classic**: Some methods behave differently or are no-ops depending on `WOW_PROJECT_ID`
- **Menu Parameter**: When `menu` is `nil`, methods automatically use `GetMenu()`
- **Varargs**: Extra parameters passed to `CreateCheckbox` and `CreateRadio` are forwarded to callbacks for custom context

## Use Cases
- Right-click context menus
- Dropdown selection menus
- Settings and options menus
- Action selection menus
- Navigation menus
- Custom frame menus
- Any scenario requiring dropdown menu functionality

## Requirements
- LibStub
- Krowi_Util-1.0 (optional, for default MenuBuilder callbacks)