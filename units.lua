local parent = 'oUF'
local oUF = oUF
local Private = oUF.Private

local enableTargetUpdate = Private.enableTargetUpdate

-- Handles unit specific actions.
function oUF:HandleUnit(object, unit)
    local unit = object.unit or unit

    if(unit == 'target') then
        object:RegisterEvent('PLAYER_TARGET_CHANGED', object.UpdateAllElements)
    elseif(unit == 'pet') then
        object:RegisterEvent('UNIT_PET', object.UpdateAllElements)
    elseif(string.match(unit, '%w+(target)')) then
        enableTargetUpdate(object)
    end
end
