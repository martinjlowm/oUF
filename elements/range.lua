--[[ Element: Range Fader

    Widget

    Range - A table containing opacity values.

    Options

    .outsideAlpha - Opacity when the unit is out of range. Values 0 (fully
    transparent) - 1 (fully opaque).
    .insideAlpha  - Opacity when the unit is within range. Values 0 (fully
    transparent) - 1 (fully opaque).

    Examples

    -- Register with oUF
    self.Range = {
    insideAlpha = 1,
    outsideAlpha = 1/2,
    }

    Hooks

]]

local parent = 'oUF'
local oUF = oUF

local _FRAMES = {}
local OnRangeFrame

local sqrt = sqrt
local rosterLib = AceLibrary("RosterLib-2.0")
local roster = {}
local Continent, Zone, ZoneName
local MapScales = {
	[0] = {[0] = {x = 29688.932932224,	y = 44537.340058402}}, -- World Map

	[-1] = { -- Battlegrounds
		[0] = {x=0.0000000001,y=0.0000000001}, -- dummy
		['Alterac Valley'] = {x=0.00025277584791183,y=0.0003791834626879}, -- Alterac Valley
		['Arathi Basin'] = {x=0.00060996413230886,y=0.00091460134301867}, -- Arathi Basin
		['Warsong Gulch'] = {x=0.000934666820934484,y=0.0013986080884933}, -- Warsong Gulch
	},

	[1] = { -- Kalimdor
		[0] = {x = 24533.025279205, y = 36800.210572494}, -- No local Map
		[1] = {x=0.00018538534641226,y=0.00027837923594884}, -- Ashenvale
		[2] = {x=0.0002110515322004,y=0.00031666883400508}, -- Aszhara
		[3] = {x=0.00016346999577114,y=0.0002448782324791}, -- Darkshore
		[4] = {x=0.001011919762407,y=0.0015176417572158}, -- Darnassus
		[5] = {x=0.000238049243117769,y=0.00035701000264713}, -- Desolace
		[6] = {x=0.000202241752828887,y=0.00030311250260898},  -- Durotar
		[7] = {x=0.00020404585770198,y=0.00030594425542014}, -- Dustwallow Marsh
		[8] = {x=0.00018605589866638,y=0.00027919347797121}, -- Felwood
		[9] = {x=0.00015413335391453,y=0.00023112978254046}, -- Feralas
		[10] = {x=0.00046338992459433,y=0.00069469745670046}, -- Moonglade
		[11] = {x=0.00020824585642133,y=0.00031234536852155}, -- Mulgore
		[12] = {x=0.00076302673135485,y=0.0011450946331024}, -- Orgrimmar
		[13] = {x=0.00030702139650072,y=0.00046115900788988}, -- Silithus
		[14] = {x=0.0002192035317421,y=0.00032897400004523}, -- Stonetalon Mountains
		[15] = {x=0.00015519559383392,y=0.00023255497217178}, -- Tanaris
		[16] = {x=0.00021010743720191,y=0.00031522342136928}, -- Teldrassil
		[17] = {x=0.0001055257661002,y=0.00015825512153762}, -- Barrens
		[18] = {x=0.00024301665169852,y=0.00036516572747912}, -- Thousand Needles
		[19] = {x=0.00102553303755263,y=0.0015390366315842}, -- Thunderbluff
		[20] = {x=0.00028926772730691,y=0.0004336131470544}, -- Un'Goro Crater
		[21] = {x=0.0001503484589713,y=0.0002260080405644}, -- Winterspring
	},

	[2] = { -- Eastern Kingdoms
		[0] = {x = 27149.795290881, y = 40741.175327834}, -- No local Map
		[1] = {x=0.00038236060312816,y=0.00057270910058703}, -- Alterac Mountains
		[2] = {x=0.00029711957488741,y=0.00044587893145425}, -- Arathi Highlands
		[3] = {x=0.00043004538331713,y=0.00064518196242196}, -- Badlands
		[4] = {x=0.00031955327306475,y=0.00047930649348668}, -- Blasted Lands
		[5] = {x=0.00036544565643583,y=0.00054845426763807}, -- Burning Steppes
		[6] = {x=0.00042719074657985,y=0.00064268921102796}, -- Deadwind Pass
		[7] = {x=0.00021748670509883,y=0.00032613213573183}, -- Dun Morogh
		[8] = {x=0.00039665134889739,y=0.000594192317755393},-- Duskwood
		[9] = {x=0.00027669753347124,y=0.00041501436914716}, -- Eastern Plaguelands
		[10] = {x=0.00030816452843802,y=0.00046261719294957}, -- Elwynn Forest
		[11] = {x=0.00033472904137203,y=0.00050214784485953}, -- Hillsbrad Foothills
		[12] = {x=0.0013541845338685,y=0.0020301469734737}, -- Ironforge
		[13] = {x=0.00038827742849077,y=0.000582420040021079}, -- Loch Modan
		[14] = {x=0.00049317521708352,y=0.0007399320602417}, -- Redridge Mountains
		[15] = {x=0.00047916280371802,y=0.00071918751512255}, -- Searing Gorge
		[16] = {x=0.00025506743362975,y=0.00038200191089085}, -- Silverpine
		[17] = {x=0.00079576990434102,y=0.0011931381055287}, -- Stormwind
		[18] = {x=0.00016783603600093,y=0.00025128040994917}, -- Stranglethorn
		[19] = {x=0.00046689595494952,y=0.00070027368409293}, -- Swamp of Sorrows
		[20] = {x=0.0002777065549578,y=0.00041729531117848}, -- Hinterlands
		[21] = {x=0.00023638989244189,y=0.0003550010068076}, -- Tirisfal
		[22] = {x=0.0011167100497655,y=0.0016737942184721}, -- Undercity
		[23] = {x=0.00024908781051636,y=0.00037342309951782}, -- Western Plaguelands
		[24] = {x=0.00030591232436044,y=0.00045816733368805},-- Westfall
		[25] = {x=0.00025879591703415,y=0.00038863212934562}, -- Wetlands
	}
}

local events = {
    CHAT_MSG_COMBAT_PARTY_HITS = { '(%a+) hits .+', '(%a+) crits .+' },
    CHAT_MSG_COMBAT_FRIENDLYPLAYER_HITS = { '(%a+) hits .+',
                                            '(%a+) crits .+' },
    CHAT_MSG_COMBAT_CREATURE_VS_SELF_HITS = { '.+ hits (%a+) for .+',
                                              '.+ crits (%a+) for .+' },
    CHAT_MSG_COMBAT_CREATURE_VS_PARTY_HITS = { '.+ hits (%a+) for .+',
                                               '.+ crits (%a+) for .+' },
    CHAT_MSG_COMBAT_CREATURE_VS_CREATURE_HITS = { '.+ hits (%a+) for .+',
                                                  '.+ crits (%a+) for .+',
                                                  '.+ crits (%a+) for .+' },

    CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE = { ".+'s .+ hits (%a+) for .+",
                                               ".+'s .+ crits (%a+) for .+",
                                               ".+'s .+ was resisted by (%a+)%." },
    CHAT_MSG_SPELL_CREATURE_VS_PARTY_DAMAGE = { ".+'s .+ hits (%a+) for .+",
                                                ".+'s .+ crits (%a+) for .+",
                                                ".+'s .+ was resisted by (%a+)%." },
    CHAT_MSG_SPELL_CREATURE_VS_CREATURE_DAMAGE = { ".+'s .+ hits (%a+) for .+",
                                                   ".+'s .+ crits (%a+) for .+",
                                                   ".+'s .+ was resisted by (%a+)%." },

    CHAT_MSG_SPELL_FRIENDLYPLAYER_BUFF = "(%a+)'s .+",
    CHAT_MSG_SPELL_FRIENDLYPLAYER_DAMAGE = { "(%a+)'s .+ hits .+",
                                             "(%a+)'s .+ crits .+" },
    CHAT_MSG_SPELL_HOSTILEPLAYER_DAMAGE = ".+'s .+ hits (%a+) for .+",
    CHAT_MSG_SPELL_PARTY_BUFF = '(.+) gains %d+ health from .+',
    CHAT_MSG_SPELL_PARTY_DAMAGE = { "(%a+)'s .+ hits .+",
                                    "(%a+)'s .+ crits .+" },
    CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_BUFFS = '(.+) gains %d+ health from .+',
    CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_DAMAGE = { '(%a+) is afflicted by .+',
                                                      '(%a+) suffers %d+ .+' },
    CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE = { '(%a+) is afflicted by .+',
                                                     '(%a+) suffers %d+ .+' },
    CHAT_MSG_SPELL_PERIODIC_PARTY_DAMAGE = '(%a+) is afflicted by .+',
    CHAT_MSG_SPELL_PERIODIC_PARTY_BUFFS = { ".+ gains %d+ health from (.+)'s .+",
                                            '(%a+) gains .+'},

    CHAT_MSG_COMBAT_CREATURE_VS_PARTY_MISSES = { '.+ attacks%. (%a+) parries%.',
                                                 '.+ attacks%. (%a+) dodges%.',
                                                 '.+ attacks%. (%a+) blocks%.',
                                                 '.+ misses (%a+)%.' },
    CHAT_MSG_SPELL_HOSTILEPLAYER_BUFF = { '.+ heals (%a+) for .+',
                                          "(%a+)'s .+" },
}


local function ParseCombatMessage(self, event, msg)
    local unit
    local pattern = events[event]
    if type(pattern) == "string" then
        local _, _, unitname = string.find(msg, pattern)
        if unitname and not string.match(unitname, '[Yy]ou') then
            unit = rosterLib:GetUnitIDFromName(unitname)
            if unit then
                roster[unit] = GetTime()
            end
        end
    elseif type(pattern) == "table" then
        for _, val in pairs(pattern) do
            local _, _, unitname = string.find(msg, val)
            if unitname and not string.match(unitname, '[Yy]ou') then
                unit = rosterLib:GetUnitIDFromName(unitname)
                if unit then
                    roster[unit] = GetTime()
                    return
                end
            end
        end
    end
end

local function ZoneChanged()
    SetMapToCurrentZone()
    Continent = GetCurrentMapContinent()
    Zone = GetCurrentMapZone()
    ZoneName = GetZoneText()
    if ZoneName == "Warsong Gulch" or ZoneName == "Arathi Basin" or ZoneName == "Alterac Valley" then
        Zone = ZoneName
    end
end
ZoneChanged()

local function UnitInRange(unit)
    local range = 100
    if UnitExists(unit) and UnitIsVisible(unit) then
        local _, instance = IsInInstance()

        if CheckInteractDistance(unit, 1) then
            range = 10
        elseif CheckInteractDistance(unit, 3) then
            range = 10
        elseif CheckInteractDistance(unit, 4) then
            range = 30
        elseif (instance == "none" or instance == "pvp") and not WorldMapFrame:IsVisible() then
            local px, py, ux, uy, distance
            SetMapToCurrentZone()
            px, py = GetPlayerMapPosition('player')
            ux, uy = GetPlayerMapPosition(unit)
            if Zone ~= 0 and Continent ~= 0 then
                local x, y
                x = (px - ux)/MapScales[Continent][Zone].x
                y = (py - uy)/MapScales[Continent][Zone].y
                distance = sqrt(x * x + y * y)
            else
                local xDelta, yDelta
                px, py = px * MapScales[Continent][Zone].x, py * MapScales[Continent][Zone].y
                ux, uy = ux * MapScales[Continent][Zone].x, uy * MapScales[Continent][Zone].y
                xDelta = (ux - px)
                yDelta = (uy - py)
                distance = sqrt(xDelta * xDelta + yDelta * yDelta)
            end

            range = distance
        elseif (GetTime() - (roster[unit] or 0)) < 4 then
            range = 40
        else
            range = 45
        end
    end

    return range <= 40, range
end


local UnitIsConnected = UnitIsConnected

-- updating of range.
local timer = 0
local OnRangeUpdate = function(self)
    timer = timer + arg1

    if(timer >= .20) then
        for _, object in next, _FRAMES do
            if(object:IsShown()) then
                local range = object.Range

                if UnitIsConnected(object.unit) then
                    local inRange, checkedRange = UnitInRange(object.unit)
                    if(checkedRange and not inRange) then
                        if(range.Override) then
                            --[[ .Override(self, status)

                                A function used to override the calls to :SetAlpha().

                                Arguments

                                self   - The unit object.
                                status - The range status of the unit. Either `inside` or
                                `outside`.
                            ]]
                            range.Override(object, 'outside')
                        else
                            object:SetAlpha(range.outsideAlpha)
                        end
                    else
                        if(range.Override) then
                            range.Override(object, 'inside')
                        elseif(object:GetAlpha() ~= range.insideAlpha) then
                            object:SetAlpha(range.insideAlpha)
                        end
                    end
                else
                    if(range.Override) then
                        range.Override(object, 'offline')
                    elseif(object:GetAlpha() ~= range.insideAlpha) then
                        object:SetAlpha(range.insideAlpha)
                    end
                end
            end
        end

        timer = 0
    end
end

local Enable = function(self)
    local range = self.Range
    if range and range.insideAlpha and range.outsideAlpha then
        table.insert(_FRAMES, self)

        for event in next, events do
            self:RegisterEvent(event, ParseCombatMessage)
        end
        self:RegisterEvent('ZONE_CHANGED_NEW_AREA', ZoneChanged)

        if not OnRangeFrame then
            OnRangeFrame = CreateFrame('Frame')
            OnRangeFrame:SetScript('OnUpdate', OnRangeUpdate)
        end

        OnRangeFrame:Show()

        return true
    end
end

local Disable = function(self)
    local range = self.Range
    if range then
        for k, frame in next, _FRAMES do
            if frame == self then
                table.remove(_FRAMES, k)
                break
            end
        end
        self:SetAlpha(1)

        if table.getn(_FRAMES) == 0 then
            OnRangeFrame:Hide()
        end
    end
end

oUF:AddElement('Range', nil, Enable, Disable)
