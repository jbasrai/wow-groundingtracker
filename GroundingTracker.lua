local frame
local groundingDown = false
local playerID
local gtotemID
local inArena = false

local tbl = {}

local function printTable()
	SendChatMessage("GroundingTracker: ", "PARTY")
	for spellName, amount in pairs(tbl) do	
		SendChatMessage("     "..spellName.." x"..amount, "PARTY")
	end
end

local function GroundingTracker_PLAYER_ENTERING_WORLD(self)	
	frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	local itype = select(2, IsInInstance())
	if(itype == "arena") then
		inArena = true
		tbl = {}
	elseif(inArena) then
		inArena = false
		printTable()
	end
end	

local function GroundingTracker_COMBAT_LOG_EVENT_UNFILTERED(self, ...)
	
	playerID = UnitGUID("player")
	event = select(2, ...)
	sourceID = select(4, ...)
	destID = select(8, ...)
	spellID = select(12, ...)
	
	if(event == "SPELL_SUMMON" and playerID == sourceID and spellID == 8177) then
		gtotemID = destID
		groundingDown = true	
	elseif(groundingDown and ((event == "SPELL_CAST_SUCCESS" and destID == gtotemID) or
		(event == "SPELL_DAMAGE" and destID == gtotemID) or 
		(event == "SPELL_MISSED" and destID == gtotemID))) then
		groundingDown = false
		spellName = select(13, ...)
		if(tbl[spellName] == nil) then
			tbl[spellName] = 1
		else
			tbl[spellName] = tbl[spellName] + 1
		end
		SendChatMessage("Grounded: "..spellName.."!", "PARTY")
	end
	
end


SLASH_GROUNDINGTRACKER1 = "/gt"
SlashCmdList["GROUNDINGTRACKER"] = function() printTable() end

local eventhandler = {
	["PLAYER_ENTERING_WORLD"] = function(self) GroundingTracker_PLAYER_ENTERING_WORLD(self) end,
	["COMBAT_LOG_EVENT_UNFILTERED"] = function(self, ...) GroundingTracker_COMBAT_LOG_EVENT_UNFILTERED (self, ...) end,
}

local function GroundingTracker_OnEvent(self, event, ...)
	eventhandler[event](self, ...)
end

frame = CreateFrame("Frame", nil, UIParent)
frame:SetScript("OnEvent", GroundingTracker_OnEvent)
frame:RegisterEvent("PLAYER_ENTERING_WORLD")