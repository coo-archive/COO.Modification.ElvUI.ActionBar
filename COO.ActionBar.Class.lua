---------------------------------------------------------------------------
-- Обработка классового бара
---------------------------------------------------------------------------

local COO, COOCFG = unpack(select(2, ...))

function ClassBarOnPlayerLogin(ASelf, AEvent, ...)
	COO.SetActionBarSize(_G[COO.BlizzardBarName[1]..COO.ActionBarNameExtension], COO.BlizzardBarName[1], COOCFG.ClassBarOrientation, 1, 4, COO.ButtonInClassBar)

	for i = 1, COO.ButtonInClassBar do
		local _, name = GetShapeshiftFormInfo(i)

		if name then
			_G[COO.BlizzardBarName[1].."Button"..i]:Show()
		end
	end

	RegisterStateDriver(ASelf, "visibility", COO.IsBarShow(COO.BlizzardBarName[1]) or "hide")
end

function ClassBarOnChange(ASelf, AEvent, ...)
	if InCombatLockdown() then
		return
	end

	for i = 1, COO.ButtonInClassBar do
		local _, name = GetShapeshiftFormInfo(i)

		if name then
			_G[COO.BlizzardBarName[1].."Button"..i]:Show()
		else
			_G[COO.BlizzardBarName[1].."Button"..i]:Hide()
		end
	end
end

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

	for i = 1, COO.ButtonInClassBar do
		ButtonIcon = _G[COO.BlizzardBarName[1].."Button"..i.."Icon"]
		ButtonCooldownTexture = _G[COO.BlizzardBarName[1].."Button"..i.."Cooldown"]
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
			ABar.lastSelected = _G[COO.BlizzardBarName[1].."Button"..i]:GetID()

			_G[COO.BlizzardBarName[1].."Button"..i]:SetChecked(1)
		else
			_G[COO.BlizzardBarName[1].."Button"..i]:SetChecked(0)
		end
	end
end

function COO.TransformationToCOOClassBar(AOrientation)
	COOClassBarMenu = CreateFrame("BUTTON", COO.BlizzardBarName[1]..COO.ActionBarCtrlButtonNameExtension, COO.UIParent, "UIPanelButtonTemplate")
	COOClassBarMenu:SetWidth(24)
	COOClassBarMenu:SetHeight(24)
	COOClassBarMenu:SetMovable(true)
	COOClassBarMenu:EnableMouse(true)
	COOClassBarMenu:RegisterForDrag("LeftButton")
	COOClassBarMenu:SetPoint("TOPLEFT", COO.UIParent, "CENTER", 0, 0)
	COOClassBarMenu:SetScript("OnDragStart", COOClassBarMenu.StartMoving)
	COOClassBarMenu:SetScript("OnDragStop", COOClassBarMenu.StopMovingOrSizing)

	COOClassBarMenu:SetNormalTexture("Interface\\addons\\COO.ActionBar\\media\\COOActionBarMenu.tga")
	COOClassBarMenu:GetNormalTexture():SetTexCoord(0,1,0,1)
	COOClassBarMenu:SetHighlightTexture("Interface\\addons\\COO.ActionBar\\media\\COOActionBarMenu.tga")
	COOClassBarMenu:GetHighlightTexture():SetTexCoord(0,1,0,1)
	COOClassBarMenu:SetPushedTexture("Interface\\addons\\COO.ActionBar\\media\\COOActionBarMenu.tga")
	COOClassBarMenu:GetPushedTexture():SetTexCoord(0,1,0,1)

	local BarFrame = CreateFrame("Frame", COO.BlizzardBarName[1]..COO.ActionBarNameExtension, COO.UIParent, "SecureHandlerStateTemplate")

	COO.SetActionBarSize(BarFrame, COO.BlizzardBarName[1], AOrientation, 1, 4, COO.ButtonInClassBar)
	COO.SetActionBarPoint(BarFrame, COOClassBarMenu, "TOPLEFT", "BOTTOMLEFT", 0, -COOCFG.ButtonSpacing)

	return BarFrame
end

-- Устанавливаем классовы бар
function COO.PositionClassBar()
	local BarFrame = COO.TransformationToCOOClassBar(COOCFG.ClassBarOrientation)
	
	BarFrame:SetScale(COOCFG.ClassButtonSize / _G[COO.BlizzardBarName[1].."Button"..1]:GetWidth())
	
	BarFrame:RegisterEvent("PLAYER_LOGIN")
	BarFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	BarFrame:RegisterEvent("UPDATE_SHAPESHIFT_FORMS")
	BarFrame:RegisterEvent("UPDATE_SHAPESHIFT_USABLE")
	BarFrame:RegisterEvent("UPDATE_SHAPESHIFT_COOLDOWN")
	BarFrame:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
	BarFrame:RegisterEvent("ACTIONBAR_PAGE_CHANGED")
	BarFrame:SetScript("OnEvent", function(self, event, ...)
		if event == "PLAYER_LOGIN" then
			ClassBarOnPlayerLogin(self, event, ...)
		elseif event == "UPDATE_SHAPESHIFT_FORMS" then
			ClassBarOnChange(self, event, ...)
			ClassBarOnUpdate(BarFrame, event, ...)
		else
			ClassBarOnUpdate(BarFrame, event, ...)
		end
	end)
end