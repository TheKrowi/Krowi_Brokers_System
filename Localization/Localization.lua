local _, addon = ...;

local localization = {};
addon.Localization = localization;

function localization.GetDefaultLocale()
	local L = {};
	
	return setmetatable(L, {
		__newindex = function(self, key, value)
			if value == true then
				value = key;
			end
			rawset(self, key, value);
		end,
		__index = function(self, key)
			return key;
		end
	});
end
