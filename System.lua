local _, addon = ...

local system = {}
addon.System = system

-- Initialization
function system.Init()
	system.ResetFPSTracking()
end

-- FPS Tracking
local min, max, total, count, currentFps
local fpsStats = {}

function system.ResetFPSTracking()
	min = nil
	max = nil
	total = 0
	count = 0
end

function system.UpdateFps()
	currentFps = GetFramerate()

	if not min or currentFps < min then
		min = currentFps
	end

	if not max or currentFps > max then
		max = currentFps
	end

	total = total + currentFps
	count = count + 1
end

function system.GetFpsStats()
	fpsStats.Min = min or 0
	fpsStats.Max = max or 0
	fpsStats.Average = count > 0 and (total / count) or 0
	fpsStats.Current = GetFramerate()
	return fpsStats
end

-- Network Stats
local bandwidthIn, bandwidthOut, latencyHome, latencyWorld
local netStats = {}

function system.GetNetStats()
    bandwidthIn, bandwidthOut, latencyHome, latencyWorld = GetNetStats()
    netStats.BandwidthIn = bandwidthIn
    netStats.BandwidthOut = bandwidthOut
    netStats.LatencyHome = latencyHome
    netStats.LatencyWorld = latencyWorld
    return netStats
end

-- CPU Profiling
function system.IsCPUProfilingEnabled()
	return GetCVar('scriptProfile') == '1'
end

-- Addon Stats
local previousMemory = {}
local previousCPU = {}
local cpuProfilingEnabled = system.IsCPUProfilingEnabled()
local addons = {}
local addonDataPool = {}
local totalMemory, totalMemoryIncrease, totalCPU, totalCPUIncrease, numAddons
local title, mem, memIncrease, cpu, cpuIncrease
local sortBy
local addonCount, addonData

local function sortByMemory(a, b)
	if not a or not b then return false end
	if KrowiBSY_Options.AddOnSortReverse then
		return a.Memory < b.Memory
	end
	return a.Memory > b.Memory
end
local function sortByMemoryIncrease(a, b)
	if not a or not b then return false end
	if KrowiBSY_Options.AddOnSortReverse then
		return a.MemoryIncrease < b.MemoryIncrease
	end
	return a.MemoryIncrease > b.MemoryIncrease
end
local function sortByCPU(a, b)
	if not a or not b then return false end
	if KrowiBSY_Options.AddOnSortReverse then
		return a.CPU < b.CPU
	end
	return a.CPU > b.CPU
end
local function sortByCPUIncrease(a, b)
	if not a or not b then return false end
	if KrowiBSY_Options.AddOnSortReverse then
		return a.CPUIncrease < b.CPUIncrease
	end
	return a.CPUIncrease > b.CPUIncrease
end
local function sortByName(a, b)
	if not a or not b then return false end
	if KrowiBSY_Options.AddOnSortReverse then
		return a.Name > b.Name
	end
	return a.Name < b.Name
end

function system.GetAllAddOnStats()
	UpdateAddOnMemoryUsage()
	
	if cpuProfilingEnabled then
		UpdateAddOnCPUUsage()
	end

	totalMemory = 0
	totalMemoryIncrease = 0
	totalCPU = 0
	totalCPUIncrease = 0
	addonCount = 0
	numAddons = C_AddOns.GetNumAddOns()

	for i = 1, numAddons do
		if C_AddOns.IsAddOnLoaded(i) then
			_, title = C_AddOns.GetAddOnInfo(i)
			mem = GetAddOnMemoryUsage(i)
			cpu = cpuProfilingEnabled and GetAddOnCPUUsage(i) or 0

			memIncrease = 0
			if previousMemory[i] then
				memIncrease = mem - previousMemory[i]
			end
			previousMemory[i] = mem

			cpuIncrease = 0
			if previousCPU[i] then
				cpuIncrease = cpu - previousCPU[i]
			end
			previousCPU[i] = cpu

			totalMemory = totalMemory + mem
			totalMemoryIncrease = totalMemoryIncrease + memIncrease
			totalCPU = totalCPU + cpu
			totalCPUIncrease = totalCPUIncrease + cpuIncrease

			addonCount = addonCount + 1
			
			addonData = addons[addonCount] or addonDataPool[addonCount] or {}
			addonData.Name = title
			addonData.Memory = mem
			addonData.MemoryIncrease = memIncrease
			addonData.CPU = cpu
			addonData.CPUIncrease = cpuIncrease
			
			addons[addonCount] = addonData
		end
	end
	
	for i = addonCount + 1, #addons do
		addonDataPool[i] = addons[i]
		addons[i] = nil
	end

	sortBy = KrowiBSY_Options.AddOnSortBy
	if sortBy == 'Memory' then
		table.sort(addons, sortByMemory)
	elseif sortBy == 'MemoryIncrease' then
		table.sort(addons, sortByMemoryIncrease)
	elseif sortBy == 'CPU' then
		table.sort(addons, sortByCPU)
	elseif sortBy == 'CPUIncrease' then
		table.sort(addons, sortByCPUIncrease)
	else
		table.sort(addons, sortByName)
	end

	return addons, totalMemory, totalMemoryIncrease, totalCPU, totalCPUIncrease
end