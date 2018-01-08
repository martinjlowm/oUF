local parent = 'oUF'
local oUF = oUF

local _G = getfenv(0)

local hiddenParent = CreateFrame("Frame")
hiddenParent:Hide()

local HandleFrame = function(baseName)
    local frame
    if(type(baseName) == 'string') then
        frame = _G[baseName]
    else
        frame = baseName
    end

    if(frame) then
        frame:UnregisterAllEvents()
        frame:Hide()

        -- Keep frame hidden without causing taint
        frame:SetParent(hiddenParent)

        local health = frame.healthbar
        if(health) then
            health:UnregisterAllEvents()
        end

        local power = frame.manabar
        if(power) then
            power:UnregisterAllEvents()
        end

        local spell = frame.spellbar
        if(spell) then
            spell:UnregisterAllEvents()
        end

        local altpowerbar = frame.powerBarAlt
        if(altpowerbar) then
            altpowerbar:UnregisterAllEvents()
        end
    end
end

function oUF:DisableBlizzard(unit)
    if(not unit) then return end

    if(unit == 'player') then
        HandleFrame(PlayerFrame)
    elseif(unit == 'pet') then
        HandleFrame(PetFrame)
    elseif(unit == 'target') then
        HandleFrame(TargetFrame)
        HandleFrame(ComboFrame)
    elseif(unit == 'targettarget') then
        HandleFrame(TargetFrameToT)
    elseif string.match(unit, '(party)%d?$') == 'party' then
        local id = string.match(unit, 'party(%d)')
        if id then
            HandleFrame('PartyMemberFrame' .. id)
        else
            for i = 1, 4 do
                HandleFrame(string.format('PartyMemberFrame%d', i))
            end
        end
    end
end
