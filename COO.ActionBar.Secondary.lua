local COO, COOCFG = unpack(select(2, ...))
local E, _, _, DB = unpack(ElvUI)

--[[for _, SecondaryBar in ipairs(COO.SecondaryBar) do
	local Buttons = {}
	
	for i = 1, COO.ButtonInSpellBar do	
		_G[SecondaryBar.Bar:GetName().."Button"..i]:ClearAllPoints()
		_G[SecondaryBar.Bar:GetName().."Button"..i]:SetParent(SecondaryBar.Bar)
		Buttons[i] = _G["ActionButton"..i]
	end
	
	SecondaryBar.Bar:SetAttribute("Buttons", Buttons) 
	SecondaryBar.Bar:SetAttribute("Orientation", SecondaryBar.Orientation) 
	COO.ConvertToCOOActionBar(SecondaryBar.Bar)
end]]--

for i, Bar in ipairs(COO.Bar) do
	if i == 6 and E then
	
	else
		COO.ConvertToCOOActionBar(Bar.Frame)
	end
end

--[[local BarFrame = CreateFrame("Frame", "COO.MultiBarBottomLeft", UIParent, "SecureHandlerStateTemplate")

MultiBarBottomLeft:SetParent(BarFrame)

local Buttons = {}

for i = 1, COO.ButtonInSpellBar do	
	_G["MultiBarBottomLeftButton"..i]:ClearAllPoints()
	--_G["MultiBarBottomLeftButton"..i]:SetParent(BarFrame)
	Buttons[i] = _G["MultiBarBottomLeftButton"..i]
end	

BarFrame:SetAttribute("Buttons", Buttons) 
BarFrame:SetAttribute("Orientation", COO.Orientation[1]) 

COO.ConvertToCOOActionBar(BarFrame)]]--

--[[
-- Устанавливаем бар F2
function COO.PositionF2Bar()	
	local BarFrame = COO.TransformationToCOOActionBar(COO.BlizzardBarName[3], COOCFG.F2BarOrientation)
	
	MultiBarBottomLeft:SetParent(BarFrame)
	MultiBarBottomLeft:SetAllPoints(BarFrame)
	
	BarFrame:SetScale(COOCFG.ActionButtonSize / _G[COO.BlizzardBarName[3].."Button"..1]:GetWidth())
end

-- Устанавливаем бар F3
function COO.PositionF3Bar()	
	local BarFrame = COO.TransformationToCOOActionBar(COO.BlizzardBarName[4], COOCFG.F3BarOrientation)
	
	MultiBarBottomRight:SetParent(BarFrame)
	
	BarFrame:SetScale(COOCFG.ActionButtonSize / _G[COO.BlizzardBarName[4].."Button"..1]:GetWidth())
end

-- Устанавливаем бар F4
function COO.PositionF4Bar()
	local BarFrame = COO.TransformationToCOOActionBar(COO.BlizzardBarName[5], COOCFG.F4BarOrientation)
	
	MultiBarLeft:SetParent(BarFrame)
	
	BarFrame:SetScale(COOCFG.ActionButtonSize / _G[COO.BlizzardBarName[5].."Button"..1]:GetWidth())
end

-- Устанавливаем бар F5
function COO.PositionF5Bar()	
	local BarFrame = COO.TransformationToCOOActionBar(COO.BlizzardBarName[6], COOCFG.F5BarOrientation)
	
	MultiBarRight:SetParent(BarFrame)
	
	BarFrame:SetScale(COOCFG.ActionButtonSize / _G[COO.BlizzardBarName[6].."Button"..1]:GetWidth())
end
]]--