local _, addon = ...;

local system = {};
addon.System = system;

function system.Init()
	system.ResetFPSTracking();
end

local min, max, total, count = nil, nil, 0, 0;
function system.ResetFPSTracking()
	min = nil;
	max = nil;
	total = 0;
	count = 0;
end

local currentFps
local fpsStats = {Min = 0, Max = 0, Average = 0, Current = 0}
function system.UpdateFps()
	currentFps = GetFramerate();

	if not min or currentFps < min then
		min = currentFps;
	end

	if not max or currentFps > max then
		max = currentFps;
	end

	total = total + currentFps;
	count = count + 1;
end

function system.GetFpsStats()
	fpsStats.Min = min or 0
	fpsStats.Max = max or 0
	fpsStats.Average = count > 0 and (total / count) or 0
	fpsStats.Current = GetFramerate()
	return fpsStats
end

local bandwidthIn, bandwidthOut, latencyHome, latencyWorld
local netStats = {BandwidthIn = 0, BandwidthOut = 0, LatencyHome = 0, LatencyWorld = 0}
function system.GetNetStats()
    bandwidthIn, bandwidthOut, latencyHome, latencyWorld = GetNetStats()
    netStats.BandwidthIn = bandwidthIn
    netStats.BandwidthOut = bandwidthOut
    netStats.LatencyHome = latencyHome
    netStats.LatencyWorld = latencyWorld
    return netStats
end

function system.IsCPUProfilingEnabled()
	return GetCVar("scriptProfile") == "1";
end

local previousMemory = {};
local cpuProfilingEnabled = system.IsCPUProfilingEnabled()
local addons = {}
local addonDataPool = {}
local totalMemory, totalMemoryIncrease, numAddons
local title, mem, memIncrease, cpu
local sortBy
local addonCount, addonData

-- Reusable sort functions
local function sortByMemory(a, b) return a.Memory > b.Memory end
local function sortByMemoryIncrease(a, b) return a.MemoryIncrease > b.MemoryIncrease end
local function sortByCPU(a, b) return a.CPU > b.CPU end
local function sortByName(a, b) return a.Name < b.Name end

function system.GetAllAddOnStats()
	UpdateAddOnMemoryUsage();
	
	if cpuProfilingEnabled then
		UpdateAddOnCPUUsage();
	end

	-- Reset counters
	totalMemory = 0;
	totalMemoryIncrease = 0;
	addonCount = 0;
	numAddons = C_AddOns.GetNumAddOns();

	for i = 1, numAddons do
		if C_AddOns.IsAddOnLoaded(i) then
			_, title = C_AddOns.GetAddOnInfo(i);
			mem = GetAddOnMemoryUsage(i);
			cpu = cpuProfilingEnabled and GetAddOnCPUUsage(i) or 0;

			memIncrease = 0;
			if previousMemory[i] then
				memIncrease = mem - previousMemory[i];
			end
			previousMemory[i] = mem;

			totalMemory = totalMemory + mem;
			totalMemoryIncrease = totalMemoryIncrease + memIncrease;

			addonCount = addonCount + 1;
			
			-- Reuse existing table or get from pool
			addonData = addons[addonCount] or addonDataPool[addonCount] or {};
			addonData.Name = title;
			addonData.Memory = mem;
			addonData.MemoryIncrease = memIncrease;
			addonData.CPU = cpu;
			
			-- Reuse or create closure functions
			if not addonData.GetMemoryPercent then
				addonData.GetMemoryPercent = function()
					return totalMemory > 0 and (addonData.Memory / totalMemory) or 0;
				end
			end
			if not addonData.GetMemoryIncreasePercent then
				addonData.GetMemoryIncreasePercent = function()
					return totalMemoryIncrease ~= 0 and (addonData.MemoryIncrease / totalMemoryIncrease) or 0;
				end
			end
			
			addons[addonCount] = addonData;
		end
	end
	
	-- Store extra tables for reuse and clear unused entries
	for i = addonCount + 1, #addons do
		addonDataPool[i] = addons[i];
		addons[i] = nil;
	end

	-- Sort addons based on selected option
	sortBy = KrowiBSY_Options.AddOnSortBy or "Name";
	if sortBy == "Memory" then
		table.sort(addons, sortByMemory);
	elseif sortBy == "MemoryIncrease" then
		table.sort(addons, sortByMemoryIncrease);
	elseif sortBy == "CPU" then
		table.sort(addons, sortByCPU);
	else -- Name
		table.sort(addons, sortByName);
	end

	return addons;
end