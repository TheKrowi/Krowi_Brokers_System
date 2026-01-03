local _, addon = ...;

local tooltip = {};
addon.Tooltip = tooltip;

-- Pre-allocated format patterns
local memoryFormatMB = '%.2f%s'
local memoryFormatMBWithSign = '%+.2f%s'
local memoryFormatKB = '%.0f%s'
local memoryFormatKBWithSign = '%+.0f%s'
local memoryFormatB = '%.0f%s'
local memoryFormatBWithSign = '%+.0f%s'

-- Pre-allocated tooltip format patterns
local coloredTextPattern = '|c%s%s|r'
local coloredTextInParensPattern = ' (|c%s%s|r)'
local memoryWithCPUPattern = '%s%s / %.2f ms'
local memoryConcatPattern = '%s%s'
local totalMemoryPattern = '%s (%s)'

local function FormatMemoryValue(memoryKB, showSign)
	if memoryKB >= 1024 then
		return string.format(showSign and memoryFormatMBWithSign or memoryFormatMB, memoryKB / 1024, ' mb')
	elseif memoryKB >= 1 or memoryKB <= -1 then
		return string.format(showSign and memoryFormatKBWithSign or memoryFormatKB, memoryKB, ' kb')
	end
	return string.format(showSign and memoryFormatBWithSign or memoryFormatB, memoryKB * 1024, ' b')
end

local greenRGB = addon.Util.Colors.GreenRGB
local redRGB = addon.Util.Colors.RedRGB
local colorRGB = {R = 0, G = 0, B = 0}
local colorCache = {}
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

local showMemoryIncrease, allAddonStats
local baseMemoryText, memoryIncreaseText, memoryText
local totalMemory, totalMemoryIncrease, totalMemoryText
local cpuProfilingEnabled = addon.System.IsCPUProfilingEnabled()
local function DisplayAddonMemory()
	showMemoryIncrease = KrowiBSY_Options.ShowMemoryIncrease and not IsShiftKeyDown() or not KrowiBSY_Options.ShowMemoryIncrease and IsShiftKeyDown()
	allAddonStats = addon.System.GetAllAddOnStats()
	
	totalMemory = 0
	totalMemoryIncrease = 0
	
	-- Display each addon with color based on memory usage
	for _, addonStats in ipairs(allAddonStats) do
		totalMemory = totalMemory + addonStats.Memory
		totalMemoryIncrease = totalMemoryIncrease + addonStats.MemoryIncrease
		baseMemoryText = string.format(coloredTextPattern, GetMemoryColorHex(addonStats.GetMemoryPercent()), FormatMemoryValue(addonStats.Memory, false))
		
		-- Add memory increase if needed
		memoryIncreaseText = ""
		if showMemoryIncrease and addonStats.MemoryIncrease ~= 0 then
			memoryIncreaseText = string.format(coloredTextInParensPattern, GetMemoryColorHex(addonStats.GetMemoryIncreasePercent()), FormatMemoryValue(addonStats.MemoryIncrease, true))
		end
		
		if cpuProfilingEnabled then
			memoryText = string.format(memoryWithCPUPattern, baseMemoryText, memoryIncreaseText, addonStats.CPU)
		else
			memoryText = string.format(memoryConcatPattern, baseMemoryText, memoryIncreaseText)
		end
		
		GameTooltip:AddDoubleLine(addonStats.Name, memoryText, 1, 1, 1)
	end

	if showMemoryIncrease then
		totalMemoryText = string.format(totalMemoryPattern, FormatMemoryValue(totalMemory, false), FormatMemoryValue(totalMemoryIncrease, true))
	else
		totalMemoryText = FormatMemoryValue(totalMemory, false)
	end

	GameTooltip_AddBlankLineToTooltip(GameTooltip)
	GameTooltip:AddDoubleLine(addon.L["Total"], totalMemoryText, 1, 1, 1, 1, 1, 1)
end

function tooltip.Init()
	-- Initialize tooltip if needed
end

local fpsStats, netStats;
function tooltip.Show(frame)
	GameTooltip:SetOwner(frame, "ANCHOR_NONE");
	GameTooltip:SetPoint("TOPLEFT", frame, "BOTTOMLEFT");
	GameTooltip:AddLine(addon.Metadata.Title .. " " .. addon.Metadata.Version);
	GameTooltip_AddBlankLineToTooltip(GameTooltip);

	fpsStats = addon.System.GetFpsStats();
	GameTooltip:AddDoubleLine(addon.L["Min FPS"], addon.FormatFps(fpsStats.Min), 1, 1, 1);
	GameTooltip:AddDoubleLine(addon.L["Max FPS"], addon.FormatFps(fpsStats.Max), 1, 1, 1);
	GameTooltip:AddDoubleLine(addon.L["Average FPS"], addon.FormatFps(fpsStats.Average), 1, 1, 1);
	GameTooltip_AddBlankLineToTooltip(GameTooltip);
	GameTooltip:AddDoubleLine(addon.L["Current FPS"], addon.FormatFps(fpsStats.Current), 1, 1, 1);

	GameTooltip_AddBlankLineToTooltip(GameTooltip);

	netStats = addon.System.GetNetStats();
	GameTooltip:AddDoubleLine(addon.L["Home Latency"], addon.FormatLatency(netStats.LatencyHome, true), 1, 1, 1);
	GameTooltip:AddDoubleLine(addon.L["World Latency"], addon.FormatLatency(netStats.LatencyWorld, true), 1, 1, 1);

	GameTooltip_AddBlankLineToTooltip(GameTooltip);

	if GetFileStreamingStatus() ~= 0 or GetBackgroundLoadingStatus() ~= 0 then
		GameTooltip_AddBlankLineToTooltip(GameTooltip);
		GameTooltip:AddDoubleLine(addon.L["Bandwidth"], string.format('%.2f Mbps', GetAvailableBandwidth()), 1, 1, 1, 1, 1, 1);
		GameTooltip:AddDoubleLine(addon.L["Download"], string.format('%.2f%%', GetDownloadedPercentage() * 100), 1, 1, 1, 1, 1, 1);
	end
	GameTooltip:AddDoubleLine(addon.L["Bandwidth In"], addon.FormatBandwidth(netStats.BandwidthIn, true), 1, 1, 1, 1, 1, 1);
	GameTooltip:AddDoubleLine(addon.L["Bandwidth Out"], addon.FormatBandwidth(netStats.BandwidthOut, true), 1, 1, 1, 1, 1, 1);

	GameTooltip_AddBlankLineToTooltip(GameTooltip);

	DisplayAddonMemory();

	GameTooltip_AddBlankLineToTooltip(GameTooltip);
	GameTooltip:AddLine(KrowiBSY_Options.ShowMemoryIncrease and addon.L["Hold Shift: Hide Memory Increase"] or addon.L["Hold Shift: Show Memory Increase"], 0.5, 0.8, 1);
	GameTooltip:AddLine(addon.L["Ctrl + Shift + Left-Click: Toggle CPU Profiling (Reload UI)"], 0.5, 0.8, 1);
	GameTooltip:AddLine(addon.L["Right-Click: Options"], 0.5, 0.8, 1);

	GameTooltip:Show();
end