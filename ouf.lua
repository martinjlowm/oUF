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

local iterateChildren = function(...)
    for l = 1, select('#', unpack(arg)) do
        local obj = select(l, unpack(arg))

        self:UpdateAllElements('iterateChildren')
    end
end

local OnAttributeChanged = function(self, name, value)
    if(name == "unit" and value) then
        if(self.hasChildren) then
            iterateChildren(self:GetChildren())
        end

        self:UpdateAllElements('OnAttributeChanged')
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

local OnShow = function(self)
    self:UpdateAllElements('OnShow')
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

    return self:UpdateAllElements(event)
end

local initObject = function(unit, style, styleFunc, header, ...)
    local num = select('#', unpack(arg))
    for i = 1, num do
        local object = select(i, unpack(arg))
        local objectUnit = unit
        print(unit)
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
        if (suffix and not string.match(objectUnit, suffix)) then
            objectUnit = objectUnit .. suffix
        end

        if (not (suffix == 'target' or objectUnit and string.match(objectUnit, 'target'))) then
            -- object:RegisterEvent('UNIT_ENTERED_VEHICLE', updateActiveUnit)
            -- object:RegisterEvent('UNIT_EXITED_VEHICLE', updateActiveUnit)

            -- We don't need to register UNIT_PET for the player unit. We register it
            -- mainly because UNIT_EXITED_VEHICLE and UNIT_ENTERED_VEHICLE doesn't always
            -- have pet information when they fire for party and raid units.
            if(objectUnit ~= 'player') then
                object:RegisterEvent('UNIT_PET', UpdatePet, true)
            end
        end

        if (not header) then
            -- No header means it's a frame created through :Spawn().
            -- Left click (target), Right click (menu)
            object:SetAttribute("*type1", 'target')
            object:SetAttribute('*type2', 'togglemenu')
            -- object.ShowMenu = ShowMenu
            object:RegisterForClicks('LeftButtonDown', 'RightButtonDown')
            -- object:SetScript('OnClick', OnClick)
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

        object:SetScript('OnAttributeChanged', OnAttributeChanged)
        object:SetScript('OnShow', function(...) OnShow(this) end)

        activeElements[object] = {}
        for element in next, elements do
            object:EnableElement(element, objectUnit)
        end

        for _, func in next, callback do
            func(object)
        end

        -- Make Clique happy
        -- _G.ClickCastFrames = ClickCastFrames or {}
        -- ClickCastFrames[object] = true
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
    local function getRelativePointAnchor( point )
	point = strupper(point);
	if (point == "TOP") then
            return "BOTTOM", 0, -1;
	elseif (point == "BOTTOM") then
            return "TOP", 0, 1;
	elseif (point == "LEFT") then
            return "RIGHT", 1, 0;
	elseif (point == "RIGHT") then
            return "LEFT", -1, 0;
	elseif (point == "TOPLEFT") then
            return "BOTTOMRIGHT", 1, -1;
	elseif (point == "TOPRIGHT") then
            return "BOTTOMLEFT", -1, -1;
	elseif (point == "BOTTOMLEFT") then
            return "TOPRIGHT", 1, 1;
	elseif (point == "BOTTOMRIGHT") then
            return "TOPLEFT", -1, 1;
	else
            return "CENTER", 0, 0;
	end
    end

    local function ApplyUnitButtonConfiguration( ... )
	for i = 1, select("#", unpack(arg)), 1 do
            local frame = select(i, unpack(arg));
            local anchor = frame:GetAttribute("initial-anchor");
            local width = tonumber(frame:GetAttribute("initial-width") or nil);
            local height = tonumber(frame:GetAttribute("initial-height")or nil);
            local scale = tonumber(frame:GetAttribute("initial-scale")or nil);
            local unitWatch = frame:GetAttribute("initial-unitWatch");
            if ( anchor ) then
                local point, relPoint, xOffset, yOffset = strsplit(",", anchor);
                relpoint = relpoint or point;
                xOffset = tonumber(xOffset) or 0;
                yOffset = tonumber(yOffset) or 0;
                frame:SetPoint(point, frame:GetParent(), relPoint, xOffset, yOffset);
            end
            if ( width ) then
                frame:SetWidth(width);
            end
            if ( height ) then
                frame:SetHeight(height);
            end
            if ( scale ) then
                frame:SetScale(scale);
            end
            if ( unitWatch ) then
                if ( unitWatch == "state" ) then
                    RegisterUnitWatch(frame, true);
                else
                    RegisterUnitWatch(frame);
                end
            end

            -- call this function recursively for the current frame's children
            ApplyUnitButtonConfiguration(frame:GetChildren());
	end
    end

    local function ApplyConfig( header, newChild, defaultConfigFunction )
	local configFunction = header.initialConfigFunction or defaultConfigFunction;
	if ( type(configFunction) == "function" ) then
            configFunction(newChild);
            return true;
	end
    end

    function SetupUnitButtonConfiguration( header, newChild, defaultConfigFunction )
	if ApplyConfig(header, newChild, defaultConfigFunction) then
            ApplyUnitButtonConfiguration(newChild);
	end
    end

    local function fillTable( tbl, ... )
	for key in pairs(tbl) do
            tbl[key] = nil;
	end
	for i = 1, select('#', unpack(arg)), 1 do
            local key = select(i, unpack(arg));
            key = tonumber(key) or key;
            tbl[key] = true;
	end
    end

    local function doubleFillTable(tbl, ...)
	fillTable(tbl, unpack(arg));
	for i = 1, select('#', unpack(arg)), 1 do
            tbl[i] = select(i, unpack(arg));
	end
    end

    local tokenTable = {};
    local sortingTable = {};
    local groupingTable = {};
    local tempTable = {};

    local function GetGroupHeaderType(self)
	local type, start, stop;

	local nRaid = GetNumRaidMembers();
	local nParty = GetNumPartyMembers();
	if ( nRaid > 0 and self:GetAttribute("showRaid") ) then
            type = "RAID";
	elseif ( (nRaid > 0 or nParty > 0) and self:GetAttribute("showParty") ) then
            type = "PARTY";
	elseif ( self:GetAttribute("showSolo") ) then
            type = "SOLO";
	end
	if ( type ) then
            if ( type == "RAID" ) then
                start = 1;
                stop = nRaid;
            else
                if ( type == "SOLO" or self:GetAttribute("showPlayer") ) then
                    start = 0;
                else
                    start = 1;
                end
                stop = nParty;
            end
	end
	return type, start, stop;
    end

    local function configureChildren(self)
	local point = self:GetAttribute("point") or "TOP"; --default anchor point of "TOP"
	local relativePoint, xOffsetMult, yOffsetMult = getRelativePointAnchor(point);
	local xMultiplier, yMultiplier =  abs(xOffsetMult), abs(yOffsetMult);
	local xOffset = self:GetAttribute("xOffset") or 0; --default of 0
	local yOffset = self:GetAttribute("yOffset") or 0; --default of 0
	local sortDir = self:GetAttribute("sortDir") or "ASC"; --sort ascending by default
	local columnSpacing = self:GetAttribute("columnSpacing") or 0;
	local startingIndex = self:GetAttribute("startingIndex") or 1;

	local unitCount = table.getn(sortingTable)
	local numDisplayed = unitCount - (startingIndex - 1);
	local unitsPerColumn = self:GetAttribute("unitsPerColumn");
	local numColumns;
	if ( unitsPerColumn and numDisplayed > unitsPerColumn ) then
            numColumns = min( ceil(numDisplayed / unitsPerColumn), (self:GetAttribute("maxColumns") or 1) );
	else
            unitsPerColumn = numDisplayed;
            numColumns = 1;
	end
	local loopStart = startingIndex;
	local loopFinish = min((startingIndex - 1) + unitsPerColumn * numColumns, unitCount)
	local step = 1;

	numDisplayed = loopFinish - (loopStart - 1);

	if ( sortDir == "DESC" ) then
            loopStart = unitCount - (startingIndex - 1);
            loopFinish = loopStart - (numDisplayed - 1);
            step = -1;
	end

	-- ensure there are enough buttons
	local needButtons = max(1, numDisplayed);
	if not ( self:GetAttribute("child"..needButtons) ) then
            local name = self:GetName();
            if not ( name ) then
                self:Hide();
                return;
            end
            for i = 1, needButtons, 1 do
                if not ( self:GetAttribute("child"..i) ) then
                    local newButton = CreateFrame('Button', name.."UnitButton"..i, self);
                    SetupUnitButtonConfiguration(self, newButton);
                    self:SetAttribute("child"..i, newButton);
                end
            end
	end

	local columnAnchorPoint, columnRelPoint, colxMulti, colyMulti;
	if ( numColumns > 1 ) then
            columnAnchorPoint = self:GetAttribute("columnAnchorPoint");
            columnRelPoint, colxMulti, colyMulti = getRelativePointAnchor(columnAnchorPoint);
	end

	local buttonNum = 0;
	local columnNum = 1;
	local columnUnitCount = 0;
	local currentAnchor = self;
	for i = loopStart, loopFinish, step do
            buttonNum = buttonNum + 1;
            columnUnitCount = columnUnitCount + 1;
            if ( columnUnitCount > unitsPerColumn ) then
                columnUnitCount = 1;
                columnNum = columnNum + 1;
            end

            local unitButton = self:GetAttribute("child"..buttonNum);
            unitButton:Hide();
            unitButton:ClearAllPoints();
            if ( buttonNum == 1 ) then
                unitButton:SetPoint(point, currentAnchor, point, 0, 0);
                if ( columnAnchorPoint ) then
                    unitButton:SetPoint(columnAnchorPoint, currentAnchor, columnAnchorPoint, 0, 0);
                end

            elseif ( columnUnitCount == 1 ) then
                local columnAnchor = self:GetAttribute("child"..(buttonNum - unitsPerColumn));
                unitButton:SetPoint(columnAnchorPoint, columnAnchor, columnRelPoint, colxMulti * columnSpacing, colyMulti * columnSpacing);

            else
                unitButton:SetPoint(point, currentAnchor, relativePoint, xMultiplier * xOffset, yMultiplier * yOffset);
            end
            unitButton:SetAttribute("unit", sortingTable[sortingTable[i]]);
            unitButton:Show();

            currentAnchor = unitButton;
	end
	repeat
            buttonNum = buttonNum + 1;
            local unitButton = self:GetAttribute("child"..buttonNum);
            if ( unitButton ) then
                unitButton:Hide();
                unitButton:SetAttribute("unit", nil);
            end
	until not ( unitButton )

	local unitButton = self:GetAttribute("child1");
	local unitButtonWidth = unitButton:GetWidth();
	local unitButtonHeight = unitButton:GetHeight();
	if ( numDisplayed > 0 ) then
            local width = xMultiplier * (unitsPerColumn - 1) * unitButtonWidth + ( (unitsPerColumn - 1) * (xOffset * xOffsetMult) ) + unitButtonWidth;
            local height = yMultiplier * (unitsPerColumn - 1) * unitButtonHeight + ( (unitsPerColumn - 1) * (yOffset * yOffsetMult) ) + unitButtonHeight;

            if ( numColumns > 1 ) then
                width = width + ( (numColumns -1) * abs(colxMulti) * (width + columnSpacing) );
                height = height + ( (numColumns -1) * abs(colyMulti) * (height + columnSpacing) );
            end

            self:SetWidth(width);
            self:SetHeight(height);
	else
            local minWidth = self:GetAttribute("minWidth") or (yMultiplier * unitButtonWidth);
            local minHeight = self:GetAttribute("minHeight") or (xMultiplier * unitButtonHeight);
            self:SetWidth( max(minWidth, 0.1) );
            self:SetHeight( max(minHeight, 0.1) );
	end
    end

    local function GetGroupRosterInfo(type, index)
	local _, unit, name, subgroup, className
	if ( type == "RAID" ) then
            unit = "raid"..index;
            name, _, subgroup, _, _, className, _, _, _, role = GetRaidRosterInfo(index);
	else
            if ( index > 0 ) then
                unit = "party"..index;
            else
                unit = "player";
            end
            subgroup = 1;
	end
	return unit, name, subgroup, className;
    end

    local function onUpdate(self)
	local nameList = self:GetAttribute("nameList");
	local groupFilter = self:GetAttribute("groupFilter");
	local sortMethod = self:GetAttribute("sortMethod");
	local groupBy = self:GetAttribute("groupBy");

	for key in pairs(sortingTable) do
            sortingTable[key] = nil;
	end

	-- See if this header should be shown
	local type, start, stop = GetGroupHeaderType(self);
	if ( not type ) then
            configureChildren(self);
            return;
	end

	if ( not groupFilter and not nameList ) then
            groupFilter = "1,2,3,4,5,6,7,8";
	end

	if ( groupFilter ) then
            -- filtering by a list of group numbers and/or classes
            fillTable(tokenTable, string.split(",", groupFilter));
            local strictFiltering = self:GetAttribute("strictFiltering"); -- non-strict by default
            for i = start, stop, 1 do
                local unit, name, subgroup, className, role = GetGroupRosterInfo(type, i);
                if ( name and
                         ((not strictFiltering) and
                                 (tokenTable[subgroup] or tokenTable[className] or (role and tokenTable[role])) -- non-strict filtering
                         ) or
                         (tokenTable[subgroup] and tokenTable[className]) -- strict filtering
                ) then
                    tinsert(sortingTable, name);
                    sortingTable[name] = unit;
                    if ( groupBy == "GROUP" ) then
                        groupingTable[name] = subgroup;

                    elseif ( groupBy == "CLASS" ) then
                        groupingTable[name] = className;

                    elseif ( groupBy == "ROLE" ) then
                        groupingTable[name] = role;

                    end
                end
            end

            if ( groupBy ) then
                local groupingOrder = self:GetAttribute("groupingOrder");
                doubleFillTable(tokenTable, string.split(",", groupingOrder));
                for k in pairs(tempTable) do
                    tempTable[k] = nil;
                end
                for _, grouping in ipairs(tokenTable) do
                    grouping = tonumber(grouping) or grouping;
                    for k in ipairs(groupingTable) do
                        groupingTable[k] = nil;
                    end
                    for index, name in ipairs(sortingTable) do
                        if ( groupingTable[name] == grouping ) then
                            tinsert(groupingTable, name);
                            tempTable[name] = true;
                        end
                    end
                    if ( sortMethod == "NAME" ) then -- sort by ID by default
                        table.sort(groupingTable);
                    end
                    for _, name in ipairs(groupingTable) do
                        tinsert(tempTable, name);
                    end
                end
                -- handle units whose group didn't appear in groupingOrder
                for k in ipairs(groupingTable) do
                    groupingTable[k] = nil;
                end
                for index, name in ipairs(sortingTable) do
                    if not ( tempTable[name] ) then
                        tinsert(groupingTable, name);
                    end
                end
                if ( sortMethod == "NAME" ) then -- sort by ID by default
                    table.sort(groupingTable);
                end
                for _, name in ipairs(groupingTable) do
                    tinsert(tempTable, name);
                end

                --copy the names back to sortingTable
                for index, name in ipairs(tempTable) do
                    sortingTable[index] = name;
                end

            elseif ( sortMethod == "NAME" ) then -- sort by ID by default
                table.sort(sortingTable);

            end

	else
            -- filtering via a list of names
            doubleFillTable(sortingTable, string.split(",", nameList));
            for i = start, stop, 1 do
                local unit, name = GetGroupRosterInfo(type, i);
                if ( sortingTable[name] ) then
                    sortingTable[name] = unit;
                end
            end
            for i = table.getn(sortingTable), 1, -1 do
                local name = sortingTable[i];
                if ( sortingTable[name] == true ) then
                    tremove(sortingTable, i);
                end
            end
            if ( sortMethod == "NAME" ) then
                table.sort(sortingTable);
            end

	end

	configureChildren(self);
    end

    local styleProxy = function(self, frame, ...)
        return walkObject(_G[frame])
    end

    -- There has to be an easier way to do this.
    local initialConfigFunction = function()
        local header = self:GetParent()
        local frames = table.new()
        table.insert(frames, self)
        self:GetChildList(frames)
        for i = 1, table.getn(frames) do
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
                frame:SetAttribute('oUF-guessUnit', unit)
            end

            local body = header:GetAttribute'oUF-initialConfigFunction'
            if(body) then
                frame:Run(body, unit)
            end
        end

        header:styleFunction(self:GetName())
    end

    function oUF:SpawnHeader(overrideName, template, visibility, ...)
        if (not style) then
            return error('Unable to create frame. No styles have been registered.')
        end

        -- local isPetHeader = string.match(template, '(PetHeader)')
        local name = overrideName or generateName(nil, unpack(arg))
        local header = CreateFrame('Frame', name, UIParent)

	header:RegisterEvent("PARTY_MEMBERS_CHANGED")
	header:RegisterEvent("UNIT_NAME_UPDATE")
        header:SetScript('OnEvent', function(...) if this:IsVisible() then onUpdate(this) end end)
        header:SetScript('OnAttributeChanged', function(this) if this:IsShown() then onUpdate(this) end end)
        header:SetScript('OnShow', function(...) onUpdate(this) end)

        for i = 1, select('#', unpack(arg)), 2 do
            local att, val = select(i, unpack(arg))
            if (not att) then break end
            header:SetAttribute(att, val)
        end

        header.style = style
        header.styleFunction = styleProxy

        -- Expose the header through oUF.headers.
        table.insert(headers, header)

        -- We set it here so layouts can't directly override it.
        header:SetAttribute('initialConfigFunction', initialConfigFunction)
        header:SetAttribute('oUF-headerType', isPetHeader and 'pet' or 'group')

        if header:GetAttribute('showParty') then
            self:DisableBlizzard('party')
        end

        if visibility then
            local type, list = string.split(' ', visibility, 2)
            if(list and type == 'custom') then
                RegisterAttributeDriver(header, 'state-visibility', list)
            else
                local condition = getCondition(string.split(',', visibility))
                RegisterAttributeDriver(header, 'state-visibility', condition)
            end
        end

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

    object:SetAttribute('unit', unit)

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
