BuffFrame:ClearAllPoints()
BuffFrame:SetPoint("TOPRIGHT",UIParent, "TOPRIGHT", 0,0)

TemporaryEnchantFrame:ClearAllPoints()
TemporaryEnchantFrame:SetPoint("TOPRIGHT",UIParent, "TOPRIGHT", 0,0)

-- decimal places of the value. to assign '2' will show it like '123.45'.
local DECIMAL_PLACES = 2

-- additional strings. if you don't like it just assign 'nil'. but do not delete these variables themselves.
local UPDATED = YELLOW_FONT_COLOR_CODE .. CANNOT_COOPERATE_LABEL --> '*'
local RETRIEVING = GRAY_FONT_COLOR_CODE .. RETRIEVING_DATA .. CONTINUED --> 'Retrieving data...'
local UNAVAILABLE = nil -- GRAY_FONT_COLOR_CODE .. UNAVAILABLE --> 'Unavailable'

-- output prefix. has to have unique strings to update the tooltip correctly.
local PREFIX = STAT_FORMAT:format(STAT_AVERAGE_ITEM_LEVEL) .. '|Hequippeditemlevelbyvilliv|h |h' .. HIGHLIGHT_FONT_COLOR_CODE


local Frame = CreateFrame('Frame')
Frame:Hide()

local inCombat, isRegistered, isInspecting

local UnitAverageItemLevel
do
	local invalidSlots = { [INVSLOT_BODY] = true, [INVSLOT_TABARD] = true, }
	local coefficient = 10 ^ DECIMAL_PLACES
	local formatString = '%.' .. DECIMAL_PLACES .. 'f'

	local function calculate (unit, slot, total, count, is2Handed, isRetrieving)
		if ( slot > INVSLOT_LAST_EQUIPPED ) then
			if ( not isRetrieving ) then
				return formatString:format(math.floor(total / (is2Handed and count - 1 or count) * coefficient) / coefficient)
			end
			return
		end

		if ( invalidSlots[slot] ) then
			return calculate(unit, slot + 1, total, count, is2Handed, isRetrieving)
		end

		local id = GetInventoryItemID(unit, slot)
		local _, level, equipLoc
		if ( id ) then
			_, _, _, level, _, _, _, _, equipLoc = GetItemInfo(id)
		end

		if ( isRetrieving or id and not (level and equipLoc) ) then
			return calculate(unit, slot + 1, total, count, is2Handed, true)
		end

		total = id and total + level or total
		count = count + 1

		if ( slot == INVSLOT_MAINHAND ) then
			is2Handed = not id and 0 or equipLoc == 'INVTYPE_2HWEAPON' and 1
		elseif ( slot == INVSLOT_OFFHAND ) then
			is2Handed = is2Handed == 0 and equipLoc == 'INVTYPE_2HWEAPON' or is2Handed == 1 and not id
		end

		return calculate(unit, slot + 1, total, count, is2Handed)
	end

	function UnitAverageItemLevel (unit)
		return calculate(unit, INVSLOT_FIRST_EQUIPPED, 0, 0)
	end
end

local function SetText (tooltip, value)
	if ( not value ) then
		return
	end

	local name = tooltip:GetName() .. 'TextLeft'

	for line = 2, tooltip:NumLines() do
		local fontString = _G[name .. line]
		local text = fontString and fontString:GetText()

		if ( text and text:match(PREFIX) ) then
			fontString:SetText(PREFIX .. value)
			return tooltip:Show()
		end
	end

	tooltip:AddLine(PREFIX .. value)
	return tooltip:Show()
end

local Update
do
	local cache = {}

	function Update (unit, shouldUpdate, willUpdate)
		willUpdate = not inCombat and willUpdate

		local key = UnitGUID(unit)
		local value = cache[key]

		if ( not (shouldUpdate or willUpdate) and value ) then
			return SetText(GameTooltip, value)
		end

		if ( unit ~= 'player' ) then
			if ( not CanInspect(unit) or InspectFrame and InspectFrame:IsShown() ) then
				return SetText(GameTooltip, value or UNAVAILABLE)
			end

			NotifyInspect(unit)
			isInspecting = true
		end

		value = UnitAverageItemLevel(unit)

		if ( not value ) then
			Frame:Show()
			return SetText(GameTooltip, RETRIEVING)
		end

		cache[key] = value
		return SetText(GameTooltip, willUpdate and UPDATED and (value .. UPDATED) or value)
	end
end

local function GetUnit (tooltip)
	local _, unit = tooltip:GetUnit()
	if ( not unit ) then
		local mouseFocus = GetMouseFocus()
		unit = mouseFocus and (mouseFocus.unit or mouseFocus:GetAttribute('unit'))
		if ( not unit ) then
			return
		end
	end

	return UnitIsPlayer(unit) and unit
end

do
	local updateTooltip = TOOLTIP_UPDATE_TIME

	Frame:SetScript('OnUpdate', function (self, elapsed)
		updateTooltip = updateTooltip - elapsed
		if ( updateTooltip > 0 ) then
			return
		end

		self:Hide()
		updateTooltip = TOOLTIP_UPDATE_TIME

		local unit = GetUnit(GameTooltip)
		if ( unit ) then
			return Update(unit, true)
		end
	end)
end

Frame:SetScript('OnEvent', function (self, event, arg1)
	if ( event == 'PLAYER_REGEN_DISABLED' or event == 'PLAYER_REGEN_ENABLED' ) then
		inCombat = event == 'PLAYER_REGEN_DISABLED'
		return
	end

	local unit = GetUnit(GameTooltip)
	if ( not unit ) then
		return
	end

	if ( UnitIsUnit(unit, arg1 or 'target') ) then
		return Update(unit, arg1, not arg1)
	end
end)

Frame:RegisterEvent('PLAYER_REGEN_DISABLED')
Frame:RegisterEvent('PLAYER_REGEN_ENABLED')

GameTooltip:HookScript('OnTooltipSetUnit', function (self)
	local unit = GetUnit(self)
	if ( not unit ) then
		return
	end

	if ( not isRegistered ) then
		Frame:RegisterEvent('UNIT_INVENTORY_CHANGED')
		Frame:RegisterEvent('PLAYER_TARGET_CHANGED')
		isRegistered = true
	end

	return Update(unit, nil, UnitIsUnit(unit,'target'))
end)

GameTooltip:HookScript('OnTooltipCleared', function (self)
	if ( isRegistered ) then
		Frame:UnregisterEvent('UNIT_INVENTORY_CHANGED')
		Frame:UnregisterEvent('PLAYER_TARGET_CHANGED')
		isRegistered = nil
	end

	if ( isInspecting ) then
		ClearInspectPlayer()
		isInspecting = nil
	end
end)
