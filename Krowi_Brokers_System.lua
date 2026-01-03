local addonName, addon = ...;

addon.L = LibStub(addon.Libs.AceLocale):GetLocale(addonName);

KrowiBSY_Options = KrowiBSY_Options or {
	ExampleSetting = true,
};

KrowiBSY_SavedData = KrowiBSY_SavedData or {
	-- Saved data can be initialized here
};

-- Helper functions

-- Main functions

function addon.GetDisplayText()
	return addon.L["Template"] .. ": " .. (KrowiBSY_Options.ExampleSetting and addon.L["Enabled"] or addon.L["Disabled"]);
end

local function OnClick(self, button)
	if button == "LeftButton" then
		-- Add left-click behavior here
		-- print(addon.L["Left-Click Action"]);
		return;
	end

	if button ~= "RightButton" then
		return;
	end

	-- addon.Menu.ShowPopup();
end

local function OnEnter(self)
	-- addon.Tooltip.Show(self);
end

local function OnLeave(self)
	GameTooltip:Hide();
end

local function OnEvent(self, event, ...)
	if event == "PLAYER_ENTERING_WORLD" then
		addon.LDB:Update();
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
addon.System.Init(brokers)