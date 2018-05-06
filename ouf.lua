local parent = 'oUF'
local global = GetAddOnMetadata('oUF', 'X-oUF')
local _VERSION = GetAddOnMetadata('oUF', 'version')

local _G = getfenv(0)
local oUF = oUF
local Private = oUF.Private

local argcheck = Private.argcheck

-- local print = Private.print
local error = Private.error

local sformat = string.format
local sgsub = string.gsub
local slower = string.lower
local smatch = string.match
local ssplit = string.split
local strim = string.trim
local supper = string.upper
local tgetn = table.getn
local tinsert = table.insert
local tonumber = tonumber
local tremove = table.remove
local tsort = table.sort
local twipe = table.wipe
local unpack = unpack
local abs = abs

local styles, style = {}
local callback, objects, headers = {}, {}, {}

local elements = {}
local activeElements = {}


local function createOnUpdate()
    local total = 0

    return function()
        if not this.unit then
            return
        elseif total > this.onUpdateFrequency then
            this:UpdateAllElements('OnUpdate')
            total = 0
        end

        total = total + arg1
    end
end

-- updating of 'nvalid'units.
local enableTargetUpdate = function(object)
    object.onUpdateFrequency = object.onUpdateFrequency or .5
    object.__eventless = true

    object:SetScript('OnUpdate', createOnUpdate())
end
Private.enableTargetUpdate = enableTargetUpdate

local updateActiveUnit = function(self, event, unit)
    -- Calculate units to work with
    local realUnit = self:GetAttribute('unit')

    -- _GetUnit() doesn't rewrite playerpet -> pet like _GetModifiedUnit does.
    if realUnit == 'playerpet' then
        realUnit = 'pet'
    elseif realUnit == 'playertarget' then
        realUnit = 'target'
    end

    -- Drop out if the event unit doesn't match any of the frame units.
    if (unit and unit ~= realUnit) then return end

    -- Change the active unit and run a full update.
    if Private.UpdateUnits(self, realUnit) then
        self:UpdateAllElements('RefreshUnit')

        return true
    end
end

local iterateChildren = function(...)
    local obj
    for l = 1, arg.n do
        obj = arg[l]

        if type(obj) == 'table' and obj.isChild then
            updateActiveUnit(obj, 'iterateChildren')
        end
    end
end

local OnAttributeChanged = function(self, name, value)
    if name == 'unit' and value then
        if self.hasChildren then
            iterateChildren(self:GetChildren())
        end

        if not self:GetAttribute('oUF-onlyProcessChildren') then
            updateActiveUnit(self, 'OnAttributeChanged')
        end
    end
end

local frame_metatable = {
    __index = CreateFrame('Button')
}
Private.frame_metatable = frame_metatable



for k, v in pairs{
    EnableElement = function(self, name, unit)
        argcheck(name, 2, 'string')
        argcheck(unit, 3, 'string', 'nil')

        local element = elements[name]
        if not element or self:IsElementEnabled(name) then return end

        if element.enable(self, unit or self:GetAttribute('unit')) then
            activeElements[self][name] = true

            if element.update then
                tinsert(self.__elements, element.update)
            end
        end
    end,

    DisableElement = function(self, name)
        argcheck(name, 2, 'string')

        local enabled = self:IsElementEnabled(name)
        if not enabled then return end

        local update = elements[name].update
        for k, func in next, self.__elements do
            if func == update then
                tremove(self.__elements, k)
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
        -- TODO: benchmark this, add cumulative time it takes to update 40
        -- elements - do keep in mind that auras are updated which can have as
        -- much as 30 buffs along with debuffs
        local unit = self.unit
        if not UnitExists(unit) then return end

        assert(type(event) == 'string', "Invalid argument 'event' in UpdateAllElements.")

        if self.PreUpdate then
            self:PreUpdate(event)
        end

        for _, func in next, self.__elements do
            func(self, event, unit)
        end

        if self.PostUpdate then
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


local OnEvent = function(self, event)
    local unit = self:GetAttribute('unit')

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

local OnShow = function(self)
    self:UpdateAllElements('OnShow')
end

local UpdatePet = function(self, event, unit)
    local petUnit
    if unit == 'target' then
        return
    elseif unit == 'player' then
        petUnit = 'pet'
    else
        -- Convert raid26 -> raidpet26
        petUnit = sgsub(unit, '^(%a+)(%d+)', '%1pet%2')
    end

    if self:GetAttribute('unit') ~= petUnit then return end

    return self:UpdateAllElements(event)
end

local initObject = function(unit, style, styleFunc, header, ...)
    local num = arg.n

    local object, objectUnit, suffix
    for i = 1, num do
        object = arg[i]
        objectUnit = object:GetAttribute('oUF-guessUnit') or unit

        suffix = object:GetAttribute('unitsuffix')

        object.__elements = {}
        object.style = style
        object = setmetatable(object, frame_metatable)

        -- Expose the frame through oUF.objects.
        tinsert(objects, object)

        -- We have to force update the frames when PEW fires.
        object:RegisterEvent('PLAYER_ENTERING_WORLD', object.UpdateAllElements)

        -- Handle the case where someone has modified the unitsuffix attribute in
        -- oUF-initialConfigFunction.
        if suffix and not smatch(objectUnit, suffix) then
            objectUnit = objectUnit .. suffix
        end

        if not (suffix == 'target' or objectUnit and smatch(objectUnit, 'target')) then
            -- object:RegisterEvent('UNIT_ENTERED_VEHICLE', updateActiveUnit)
            -- object:RegisterEvent('UNIT_EXITED_VEHICLE', updateActiveUnit)

            -- We don't need to register UNIT_PET for the player unit. We register it
            -- mainly because UNIT_EXITED_VEHICLE and UNIT_ENTERED_VEHICLE doesn't always
            -- have pet information when they fire for party and raid units.
            if objectUnit ~= 'player' then
                object:RegisterEvent('UNIT_PET', UpdatePet, true)
            end
        end

        if not header then
            -- No header means it's a frame created through :Spawn().
            object:SetAttribute('*type1', 'target')
            object:SetAttribute('*type2', 'togglemenu')
            object:RegisterForClicks('LeftButtonDown', 'RightButtonDown')

            -- Other boss and target units are handled by :HandleUnit().
            if suffix == 'target' then
                enableTargetUpdate(object)
            else
                oUF:HandleUnit(object, unit)
            end
        else
            -- Used to update frames when they change position in a group.
            object:RegisterEvent('PARTY_MEMBERS_CHANGED', object.UpdateAllElements)

            if num > 1 then
                if object:GetParent() == header then
                    object.hasChildren = true
                else
                    object.isChild = true
                end
            end

            if suffix == 'target' then
                enableTargetUpdate(object)
            end
        end

        Private.UpdateUnits(object, objectUnit)

        styleFunc(object, objectUnit, not header)

        object:SetScript('OnAttributeChanged', OnAttributeChanged)
        object:SetScript('OnShow', function(...) OnShow(this) end)

        activeElements[object] = {}
        for element in next, elements do
            object:EnableElement(element, objectUnit)
        end

        for _, func in next, callback do
            func(object)
        end
    end
end

local walkObject = function(object, unit)
    local parent = object:GetParent()
    local style = parent.style or style
    local styleFunc = styles[style]

    local header = parent.GetAttribute and parent:GetAttribute('oUF-headerType') and parent
    -- Check if we should leave the main frame blank.
    if (object:GetAttribute('oUF-onlyProcessChildren')) then
    	object.hasChildren = true
    	object:SetScript('OnAttributeChanged', OnAttributeChanged)
    	return initObject(unit, style, styleFunc, header, object:GetChildren())
    end

    return initObject(unit, style, styleFunc, header, object, object:GetChildren())
end

function oUF:RegisterInitCallback(func)
    tinsert(callback, func)
end

function oUF:RegisterMetaFunction(name, func)
    argcheck(name, 2, 'string')
    argcheck(func, 3, 'function', 'table')

    if frame_metatable.__index[name] then
        return
    end

    frame_metatable.__index[name] = func
end

function oUF:RegisterStyle(name, func)
    argcheck(name, 2, 'string')
    argcheck(func, 3, 'function', 'table')

    if(styles[name]) then return error('Style [%s] already registered.', name) end
    if(not style) then style = name end

    styles[name] = func
end

function oUF:SetActiveStyle(name)
    argcheck(name, 2, 'string')
    if(not styles[name]) then return error('Style [%s] does not exist.', name) end

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

        local short, condition
        for i = 1, arg.n do
            short = arg[i]

            condition = conditions[short]
            if condition then
                cond = cond .. condition
            end
        end

        return cond .. 'hide'
    end
end

local generateName = function(unit, ...)
    local name = 'oUF_' .. sgsub(style, '[^%a%d_]+', '')

    local raid, party, groupFilter
    for i = 1, arg.n, 2 do
        local att, val = arg[i]
        if att == 'showRaid' then
            raid = true
        elseif att == 'showParty' then
            party = true
        elseif att == 'groupFilter' then
            groupFilter = val
        end
    end

    local append
    if raid then
        if groupFilter then
            if type(groupFilter) == 'number' and groupFilter > 0 then
                append = groupFilter
            elseif smatch(groupFilter, 'TANK') then
                append = 'MainTank'
            elseif smatch(groupFilter, 'ASSIST') then
                append = 'MainAssist'
            else
                local _, count = sgsub(groupFilter, ',', '')
                if count == 0 then
                    append = 'Raid' .. groupFilter
                else
                    append = 'Raid'
                end
            end
        else
            append = 'Raid'
        end
    elseif party then
        append = 'Party'
    elseif unit then
        append = sgsub(unit, '^%l', supper)
    end

    if append then
        name = name .. append
    end

    -- Change oUF_LilyRaidRaid into oUF_LilyRaid
    name = sgsub(name, '(%u%l+)([%u%l]*)%1', '%1')
    -- Change oUF_LilyTargettarget into oUF_LilyTargetTarget
    name = sgsub(name, 't(arget)', 'T%1')

    local base = name
    local i = 2

    while _G[name] do
        name = base .. i
        i = i + 1
    end

    return name
end

do
    local function GetPetUnit(type, index)
        if type == 'RAID' then
            return 'raidpet' .. index
        elseif index > 0 then
            return 'partypet' .. index
        else
            return 'pet'
        end
    end

    local function getRelativePointAnchor(point)
	point = supper(point)

	if point == 'TOP' then
            return 'BOTTOM', 0, -1
	elseif point == 'BOTTOM' then
            return 'TOP', 0, 1
	elseif point == 'LEFT' then
            return 'RIGHT', 1, 0
	elseif point == 'RIGHT' then
            return 'LEFT', -1, 0
	elseif point == 'TOPLEFT' then
            return 'BOTTOMRIGHT', 1, -1
	elseif point == 'TOPRIGHT' then
            return 'BOTTOMLEFT', -1, -1
	elseif point == 'BOTTOMLEFT' then
            return 'TOPRIGHT', 1, 1
	elseif point == 'BOTTOMRIGHT' then
            return 'TOPLEFT', -1, 1
	else
            return 'CENTER', 0, 0
	end
    end

    local function ApplyUnitButtonConfiguration(...)
	for i = 1, arg.n do
            local frame = arg[i]
            local anchor = frame:GetAttribute('initial-anchor')
            local width = tonumber(frame:GetAttribute('initial-width') or nil)
            local height = tonumber(frame:GetAttribute('initial-height') or nil)
            local scale = tonumber(frame:GetAttribute('initial-scale') or nil)
            local unitWatch = frame:GetAttribute('initial-unitWatch')

            if anchor then
                local point, relPoint, xOffset, yOffset = ssplit(',', anchor)
                relpoint = relpoint or point
                xOffset = tonumber(xOffset) or 0
                yOffset = tonumber(yOffset) or 0
                frame:SetPoint(point, frame:GetParent(), relPoint, xOffset, yOffset)
            end
            if width then
                frame:SetWidth(width)
            end
            if height then
                frame:SetHeight(height)
            end
            if scale then
                frame:SetScale(scale)
            end
            if unitWatch then
                if unitWatch == 'state' then
                    RegisterUnitWatch(frame, true)
                else
                    RegisterUnitWatch(frame)
                end
            end

            -- call this function recursively for the current frame's children
            ApplyUnitButtonConfiguration(frame:GetChildren())
	end
    end

    local function ApplyConfig(header, newChild, defaultConfigFunction)
	local configFunction = header:GetAttribute('initialConfigFunction') or defaultConfigFunction
	if type(configFunction) == 'function' then
            configFunction(newChild)
            return true
	end
    end

    function SetupUnitButtonConfiguration(header, newChild, defaultConfigFunction)
	if ApplyConfig(header, newChild, defaultConfigFunction) then
            ApplyUnitButtonConfiguration(newChild)
	end
    end

    local function fillTable(tbl, ...)
        local key
	for i = 1, arg.n do
            key = arg[i]
            key = tonumber(key) or strim(key)
            tbl[key] = i
	end
    end

    local function doubleFillTable(tbl, ...)
	fillTable(tbl, unpack(arg))
	for i = 1, arg.n do
            tbl[i] = strim(arg[i])
	end
    end

    local tokenTable = {}
    local sortingTable = {}
    local groupingTable = {}

    local function GetGroupHeaderType(self)
	local kind, start, stop

	local nRaid = GetNumRaidMembers()
	local nParty = GetNumPartyMembers()
        if nRaid > 0 and self:GetAttribute('showRaid') then
            kind = 'RAID'
	elseif (nRaid > 0 or nParty > 0) and self:GetAttribute('showParty') then
            kind = 'PARTY'
	elseif self:GetAttribute('showSolo') then
            kind = 'SOLO'
	end

	if kind then
            if kind == 'RAID' then
                start = 1
                stop = nRaid
            else
                if kind == 'SOLO' or self:GetAttribute('showPlayer') then
                    start = 0
                else
                    start = 1
                end

                stop = nParty
            end
	end

	return kind, start, stop
    end

    local function configureChildren(self, unitTable)
	local point = self:GetAttribute('point') or 'TOP'
        local relativePoint, xOffsetMult, yOffsetMult = getRelativePointAnchor(point)
	local xMultiplier, yMultiplier = abs(xOffsetMult), abs(yOffsetMult)
	local xOffset = self:GetAttribute('xOffset') or 0
	local yOffset = self:GetAttribute('yOffset') or 0
	local sortDir = self:GetAttribute('sortDir') or 'ASC'
	local columnSpacing = self:GetAttribute('columnSpacing') or 0
	local startingIndex = self:GetAttribute('startingIndex') or 1

        local unitCount = tgetn(unitTable)

	local numDisplayed = unitCount - (startingIndex - 1)
	local unitsPerColumn = self:GetAttribute('unitsPerColumn')

	local numColumns
	if unitsPerColumn and numDisplayed > unitsPerColumn then
            numColumns = min( ceil(numDisplayed / unitsPerColumn), (self:GetAttribute('maxColumns') or 1) )
	else
            unitsPerColumn = numDisplayed
            numColumns = 1
	end

	local loopStart = startingIndex
	local loopFinish = min((startingIndex - 1) + unitsPerColumn * numColumns, unitCount)
	local step = 1

	numDisplayed = loopFinish - (loopStart - 1)

	if sortDir == 'DESC' then
            loopStart = unitCount - (startingIndex - 1)
            loopFinish = loopStart - (numDisplayed - 1)
            step = -1
	end

	-- ensure there are enough buttons
	local needButtons = max(1, numDisplayed)
        local neededButton = sformat('child%d', needButtons)
	if not self:GetAttribute(neededButton) then
            local name = self:GetName()
            if not name then
                self:Hide()
                return
            end

            for i = 1, needButtons do
                neededButton = sformat('child%d', i)
                if not self:GetAttribute(neededButton) then
                    local newButton = CreateFrame('Button', sformat('%sUnitButton%d', name, i), self)
                    SetupUnitButtonConfiguration(self, newButton)
                    self:SetAttribute(neededButton, newButton)
                end
            end
	end

	local columnAnchorPoint, columnRelPoint, colxMulti, colyMulti
	if numColumns > 1 then
            columnAnchorPoint = self:GetAttribute('columnAnchorPoint')
            columnRelPoint, colxMulti, colyMulti = getRelativePointAnchor(columnAnchorPoint)
	end

	local buttonNum = 0
	local columnNum = 1
	local columnUnitCount = 0
	local currentAnchor = self

        -- print('oUF: Unit frame position acts strange leaving BG -> raid')
	for i = loopStart, loopFinish, step do
            buttonNum = buttonNum + 1
            columnUnitCount = columnUnitCount + 1
            if columnUnitCount > unitsPerColumn then
                columnUnitCount = 1
                columnNum = columnNum + 1
            end

            local unitButton = self:GetAttribute('child'..buttonNum)
            -- print(string.format('SetPoint: %s, %s, %s, %d, %d', point, tostring(currentAnchor:GetName()), point, 0, 0))
            if buttonNum == 1 then
                unitButton:SetPoint(point, currentAnchor, point, 0, 0)
                if columnAnchorPoint then
                    unitButton:SetPoint(columnAnchorPoint, currentAnchor, columnAnchorPoint, 0, 0)
                end

            elseif columnUnitCount == 1 then
                local columnAnchor = self:GetAttribute('child'..(buttonNum - unitsPerColumn))
                unitButton:SetPoint(columnAnchorPoint, columnAnchor, columnRelPoint, colxMulti * columnSpacing, colyMulti * columnSpacing)
            else
                unitButton:SetPoint(point, currentAnchor, relativePoint, xMultiplier * xOffset, yMultiplier * yOffset)
            end

            unitButton:SetAttribute('unit', unitTable[i])
            unitButton:Show()

            currentAnchor = unitButton
	end
        -- print('Hiding childs ' .. buttonNum + 1 .. ' and onwards')
        for buttonNum = buttonNum + 1, 40 do
            local unitButton = self:GetAttribute('child'..buttonNum)
            if unitButton then
                unitButton:Hide()
                unitButton:ClearAllPoints()
                unitButton:SetAttribute('unit', nil)
            else
                break
            end
        end

	local unitButton = self:GetAttribute('child1')
	local unitButtonWidth = unitButton:GetWidth()
	local unitButtonHeight = unitButton:GetHeight()
	if numDisplayed > 0 then
            local width = xMultiplier * (unitsPerColumn - 1) * unitButtonWidth + ( (unitsPerColumn - 1) * (xOffset * xOffsetMult) ) + unitButtonWidth
            local height = yMultiplier * (unitsPerColumn - 1) * unitButtonHeight + ( (unitsPerColumn - 1) * (yOffset * yOffsetMult) ) + unitButtonHeight

            if numColumns > 1 then
                width = width + ( (numColumns - 1) * abs(colxMulti) * (width + columnSpacing) )
                height = height + ( (numColumns - 1) * abs(colyMulti) * (height + columnSpacing) )
            end

            self:SetWidth(width)
            self:SetHeight(height)
	else
            local minWidth = self:GetAttribute('minWidth') or (yMultiplier * unitButtonWidth)
            local minHeight = self:GetAttribute('minHeight') or (xMultiplier * unitButtonHeight)
            self:SetWidth(max(minWidth, 0.1))
            self:SetHeight(max(minHeight, 0.1))
	end
    end

    local function GetGroupRosterInfo(kind, index)
	local _, unit, name, subgroup, className
	if kind == 'RAID' then
            unit = 'raid'..index
            name, _, subgroup, _, _, className, _, _, _, role = GetRaidRosterInfo(index)
	else
            if index > 0 then
                unit = 'party'..index
            else
                unit = 'player'
            end

            if UnitExists(unit) then
                name = UnitName(unit)
                _, className = UnitClass(unit)
            end

            subgroup = 1
	end

	return unit, name, subgroup, className
    end

    local function sortOnGroupWithNames(a, b)
	local order1 = tokenTable[ groupingTable[a] ]
	local order2 = tokenTable[ groupingTable[b] ]

	if order1 then
            if not order2 then
                return true
            else
                if order1 == order2 then
                    return sortingTable[a] < sortingTable[b]
                else
                    return order1 < order2
                end
            end
	else
            if order2 then
                return false
            else
                return sortingTable[a] < sortingTable[b]
            end
	end
    end

    local startTime
    local function Update(self)
        -- print('Update!')
        -- startTime = GetTime()
	local nameList = self:GetAttribute('nameList')
	local groupFilter = self:GetAttribute('groupFilter')
	local sortMethod = self:GetAttribute('sortMethod')
	local groupBy = self:GetAttribute('groupBy')
        local petHeader = self:GetAttribute('oUF-headerType') == 'pet'

        twipe(sortingTable)

	-- See if this header should be shown
	local kind, start, stop = GetGroupHeaderType(self)

        if not kind then
            configureChildren(self, sortingTable)
            return
	end

	if not groupFilter and not nameList then
            groupFilter = '1,2,3,4,5,6,7,8'
	end

	if groupFilter then
            -- filtering by a list of group numbers and/or classes
            fillTable(tokenTable, ssplit(',', groupFilter))
            -- print({start, stop})
            local strictFiltering = self:GetAttribute('strictFiltering')
            for i = start, stop do
                local unit, name, subgroup, className, role = GetGroupRosterInfo(kind, i)

                if petHeader then
                    unit = GetPetUnit(kind, i)
                    name = UnitName(unit)
                end
                -- print({unit, name})
                if UnitExists(unit) then
                    if name and
                        ( (not strictFiltering) and
                                (tokenTable[subgroup] or
                                 tokenTable[className])
                        ) or (tokenTable[subgroup] and tokenTable[className])
                    then
                        tinsert(sortingTable, unit)
                        sortingTable[unit] = name

                        groupingTable[unit] = subgroup
                    end
                end
            end

            tsort(sortingTable, sortOnGroupWithNames)
            -- print({sortingTable, table.getn(sortingTable)})
	else
            -- filtering via a list of names
            doubleFillTable(tokenTable, ssplit(',', nameList))
            for i = start, stop, 1 do
                local unit, name = GetGroupRosterInfo(kind, i)

                if petHeader then
                    unit = GetPetUnit(kind, i)
                    name = UnitName(unit)
                end

                if tokenTable[name] and UnitExists(unit) then
                    tinsert(sortingTable, unit)
                    sortingTable[unit] = name
                end
            end

            tsort(sortingTable)
	end

	configureChildren(self, sortingTable)

        -- print(GetTime() - startTime)
    end

    local styleProxy = function(self, frameName, ...)
        return walkObject(_G[frameName])
    end

    -- There has to be an easier way to do this.
    local initialConfigFunction = function(frame)
        local header = frame:GetParent()

        local unit
        -- There's no need to do anything on frames with onlyProcessChildren
        if not frame:GetAttribute('oUF-onlyProcessChildren') then
            RegisterUnitWatch(frame)

            -- Attempt to guess what the header is set to spawn.
            local groupFilter = header:GetAttribute('groupFilter')

            if type(groupFilter) == 'string' and groupFilter:match('MAIN[AT]') then
                local role = groupFilter:match('MAIN([AT])')
                if role == 'T' then
                    unit = 'maintank'
                else
                    unit = 'mainassist'
                end
            elseif header:GetAttribute('showRaid') then
                unit = 'raid'
            elseif header:GetAttribute('showParty') then
                unit = 'party'
            end

            local headerType = header:GetAttribute('oUF-headerType')
            local suffix = frame:GetAttribute('unitsuffix')
            if unit and suffix then
                if headerType == 'pet' and suffix == 'target' then
                    unit = unit .. headerType .. suffix
                else
                    unit = unit .. suffix
                end
            elseif unit and headerType == 'pet' then
                unit = unit .. headerType
            end

            frame:SetAttribute('*type1', 'target')
            frame:SetAttribute('*type2', 'togglemenu')
            frame:RegisterForClicks('LeftButtonDown', 'RightButtonDown')
            frame:SetAttribute('oUF-guessUnit', unit)
        end

        local body = header:GetAttribute('oUF-initialConfigFunction')
        if body then
            body(frame)
        end

        header:styleFunction(frame:GetName())
    end

    local function OnUpdate()
        this.eventTimer = this.eventTimer + arg1
        if this.eventTimer > 2 then
            if tgetn(this.eventHeap) > 0 then
                Update(this)

                twipe(this.eventHeap)
            end

            this.eventTimer = 0
        end
    end

    local function OnEvent()
        local doUpdate
        local inRaid = UnitInRaid('player')
        local inParty = UnitInParty('player') and not inRaid

        doUpdate = inRaid and event == 'RAID_ROSTER_UPDATE'
        doUpdate = doUpdate or inParty and event == 'PARTY_MEMBERS_CHANGED'
        doUpdate = doUpdate or event == 'UNIT_PET'
        doUpdate = doUpdate and this:IsVisible()
        -- doUpdate = doUpdate and not UnitAffectingCombat('player')

        if doUpdate then
            tinsert(this.eventHeap, event)
        end
    end

    local repeatingCount, repeatingAttr = 0
    local function OnAttributeChanged(self, attr, value)
        if repeatingAttr ~= attr then
            repeatingAttr = attr
            repeatingCount = 0
        end

        if repeatingCount > 50 then
            return
        end

        repeatingCount = repeatingCount + 1

        if self:IsVisible() then
            -- print({'Updating raid frames! OnAttributeChanged', attr})
            Update(self)
        end
    end

    local function OnShow()
        -- print('Updating raid frames! OnShow')
        Update(this)
    end

    function oUF:SpawnHeader(overrideName, template, visibility, ...)
        if not style then
            return error('Unable to create frame. No styles have been registered.')
        end

        local name = overrideName or generateName(nil, unpack(arg))
        local header = CreateFrame('Frame', name, UIParent)
        header:Hide()

        header:SetScript('OnEvent', OnEvent)
        header:SetScript('OnAttributeChanged', OnAttributeChanged)
        header:SetScript('OnShow', OnShow)
        header:SetScript('OnUpdate', OnUpdate)
        header.eventHeap = {}
        header.eventTimer = 0

        for i = 1, arg.n, 2 do
            local att, val = arg[i], arg[i + 1]
            if not att then break end
            header:SetAttribute(att, val)
        end

        if header:GetAttribute('showRaid') then
            header:RegisterEvent('RAID_ROSTER_UPDATE')
        end

        if header:GetAttribute('showParty') then
            header:RegisterEvent('PARTY_MEMBERS_CHANGED')
        end

        header.style = style
        header.styleFunction = styleProxy


        local isPetHeader = header:GetAttribute('petHeader')
        if isPetHeader then
            header:RegisterEvent('UNIT_PET')
        end

        -- Expose the header through oUF.headers.
        tinsert(headers, header)

        -- We set it here so layouts can't directly override it.
        header:SetAttribute('initialConfigFunction', initialConfigFunction)
        header:SetAttribute('oUF-headerType', isPetHeader and 'pet' or 'group')

        if header:GetAttribute('showParty') then
            self:DisableBlizzard('party')
        end

        if visibility then
            local type, list = ssplit(' ', visibility, 2)
            if list and type == 'custom' then
                RegisterAttributeDriver(header, 'state-visibility', list)
            else
                local condition = getCondition(ssplit(',', visibility))
                RegisterAttributeDriver(header, 'state-visibility', condition)
            end
        end

        return header
    end
end

function oUF:Spawn(unit, overrideName)
    argcheck(unit, 2, 'string')

    if not style then
        return error('Unable to create frame. No styles have been registered.')
    end

    unit = slower(unit)

    local name = overrideName or generateName(unit)
    local object = CreateFrame('Button', name, UIParent)
    Private.UpdateUnits(object, unit)

    self:DisableBlizzard(unit)
    walkObject(object, unit)

    object:SetAttribute('unit', unit)

    RegisterUnitWatch(object)

    return object
end

function oUF:AddElement(name, update, enable, disable)
    argcheck(name, 2, 'string')
    argcheck(update, 3, 'function', 'nil')
    argcheck(enable, 4, 'function', 'nil')
    argcheck(disable, 5, 'function', 'nil')

    if elements[name] then
        return error('Element [%s] is already registered.', name)
    end

    elements[name] = {
        update = update,
        enable = enable,
        disable = disable,
    }
end

oUF.version = _VERSION
oUF.objects = objects
oUF.headers = headers

if global then
    if parent ~= 'oUF' and global == 'oUF' then
        error('%s is doing it wrong and setting its global to oUF.', parent)
    else
        _G[global] = oUF
    end
end
