local addonName, addon = ...

local menu = {}
addon.Menu = menu

local menuBuilder

function menu.RefreshBroker()
	addon.RefreshDisplayConfiguration()
	addon.LDB:Update()
end

function menu.Init()
	local lib = LibStub('Krowi_MenuBuilder-1.0')

	menuBuilder = lib:New({
		uniqueTag = addon.Metadata.Prefix .. '_RIGHT_CLICK_MENU_OPTIONS',
		callbacks = {
			OnCheckboxSelect = function(filters, keys)
				addon.Util.WriteNestedKeys(filters, keys, not menuBuilder:KeyIsTrue(filters, keys))
				menu.RefreshBroker()
			end,
			OnRadioSelect = function(filters, keys, value)
				addon.Util.WriteNestedKeys(filters, keys, value)
				menu.RefreshBroker()
			end
		}
	})
end

local function CreateMenu(menuObj, caller)
	menuBuilder:CreateTitle(menuObj, addon.Metadata.Title .. ' ' .. addon.Metadata.Version)

	menuBuilder:CreateDivider(menuObj)

	local fpsOptions = menuBuilder:CreateSubmenuButton(menuObj, addon.L['FPS'])
	menuBuilder:CreateCheckbox(fpsOptions, addon.L['Show Label'], KrowiBSY_Options, {'FpsShowLabel'})
	menuBuilder:CreateCheckbox(fpsOptions, addon.L['Show Min'], KrowiBSY_Options, {'FpsShowMin'})
	menuBuilder:CreateCheckbox(fpsOptions, addon.L['Show Min Label'], KrowiBSY_Options, {'FpsShowMinLabel'})
	menuBuilder:CreateCheckbox(fpsOptions, addon.L['Show Average'], KrowiBSY_Options, {'FpsShowAverage'})
	menuBuilder:CreateCheckbox(fpsOptions, addon.L['Show Average Label'], KrowiBSY_Options, {'FpsShowAverageLabel'})
	menuBuilder:CreateCheckbox(fpsOptions, addon.L['Show Max'], KrowiBSY_Options, {'FpsShowMax'})
	menuBuilder:CreateCheckbox(fpsOptions, addon.L['Show Max Label'], KrowiBSY_Options, {'FpsShowMaxLabel'})
	menuBuilder:CreateCheckbox(fpsOptions, addon.L['Show Current'], KrowiBSY_Options, {'FpsShowCurrent'})
	menuBuilder:CreateCheckbox(fpsOptions, addon.L['Show Current Label'], KrowiBSY_Options, {'FpsShowCurrentLabel'})
	local fpsDecimalPlaces = menuBuilder:CreateSubmenuButton(fpsOptions, addon.L['Decimal Places'])
	for i = 0, 2 do
		menuBuilder:CreateRadio(fpsDecimalPlaces, tostring(i), KrowiBSY_Options, {'FpsDecimalPlaces'}, i)
	end
	menuBuilder:AddChildMenu(fpsOptions, fpsDecimalPlaces)
	menuBuilder:AddChildMenu(menuObj, fpsOptions)

	local latencyOptions = menuBuilder:CreateSubmenuButton(menuObj, addon.L['Latency'])
	menuBuilder:CreateCheckbox(latencyOptions, addon.L['Show Label'], KrowiBSY_Options, {'LatencyShowLabel'})
	local latencyLabelType = menuBuilder:CreateSubmenuButton(latencyOptions, addon.L['Label Type'])
	menuBuilder:CreateRadio(latencyLabelType, addon.L['Latency'], KrowiBSY_Options, {'LatencyLabelType'}, 'Latency')
	menuBuilder:CreateRadio(latencyLabelType, addon.L['MS'], KrowiBSY_Options, {'LatencyLabelType'}, 'MS')
	menuBuilder:AddChildMenu(latencyOptions, latencyLabelType)
	menuBuilder:CreateCheckbox(latencyOptions, addon.L['Show Home'], KrowiBSY_Options, {'LatencyShowHome'})
	menuBuilder:CreateCheckbox(latencyOptions, addon.L['Show Home Label'], KrowiBSY_Options, {'LatencyShowHomeLabel'})
	menuBuilder:CreateCheckbox(latencyOptions, addon.L['Show World'], KrowiBSY_Options, {'LatencyShowWorld'})
	menuBuilder:CreateCheckbox(latencyOptions, addon.L['Show World Label'], KrowiBSY_Options, {'LatencyShowWorldLabel'})
	menuBuilder:CreateCheckbox(latencyOptions, addon.L['Show ms'], KrowiBSY_Options, {'LatencyShowMs'})
	menuBuilder:AddChildMenu(menuObj, latencyOptions)

	local bandwidthOptions = menuBuilder:CreateSubmenuButton(menuObj, addon.L['Bandwidth'])
	menuBuilder:CreateCheckbox(bandwidthOptions, addon.L['Show Label'], KrowiBSY_Options, {'BandwidthShowLabel'})
	menuBuilder:CreateCheckbox(bandwidthOptions, addon.L['Show In'], KrowiBSY_Options, {'BandwidthShowIn'})
	menuBuilder:CreateCheckbox(bandwidthOptions, addon.L['Show In Label'], KrowiBSY_Options, {'BandwidthShowInLabel'})
	menuBuilder:CreateCheckbox(bandwidthOptions, addon.L['Show Out'], KrowiBSY_Options, {'BandwidthShowOut'})
	menuBuilder:CreateCheckbox(bandwidthOptions, addon.L['Show Out Label'], KrowiBSY_Options, {'BandwidthShowOutLabel'})
	menuBuilder:CreateCheckbox(bandwidthOptions, addon.L['Show kbps'], KrowiBSY_Options, {'BandwidthShowKbps'})
	local bandwidthDecimalPlaces = menuBuilder:CreateSubmenuButton(bandwidthOptions, addon.L['Decimal Places'])
	for i = 0, 4 do
		menuBuilder:CreateRadio(bandwidthDecimalPlaces, tostring(i), KrowiBSY_Options, {'BandwidthDecimalPlaces'}, i)
	end
	menuBuilder:AddChildMenu(bandwidthOptions, bandwidthDecimalPlaces)
	menuBuilder:AddChildMenu(menuObj, bandwidthOptions)

	local addOnOptions = menuBuilder:CreateSubmenuButton(menuObj, addon.L['AddOn'])
	menuBuilder:CreateCheckbox(addOnOptions, addon.L['Show Memory'], KrowiBSY_Options, {'ShowMemory'})
	local showCPU = menuBuilder:CreateCheckbox(addOnOptions, addon.L['Show CPU'], KrowiBSY_Options, {'ShowCPU'})
	menuBuilder:SetElementEnabled(showCPU, addon.System.IsCPUProfilingEnabled())
	menuBuilder:CreateCheckbox(addOnOptions, addon.L['Show Increase'], KrowiBSY_Options, {'ShowIncrease'})
	local addOnSortBy = menuBuilder:CreateSubmenuButton(addOnOptions, addon.L['Sort AddOns By'])
	menuBuilder:CreateRadio(addOnSortBy, addon.L['Name'], KrowiBSY_Options, {'AddOnSortBy'}, 'Name')
	menuBuilder:CreateRadio(addOnSortBy, addon.L['Memory'], KrowiBSY_Options, {'AddOnSortBy'}, 'Memory')
	menuBuilder:CreateRadio(addOnSortBy, addon.L['Memory Increase'], KrowiBSY_Options, {'AddOnSortBy'}, 'MemoryIncrease')
	local sortByCPU = menuBuilder:CreateRadio(addOnSortBy, addon.L['CPU'], KrowiBSY_Options, {'AddOnSortBy'}, 'CPU')
	menuBuilder:SetElementEnabled(sortByCPU, addon.System.IsCPUProfilingEnabled())
	local sortByCPUIncrease = menuBuilder:CreateRadio(addOnSortBy, addon.L['CPU Increase'], KrowiBSY_Options, {'AddOnSortBy'}, 'CPUIncrease')
	menuBuilder:SetElementEnabled(sortByCPUIncrease, addon.System.IsCPUProfilingEnabled())
	menuBuilder:AddChildMenu(addOnOptions, addOnSortBy)
	menuBuilder:CreateCheckbox(addOnOptions, addon.L['Reverse Sort'], KrowiBSY_Options, {'AddOnSortReverse'})
	menuBuilder:AddChildMenu(menuObj, addOnOptions)

	menu.CreateElvUIOptionsMenu(menuBuilder, menuObj, caller)
	menu.CreateTitanOptionsMenu(menuBuilder, menuObj, caller)
end

function menu.ShowPopup(caller)
	menuBuilder:ShowPopup(function()
		local menuObj = menuBuilder:GetMenu()
		CreateMenu(menuObj, caller)
	end)
end