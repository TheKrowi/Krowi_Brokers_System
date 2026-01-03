local _, addon = ...;

local tooltip = {};
addon.Tooltip = tooltip;

function tooltip.Init()
	-- Initialize tooltip if needed
end

function tooltip.Show(frame)
	GameTooltip:SetOwner(frame, "ANCHOR_NONE");
	GameTooltip:SetPoint("TOPLEFT", frame, "BOTTOMLEFT");
	GameTooltip:AddLine(addon.Metadata.Title .. " " .. addon.Metadata.Version);
	GameTooltip_AddBlankLineToTooltip(GameTooltip);

	-- Other lines can be added here
	
	GameTooltip:Show();
end