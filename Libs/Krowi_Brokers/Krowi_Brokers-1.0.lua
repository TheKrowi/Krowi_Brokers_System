--[[
    Copyright (c) 2026 Krowi

    All Rights Reserved unless otherwise explicitly stated.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
]]

---@diagnostic disable: undefined-global

local MAJOR, MINOR = "Krowi_Brokers-1.0", 1
local lib = LibStub:NewLibrary(MAJOR, MINOR)
if not lib then	return end

lib.MAJOR = MAJOR
lib.MINOR = MINOR

-- Init handling

function lib:InitBroker(addonName, addon, icon, onEnter, onLeave, onClick, onEvent, getDisplayText, menu, tooltip)
    if menu then
        menu.Init()
    end

    if tooltip then
        tooltip.Init()
    end

    local dataObject = LibStub("LibDataBroker-1.1"):NewDataObject(addonName, {
		type = "data source",
		tocname = addonName,
		icon = icon,
		text = addon.Metadata.Title .. " " .. addon.Metadata.Version,
		category = "Information",
		OnEnter = onEnter,
		OnLeave = onLeave,
		OnClick = onClick,
	})

	function dataObject:Update()
		self.text = getDisplayText()
	end

	dataObject:Update()

	addon.LDB = dataObject

    if onEvent then
        self:RegisterOnEvent(onEvent)
    end
end

-- OnEvent handling

local eventFrameOnEventHandlers = {}
local function EventFrameOnEvent(self, event, ...)
	for _, handler in next, eventFrameOnEventHandlers do
		handler(self, event, ...)
	end
end

function lib:CreateEventFrame()
	self:GetEventFrame()
end

function lib:GetEventFrame()
	if self.EventFrame then
		return self.EventFrame
	end

	self.EventFrame = CreateFrame("Frame", "Krowi_Brokers_EventFrame")
	self.EventFrame:SetScript("OnEvent", EventFrameOnEvent)
	return self.EventFrame
end

function lib:RegisterEvents(...)
	local eventFrame = self:GetEventFrame()
	for i = 1, select("#", ...) do
		local event = select(i, ...)
		eventFrame:RegisterEvent(event)
	end
end

function lib:RegisterOnEvent(handler)
	tinsert(eventFrameOnEventHandlers, handler)
end