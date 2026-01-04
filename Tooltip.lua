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
local cpuFormat = '%.2f ms'
local cpuFormatWithSign = '%+.2f ms'

-- Pattern Blocks
local memoryBlock = '|c%s%s|r'
local memoryIncreaseBlock = '(|c%s%s|r)'
local cpuBlock = '|c%s' .. cpuFormat .. '|r'
local cpuIncreaseBlock = '(|c%s' .. cpuFormatWithSign .. '|r)'

-- Combined Patterns
local memPattern = memoryBlock
local memIncMemPattern = memoryIncreaseBlock .. ' ' .. memoryBlock
local cpuPattern = cpuBlock
local cpuIncCpuPattern = cpuIncreaseBlock .. ' ' .. cpuBlock
local memCpuPattern = memoryBlock .. ' | ' .. cpuBlock
local memIncMemCpuPattern = memoryIncreaseBlock .. ' ' .. memoryBlock .. ' | ' .. cpuBlock
local memCpuIncCpuPattern = memoryBlock .. ' | ' .. cpuIncreaseBlock .. ' ' .. cpuBlock
local memIncMemCpuIncCpuPattern = memoryIncreaseBlock .. ' ' .. memoryBlock .. ' | ' .. cpuIncreaseBlock .. ' ' .. cpuBlock
local incValPattern = '(%s) %s'
local valAndValPattern = '%s / %s'
local bandwidthPattern = '%.2f Mbps'
local downloadPattern = '%.2f%%'

-- Cached Variables
local cachedTitleString

local greenRGB, redRGB = addon.Util.Colors.GreenRGB, addon.Util.Colors.RedRGB
local colorRGB, colorCache = {}, {}

local showMemory, showCPU, showIncrease
local allAddonStats, totalMemory, totalMemoryIncrease, totalCPU, totalCPUIncrease
local addonText, totalText, totalCPUText
local memoryPercent, memoryIncreasePercent, cpuPercent, cpuIncreasePercent
local cpuProfilingEnabled = addon.System.IsCPUProfilingEnabled()

local fpsStats, netStats

-- Initialization
function tooltip.Init()
	cachedTitleString = addon.Metadata.Title .. ' ' .. addon.Metadata.Version
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

local function GetIncreaseColorHex(percent)
	-- For increases: positive (increase) = red, negative (decrease) = green
	return GetMemoryColorHex(percent < 0 and (1 + percent) or percent)
end

-- Memory Display Functions
local function DisplayAddonMemory()
	-- Modifier keys: Shift = toggle memory, Alt = toggle CPU, Ctrl = toggle increases
	showMemory = KrowiBSY_Options.ShowMemory ~= IsShiftKeyDown()
	showCPU = cpuProfilingEnabled and (KrowiBSY_Options.ShowCPU ~= IsAltKeyDown())
	showIncrease = KrowiBSY_Options.ShowIncrease ~= IsControlKeyDown()
	allAddonStats, totalMemory, totalMemoryIncrease, totalCPU, totalCPUIncrease = addon.System.GetAllAddOnStats()
	
	for _, addonStats in ipairs(allAddonStats) do
		memoryPercent = totalMemory > 0 and (addonStats.Memory / totalMemory) or 0
		memoryIncreasePercent = totalMemoryIncrease ~= 0 and (addonStats.MemoryIncrease / totalMemoryIncrease) or 0
		cpuPercent = totalCPU > 0 and (addonStats.CPU / totalCPU) or 0
		cpuIncreasePercent = totalCPUIncrease ~= 0 and (addonStats.CPUIncrease / totalCPUIncrease) or 0
		
		if showMemory and showCPU then
			if showIncrease and addonStats.MemoryIncrease ~= 0 and addonStats.CPUIncrease ~= 0 then
				addonText = string.format(memIncMemCpuIncCpuPattern,
					GetIncreaseColorHex(memoryIncreasePercent), FormatMemoryValue(addonStats.MemoryIncrease, true),
					GetMemoryColorHex(memoryPercent), FormatMemoryValue(addonStats.Memory, false),
					GetIncreaseColorHex(cpuIncreasePercent), addonStats.CPUIncrease,
					GetMemoryColorHex(cpuPercent), addonStats.CPU)
			elseif showIncrease and addonStats.MemoryIncrease ~= 0 then
				addonText = string.format(memIncMemCpuPattern,
					GetIncreaseColorHex(memoryIncreasePercent), FormatMemoryValue(addonStats.MemoryIncrease, true),
					GetMemoryColorHex(memoryPercent), FormatMemoryValue(addonStats.Memory, false),
					GetMemoryColorHex(cpuPercent), addonStats.CPU)
			elseif showIncrease and addonStats.CPUIncrease ~= 0 then
				addonText = string.format(memCpuIncCpuPattern,
					GetMemoryColorHex(memoryPercent), FormatMemoryValue(addonStats.Memory, false),
					GetIncreaseColorHex(cpuIncreasePercent), addonStats.CPUIncrease,
					GetMemoryColorHex(cpuPercent), addonStats.CPU)
			else
				addonText = string.format(memCpuPattern,
					GetMemoryColorHex(memoryPercent), FormatMemoryValue(addonStats.Memory, false),
					GetMemoryColorHex(cpuPercent), addonStats.CPU)
			end
		elseif showMemory then
			if showIncrease and addonStats.MemoryIncrease ~= 0 then
				addonText = string.format(memIncMemPattern,
					GetIncreaseColorHex(memoryIncreasePercent), FormatMemoryValue(addonStats.MemoryIncrease, true),
					GetMemoryColorHex(memoryPercent), FormatMemoryValue(addonStats.Memory, false))
			else
				addonText = string.format(memPattern,
					GetMemoryColorHex(memoryPercent), FormatMemoryValue(addonStats.Memory, false))
			end
		elseif showCPU then
			if showIncrease and addonStats.CPUIncrease ~= 0 then
				addonText = string.format(cpuIncCpuPattern,
					GetIncreaseColorHex(cpuIncreasePercent), addonStats.CPUIncrease,
					GetMemoryColorHex(cpuPercent), addonStats.CPU)
			else
				addonText = string.format(cpuPattern,
					GetMemoryColorHex(cpuPercent), addonStats.CPU)
			end
		else
			-- Nothing to show for this addon
			addonText = nil
		end
		
		if addonText then
			GameTooltip:AddDoubleLine(addonStats.Name, addonText, 1, 1, 1)
		end
	end

	-- Build total line
	if showMemory and showCPU then
		if showIncrease then
			totalText = string.format(incValPattern, FormatMemoryValue(totalMemoryIncrease, true), FormatMemoryValue(totalMemory, false))
			totalCPUText = string.format(incValPattern, string.format(cpuFormatWithSign, totalCPUIncrease), string.format(cpuFormat, totalCPU))
		else
			totalText = FormatMemoryValue(totalMemory, false)
			totalCPUText = string.format(cpuFormat, totalCPU)
		end
		totalText = string.format(valAndValPattern, totalText, totalCPUText)
	elseif showMemory then
		if showIncrease then
			totalText = string.format(incValPattern, FormatMemoryValue(totalMemoryIncrease, true), FormatMemoryValue(totalMemory, false))
		else
			totalText = FormatMemoryValue(totalMemory, false)
		end
	elseif showCPU then
		if showIncrease then
			totalText = string.format(incValPattern, string.format(cpuFormatWithSign, totalCPUIncrease), string.format(cpuFormat, totalCPU))
		else
			totalText = string.format(cpuFormat, totalCPU)
		end
	else
		-- Nothing to show
		totalText = nil
	end

	if totalText then
		GameTooltip_AddBlankLineToTooltip(GameTooltip)
		GameTooltip:AddDoubleLine(addon.L['Total'], totalText, 1, 1, 1, 1, 1, 1)
	end
end

-- Tooltip Display Functions
local function DisplayFpsStats()
	fpsStats = addon.System.GetFpsStats()
	GameTooltip:AddDoubleLine(addon.L['Min FPS'], addon.FormatFps(fpsStats.Min), 1, 1, 1)
	GameTooltip:AddDoubleLine(addon.L['Average FPS'], addon.FormatFps(fpsStats.Average), 1, 1, 1)
	GameTooltip:AddDoubleLine(addon.L['Max FPS'], addon.FormatFps(fpsStats.Max), 1, 1, 1)
	GameTooltip_AddBlankLineToTooltip(GameTooltip)
	GameTooltip:AddDoubleLine(addon.L['Current FPS'], addon.FormatFps(fpsStats.Current), 1, 1, 1)
end

local function DisplayNetworkStats()
	netStats = addon.System.GetNetStats()
	
	GameTooltip:AddDoubleLine(addon.L['Home Latency'], addon.FormatLatency(netStats.LatencyHome, true), 1, 1, 1)
	GameTooltip:AddDoubleLine(addon.L['World Latency'], addon.FormatLatency(netStats.LatencyWorld, true), 1, 1, 1)
	
	GameTooltip_AddBlankLineToTooltip(GameTooltip)
	
	if GetFileStreamingStatus() ~= 0 or GetBackgroundLoadingStatus() ~= 0 then
		GameTooltip_AddBlankLineToTooltip(GameTooltip)
		GameTooltip:AddDoubleLine(addon.L['Bandwidth'], string.format(bandwidthPattern, GetAvailableBandwidth()), 1, 1, 1, 1, 1, 1)
		GameTooltip:AddDoubleLine(addon.L['Download'], string.format(downloadPattern, GetDownloadedPercentage() * 100), 1, 1, 1, 1, 1, 1)
	end
	
	GameTooltip:AddDoubleLine(addon.L['Bandwidth In'], addon.FormatBandwidth(netStats.BandwidthIn, true), 1, 1, 1, 1, 1, 1)
	GameTooltip:AddDoubleLine(addon.L['Bandwidth Out'], addon.FormatBandwidth(netStats.BandwidthOut, true), 1, 1, 1, 1, 1, 1)
end

local function DisplayInstructions()
	GameTooltip:AddLine((KrowiBSY_Options.ShowMemory and addon.L['Hold Shift: Hide Memory'] or addon.L['Hold Shift: Show Memory']), 0.5, 0.8, 1)
	if cpuProfilingEnabled then
		GameTooltip:AddLine((KrowiBSY_Options.ShowCPU and addon.L['Hold Alt: Hide CPU'] or addon.L['Hold Alt: Show CPU']), 0.5, 0.8, 1)
	end
	GameTooltip:AddLine((KrowiBSY_Options.ShowIncrease and addon.L['Hold Ctrl: Hide Increases'] or addon.L['Hold Ctrl: Show Increases']), 0.5, 0.8, 1)
	GameTooltip:AddLine(addon.L['Left-Click: Garbage Collect'], 0.5, 0.8, 1)
	GameTooltip:AddLine(addon.L['Ctrl + Shift + Left-Click: Toggle CPU Profiling (Reload UI)'], 0.5, 0.8, 1)
	GameTooltip:AddLine(addon.L['Right-Click: Options'], 0.5, 0.8, 1)
end

-- Main Tooltip Display
function tooltip.Show(frame)
	GameTooltip:SetOwner(frame, 'ANCHOR_NONE')
	GameTooltip:SetPoint('TOPLEFT', frame, 'BOTTOMLEFT')
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