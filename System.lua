local _, addon = ...;

local system = {};
addon.System = system;

local min, max, total, count

function system.Init(brokers)
	-- Initialize system monitoring
	system.ResetFPSTracking();

    print(brokers.RegisterOnUpdate)
end

function system.ResetFPSTracking()
	min = nil;
	max = nil;
	total = 0;
	count = 0;
end

function system.UpdateFPS()
	local currentFPS = GetFramerate();
	
	-- Update Min
	if not min or currentFPS < min then
		min = currentFPS;
	end
	
	-- Update Max
	if not max or currentFPS > max then
		max = currentFPS;
	end
	
	-- Update Total and Count for average
	total = total + currentFPS;
	count = count + 1;
end

function system.GetFPSStats()
	local average = count > 0 and (total / count) or 0;
	
	return {
		Min = min or 0,
		Max = max or 0,
		Average = average,
		Current = GetFramerate()
	};
end