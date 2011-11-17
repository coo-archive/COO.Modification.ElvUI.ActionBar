---------------------------------------------------------------------------
-- Обработка главного бара
---------------------------------------------------------------------------

local COO, COOCFG = unpack(select(2, ...))
local E, C, _, DB = unpack(ElvUI)
local ClassBar
local PetBarFrame
local PetBarOrientation

if E then
	ClassBar = ElvuiShiftBar
	PetBarFrame = ElvuiPetBar
else
	ClassBar = ShapeshiftBarFrame
	PetBarFrame = nil
end

if C then
	if C["actionbar"].bottompetbar == true then
		PetBarOrientation = COO.Orientation[1]
	else
		PetBarOrientation = COO.Orientation[2]
	end
else
	PetBarOrientation = COO.Orientation[1]
end

COO.Bar[1] = {
	["Frame"] = CreateFrame("Frame", "COO.MainBar", COO.UIParent, "SecureHandlerStateTemplate"),
	["Buttons"] = {},
	["Orientation"] = COOCFG.SecondaryBar[1].Orientation,
}
COO.Bar[2] = {
	["Frame"] = MultiBarBottomLeft,
	["Buttons"] = {},
	["Orientation"] = COOCFG.SecondaryBar[2].Orientation,
}
COO.Bar[3] = {
	["Frame"] = MultiBarBottomRight,
	["Buttons"] = {},
	["Orientation"] = COOCFG.SecondaryBar[3].Orientation,
}
COO.Bar[4] = {
	["Frame"] = MultiBarRight,
	["Buttons"] = {},
	["Orientation"] = COOCFG.SecondaryBar[4].Orientation,
}
COO.Bar[5] = {
	["Frame"] = MultiBarLeft,
	["Buttons"] = {},
	["Orientation"] = COOCFG.SecondaryBar[5].Orientation,
}
COO.Bar[6] = {
	["Frame"] = ClassBar,
	["Buttons"] = {},
	["Orientation"] = COOCFG.SecondaryBar[6].Orientation,
}
COO.Bar[7] = {
	["Frame"] = PetBarFrame,
	["Buttons"] = {},
	["Orientation"] = PetBarOrientation,
}

for i, Bar in ipairs(COO.Bar) do
	if i == 1 then
		for j = 1, COO.ButtonInSpellBar do	
			Bar.Buttons[j] = _G["ActionButton"..j]
			Bar.Buttons[j]:SetParent(Bar.Frame)
		end
	elseif i == 6 then
		Bar.Frame:SetParent(COO.UIParent)
		
		for j = 1, NUM_SHAPESHIFT_SLOTS do
			Bar.Buttons[j] = _G["ShapeshiftButton"..j]
			Bar.Buttons[j]:SetParent(Bar.Frame)
		end
	elseif i == 7 then
		Bar.Frame:SetParent(COO.UIParent)
		
		for j = 1, 10 do
			Bar.Buttons[j] = _G["PetActionButton"..j]
			Bar.Buttons[j]:SetParent(Bar.Frame)
		end
	else
		Bar.Frame:SetParent(COO.UIParent)
		
		for j = 1, COO.ButtonInSpellBar do	
			Bar.Buttons[j] = _G[Bar.Frame:GetName().."Button"..j]
		end
	end
	
	Bar.Frame:SetAttribute("Buttons", Bar.Buttons) 
	Bar.Frame:SetAttribute("Orientation", Bar.Orientation) 
end

-- Событие главного бара на логин
function MainBarOnPlayerLogin(self, event, ...)	
	--for i = 1, COO.ButtonInSpellBar do		
		--self:SetFrameRef("ActionButton"..i, _G["ActionButton"..i])
	--end	
	
	--self:Execute([[
		--buttons = table.new()
		--for i = 1, 12 do
			--table.insert(buttons, self:GetFrameRef("ActionButton"..i))
		--end
	--]])

	--local button
	
	--self:SetAttribute("_onstate-page", [[ 
		--for i, button in ipairs(buttons) do
			--button:SetAttribute("actionpage", tonumber(newstate))
		--end
	--]])

	--self:SetAttribute("_onstate-vehicleupdate", [[		
		--if newstate == "s2" then
			--self:Hide()
		--else
			--self:Show()
		--end	
	--]])
	
	--RegisterStateDriver(self, "page", COO.GetCurrentPageFullName())
	--RegisterStateDriver(self, "vehicleupdate", "[vehicleui] s2;s1")
end

---------
-- Устанавливаем главный бар
---------

COO.Bar[1].Frame:RegisterEvent("PLAYER_LOGIN")
COO.Bar[1].Frame:RegisterEvent("KNOWN_CURRENCY_TYPES_UPDATE")
COO.Bar[1].Frame:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
COO.Bar[1].Frame:RegisterEvent("BAG_UPDATE")
COO.Bar[1].Frame:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
COO.Bar[1].Frame:SetScript("OnEvent", function(self, event, ...)
	if event == "PLAYER_LOGIN" then
		ElvuiActionBarBackground:Hide()
		ElvuiPetActionBarBackground:Hide()
		--_G["LeftSplit"]:SetAlpha(0)
		_G["LeftSplit"]:SetScript("OnMouseDown", function(self) end)
		--_G["RightSplit"]:SetAlpha(0)
		_G["RightSplit"]:SetScript("OnMouseDown", function(self) end)
		_G["TopMainBar"]:SetAlpha(0)
		_G["TopMainBar"]:SetScript("OnMouseDown", function(self) end)
		_G["RightBarBig"]:SetAlpha(0)
		_G["RightBarBig"]:SetScript("OnMouseDown", function(self) end)
		_G["RightBarInc"]:SetAlpha(0)
		_G["RightBarInc"]:SetScript("OnMouseDown", function(self) end)
		_G["RightBarDec"]:SetAlpha(0)
		_G["RightBarDec"]:SetScript("OnMouseDown", function(self) end)
		MainBarOnPlayerLogin(self, event, ...)
	elseif event == "PLAYER_ENTERING_WORLD" then	
		COO.ConvertToCOOActionBar(COO.Bar[1].Frame, COO.Orientation[1])
		ElvuiActionBarBackground:Hide()
	elseif event == "PLAYER_TALENT_UPDATE" or event == "ACTIVE_TALENT_GROUP_CHANGED" then
		LoadAddOn("Blizzard_GlyphUI")
	else
		MainMenuBar_OnEvent(self, event, ...)
	end
end)

---------
-- 
---------

function ClassBarOnUpdate(ABar, AEvent, ...)
	local numForms = GetNumShapeshiftForms()
	local ButtonTexture
	local ButtonName
	local ButtonActive
	local ButtonCastable
	local ButtonIcon
	local ButtonCooldownTexture
	local CooldownStart
	local CooldownDuration
	local CooldownEnable
	
	local Buttons = ABar:GetAttribute("Buttons") 
	
	for i, CurrentButton in ipairs(Buttons) do	
		ButtonIcon = _G[CurrentButton:GetName().."Icon"]
		ButtonCooldownTexture = _G[CurrentButton:GetName().."Cooldown"]
		ButtonTexture, ButtonName, ButtonActive, ButtonCastable = GetShapeshiftFormInfo(i)
		CooldownStart, CooldownDuration, CooldownEnable = GetShapeshiftFormCooldown(i)
		CooldownFrame_SetTimer(ButtonCooldownTexture, CooldownStart, CooldownDuration, CooldownEnable)
		ButtonIcon:SetTexture(ButtonTexture)

		if ButtonCastable then
			ButtonIcon:SetVertexColor(1.0, 1.0, 1.0)
		else
			ButtonIcon:SetVertexColor(0.4, 0.4, 0.4)
		end

		if ButtonTexture then
			ButtonCooldownTexture:SetAlpha(1)
		else
			ButtonCooldownTexture:SetAlpha(0)
		end

		if ButtonActive then
			ABar.lastSelected = CurrentButton:GetID()

			CurrentButton:SetChecked(1)
		else
			CurrentButton:SetChecked(0)
		end
	end
end

function ClassBarOnChange(ABar, AEvent, ...)
	if InCombatLockdown() then
		return
	end

	local Buttons = ABar:GetAttribute("Buttons") 
	
	for i, CurrentButton in ipairs(Buttons) do
		local _, name = GetShapeshiftFormInfo(i)

		if name then
			CurrentButton:Show()
		else
			CurrentButton:Hide()
		end
	end
end

function ClassBarOnPlayerLogin(ASelf, AEvent, ...)
	local Buttons = COO.Bar[6].Frame:GetAttribute("Buttons") 
	
	for i, CurrentButton in ipairs(Buttons) do
		local _, name = GetShapeshiftFormInfo(i)

		if name then
			CurrentButton:Show()
		end
	end

	RegisterStateDriver(ASelf, "visibility", "true" or "hide") --COO.Bar[6].Frame:GetAttribute("Visible") or "hide")
end

---------
-- 
---------

--[[COO.Bar[6].Frame:RegisterEvent("PLAYER_LOGIN")
COO.Bar[6].Frame:RegisterEvent("PLAYER_ENTERING_WORLD")
COO.Bar[6].Frame:RegisterEvent("UPDATE_SHAPESHIFT_FORMS")
COO.Bar[6].Frame:RegisterEvent("UPDATE_SHAPESHIFT_USABLE")
COO.Bar[6].Frame:RegisterEvent("UPDATE_SHAPESHIFT_COOLDOWN")
COO.Bar[6].Frame:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
COO.Bar[6].Frame:RegisterEvent("ACTIONBAR_PAGE_CHANGED")
COO.Bar[6].Frame:SetScript("OnEvent", function(self, event, ...)
	if event == "PLAYER_LOGIN" then
		ClassBarOnPlayerLogin(self, event, ...)
	elseif event == "UPDATE_SHAPESHIFT_FORMS" then
		ClassBarOnChange(COO.Bar[6].Frame, event, ...)
		ClassBarOnUpdate(COO.Bar[6].Frame, event, ...)
	else
		ClassBarOnUpdate(COO.Bar[6].Frame, event, ...)
	end
end)]]--

---------
-- 
---------

for i, Bar in ipairs(COO.Bar) do
	if i == 6 and E then
	
	else
		COO.ConvertToCOOActionBar(Bar.Frame)
	end
end
