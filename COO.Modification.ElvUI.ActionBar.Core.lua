local addon, engine = ...
	engine[1] = {} -- COO
	engine[2] = {} -- COOCFG

local COO, COOCFG = unpack(select(2, ...))

COO.UIParent = CreateFrame('Frame', 'COOParent', UIParent)
COO.UIParent:SetFrameLevel(COO.UIParent:GetFrameLevel())
COO.UIParent:SetFrameStrata(COO.UIParent:GetFrameStrata())
COO.UIParent:SetPoint('CENTER', UIParent, 'CENTER')
COO.UIParent:SetSize(UIParent:GetSize())

--Идентификаторы классовых панелей
COO.Pages = {
	--DRUID: Caster: 0, Cat: 1, Tree of Life: 0, Bear: 3, Moonkin: 4
	["DRUID"] = "[bonusbar:1,nostealth] 7; [bonusbar:1,stealth] 8; [bonusbar:2] 8; [bonusbar:3] 9; [bonusbar:4] 10;",
	--WARRIOR: Battle Stance: 1, Defensive Stance: 2, Berserker Stance: 3 
	["WARRIOR"] = "[bonusbar:1] 7; [bonusbar:2] 8; [bonusbar:3] 9;",
	--PRIEST: Normal: 0, Shadowform: 1
	["PRIEST"] = "[bonusbar:1] 7;",
	--ROGUE: Normal: 0, Stealthed: 1
	["ROGUE"] = "[bonusbar:1] 7; [form:3] 7;",
	--DEFAULT
	["DEFAULT"] = "[bonusbar:5] 11; [bar:2] 2; [bar:3] 3; [bar:4] 4; [bar:5] 5; [bar:6] 6;",
}

COO.Bar = {{}, {}, {}, {}, {}, {}, {}}

COO.Multiplier = 768 / string.match(GetCVar("gxResolution"), "%d+x(%d+)") / 0.85333333333333
COO.ActionBarNameExtension = "COOBar"
COO.ActionBarCtrlButtonNameExtension = "COOActionBarMenu"
COO.ButtonInBlock = 3
COO.ButtonInSpellBar = 12
COO.ButtonInClassBar = NUM_SHAPESHIFT_SLOTS
COO.Orientation = {"Horizontal", "Vertical",}
COO.BlizzardBarName = {"Shapeshift", "Action", "MultiBarBottomLeft", "MultiBarBottomRight", "MultiBarLeft", "MultiBarRight",}

COOCFG.SecondaryBar = {{}, {}, {}}

--[[
COOCFG.ClassBarOrientation = COO.Orientation[2]
COOCFG.F2BarOrientation = COO.Orientation[1]
COOCFG.F3BarOrientation = COO.Orientation[1]
COOCFG.F4BarOrientation = COO.Orientation[2]
COOCFG.F5BarOrientation = COO.Orientation[2]
COOCFG.ButtonSpacing = 6
COOCFG.ActionButtonSize = 28
COOCFG.ClassButtonSize = 24
]]--

function scale(X)
    return COO.Multiplier * math.floor(X / COO.Multiplier + 0.5)
end

---------
-- Публичные функции для доступа из других юнитов
---------

function COO.Scale(x) 
	return scale(x)
end

function COO.GetCharacterClassName()
	local CharacterClassPlayerLng, CharacterClassEnglishLng = UnitClass("player")
	
	return CharacterClassEnglishLng
end

function COO.GetCurrentPageFullName()
	local DefaultPage = COO.Pages["DEFAULT"]
	
	local CurrentPage = COO.Pages[COO.GetCharacterClassName()]
	
	if CurrentPage then
		return DefaultPage.." "..CurrentPage.." 1"
	else
		return DefaultPage.." 1"
	end
end