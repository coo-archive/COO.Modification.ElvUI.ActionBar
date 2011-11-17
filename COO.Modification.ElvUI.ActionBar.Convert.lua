local COO, COOCFG = unpack(select(2, ...))
local E, _, _, DB = unpack(ElvUI)

function GetBarVisible(ABar)
	local BarName = ABar:GetName()

	if BarName == "ShapeshiftBarFrame" then
		local States = {
			["DRUID"] = "show",
			["WARRIOR"] = "show",
			["PALADIN"] = "show",
			["DEATHKNIGHT"] = "show",
			["ROGUE"] = "show",
			["PRIEST"] = "show",
			["HUNTER"] = "show",
			["WARLOCK"] = "show",
		}
		
		return States[COO.GetCharacterClassName()]
	else
		return "show"
	end
end

function GetBarLineCount(ABar)
	return ABar:GetAttribute("LineCount")
end

function GetBarBlockCount(ABar)
	return ABar:GetAttribute("BlockCount")
end

function GetBarOrientation(ABar)
	return ABar:GetAttribute("Orientation")
end

---------
-- Функции создания дополнительных объектов
---------

function CreateIncreaseButton(ABarName, ATexture)
	local Result = CreateFrame("Button", ABarName.."COOIncreaseButton", COO.UIParent, "UIPanelButtonTemplate")
	
	Result:SetWidth(16)
	Result:SetHeight(16)
	Result:SetNormalTexture(ATexture)
	Result:GetNormalTexture():SetTexCoord(0,1,0,1)
	Result:SetHighlightTexture(ATexture)
	Result:GetHighlightTexture():SetTexCoord(0,1,0,1)
	Result:SetPushedTexture(ATexture)
	Result:GetPushedTexture():SetTexCoord(0,1,0,1)
	Result:Hide()
	
	return Result
end

---------
-- События служебных кнопок
---------

function SwitchIncreaseButtonVisible(ABar)
	local IncreaseLineButton = ABar:GetAttribute("IncreaseLineButton")
	
	--if IncreaseLineButton then
		if IncreaseLineButton:IsVisible() then
			IncreaseLineButton:Hide()
		else
			IncreaseLineButton:Show()
		end
	--end
	
	local IncreaseBlockButton = ABar:GetAttribute("IncreaseBlockButton")
	
	--if IncreaseBlockButton then
		if IncreaseBlockButton:IsVisible() then
			IncreaseBlockButton:Hide()
		else
			IncreaseBlockButton:Show()
		end
	--end
end

function IncreaseLine(ABar)
	if GetBarLineCount(ABar) == 1 then 
		COO.SetBarSize(ABar, 2, 2) 
	elseif GetBarLineCount(ABar) == 2 then 
		COO.SetBarSize(ABar, 4, 1)
	end
end

function IncreaseBlock(ABar)
	if GetBarBlockCount(ABar) == 1 then
		COO.SetBarSize(ABar, 2, 2)
	elseif GetBarBlockCount(ABar) == 2 then
		COO.SetBarSize(ABar, 1, 4)
	end
end

---------
-- Функции расчета размера бара
---------

function CalculateLongSideSize(ABar)
	local Buttons = ABar:GetAttribute("Buttons") 

	local ButtonWidth = Buttons[1]:GetWidth()

	local ButtonInLine = COO.ButtonInBlock * ABar:GetAttribute("BlockCount")
	
	local Result = (ButtonInLine * ButtonWidth) + ((ButtonInLine - 1) * COOCFG.ButtonSpacing)
	
	return Result
end

function CalculateShortSideSize(ABar)
	local Buttons = ABar:GetAttribute("Buttons")

	local ButtonHeight = Buttons[1]:GetHeight()
	
	local LineCount = ABar:GetAttribute("LineCount")
	
	local Result = (LineCount * ButtonHeight) + ((LineCount - 1) * COOCFG.ButtonSpacing)	
	
	return Result
end

---------
-- Публичные функции для доступа из других юнитов
---------

function COO.CreateCtrlButton(ABarName)
	local Result = CreateFrame("Button", ABarName..COO.ActionBarCtrlButtonNameExtension, COO.UIParent, "UIPanelButtonTemplate")
	Result:SetAttribute("BarName", ABarName)
	Result:SetWidth(24)
	Result:SetHeight(24)
	Result:SetMovable(true)
	Result:EnableMouse(true)
	Result:RegisterForDrag("LeftButton")
	Result:SetPoint("TOPLEFT", COO.UIParent, "CENTER", 0, 0)
	Result:SetScript("OnDragStart", Result.StartMoving)
	Result:SetScript("OnDragStop", Result.StopMovingOrSizing)
	Result:SetNormalTexture("Interface\\addons\\COO.ActionBar\\media\\COOActionBarMenu.tga")
	Result:GetNormalTexture():SetTexCoord(0,1,0,1)
	Result:SetHighlightTexture("Interface\\addons\\COO.ActionBar\\media\\COOActionBarMenu.tga")
	Result:GetHighlightTexture():SetTexCoord(0,1,0,1)
	Result:SetPushedTexture("Interface\\addons\\COO.ActionBar\\media\\COOActionBarMenu.tga")
	Result:GetPushedTexture():SetTexCoord(0,1,0,1)
	
	return Result
end

function COO.SetBarAnchor(ABar, APoint)
	local Orientation = GetBarOrientation(ABar)

	if Orientation == COO.Orientation[1] then
		ABar:SetPoint("TOPLEFT", APoint, "TOPRIGHT", COOCFG.ButtonSpacing, 0)
	elseif Orientation == COO.Orientation[2] then
		ABar:SetPoint("TOPLEFT", APoint, "BOTTOMLEFT", 0, -COOCFG.ButtonSpacing)
	end
end 

function COO.SetBarSize(ABar, ALineCount, ABlockCount)
	ABar:SetAttribute("Visible", GetBarVisible(ABar))
	
	ABar:SetAttribute("LineCount", ALineCount)
	ABar:SetAttribute("BlockCount", ABlockCount)
	
	local ButtonInLine = ABlockCount * COO.ButtonInBlock
	local Orientation = GetBarOrientation(ABar)
	
	if Orientation == COO.Orientation[1] then
		ABar:SetWidth(CalculateLongSideSize(ABar))
		ABar:SetHeight(CalculateShortSideSize(ABar))
	elseif Orientation == COO.Orientation[2] then
		ABar:SetWidth(CalculateShortSideSize(ABar))
		ABar:SetHeight(CalculateLongSideSize(ABar))
	end
	
	local CurrentLineNumber = 1
	local CurrentBlockNumberInLine = 1
	local CurrentButtonNumberInLine = 1
	local MaxButtonNumberInCurrentBlock = 0;
	
	local Buttons = ABar:GetAttribute("Buttons") 
	
	for i, CurrentButton in ipairs(Buttons) do					
		MaxButtonNumberInCurrentBlock = ((CurrentLineNumber - 1) * (COO.ButtonInBlock * ABlockCount)) + (COO.ButtonInBlock * CurrentBlockNumberInLine)
		
		-- если закончали заполнение блока
		if (i - MaxButtonNumberInCurrentBlock) > 0 then
			-- переходим к следующему блоку
			CurrentBlockNumberInLine = CurrentBlockNumberInLine + 1
			
			-- если закончали заполнение строки
			if CurrentBlockNumberInLine > ABlockCount then
				-- переходим на следующую строку
				CurrentLineNumber = CurrentLineNumber + 1
				CurrentBlockNumberInLine = 1
				CurrentButtonNumberInLine = 1
			end
		end
		
		CurrentButton:ClearAllPoints()
		
		-- Если это новая строка
		if CurrentButtonNumberInLine == 1 then
			-- Если это самая первая кнопка
			if i == 1 then
				if Orientation == COO.Orientation[1] then
					CurrentButton:SetPoint("TOPLEFT", ABar, "TOPLEFT", 0, 0)
				elseif Orientation == COO.Orientation[2] then
					CurrentButton:SetPoint("TOPRIGHT", ABar, "TOPRIGHT", 0, 0)
				end
			-- Если это вторая, третья и т.д. строки
			else
				if Orientation == COO.Orientation[1] then
					CurrentButton:SetPoint("TOPLEFT", Buttons[i-ButtonInLine], "BOTTOMLEFT", 0, -COOCFG.ButtonSpacing)
				elseif Orientation == COO.Orientation[2] then
					CurrentButton:SetPoint("TOPRIGHT", Buttons[i-ButtonInLine], "TOPLEFT", COOCFG.ButtonSpacing, 0)
				end
			end
		-- Если это очередная кнопка в текущей строке
		else
			if Orientation == COO.Orientation[1] then
				CurrentButton:SetPoint("TOPLEFT", Buttons[i-1], "TOPRIGHT", COOCFG.ButtonSpacing, 0)
			elseif Orientation == COO.Orientation[2] then
				CurrentButton:SetPoint("TOPLEFT", Buttons[i-1], "BOTTOMLEFT", 0, -COOCFG.ButtonSpacing)
			end
		end
		
		CurrentButtonNumberInLine = CurrentButtonNumberInLine + 1
	end
end

function COO.ConvertToCOOActionBar(ABar)
	ABar:ClearAllPoints()
	ABar:SetParent(COO.UIParent)

	--local CtrlButton = COO.CreateCtrlButton(ABar:GetName())
	--CtrlButton:SetScript("OnClick", function() SwitchIncreaseButtonVisible(ABar) end)
	--ABar:SetAttribute("CtrlButton", CtrlButton) 
	
	ABar:SetPoint("CENTER", COO.UIParent, "CENTER", 0, 0)
	
	COO.SetBarSize(ABar, 1, 4)
	
	--COO.SetBarAnchor(ABar, CtrlButton)
	
	--local IncreaseLineButton = CreateIncreaseButton(ABar:GetName(), "Interface\\addons\\COO.ActionBar\\media\\down_arrow.tga")
	--IncreaseLineButton:SetPoint("TOPRIGHT", ABar, "BOTTOMRIGHT", 0, -COOCFG.ButtonSpacing)
	--IncreaseLineButton:SetScript("OnClick", function() IncreaseLine(ABar) end)
	--ABar:SetAttribute("IncreaseLineButton", IncreaseLineButton) 
	
	--local IncreaseBlockButton = CreateIncreaseButton(ABar:GetName(), "Interface\\addons\\COO.ActionBar\\media\\right_arrow.tga")
	--IncreaseBlockButton:SetPoint("BOTTOMLEFT", ABar, "BOTTOMRIGHT", COOCFG.ButtonSpacing, 0)
	--IncreaseBlockButton:SetScript("OnClick", function() IncreaseBlock(ABar)	end)	
	--ABar:SetAttribute("IncreaseBlockButton", IncreaseBlockButton) 
	
	if E then
		E.CreateMover(ABar, ABar:GetName().."Mover", ABar:GetName(), nil, nil)
	end
end