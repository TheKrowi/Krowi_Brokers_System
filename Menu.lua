local _, addon = ...

local menu = {}
addon.Menu = menu

local menuBuilder

function menu.Init()
	local lib = LibStub("Krowi_MenuBuilder-1.0")

	menuBuilder = lib:New({
		uniqueTag = addon.Metadata.Prefix .. "_RIGHT_CLICK_MENU_OPTIONS",
		callbacks = {
			OnCheckboxSelect = function(filters, keys)
				addon.Util.WriteNestedKeys(filters, keys, not menuBuilder:KeyIsTrue(filters, keys))
				addon.RefreshDisplayConfiguration()
				addon.LDB:Update()
			end,
			OnRadioSelect = function(filters, keys, value)
				addon.Util.WriteNestedKeys(filters, keys, value)
				addon.RefreshDisplayConfiguration()
				addon.LDB:Update()
			end
		}
	})
end

function CreateMenu(menuObj)
	menuBuilder:CreateTitle(menuObj, addon.Metadata.Title .. " " .. addon.Metadata.Version)

	menuBuilder:CreateDivider(menuObj)

	menuBuilder:CreateTitle(menuObj, addon.L["FPS Display Options"])
	menuBuilder:CreateCheckbox(menuObj, addon.L["Show FPS Label"], KrowiBSY_Options, {"FpsShowLabel"})
	menuBuilder:CreateCheckbox(menuObj, addon.L["Show Min FPS"], KrowiBSY_Options, {"FpsShowMin"})
	menuBuilder:CreateCheckbox(menuObj, addon.L["Show Min FPS Label"], KrowiBSY_Options, {"FpsShowMinLabel"})
	menuBuilder:CreateCheckbox(menuObj, addon.L["Show Average FPS"], KrowiBSY_Options, {"FpsShowAverage"})
	menuBuilder:CreateCheckbox(menuObj, addon.L["Show Average FPS Label"], KrowiBSY_Options, {"FpsShowAverageLabel"})
	menuBuilder:CreateCheckbox(menuObj, addon.L["Show Max FPS"], KrowiBSY_Options, {"FpsShowMax"})
	menuBuilder:CreateCheckbox(menuObj, addon.L["Show Max FPS Label"], KrowiBSY_Options, {"FpsShowMaxLabel"})
	menuBuilder:CreateCheckbox(menuObj, addon.L["Show Current FPS"], KrowiBSY_Options, {"FpsShowCurrent"})
	menuBuilder:CreateCheckbox(menuObj, addon.L["Show Current FPS Label"], KrowiBSY_Options, {"FpsShowCurrentLabel"})
	local fpsDecimalPlaces = menuBuilder:CreateSubmenuButton(menuObj, addon.L["FPS Decimal Places"])
	for i = 0, 2 do
		menuBuilder:CreateRadio(fpsDecimalPlaces, tostring(i), KrowiBSY_Options, {"FpsDecimalPlaces"}, i)
	end
	menuBuilder:AddChildMenu(menuObj, fpsDecimalPlaces)

	menuBuilder:CreateDivider(menuObj)

	menuBuilder:CreateTitle(menuObj, addon.L["Latency Display Options"])
	menuBuilder:CreateCheckbox(menuObj, addon.L["Show Latency Label"], KrowiBSY_Options, {"LatencyShowLabel"})
	local latencyLabelType = menuBuilder:CreateSubmenuButton(menuObj, addon.L["Latency Label Type"])
	menuBuilder:CreateRadio(latencyLabelType, addon.L["Latency"], KrowiBSY_Options, {"LatencyLabelType"}, "Latency")
	menuBuilder:CreateRadio(latencyLabelType, addon.L["MS"], KrowiBSY_Options, {"LatencyLabelType"}, "MS")
	menuBuilder:AddChildMenu(menuObj, latencyLabelType)
	menuBuilder:CreateCheckbox(menuObj, addon.L["Show Latency Home"], KrowiBSY_Options, {"LatencyShowHome"})
	menuBuilder:CreateCheckbox(menuObj, addon.L["Show Latency Home Label"], KrowiBSY_Options, {"LatencyShowHomeLabel"})
	menuBuilder:CreateCheckbox(menuObj, addon.L["Show Latency World"], KrowiBSY_Options, {"LatencyShowWorld"})
	menuBuilder:CreateCheckbox(menuObj, addon.L["Show Latency World Label"], KrowiBSY_Options, {"LatencyShowWorldLabel"})
	menuBuilder:CreateCheckbox(menuObj, addon.L["Show ms"], KrowiBSY_Options, {"LatencyShowMs"})

	menuBuilder:CreateDivider(menuObj)

	menuBuilder:CreateTitle(menuObj, addon.L["Bandwidth Display Options"])
	menuBuilder:CreateCheckbox(menuObj, addon.L["Show Bandwidth Label"], KrowiBSY_Options, {"BandwidthShowLabel"})
	menuBuilder:CreateCheckbox(menuObj, addon.L["Show Bandwidth In"], KrowiBSY_Options, {"BandwidthShowIn"})
	menuBuilder:CreateCheckbox(menuObj, addon.L["Show Bandwidth In Label"], KrowiBSY_Options, {"BandwidthShowInLabel"})
	menuBuilder:CreateCheckbox(menuObj, addon.L["Show Bandwidth Out"], KrowiBSY_Options, {"BandwidthShowOut"})
	menuBuilder:CreateCheckbox(menuObj, addon.L["Show Bandwidth Out Label"], KrowiBSY_Options, {"BandwidthShowOutLabel"})
	menuBuilder:CreateCheckbox(menuObj, addon.L["Show kbps"], KrowiBSY_Options, {"BandwidthShowKbps"})
	local bandwidthDecimalPlaces = menuBuilder:CreateSubmenuButton(menuObj, addon.L["Bandwidth Decimal Places"])
	for i = 0, 4 do
		menuBuilder:CreateRadio(bandwidthDecimalPlaces, tostring(i), KrowiBSY_Options, {"BandwidthDecimalPlaces"}, i)
	end
	menuBuilder:AddChildMenu(menuObj, bandwidthDecimalPlaces)

	menuBuilder:CreateDivider(menuObj)

	menuBuilder:CreateTitle(menuObj, addon.L["AddOn Display Options"])
	menuBuilder:CreateCheckbox(menuObj, addon.L["Show Memory Increase"], KrowiBSY_Options, {"ShowMemoryIncrease"})
	menuBuilder:CreateCheckbox(menuObj, addon.L["Show CPU Increase"], KrowiBSY_Options, {"ShowCPUIncrease"})
	local addOnSortBy = menuBuilder:CreateSubmenuButton(menuObj, addon.L["Sort AddOns By"])
	menuBuilder:CreateRadio(addOnSortBy, addon.L["Name"], KrowiBSY_Options, {"AddOnSortBy"}, "Name")
	menuBuilder:CreateRadio(addOnSortBy, addon.L["Memory"], KrowiBSY_Options, {"AddOnSortBy"}, "Memory")
	menuBuilder:CreateRadio(addOnSortBy, addon.L["Memory Increase"], KrowiBSY_Options, {"AddOnSortBy"}, "MemoryIncrease")
	menuBuilder:CreateRadio(addOnSortBy, addon.L["CPU"], KrowiBSY_Options, {"AddOnSortBy"}, "CPU")
	menuBuilder:CreateRadio(addOnSortBy, addon.L["CPU Increase"], KrowiBSY_Options, {"AddOnSortBy"}, "CPUIncrease")
	menuBuilder:AddChildMenu(menuObj, addOnSortBy)
end

function menu.ShowPopup()
	menuBuilder:ShowPopup(function()
		local menuObj = menuBuilder:GetMenu()
		CreateMenu(menuObj)
	end)
end