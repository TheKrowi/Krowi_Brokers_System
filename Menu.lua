local _, addon = ...;

local menu = {};
addon.Menu = menu;

local menuBuilder;

function menu.Init()
	local lib = LibStub("Krowi_MenuBuilder-1.0");

	menuBuilder = lib:New({
		uniqueTag = addon.Metadata.Prefix .. "_RIGHT_CLICK_MENU_OPTIONS",
		callbacks = {
			OnCheckboxSelect = function(filters, keys)
				addon.Util.WriteNestedKeys(filters, keys, not menuBuilder:KeyIsTrue(filters, keys));
				addon.TemplateLDB:Update();
			end,
			OnRadioSelect = function(filters, keys, value)
				addon.Util.WriteNestedKeys(filters, keys, value);
				addon.TemplateLDB:Update();
			end
		}
	});
end

function CreateMenu(menuObj)
	menuBuilder:CreateTitle(menuObj, addon.Metadata.Title .. " " .. addon.Metadata.Version);

	menuBuilder:CreateDivider(menuObj);

	-- Examples
	menuBuilder:CreateTitle(menuObj, addon.L["Time Format"]);
	local timeFormat = menuBuilder:CreateSubmenuButton(menuObj, addon.L["Format"]);
	menuBuilder:CreateRadio(timeFormat, addon.L["12 Hour"], KrowiBTE_Options, {"TimeFormat"}, "12H");
	menuBuilder:CreateRadio(timeFormat, addon.L["24 Hour"], KrowiBTE_Options, {"TimeFormat"}, "24H");
	menuBuilder:AddChildMenu(menuObj, timeFormat);

	menuBuilder:CreateDivider(menuObj);

	menuBuilder:CreateTitle(menuObj, addon.L["Time Display"]);

	local timeMode = menuBuilder:CreateSubmenuButton(menuObj, addon.L["Display Mode"]);
	menuBuilder:CreateRadio(timeMode, addon.L["Local Time"], KrowiBTE_Options, {"TimeMode"}, "Local");
	menuBuilder:CreateRadio(timeMode, addon.L["Server Time"], KrowiBTE_Options, {"TimeMode"}, "Server");
	menuBuilder:CreateRadio(timeMode, addon.L["Both"], KrowiBTE_Options, {"TimeMode"}, "Both");
	menuBuilder:AddChildMenu(menuObj, timeMode);

	menuBuilder:CreateDivider(menuObj);

	menuBuilder:CreateCheckbox(menuObj, addon.L["Show Seconds"], KrowiBTE_Options, {"ShowSeconds"});

	-- Other menu items can be added here
end

function menu.ShowPopup()
	menuBuilder:ShowPopup(function()
		local menuObj = menuBuilder:GetMenu();
		CreateMenu(menuObj);
	end);
end