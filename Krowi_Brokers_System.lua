local addonName, addon = ...

addon.L = LibStub(addon.Libs.AceLocale):GetLocale(addonName)

-- Options & Saved Data
KrowiBSY_Options = KrowiBSY_Options or {
	FpsDecimalPlaces = 0,
	FpsShowLabel = true,
	FpsShowCurrent = true,
	FpsShowCurrentLabel = false,
	FpsShowMin = false,
	FpsShowMinLabel = false,
	FpsShowMax = false,
	FpsShowMaxLabel = false,
	FpsShowAverage = false,
	FpsShowAverageLabel = false,
	LatencyShowLabel = true,
	LatencyLabelType = 'MS',
	LatencyShowHome = false,
	LatencyShowHomeLabel = false,
	LatencyShowWorld = true,
	LatencyShowWorldLabel = false,
	LatencyShowMs = false,
	BandwidthDecimalPlaces = 2,
	BandwidthShowLabel = false,
	BandwidthShowIn = false,
	BandwidthShowInLabel = false,
	BandwidthShowOut = false,
	BandwidthShowOutLabel = false,
	BandwidthShowKbps = false,
	AddOnSortBy = 'Memory',
	AddOnSortReverse = false,
	ShowMemory = true,
	ShowCPU = true,
	ShowIncrease = true,
}

KrowiBSY_SavedData = KrowiBSY_SavedData or {}

-- Color & Threshold Management
local statusColors = {
	addon.Util.Colors.RGBPrct2HEX(addon.Util.Colors.GreenRGB),
	addon.Util.Colors.RGBPrct2HEX(addon.Util.Colors.YellowRGB),
	addon.Util.Colors.RGBPrct2HEX(addon.Util.Colors.OrangeRGB),
	addon.Util.Colors.RGBPrct2HEX(addon.Util.Colors.RedRGB),
}

local fpsThreshold90 = 54
local fpsThreshold70 = 42
local fpsThreshold50 = 30

local function GetMaxFps()
	local useMaxFPS = GetCVar('useMaxFPS') == '1'
	local useTargetFPS = GetCVar('useTargetFPS') == '1'
	local maxFPS = tonumber(GetCVar('maxFPS')) or 0
	local targetFPS = tonumber(GetCVar('targetFPS')) or 60

	if useMaxFPS and useTargetFPS then
		return math.min(maxFPS, targetFPS)
	elseif useMaxFPS then
		return maxFPS
	elseif useTargetFPS then
		return targetFPS
	else
		return 60
	end
end

local function RefreshThresholds()
	local maxFps = GetMaxFps()
	fpsThreshold90 = maxFps * 0.90
	fpsThreshold70 = maxFps * 0.70
	fpsThreshold50 = maxFps * 0.50
end

local function GetFpsColor(value)
	return statusColors[value >= fpsThreshold90 and 1 or (value >= fpsThreshold70) and 2 or (value >= fpsThreshold50) and 3 or 4]
end

local function GetLatencyColor(ping)
	return statusColors[ping < 150 and 1 or (ping >= 150 and ping < 300) and 2 or (ping >= 300 and ping < 500) and 3 or 4]
end

-- Formatting Functions
local fpsFormatPattern, bandwidthFormatPattern, bandwidthFormatPatternWithUnit

function addon.FormatFps(value)
	return string.format(fpsFormatPattern, GetFpsColor(value), value)
end

function addon.FormatLatency(value, showUnit)
	if showUnit then
		return string.format('|c%s%d ms|r', GetLatencyColor(value), value)
	else
		return string.format('|c%s%d|r', GetLatencyColor(value), value)
	end
end

function addon.FormatBandwidth(value, showUnit)
	return string.format(showUnit and bandwidthFormatPatternWithUnit or bandwidthFormatPattern, value)
end

local formatters = {
	fps = addon.FormatFps,
	latency = function(value)
		return addon.FormatLatency(value, KrowiBSY_Options.LatencyShowMs)
	end,
	bandwidth = function(value)
		return addon.FormatBandwidth(value, KrowiBSY_Options.BandwidthShowKbps)
	end
}

-- Display Pattern Building
local masterFormatPattern = ''
local masterFormatStats = {}

local function RefreshFormatPatterns()
	fpsFormatPattern = '|c%s%.' .. KrowiBSY_Options.FpsDecimalPlaces .. 'f|r'
	bandwidthFormatPattern = '%.' .. KrowiBSY_Options.BandwidthDecimalPlaces .. 'f'
	bandwidthFormatPatternWithUnit = '%.' .. KrowiBSY_Options.BandwidthDecimalPlaces .. 'f kbps'
end

local pattern, stats, hasContent, needsSeparator
local function AddSectionLabel(showLabel, labelKey)
	if not showLabel then
		return
	end
	if hasContent then
		pattern = pattern .. ' '
	end
	pattern = pattern .. addon.L[labelKey] .. ':'
	hasContent = true
end

local function AddStatItem(showStat, showLabel, labelKey, statName, formatterName)
	if not showStat then
		return
	end

	if needsSeparator then
		pattern = pattern .. ', '
	elseif hasContent then
		pattern = pattern .. ' '
	end

	if showLabel then
		pattern = pattern .. addon.L[labelKey] .. ': '
	end

	pattern = pattern .. '%s'
	table.insert(stats, {stat = statName, formatter = formatterName})
	hasContent = true
	needsSeparator = true
end

local function BuildDisplayPattern()
	pattern = ''
	stats = {}
	hasContent = false

	AddSectionLabel(KrowiBSY_Options.FpsShowLabel, 'FPS')
	needsSeparator = false
	AddStatItem(KrowiBSY_Options.FpsShowMin, KrowiBSY_Options.FpsShowMinLabel, 'Min', 'Min', 'fps')
	AddStatItem(KrowiBSY_Options.FpsShowAverage, KrowiBSY_Options.FpsShowAverageLabel, 'Avg', 'Average', 'fps')
	AddStatItem(KrowiBSY_Options.FpsShowMax, KrowiBSY_Options.FpsShowMaxLabel, 'Max', 'Max', 'fps')
	AddStatItem(KrowiBSY_Options.FpsShowCurrent, KrowiBSY_Options.FpsShowCurrentLabel, 'Current', 'Current', 'fps')

	AddSectionLabel(KrowiBSY_Options.LatencyShowLabel, KrowiBSY_Options.LatencyLabelType or 'MS')
	needsSeparator = false
	AddStatItem(KrowiBSY_Options.LatencyShowHome, KrowiBSY_Options.LatencyShowHomeLabel, 'Home', 'LatencyHome', 'latency')
	AddStatItem(KrowiBSY_Options.LatencyShowWorld, KrowiBSY_Options.LatencyShowWorldLabel, 'World', 'LatencyWorld', 'latency')

	AddSectionLabel(KrowiBSY_Options.BandwidthShowLabel, 'Bandwidth')
	needsSeparator = false
	AddStatItem(KrowiBSY_Options.BandwidthShowIn, KrowiBSY_Options.BandwidthShowInLabel, 'In', 'BandwidthIn', 'bandwidth')
	AddStatItem(KrowiBSY_Options.BandwidthShowOut, KrowiBSY_Options.BandwidthShowOutLabel, 'Out', 'BandwidthOut', 'bandwidth')

	masterFormatPattern = pattern
	masterFormatStats = stats
end

function addon.RefreshDisplayConfiguration()
	RefreshThresholds()
	RefreshFormatPatterns()
	BuildDisplayPattern()
end

-- Main Display Logic
local fpsStats, netStats
local allStats, args = {}, {}
function addon.GetDisplayText()
	addon.System.UpdateFps()
	fpsStats = addon.System.GetFpsStats()
	netStats = addon.System.GetNetStats()
	
	if masterFormatPattern == '' then
		return ''
	end
	
	allStats.Current = fpsStats.Current
	allStats.Min = fpsStats.Min
	allStats.Max = fpsStats.Max
	allStats.Average = fpsStats.Average
	allStats.LatencyHome = netStats.LatencyHome
	allStats.LatencyWorld = netStats.LatencyWorld
	allStats.BandwidthIn = netStats.BandwidthIn
	allStats.BandwidthOut = netStats.BandwidthOut
	
	for i = 1, #masterFormatStats do
		local statInfo = masterFormatStats[i]
		local value = allStats[statInfo.stat]
		args[i] = formatters[statInfo.formatter](value)
	end
	
	if #args > 0 then
		return string.format(masterFormatPattern, unpack(args))
	else
		return masterFormatPattern
	end
end

-- Event Handlers
local function OnClick(self, button)
	if button == 'LeftButton' then
		if IsControlKeyDown() and IsShiftKeyDown() then
			local currentValue = GetCVar('scriptProfile')
			local newValue = (currentValue == '1') and '0' or '1'
			SetCVar('scriptProfile', newValue)
			ReloadUI()
			return
		end
		collectgarbage('collect')
		return
	end

	if button ~= 'RightButton' then
		return
	end

	addon.Menu.ShowPopup(self)
end

local function OnEnter(self)
	addon.Tooltip.Show(self)

	local throttle = 0
	self:SetScript('OnUpdate', function(frame, elapsed)
		throttle = throttle + elapsed
		if throttle < 1 then return end
		throttle = 0

		addon.Tooltip.Show(frame)
	end)
end

local function OnLeave(self)
	self:SetScript('OnUpdate', nil)
	GameTooltip:Hide()
end

local updateTimer
local function OnEvent(event, ...)
	if event == 'PLAYER_ENTERING_WORLD' then
		addon.LDB:Update()

		if updateTimer then
			return
		end

		updateTimer = C_Timer.NewTicker(1, function()
			addon.LDB:Update()
		end)
	end
end

-- Initialization
local brokers = LibStub('Krowi_Brokers-1.0')
addon.System.Init()
addon.RefreshDisplayConfiguration()
brokers:InitBroker(
	addonName,
	addon,
	OnEnter,
	OnLeave,
	OnClick,
	OnEvent
)
brokers:RegisterEvents('PLAYER_ENTERING_WORLD')