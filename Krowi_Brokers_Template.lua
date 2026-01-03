local addonName, addon = ...;

addon.L = LibStub(addon.Libs.AceLocale):GetLocale(addonName);

KrowiBTE_Options = KrowiBTE_Options or {
	ExampleSetting = true,
};

KrowiBTE_SavedData = KrowiBTE_SavedData or {
	-- Saved data can be initialized here
};

error([["Make sure to update your X-Prefix in the toc file to 'KrowiB*' to match the naming convention for Krowi Brokers addons. 
Remove this line after updating the toc file."]]);
error([["Make sure to update your X-Acronym in the toc file to 'KB*' to match the naming convention for Krowi Brokers addons. 
Remove this line after updating the toc file."]]);
error([["Make sure to update your SavedVariables in the toc file to 'KrowiB*_SavedData' to match the naming convention for Krowi Brokers addons. 
Remove this line after updating the toc file."]]);
error([["Make sure to set your X-Curse-Project-ID in the toc file. 
Remove this line after updating the toc file."]]);
error([["Make sure to set your X-Wago-ID in the toc file. 
Remove this line after updating the toc file."]]);

-- Helper functions

-- Main functions

function addon.GetDisplayText()
	return addon.L["Template"] .. ": " .. (KrowiBTE_Options.ExampleSetting and addon.L["Enabled"] or addon.L["Disabled"]);
end

local function OnClick(self, button)
	if button == "LeftButton" then
		-- Add left-click behavior here
		print(addon.L["Left-Click Action"]);
		return;
	end

	if button ~= "RightButton" then
		return;
	end

	addon.Menu.ShowPopup();
end

local function OnEnter(self)
	addon.Tooltip.Show(self);
end

local function OnLeave(self)
	GameTooltip:Hide();
end

local function OnEvent(self, event, ...)
	if event == "PLAYER_ENTERING_WORLD" then
		addon.TemplateLDB:Update();
	end
end

local brokers = LibStub("Krowi_Brokers-1.0");
brokers:InitBroker(
	addonName,
	addon,
	"Interface\\Icons\\INV_Misc_QuestionMark",
	OnEnter,
	OnLeave,
	OnClick,
	OnEvent,
	addon.GetDisplayText,
	addon.Menu,
	addon.Tooltip
)
brokers:RegisterEvents("PLAYER_ENTERING_WORLD");