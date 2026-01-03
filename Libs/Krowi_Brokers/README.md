![Retail](https://img.shields.io/badge/Retail-11.2.7-008833?style=for-the-badge) ![Mists](https://img.shields.io/badge/Mists-5.5.3-28ae7e?style=for-the-badge) ![Classic](https://img.shields.io/badge/Classic-1.15.8-c39361?style=for-the-badge)<br>
[![CurseForge](https://img.shields.io/badge/curseforge-download-F16436?style=for-the-badge&logo=curseforge&logoColor=white)](https://www.curseforge.com/wow/addons/krowi-brokers) [![Wago](https://img.shields.io/badge/Wago-Download-c1272d?style=for-the-badge)](https://addons.wago.io/addons/krowi-brokers)<br>
[![Discord](https://img.shields.io/badge/discord-join-5865F2?style=for-the-badge&logo=discord&logoColor=white)](https://discord.gg/mdBFQJYeQZ) [![PayPal](https://img.shields.io/badge/paypal-donate-002991.svg?style=for-the-badge&logo=paypal&logoColor=white)](https://www.paypal.com/donate/?hosted_button_id=9QEDV37APQ6YJ)

A lightweight library for World of Warcraft addon development that simplifies creating LibDataBroker data sources with integrated event handling, custom callbacks, and automatic initialization.

## Features

### Broker System (`Krowi_Brokers-1.0`)
- **Simple API**: Easy-to-use method for initializing LibDataBroker data objects
- **Integrated Event Handling**: Built-in event frame management for handling WoW events
- **Custom Callbacks**: Support for OnEnter, OnLeave, OnClick, and OnEvent callbacks
- **Automatic Updates**: Dynamic text updates through getDisplayText callback
- **Menu Integration**: Optional menu system initialization support
- **Tooltip Integration**: Optional tooltip system initialization support
- **Multiple Handlers**: Support for multiple event handlers on the same event frame
- **LibStub Support**: Standard LibStub library structure for dependency management

## Usage Examples

### Basic Broker Setup

```lua
local broker = LibStub("Krowi_Brokers-1.0")

-- Initialize a simple broker
broker:InitBroker(
    "MyAddon",                    -- Addon name
    MyAddon,                       -- Addon object (must have Metadata.Title and Metadata.Version)
    "Interface\\Icons\\INV_Misc_QuestionMark", -- Icon
    function(frame)                -- OnEnter
        GameTooltip:SetOwner(frame, "ANCHOR_LEFT")
        GameTooltip:AddLine("My Addon")
        GameTooltip:Show()
    end,
    function(frame)                -- OnLeave
        GameTooltip:Hide()
    end,
    function(frame, button)        -- OnClick
        print("Broker clicked with " .. button)
    end,
    function(self, event, ...)     -- OnEvent
        print("Event received:", event)
    end,
    function()                     -- GetDisplayText
        return "Dynamic Text: " .. time()
    end,
    nil,                           -- Menu (optional)
    nil                            -- Tooltip (optional)
)
```

### Advanced Example with Event Handling

```lua
local broker = LibStub("Krowi_Brokers-1.0")

-- Create addon object with metadata
local MyAddon = {
    Metadata = {
        Title = "My Broker Addon",
        Version = "1.0.0"
    }
}

-- Initialize broker with event handling
broker:InitBroker(
    "MyBrokerAddon",
    MyAddon,
    "Interface\\Icons\\Achievement_General",
    OnEnterHandler,
    OnLeaveHandler,
    OnClickHandler,
    OnEventHandler,
    GetDisplayText,
    MenuSystem,
    TooltipSystem
)

-- Register additional events
broker:RegisterEvents("PLAYER_ENTERING_WORLD", "ZONE_CHANGED_NEW_AREA")

-- The broker data object is now available at MyAddon.LDB
-- Update display text manually
MyAddon.LDB:Update()
```

### Event Handler Implementation

```lua
-- Example event handler function
local function OnEventHandler(self, event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        print("Player entered world")
    elseif event == "ZONE_CHANGED_NEW_AREA" then
        local zoneName = GetZoneText()
        print("Zone changed to:", zoneName)
    end
end

-- Register multiple event handlers for the same events
local broker = LibStub("Krowi_Brokers-1.0")

broker:RegisterOnEvent(function(self, event, ...)
    print("Handler 1:", event)
end)

broker:RegisterOnEvent(function(self, event, ...)
    print("Handler 2:", event)
end)

-- Register the events to listen for
broker:RegisterEvents("PLAYER_REGEN_DISABLED", "PLAYER_REGEN_ENABLED")
```

## API Reference

### Krowi_Brokers-1.0

#### Creating a Broker Library Instance
```lua
local broker = LibStub("Krowi_Brokers-1.0")
```

#### Broker Functions

| Function | Parameters | Description |
|----------|------------|-------------|
| `InitBroker(addonName, addon, icon, onEnter, onLeave, onClick, onEvent, getDisplayText, menu, tooltip)` | See below | Initializes a LibDataBroker data object with callbacks and event handling |
| `CreateEventFrame()` | - | Creates the shared event frame (called automatically) |
| `GetEventFrame()` | - | Returns the shared event frame, creating it if it doesn't exist |
| `RegisterEvents(...)` | `...` (strings) | Registers one or more WoW events to the event frame |
| `RegisterOnEvent(handler)` | `handler` (function) | Adds an event handler function that will be called for all registered events |

#### InitBroker() Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `addonName` | string | Yes | Name of the addon, used as the broker data object name |
| `addon` | table | Yes | Addon object that must have `Metadata.Title` and `Metadata.Version` fields |
| `icon` | string | Yes | Path to the icon texture file |
| `onEnter` | function | No | Callback when mouse enters the broker frame. Parameters: `(frame)` |
| `onLeave` | function | No | Callback when mouse leaves the broker frame. Parameters: `(frame)` |
| `onClick` | function | No | Callback when broker is clicked. Parameters: `(frame, button)` |
| `onEvent` | function | No | Callback for registered events. Parameters: `(self, event, ...)` |
| `getDisplayText` | function | Yes | Function that returns the current display text for the broker |
| `menu` | table | No | Optional menu system object with an `Init()` method |
| `tooltip` | table | No | Optional tooltip system object with an `Init()` method |

#### Event Handler Function Signature

Event handlers registered via `RegisterOnEvent` or passed to `InitBroker` should follow this signature:

```lua
function(self, event, ...)
    -- self: the event frame
    -- event: string name of the WoW event
    -- ...: event-specific arguments
end
```

#### Broker Data Object

After calling `InitBroker`, the LibDataBroker data object is stored at `addon.LDB` with the following properties and methods:

| Property/Method | Type | Description |
|-----------------|------|-------------|
| `type` | string | Always set to "data source" |
| `tocname` | string | The addon name |
| `icon` | string | Path to the icon texture |
| `text` | string | Current display text |
| `category` | string | Always set to "Information" |
| `OnEnter` | function | Mouse enter callback |
| `OnLeave` | function | Mouse leave callback |
| `OnClick` | function | Click callback |
| `Update()` | method | Call this to update the display text using `getDisplayText()` |

## Use Cases
- Creating LibDataBroker plugins for broker addons like Bazooka, ChocolateBar, Titan Panel
- Displaying dynamic information in the broker display
- Handling WoW events in broker addons
- Creating lightweight information displays
- Building data source plugins with minimal boilerplate code
- Managing event-driven broker updates

## Requirements
- LibStub
- LibDataBroker-1.1