local _, addon = ...

local tooltip = {}
addon.Tooltip = tooltip

-- Constants - Format Patterns
local memoryFormatMB = '%.2f%s'
local memoryFormatMBWithSign = '%+.2f%s'
local memoryFormatKB = '%.0f%s'
local memoryFormatKBWithSign = '%+.0f%s'
local memoryFormatB = '%.0f%s'
local memoryFormatBWithSign = '%+.0f%s'

local memoryOnlyPattern = '|c%s%s|r'
local memoryWithIncreasePattern = '|c%s%s|r (|c%s%s|r)'
local memoryWithCPUOnlyPattern = '|c%s%s|r | |c%s%.2f ms|r'
local memoryWithIncreaseAndCPUPattern = '|c%s%s|r (|c%s%s|r) | |c%s%.2f ms|r'
local memoryWithCPUAndIncreasePattern = '|c%s%s|r | |c%s%.2f ms|r (|c%s%+.2f ms|r)'
local memoryWithIncreasesAndCPUPattern = '|c%s%s|r (|c%s%s|r) | |c%s%.2f ms|r (|c%s%+.2f ms|r)'
local totalMemoryPattern = '%s (%s)'
local bandwidthPattern = '%.2f Mbps'
local downloadPattern = '%.2f%%'

-- Cached Variables
local cachedTitleString

local greenRGB, redRGB = addon.Util.Colors.GreenRGB, addon.Util.Colors.RedRGB
local colorRGB, colorCache = {}, {}

local showMemoryIncrease, showCPUIncrease
local allAddonStats, totalMemory, totalMemoryIncrease, totalCPU, totalCPUIncrease
local memoryText, totalMemoryText, cpuText, totalCPUText
local memoryPercent, memoryIncreasePercent, cpuPercent, cpuIncreasePercent
local cpuProfilingEnabled = addon.System.IsCPUProfilingEnabled()

local fpsStats, netStats

-- Initialization
function tooltip.Init()
	cachedTitleString = addon.Metadata.Title .. " " .. addon.Metadata.Version
end

-- Helper Functions - Memory Formatting
local function FormatMemoryValue(memoryKB, showSign)
	if memoryKB >= 1024 then
		return string.format(showSign and memoryFormatMBWithSign or memoryFormatMB, memoryKB / 1024, ' mb')
	elseif memoryKB >= 1 or memoryKB <= -1 then
		return string.format(showSign and memoryFormatKBWithSign or memoryFormatKB, memoryKB, ' kb')
	end
	return string.format(showSign and memoryFormatBWithSign or memoryFormatB, memoryKB * 1024, ' b')
end

local function GetMemoryColorHex(percent)
	-- Round to nearest 5% to enable caching (max 21 cached values: 0%, 5%, 10%, ... 100%)
	percent = math.floor(percent * 20 + 0.5) / 20

	if colorCache[percent] then
		return colorCache[percent]
	end

	colorRGB.R = greenRGB.R + (redRGB.R - greenRGB.R) * percent
	colorRGB.G = greenRGB.G + (redRGB.G - greenRGB.G) * percent
	colorRGB.B = greenRGB.B + (redRGB.B - greenRGB.B) * percent
	colorCache[percent] = addon.Util.Colors.RGBPrct2HEX(colorRGB)
	return colorCache[percent]
end

-- Memory Display Functions
local function DisplayAddonMemory()
	showMemoryIncrease = KrowiBSY_Options.ShowMemoryIncrease ~= IsShiftKeyDown()
	showCPUIncrease = KrowiBSY_Options.ShowCPUIncrease ~= IsAltKeyDown()
	allAddonStats, totalMemory, totalMemoryIncrease, totalCPU, totalCPUIncrease = addon.System.GetAllAddOnStats()
	
	for _, addonStats in ipairs(allAddonStats) do
		memoryPercent = totalMemory > 0 and (addonStats.Memory / totalMemory) or 0
		memoryIncreasePercent = totalMemoryIncrease ~= 0 and (addonStats.MemoryIncrease / totalMemoryIncrease) or 0
		cpuPercent = totalCPU > 0 and (addonStats.CPU / totalCPU) or 0
		cpuIncreasePercent = totalCPUIncrease ~= 0 and (addonStats.CPUIncrease / totalCPUIncrease) or 0
		
		if cpuProfilingEnabled then
			if showMemoryIncrease and addonStats.MemoryIncrease ~= 0 and showCPUIncrease and addonStats.CPUIncrease ~= 0 then
				memoryText = string.format(memoryWithIncreasesAndCPUPattern,
					GetMemoryColorHex(memoryPercent), FormatMemoryValue(addonStats.Memory, false),
					GetMemoryColorHex(memoryIncreasePercent), FormatMemoryValue(addonStats.MemoryIncrease, true),
					GetMemoryColorHex(cpuPercent), addonStats.CPU,
					GetMemoryColorHex(cpuIncreasePercent), addonStats.CPUIncrease)
			elseif showMemoryIncrease and addonStats.MemoryIncrease ~= 0 then
				memoryText = string.format(memoryWithIncreaseAndCPUPattern,
					GetMemoryColorHex(memoryPercent), FormatMemoryValue(addonStats.Memory, false),
					GetMemoryColorHex(memoryIncreasePercent), FormatMemoryValue(addonStats.MemoryIncrease, true),
					GetMemoryColorHex(cpuPercent), addonStats.CPU)
			elseif showCPUIncrease and addonStats.CPUIncrease ~= 0 then
				memoryText = string.format(memoryWithCPUAndIncreasePattern,
					GetMemoryColorHex(memoryPercent), FormatMemoryValue(addonStats.Memory, false),
					GetMemoryColorHex(cpuPercent), addonStats.CPU,
					GetMemoryColorHex(cpuIncreasePercent), addonStats.CPUIncrease)
			else
				memoryText = string.format(memoryWithCPUOnlyPattern,
					GetMemoryColorHex(memoryPercent), FormatMemoryValue(addonStats.Memory, false),
					GetMemoryColorHex(cpuPercent), addonStats.CPU)
			end
		else
			if showMemoryIncrease and addonStats.MemoryIncrease ~= 0 then
				memoryText = string.format(memoryWithIncreasePattern,
					GetMemoryColorHex(memoryPercent), FormatMemoryValue(addonStats.Memory, false),
					GetMemoryColorHex(memoryIncreasePercent), FormatMemoryValue(addonStats.MemoryIncrease, true))
			else
				memoryText = string.format(memoryOnlyPattern,
					GetMemoryColorHex(memoryPercent), FormatMemoryValue(addonStats.Memory, false))
			end
		end
		
		GameTooltip:AddDoubleLine(addonStats.Name, memoryText, 1, 1, 1)
	end

	if showMemoryIncrease then
		totalMemoryText = string.format(totalMemoryPattern, FormatMemoryValue(totalMemory, false), FormatMemoryValue(totalMemoryIncrease, true))
	else
		totalMemoryText = FormatMemoryValue(totalMemory, false)
	end
	
	if cpuProfilingEnabled then
		if showCPUIncrease then
			totalCPUText = string.format(totalMemoryPattern, string.format("%.2f ms", totalCPU), string.format("%+.2f ms", totalCPUIncrease))
		else
			totalCPUText = string.format("%.2f ms", totalCPU)
		end
		totalMemoryText = totalMemoryText .. " / " .. totalCPUText
	end

	GameTooltip_AddBlankLineToTooltip(GameTooltip)
	GameTooltip:AddDoubleLine(addon.L["Total"], totalMemoryText, 1, 1, 1, 1, 1, 1)
end

-- Tooltip Display Functions
local function DisplayFpsStats()
	fpsStats = addon.System.GetFpsStats()
	GameTooltip:AddDoubleLine(addon.L["Min FPS"], addon.FormatFps(fpsStats.Min), 1, 1, 1)
	GameTooltip:AddDoubleLine(addon.L["Average FPS"], addon.FormatFps(fpsStats.Average), 1, 1, 1)
	GameTooltip:AddDoubleLine(addon.L["Max FPS"], addon.FormatFps(fpsStats.Max), 1, 1, 1)
	GameTooltip_AddBlankLineToTooltip(GameTooltip)
	GameTooltip:AddDoubleLine(addon.L["Current FPS"], addon.FormatFps(fpsStats.Current), 1, 1, 1)
end

local function DisplayNetworkStats()
	netStats = addon.System.GetNetStats()
	
	GameTooltip:AddDoubleLine(addon.L["Home Latency"], addon.FormatLatency(netStats.LatencyHome, true), 1, 1, 1)
	GameTooltip:AddDoubleLine(addon.L["World Latency"], addon.FormatLatency(netStats.LatencyWorld, true), 1, 1, 1)
	
	GameTooltip_AddBlankLineToTooltip(GameTooltip)
	
	if GetFileStreamingStatus() ~= 0 or GetBackgroundLoadingStatus() ~= 0 then
		GameTooltip_AddBlankLineToTooltip(GameTooltip)
		GameTooltip:AddDoubleLine(addon.L["Bandwidth"], string.format(bandwidthPattern, GetAvailableBandwidth()), 1, 1, 1, 1, 1, 1)
		GameTooltip:AddDoubleLine(addon.L["Download"], string.format(downloadPattern, GetDownloadedPercentage() * 100), 1, 1, 1, 1, 1, 1)
	end
	
	GameTooltip:AddDoubleLine(addon.L["Bandwidth In"], addon.FormatBandwidth(netStats.BandwidthIn, true), 1, 1, 1, 1, 1, 1)
	GameTooltip:AddDoubleLine(addon.L["Bandwidth Out"], addon.FormatBandwidth(netStats.BandwidthOut, true), 1, 1, 1, 1, 1, 1)
end

local function DisplayInstructions()
	GameTooltip:AddLine(KrowiBSY_Options.ShowMemoryIncrease and addon.L["Hold Shift: Hide Memory Increase"] or addon.L["Hold Shift: Show Memory Increase"], 0.5, 0.8, 1)
	if cpuProfilingEnabled then
		GameTooltip:AddLine(KrowiBSY_Options.ShowCPUIncrease and addon.L["Hold Alt: Hide CPU Increase"] or addon.L["Hold Alt: Show CPU Increase"], 0.5, 0.8, 1)
	end
	GameTooltip:AddLine(addon.L["Ctrl + Shift + Left-Click: Toggle CPU Profiling (Reload UI)"], 0.5, 0.8, 1)
	GameTooltip:AddLine(addon.L["Right-Click: Options"], 0.5, 0.8, 1)
end

-- Main Tooltip Display
function tooltip.Show(frame)
	GameTooltip:SetOwner(frame, "ANCHOR_NONE")
	GameTooltip:SetPoint("TOPLEFT", frame, "BOTTOMLEFT")
	GameTooltip:AddLine(cachedTitleString)
	GameTooltip_AddBlankLineToTooltip(GameTooltip)

	DisplayFpsStats()
	GameTooltip_AddBlankLineToTooltip(GameTooltip)

	DisplayNetworkStats()
	GameTooltip_AddBlankLineToTooltip(GameTooltip)

	DisplayAddonMemory()
	GameTooltip_AddBlankLineToTooltip(GameTooltip)

	DisplayInstructions()

	GameTooltip:Show()
end