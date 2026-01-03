local addonName, addon = ...;

addon.L = LibStub(addon.Libs.AceLocale):GetLocale(addonName);

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
	LatencyLabelType = "MS",
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
	AddOnSortBy = "Name",
	ShowMemoryIncrease = true,
};

KrowiBSY_SavedData = KrowiBSY_SavedData or {
	-- Saved data can be initialized here
};

-- Helper functions
local statusColors = {
	addon.Util.Colors.RGBPrct2HEX(addon.Util.Colors.GreenRGB),
	addon.Util.Colors.RGBPrct2HEX(addon.Util.Colors.YellowRGB),
	addon.Util.Colors.RGBPrct2HEX(addon.Util.Colors.OrangeRGB),
	addon.Util.Colors.RGBPrct2HEX(addon.Util.Colors.RedRGB),
}

-- Cached FPS thresholds
local fpsThreshold90 = 54
local fpsThreshold70 = 42
local fpsThreshold50 = 30

local function GetMaxFps()
	local useMaxFPS = GetCVar("useMaxFPS") == "1"
	local useTargetFPS = GetCVar("useTargetFPS") == "1"
	local maxFPS = tonumber(GetCVar("maxFPS")) or 0
	local targetFPS = tonumber(GetCVar("targetFPS")) or 60

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

-- Cached format patterns
local fpsFormatPattern, bandwidthFormatPattern, bandwidthFormatPatternWithUnit

function addon.FormatFps(value)
	return string.format(fpsFormatPattern, GetFpsColor(value), value)
end

function addon.FormatLatency(value, showUnit)
	if showUnit then
		return string.format("|c%s%d ms|r", GetLatencyColor(value), value)
	else
		return string.format("|c%s%d|r", GetLatencyColor(value), value)
	end
end

function addon.FormatBandwidth(value, showUnit)
	return string.format(showUnit and bandwidthFormatPatternWithUnit or bandwidthFormatPattern, value)
end

-- Pre-defined formatter functions
local formatters = {
	fps = addon.FormatFps,
	latency = function(value)
		return addon.FormatLatency(value, KrowiBSY_Options.LatencyShowMs)
	end,
	bandwidth = function(value)
		return addon.FormatBandwidth(value, KrowiBSY_Options.BandwidthShowKbps)
	end
}

local masterFormatPattern = ""
local masterFormatStats = {}

local function RefreshFormatPatterns()
	fpsFormatPattern = "|c%s%." .. KrowiBSY_Options.FpsDecimalPlaces .. "f|r"
	bandwidthFormatPattern = "%." .. KrowiBSY_Options.BandwidthDecimalPlaces .. "f"
	bandwidthFormatPatternWithUnit = "%." .. KrowiBSY_Options.BandwidthDecimalPlaces .. "f kbps"
end

local function BuildDisplayPattern()
	local pattern = ""
	local stats = {}
	local hasContent = false
	
	-- Build FPS section
	if KrowiBSY_Options.FpsShowLabel then
		if hasContent then
			pattern = pattern .. " "
		end
		pattern = pattern .. addon.L["FPS"] .. ":"
		hasContent = true
	end
	
	local needsSeparator = false
	if KrowiBSY_Options.FpsShowCurrent then
		if needsSeparator then
			pattern = pattern .. ", "
		elseif hasContent then
			pattern = pattern .. " "
		end
		if KrowiBSY_Options.FpsShowCurrentLabel then
			pattern = pattern .. addon.L["Current"] .. ": "
		end
		pattern = pattern .. "%s"
		table.insert(stats, {stat = "Current", formatter = "fps"})
		hasContent = true
		needsSeparator = true
	end
	
	if KrowiBSY_Options.FpsShowMin then
		if needsSeparator then
			pattern = pattern .. ", "
		elseif hasContent then
			pattern = pattern .. " "
		end
		if KrowiBSY_Options.FpsShowMinLabel then
			pattern = pattern .. addon.L["Min"] .. ": "
		end
		pattern = pattern .. "%s"
		table.insert(stats, {stat = "Min", formatter = "fps"})
		hasContent = true
		needsSeparator = true
	end
	
	if KrowiBSY_Options.FpsShowMax then
		if needsSeparator then
			pattern = pattern .. ", "
		elseif hasContent then
			pattern = pattern .. " "
		end
		if KrowiBSY_Options.FpsShowMaxLabel then
			pattern = pattern .. addon.L["Max"] .. ": "
		end
		pattern = pattern .. "%s"
		table.insert(stats, {stat = "Max", formatter = "fps"})
		hasContent = true
		needsSeparator = true
	end
	
	if KrowiBSY_Options.FpsShowAverage then
		if needsSeparator then
			pattern = pattern .. ", "
		elseif hasContent then
			pattern = pattern .. " "
		end
		if KrowiBSY_Options.FpsShowAverageLabel then
			pattern = pattern .. addon.L["Avg"] .. ": "
		end
		pattern = pattern .. "%s"
		table.insert(stats, {stat = "Average", formatter = "fps"})
		hasContent = true
		needsSeparator = true
	end
	
	-- Build Latency section
	needsSeparator = false
	if KrowiBSY_Options.LatencyShowLabel then
		if hasContent then
			pattern = pattern .. " "
		end
		local labelType = KrowiBSY_Options.LatencyLabelType or "MS"
		pattern = pattern .. addon.L[labelType] .. ":"
		hasContent = true
	end
	
	if KrowiBSY_Options.LatencyShowHome then
		if needsSeparator then
			pattern = pattern .. ", "
		elseif hasContent then
			pattern = pattern .. " "
		end
		if KrowiBSY_Options.LatencyShowHomeLabel then
			pattern = pattern .. addon.L["Home"] .. ": "
		end
		pattern = pattern .. "%s"
		table.insert(stats, {stat = "LatencyHome", formatter = "latency"})
		hasContent = true
		needsSeparator = true
	end
	
	if KrowiBSY_Options.LatencyShowWorld then
		if needsSeparator then
			pattern = pattern .. ", "
		elseif hasContent then
			pattern = pattern .. " "
		end
		if KrowiBSY_Options.LatencyShowWorldLabel then
			pattern = pattern .. addon.L["World"] .. ": "
		end
		pattern = pattern .. "%s"
		table.insert(stats, {stat = "LatencyWorld", formatter = "latency"})
		hasContent = true
		needsSeparator = true
	end
	
	-- Build Bandwidth section
	needsSeparator = false
	if KrowiBSY_Options.BandwidthShowLabel then
		if hasContent then
			pattern = pattern .. " "
		end
		pattern = pattern .. addon.L["Bandwidth"] .. ":"
		hasContent = true
	end
	
	if KrowiBSY_Options.BandwidthShowIn then
		if needsSeparator then
			pattern = pattern .. ", "
		elseif hasContent then
			pattern = pattern .. " "
		end
		if KrowiBSY_Options.BandwidthShowInLabel then
			pattern = pattern .. addon.L["In"] .. ": "
		end
		pattern = pattern .. "%s"
		table.insert(stats, {stat = "BandwidthIn", formatter = "bandwidth"})
		hasContent = true
		needsSeparator = true
	end
	
	if KrowiBSY_Options.BandwidthShowOut then
		if needsSeparator then
			pattern = pattern .. ", "
		elseif hasContent then
			pattern = pattern .. " "
		end
		if KrowiBSY_Options.BandwidthShowOutLabel then
			pattern = pattern .. addon.L["Out"] .. ": "
		end
		pattern = pattern .. "%s"
		table.insert(stats, {stat = "BandwidthOut", formatter = "bandwidth"})
	end
	
	masterFormatPattern = pattern
	masterFormatStats = stats
end

function addon.RefreshDisplayConfiguration()
	RefreshThresholds()
	RefreshFormatPatterns()
	BuildDisplayPattern()
end

-- Main functions

local fpsStats, netStats;
local allStats = {
	Current = 0,
	Min = 0,
	Max = 0,
	Average = 0,
	LatencyHome = 0,
	LatencyWorld = 0,
	BandwidthIn = 0,
	BandwidthOut = 0
}
local args = {}
function addon.GetDisplayText()
	addon.System.UpdateFps()
	fpsStats = addon.System.GetFpsStats()
	netStats = addon.System.GetNetStats()
	
	-- If no format configured, return empty
	if masterFormatPattern == "" then
		return ""
	end
	
	-- Update reusable stats lookup table
	allStats.Current = fpsStats.Current
	allStats.Min = fpsStats.Min
	allStats.Max = fpsStats.Max
	allStats.Average = fpsStats.Average
	allStats.LatencyHome = netStats.LatencyHome
	allStats.LatencyWorld = netStats.LatencyWorld
	allStats.BandwidthIn = netStats.BandwidthIn
	allStats.BandwidthOut = netStats.BandwidthOut
	
	-- Build the arguments for string.format using direct lookups
	for i = 1, #masterFormatStats do
		local statInfo = masterFormatStats[i]
		local value = allStats[statInfo.stat]
		args[i] = formatters[statInfo.formatter](value)
	end
	
	-- Apply the pre-built pattern
	if #args > 0 then
		return string.format(masterFormatPattern, unpack(args))
	else
		return masterFormatPattern
	end
end

local function OnClick(self, button)
	if button == "LeftButton" then
		-- Ctrl + Shift + Left-Click: Toggle CPU Profiling
		if IsControlKeyDown() and IsShiftKeyDown() then
			local currentValue = GetCVar("scriptProfile");
			local newValue = (currentValue == "1") and "0" or "1";
			SetCVar("scriptProfile", newValue);
			ReloadUI()
			return;
		end
		
		-- Add left-click behavior here
		-- print(addon.L["Left-Click Action"]);
		return;
	end

	if button ~= "RightButton" then
		return;
	end

	addon.Menu.ShowPopup();
end

local function OnEnter(self)
	addon.Tooltip.Show(self);

	local throttle = 0;
	self:SetScript("OnUpdate", function(frame, elapsed)
		throttle = throttle + elapsed;
		if throttle < 1 then return; end
		throttle = 0;

		addon.Tooltip.Show(frame);
	end);
end

local function OnLeave(self)
	self:SetScript("OnUpdate", nil);
	GameTooltip:Hide();
end

local updateTimer
local function OnEvent(event, ...)
	if event == "PLAYER_ENTERING_WORLD" then
		addon.LDB:Update();

		if updateTimer then
			return
		end

		updateTimer = C_Timer.NewTicker(1, function()
			addon.LDB:Update();
		end);
	end
end

local brokers = LibStub("Krowi_Brokers-1.0");
addon.System.Init()
addon.RefreshDisplayConfiguration() -- Initialize the display configuration on load
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