local parent = 'oUF'
local global = GetAddOnMetadata('oUF', 'X-oUF')
local _VERSION = GetAddOnMetadata('oUF', 'version')

local _G = getfenv(0)
local oUF = oUF
local Private = oUF.Private

local argcheck = Private.argcheck

local print = Private.print
local error = Private.error

local styles, style = {}
local callback, objects, headers = {}, {}, {}

local elements = {}
local activeElements = {}

local function RegisterUnitWatch(object)
    object.watch = true
end

local function UnregisterUnitWatch(object)
    object.watch = false
end

local WatchUnits
do
    local elapsed = 0
    function WatchUnits()
        elapsed = elapsed + arg1
        if elapsed > .5 then
            for _, v in next, objects do
                if UnitExists(v.unit) then
                    if not v:IsShown() then
                        v:Show()
                    end
                end
            end

            elapsed = 0
        end
    end
end
oUF:SetScript('OnUpdate', WatchUnits)

-- updating of "invalid" units.
local enableTargetUpdate = function(object)
    object.onUpdateFrequency = object.onUpdateFrequency or .5
    object.__eventless = true

    local total = 0
    object:SetScript('OnUpdate', function(...)
                         if(not this.unit) then
                             return
                         elseif(total > this.onUpdateFrequency) then
                             this:UpdateAllElements('OnUpdate')
                             total = 0
                         end

                         total = total + arg1
    end)
end
Private.enableTargetUpdate = enableTargetUpdate

local updateActiveUnit = function(self, event, unit)
    -- Calculate units to work with
    local realUnit, modUnit = SecureButton_GetUnit(self), SecureButton_GetModifiedUnit(self)

    -- _GetUnit() doesn't rewrite playerpet -> pet like _GetModifiedUnit does.
    if(realUnit == 'playerpet') then
        realUnit = 'pet'
    elseif(realUnit == 'playertarget') then
        realUnit = 'target'
    end

    if(modUnit == 'pet' and realUnit ~= 'pet') then
        modUnit = 'vehicle'
    end

    if(not UnitExists(modUnit)) then return end

    -- Change the active unit and run a full update.
    if Private.UpdateUnits(self, modUnit, realUnit) then
        self:UpdateAllElements('RefreshUnit')

        return true
    end
end

local iterateChildren = function(...)
    for l = 1, select("#", unpack(arg)) do
        local obj = select(l, unpack(arg))

        if(type(obj) == 'table' and obj.isChild) then
            updateActiveUnit(obj, "iterateChildren")
        end
    end
end

local OnAttributeChanged = function(self, name, value)
    if(name == "unit" and value) then
        if(self.hasChildren) then
            iterateChildren(self:GetChildren())
        end

        if(not self:GetAttribute'oUF-onlyProcessChildren') then
            updateActiveUnit(self, "OnAttributeChanged")
        end
    end
end

local frame_metatable = {
    __index = CreateFrame"Button"
}
Private.frame_metatable = frame_metatable

for k, v in pairs{
    EnableElement = function(self, name, unit)
        argcheck(name, 2, 'string')
        argcheck(unit, 3, 'string', 'nil')

        local element = elements[name]
        if(not element or self:IsElementEnabled(name)) then return end

        if(element.enable(self, unit or self.unit)) then
            activeElements[self][name] = true

            if(element.update) then
                table.insert(self.__elements, element.update)
            end
        end
    end,

    DisableElement = function(self, name)
        argcheck(name, 2, 'string')

        local enabled = self:IsElementEnabled(name)
        if(not enabled) then return end

        local update = elements[name].update
        for k, func in next, self.__elements do
            if(func == update) then
                table.remove(self.__elements, k)
                break
            end
        end

        activeElements[self][name] = nil

        -- We need to run a new update cycle in-case we knocked ourself out of sync.
        -- The main reason we do this is to make sure the full update is completed
        -- if an element for some reason removes itself _during_ the update
        -- progress.
        self:UpdateAllElements('DisableElement', name)

        return elements[name].disable(self)
    end,

    IsElementEnabled = function(self, name)
        argcheck(name, 2, 'string')

        local element = elements[name]
        if(not element) then return end

        local active = activeElements[self]
        return active and active[name]
    end,

    Enable = RegisterUnitWatch,
    Disable = function(self)
        UnregisterUnitWatch(self)
        self:Hide()
    end,

    UpdateAllElements = function(self, event)
        local unit = self.unit
        if(not UnitExists(unit)) then
            self:Hide()
            return
        end

        if not self:IsShown() then
            self:Show()
        end

        assert(type(event) == 'string', 'Invalid argument "event" in UpdateAllElements.')

        if(self.PreUpdate) then
            self:PreUpdate(event)
        end

        for _, func in next, self.__elements do
            func(self, event, unit)
        end

        if(self.PostUpdate) then
            self:PostUpdate(event)
        end
    end,
} do
    frame_metatable.__index[k] = v
end

local OnClick = function(self)
    local button = arg1
    if button == 'RightButton' then
        if SpellIsTargeting() then
            SpellStopTargeting()
            return
        else
            this:ShowMenu()
        end
    elseif button == 'LeftButton' then
        if SpellIsTargeting() then
            SpellTargetUnit(this.unit)
        elseif CursorHasItem() then
            DropItemOnUnit(this.unit)
        else
            TargetUnit(this.unit)
        end
    end
end

local function initPlayerDrop()
    UnitPopup_ShowMenu(PlayerFrameDropDown, 'SELF', 'player')
    if not (UnitInRaid('player') or GetNumPartyMembers() > 0) or UnitIsPartyLeader('player') and PlayerFrameDropDown.init then
        UIDropDownMenu_AddButton({text = 'Reset Instances', func = ResetInstances, notCheckable = 1}, 1)
        PlayerFrameDropDown.init = nil
    end
end

local function initPartyDrop(self)
    UnitPopup_ShowMenu(getglobal(UIDROPDOWNMENU_OPEN_MENU), "PARTY", self.unit, self.name, self.id)
end


local ShowMenu = function(self)
    if UnitIsUnit(self.unit, 'player') then
        UIDropDownMenu_Initialize(PlayerFrameDropDown, initPlayerDrop, 'MENU')
        ToggleDropDownMenu(1, nil, PlayerFrameDropDown, 'cursor')
    elseif self.unit == 'pet' then
        ToggleDropDownMenu(1, nil, PetFrameDropDown, 'cursor')
    elseif self.unit == 'target' then
        ToggleDropDownMenu(1, nil, TargetFrameDropDown, 'cursor')
    elseif self.unitGroup == 'party' then
        ToggleDropDownMenu(1, nil, _G['PartyMemberFrame' .. string.sub(self.unit,6) .. 'DropDown'], 'cursor')
    elseif this.unitGroup == 'raid' then
        HideDropDownMenu(1)

        local menuFrame = FriendsDropDown
        menuFrame.displayMode = 'MENU'
        menuFrame.id = string.sub(this.unit,5)
        menuFrame.unit = self.unit
        menuFrame.name = UnitName(this.unit)
        menuFrame.initialize = initPartyDrop

        ToggleDropDownMenu(1, nil, FriendsDropDown, 'cursor')
    end
end

local OnEvent = function(self, event)
    local unit = self.unit

    if unit == 'target' or unit == 'targettarget' then
        if event == 'PLAYER_TARGET_CHANGED' then
            self:Show()
        end
    elseif unit == 'pet' then
        if event == 'UNIT_PET' then
            self:Show()
        end
    end
end


local UpdatePet = function(self, event, unit)
    local petUnit
    if(unit == 'target') then
        return
    elseif(unit == 'player') then
        petUnit = 'pet'
    else
        -- Convert raid26 -> raidpet26
        petUnit = string.gsub(unit, '^(%a+)(%d+)', '%1pet%2')
    end

    if(self.unit ~= petUnit) then return end
    if(not updateActiveUnit(self, event)) then
        return self:UpdateAllElements(event)
    end
end

local initObject = function(unit, style, styleFunc, header, ...)
    local num = select('#', unpack(arg))
    for i = 1, num do
        local object = select(i, unpack(arg))
        local objectUnit = unit
        local suffix = object['unitsuffix']

        object.__elements = {}
        object.style = style
        object = setmetatable(object, frame_metatable)

        -- Expose the frame through oUF.objects.
        table.insert(objects, object)

        -- We have to force update the frames when PEW fires.
        object:RegisterEvent("PLAYER_ENTERING_WORLD", object.UpdateAllElements)

        -- Handle the case where someone has modified the unitsuffix attribute in
        -- oUF-initialConfigFunction.
        if(suffix and not string.match(objectUnit, suffix)) then
            objectUnit = objectUnit .. suffix
        end

        if(not (suffix == 'target' or objectUnit and string.match(objectUnit, 'target'))) then
            -- object:RegisterEvent('UNIT_ENTERED_VEHICLE', updateActiveUnit)
            -- object:RegisterEvent('UNIT_EXITED_VEHICLE', updateActiveUnit)

            -- We don't need to register UNIT_PET for the player unit. We register it
            -- mainly because UNIT_EXITED_VEHICLE and UNIT_ENTERED_VEHICLE doesn't always
            -- have pet information when they fire for party and raid units.
            if(objectUnit ~= 'player') then
                object:RegisterEvent('UNIT_PET', UpdatePet, true)
            end
        end

        if(not header) then
            -- No header means it's a frame created through :Spawn().
            -- Left click (target), Right click (menu)
            -- object:SetAttribute("*type1", "target")
            -- object:SetAttribute('*type2', 'togglemenu')
            object.ShowMenu = ShowMenu
            object:RegisterForClicks('LeftButtonDown', 'RightButtonDown')
            object:SetScript('OnClick', OnClick)
            -- No need to enable this for *target frames.
            -- if(not (unit:match'target' or suffix == 'target')) then
            -- 	object:SetAttribute('toggleForVehicle', true)
            -- end

            -- Other boss and target units are handled by :HandleUnit().
            if(suffix == 'target') then
                enableTargetUpdate(object)
            else
                oUF:HandleUnit(object)
            end
        else
            -- Used to update frames when they change position in a group.
            object:RegisterEvent('GROUP_ROSTER_UPDATE', object.UpdateAllElements)

            if(num > 1) then
                if(object:GetParent() == header) then
                    object.hasChildren = true
                else
                    object.isChild = true
                end
            end

            if(suffix == 'target') then
                enableTargetUpdate(object)
            end
        end

        Private.UpdateUnits(object, objectUnit)

        styleFunc(object, objectUnit, not header)

        -- object:SetScript("OnAttributeChanged", OnAttributeChanged)
        -- object.OnAttributeChanged = OnAttributeChanged
        -- object:RegisterEvent('PLAYER_TARGET_CHANGED', OnEvent)

        activeElements[object] = {}
        for element in next, elements do
            object:EnableElement(element, objectUnit)
        end

        for _, func in next, callback do
            func(object)
        end

        -- Make Clique happy
        _G.ClickCastFrames = ClickCastFrames or {}
        ClickCastFrames[object] = true
    end
end

local walkObject = function(object, unit)
    local parent = object:GetParent()
    local styleFunc = styles[style]

    -- local header = parent:GetAttribute'oUF-headerType' and parent

    -- -- Check if we should leave the main frame blank.
    -- if(object:GetAttribute'oUF-onlyProcessChildren') then
    -- 	object.hasChildren = true
    -- 	object:SetScript('OnAttributeChanged', OnAttributeChanged)
    -- 	return initObject(unit, style, styleFunc, header, object:GetChildren())
    -- end

    return initObject(unit, style, styleFunc, nil, object, object:GetChildren())
end

function oUF:RegisterInitCallback(func)
    table.insert(callback, func)
end

function oUF:RegisterMetaFunction(name, func)
    argcheck(name, 2, 'string')
    argcheck(func, 3, 'function', 'table')

    if(frame_metatable.__index[name]) then
        return
    end

    frame_metatable.__index[name] = func
end

function oUF:RegisterStyle(name, func)
    argcheck(name, 2, 'string')
    argcheck(func, 3, 'function', 'table')

    if(styles[name]) then return error("Style [%s] already registered.", name) end
    if(not style) then style = name end

    styles[name] = func
end

function oUF:SetActiveStyle(name)
    argcheck(name, 2, 'string')
    if(not styles[name]) then return error("Style [%s] does not exist.", name) end

    style = name
end

do
    local function iter(_, n)
        -- don't expose the style functions.
        return (next(styles, n))
    end

    function oUF.IterateStyles()
        return iter, nil, nil
    end
end

local getCondition
do
    local conditions = {
        raid40 = '[@raid26,exists] show;',
        raid25 = '[@raid11,exists] show;',
        raid10 = '[@raid6,exists] show;',
        raid = '[group:raid] show;',
        party = '[group:party,nogroup:raid] show;',
        solo = '[@player,exists,nogroup:party] show;',
    }

    function getCondition(...)
        local cond = ''

        for i=1, select('#', unpack(arg)) do
            local short = select(i, unpack(arg))

            local condition = conditions[short]
            if(condition) then
                cond = cond .. condition
            end
        end

        return cond .. 'hide'
    end
end

local generateName = function(unit, ...)
    local name = 'oUF_' .. string.gsub(style, '[^%a%d_]+', '')

    local raid, party, groupFilter
    for i=1, select('#', unpack(arg)), 2 do
        local att, val = select(i, unpack(arg))
        if(att == 'showRaid') then
            raid = true
        elseif(att == 'showParty') then
            party = true
        elseif(att == 'groupFilter') then
            groupFilter = val
        end
    end

    local append
    if(raid) then
        if(groupFilter) then
            if(type(groupFilter) == 'number' and groupFilter > 0) then
                append = groupFilter
            elseif(groupFilter:match'TANK') then
                append = 'MainTank'
            elseif(groupFilter:match'ASSIST') then
                append = 'MainAssist'
            else
                local _, count = groupFilter:gsub(',', '')
                if(count == 0) then
                    append = 'Raid' .. groupFilter
                else
                    append = 'Raid'
                end
            end
        else
            append = 'Raid'
        end
    elseif(party) then
        append = 'Party'
    elseif(unit) then
        append = string.gsub(unit, "^%l", string.upper)
    end

    if(append) then
        name = name .. append
    end

    -- Change oUF_LilyRaidRaid into oUF_LilyRaid
    name = string.gsub(name, '(%u%l+)([%u%l]*)%1', '%1')
    -- Change oUF_LilyTargettarget into oUF_LilyTargetTarget
    name = string.gsub(name, 't(arget)', 'T%1')

    local base = name
    local i = 2
    while(_G[name]) do
        name = base .. i
        i = i + 1
    end

    return name
end

do
    local styleProxy = function(self, frame, ...)
        return walkObject(_G[frame])
    end

    -- There has to be an easier way to do this.
    local initialConfigFunction = [[
		local header = self:GetParent()
		local frames = table.new()
		table.insert(frames, self)
		self:GetChildList(frames)
		for i=1, #frames do
			local frame = frames[i]
			local unit
			-- There's no need to do anything on frames with onlyProcessChildren
			if(not frame:GetAttribute'oUF-onlyProcessChildren') then
				RegisterUnitWatch(frame)

				-- Attempt to guess what the header is set to spawn.
				local groupFilter = header:GetAttribute'groupFilter'

				if(type(groupFilter) == 'string' and groupFilter:match('MAIN[AT]')) then
					local role = groupFilter:match('MAIN([AT])')
					if(role == 'T') then
						unit = 'maintank'
					else
						unit = 'mainassist'
					end
				elseif(header:GetAttribute'showRaid') then
					unit = 'raid'
				elseif(header:GetAttribute'showParty') then
					unit = 'party'
				end

				local headerType = header:GetAttribute'oUF-headerType'
				local suffix = frame:GetAttribute'unitsuffix'
				if(unit and suffix) then
					if(headerType == 'pet' and suffix == 'target') then
						unit = unit .. headerType .. suffix
					else
						unit = unit .. suffix
					end
				elseif(unit and headerType == 'pet') then
					unit = unit .. headerType
				end

				frame:SetAttribute('*type1', 'target')
				frame:SetAttribute('*type2', 'togglemenu')
				frame:SetAttribute('toggleForVehicle', true)
				frame:SetAttribute('oUF-guessUnit', unit)
			end

			local body = header:GetAttribute'oUF-initialConfigFunction'
			if(body) then
				frame:Run(body, unit)
			end
		end

		header:CallMethod('styleFunction', self:GetName())

		local clique = header:GetFrameRef("clickcast_header")
		if(clique) then
			clique:SetAttribute("clickcast_button", self)
			clique:RunAttribute("clickcast_register")
		end
	]]

    function oUF:SpawnHeader(overrideName, template, visibility, ...)
        if (not style) then
            return error('Unable to create frame. No styles have been registered.')
        end

        -- local isPetHeader = string.match(template, '(PetHeader)')
        local name = overrideName or generateName(nil, unpack(arg))
        local header = CreateFrame('Frame', name, nil)

        -- header:SetAttribute("template", "oUF_ClickCastUnitTemplate")
        -- for i=1, select("#", unpack(arg)), 2 do
        -- 	local att, val = select(i, unpack(arg))
        -- 	if(not att) then break end
        -- 	header:SetAttribute(att, val)
        -- end

        header.style = style
        header.styleFunction = styleProxy

        -- Expose the header through oUF.headers.
        table.insert(headers, header)

        -- We set it here so layouts can't directly override it.
        -- header:SetAttribute('initialConfigFunction', initialConfigFunction)
        -- header:SetAttribute('oUF-headerType', isPetHeader and 'pet' or 'group')

        -- if(Clique) then
        --     SecureHandlerSetFrameRef(header, 'clickcast_header', Clique.header)
        -- end

        -- if(header:GetAttribute'showParty') then
        -- 	self:DisableBlizzard'party'
        -- end

        -- if(visibility) then
        -- 	local type, list = string.split(' ', visibility, 2)
        -- 	if(list and type == 'custom') then
        -- 		RegisterAttributeDriver(header, 'state-visibility', list)
        -- 	else
        -- 		local condition = getCondition(string.split(',', visibility))
        -- 		RegisterAttributeDriver(header, 'state-visibility', condition)
        -- 	end
        -- end

        return header
    end
end

function oUF:Spawn(unit, overrideName)
    argcheck(unit, 2, 'string')
    if(not style) then return error("Unable to create frame. No styles have been registered.") end

    unit = string.lower(unit)

    local name = overrideName or generateName(unit)
    local object = CreateFrame("Button", name)
    Private.UpdateUnits(object, unit)

    self:DisableBlizzard(unit)
    walkObject(object, unit)

    object["unit"] = unit
    RegisterUnitWatch(object)

    return object
end

function oUF:AddElement(name, update, enable, disable)
    argcheck(name, 2, 'string')
    argcheck(update, 3, 'function', 'nil')
    argcheck(enable, 4, 'function', 'nil')
    argcheck(disable, 5, 'function', 'nil')

    if(elements[name]) then return error('Element [%s] is already registered.', name) end
    elements[name] = {
        update = update;
        enable = enable;
        disable = disable;
    }
end

oUF.version = _VERSION
oUF.objects = objects
oUF.headers = headers

if(global) then
    if(parent ~= 'oUF' and global == 'oUF') then
        error("%s is doing it wrong and setting its global to oUF.", parent)
    else
        _G[global] = oUF
    end
end
