--[[
Name: Babble-SpellTree-2.2
Revision: $Rev: 1315 $
Author(s): ckknight (ckknight@gmail.com)
Website: http://ckknight.wowinterface.com/
Documentation: http://wiki.wowace.com/index.php/Babble-SpellTree-2.2
SVN: http://svn.wowace.com/root/trunk/Babble-2.2/Babble-SpellTree-2.2
Description: A library to provide localizations for spell and talent trees.
Dependencies: AceLibrary, AceLocale-2.2
License: MIT
]]

local MAJOR_VERSION = "Babble-SpellTree-2.2"
local MINOR_VERSION = 90000 + tonumber(("$Revision: 1315 $"):match("(%d+)"))

if not AceLibrary then error(MAJOR_VERSION .. " requires AceLibrary") end

if not AceLibrary:HasInstance("AceLocale-2.2") then error(MAJOR_VERSION .. " requires AceLocale-2.2") end

local _, x = AceLibrary("AceLocale-2.2"):GetLibraryVersion()
MINOR_VERSION = MINOR_VERSION * 100000 + x

if not AceLibrary:IsNewVersion(MAJOR_VERSION, MINOR_VERSION) then return end

local BabbleSpellTree = AceLibrary("AceLocale-2.2"):new(MAJOR_VERSION)

-- uncomment below for debug information
-- BabbleSpellTree:EnableDebugging()

BabbleSpellTree:RegisterTranslations("enUS", function()
	return {
	    -- All classes
	    ["Hybrid"] = true,

		-- Druid
		["Balance"] = true,
		["Feral Combat"] = true,
		["Restoration"] = true,
		-- Hunter
		["Beast Mastery"] = true,
		["Marksmanship"] = true,
		["Survival"] = true,
		-- Mage
		["Arcane"] = true,
		["Fire"] = true,
		["Frost"] = true,
		-- Paladin
		["Holy"] = true,
		["Protection"] = true,
		["Retribution"] = true,
		-- Priest
		["Discipline"] = true,
		-- ["Holy"] = true, -- same as Paladin
		["Shadow"] = true,
		-- Rogue
		["Assassination"] = true,
		["Combat"] = true,
		["Subtlety"] = true,
		-- Shaman
		["Elemental"] = true,
		["Enhancement"] = true,
		-- ["Restoration"] = true, -- same as Druid
		-- Warrior
		["Arms"] = true,
		["Fury"] = true,
		-- ["Protection"] = true, -- same as Paladin
		-- Warlock
		["Affliction"] = true,
		["Demonology"] = true,
		["Destruction"] = true,
	}
end)

BabbleSpellTree:RegisterTranslations("deDE", function()
	return {
	-- All classes
	    ["Hybrid"] = "Hybride",

		-- Druid
		["Balance"] = "Gleichgewicht",
		["Feral Combat"] = "Wilder Kampf",
		["Restoration"] = "Wiederherstellung",
		-- Hunter
		["Beast Mastery"] = "Tierherrschaft",
		["Marksmanship"] = "Treffsicherheit",
		["Survival"] = "Überleben",
		-- Mage
		["Arcane"] = "Arcan",
		["Fire"] = "Feuer",
		["Frost"] = "Frost",
		-- Paladin
		["Holy"] = "Heilig",
		["Protection"] = "Schutz",
		["Retribution"] = "Vergeltung",
		-- Priest
		["Discipline"] = "Disziplin",
		-- ["Holy"] = "Heilig", -- same as Paladin
		["Shadow"] = "Schatten",
		-- Rogue
		["Assassination"] = "Meucheln",
		["Combat"] = "Kampf",
		["Subtlety"] = "Täuschung",
		-- Shaman
		["Elemental"] = "Elementar",
		["Enhancement"] = "Verstärkung",
		-- ["Restoration"] = "Wiederherstellung", -- same as Druid
		-- Warrior
		["Arms"] = "Waffen",
		["Fury"] = "Furor",
		-- ["Protection"] = "Schutz", -- same as Paladin
		-- Warlock
		["Affliction"] = "Gebrechen",
		["Demonology"] = "Dämonologie",
		["Destruction"] = "Zerstörung",
	}
end)

BabbleSpellTree:RegisterTranslations("frFR", function()
	return {
		-- All classes
		["Hybrid"] = "Hybride",
		-- Druid
		["Balance"] = "Equilibre",
		["Feral Combat"] = "Combat farouche",
		["Restoration"] = "Restauration",
		-- Hunter
		["Beast Mastery"] = "Maîtrise des bêtes",
		["Marksmanship"] = "Précision",
		["Survival"] = "Survie",
		-- Mage
		["Arcane"] = "Arcane",
		["Fire"] = "Feu",
		["Frost"] = "Givre",
		-- Paladin
		["Holy"] = "Sacré",
		["Protection"] = "Protection",
		["Retribution"] = "Vindicte",
		-- Priest
		["Discipline"] = "Discipline",
		-- ["Holy"] = "Sacré", -- same as Paladin
		["Shadow"] = "Ombre",
		-- Rogue
		["Assassination"] = "Assassinat",
		["Combat"] = "Combat",
		["Subtlety"] = "Finesse",
		-- Shaman
		["Elemental"] = "Elémentaire",
		["Enhancement"] = "Amélioration",
		-- ["Restoration"] = "Restauration", -- same as Druid
		-- Warrior
		["Arms"] = "Armes",
		["Fury"] = "Fureur",
		-- ["Protection"] = true, -- same as Paladin
		-- Warlock
		["Affliction"] = "Affliction",
		["Demonology"] = "Démonologie",
		["Destruction"] = "Destruction",
	}
end)

BabbleSpellTree:RegisterTranslations("koKR", function()
	return {
		 -- All classes
		["Hybrid"] = "하이브리드",  -- Check
		-- Druid
		["Balance"] = "조화",
		["Feral Combat"] = "야성",
		["Restoration"] = "회복",
		-- Hunter
		["Beast Mastery"] = "야수",
		["Marksmanship"] = "사격",
		["Survival"] = "생존",
		-- Mage
		["Arcane"] = "비전",
		["Fire"] = "화염",
		["Frost"] = "냉기",
		-- Paladin
		["Holy"] = "신성",
		["Protection"] = "보호",
		["Retribution"] = "징벌",
		-- Priest
		["Discipline"] = "수양",
		-- ["Holy"] = "신성", -- same as Paladin
		["Shadow"] = "암흑",
		-- Rogue
		["Assassination"] = "암살",
		["Combat"] = "전투",
		["Subtlety"] = "잠행",
		-- Shaman
		["Elemental"] = "정기",
		["Enhancement"] = "고양",
		["Restoration"] = "복원", -- not same as Druid in Korean locale
		-- Warrior
		["Arms"] = "무기",
		["Fury"] = "분노",
		["Protection"] = "방어", -- not same as Paladin in Korean locale
		-- Warlock
		["Affliction"] = "고통",
		["Demonology"] = "악마",
		["Destruction"] = "파괴",
	}
end)

BabbleSpellTree:RegisterTranslations("zhCN", function()
	return {
	    -- All classes
	    ["Hybrid"] = "混合",

		-- Druid
		["Balance"] = "平衡",
		["Feral Combat"] = "野性战斗",
		["Restoration"] = "恢复",
		-- Hunter
		["Beast Mastery"] = "野兽控制",
		["Marksmanship"] = "射击",
		["Survival"] = "生存技能",
		-- Mage
		["Arcane"] = "奥术",
		["Fire"] = "火焰",
		["Frost"] = "冰霜",
		-- Paladin
		["Holy"] = "神圣",
		["Protection"] = "防护",
		["Retribution"] = "惩戒",
		-- Priest
		["Discipline"] = "戒律",
		-- ["Holy"] = "神圣", -- same as Paladin
		["Shadow"] = "暗影魔法",
		-- Rogue
		["Assassination"] = "刺杀",
		["Combat"] = "战斗",
		["Subtlety"] = "敏锐",
		-- Shaman
		["Elemental"] = "元素战斗",
		["Enhancement"] = "增强",
		-- ["Restoration"] = "恢复", -- same as Druid
		-- Warrior
		["Arms"] = "武器",
		["Fury"] = "狂怒",
		-- ["Protection"] = "防护", -- same as Paladin
		-- Warlock
		["Affliction"] = "痛苦",
		["Demonology"] = "恶魔学识",
		["Destruction"] = "毁灭",
	}
end)

BabbleSpellTree:RegisterTranslations("zhTW", function()
	return {
	    -- All classes
	    ["Hybrid"] = "混合",

		-- Druid
		["Balance"] = "平衡",
		["Feral Combat"] = "野性戰鬥",
		["Restoration"] = "恢復",
		-- Hunter
		["Beast Mastery"] = "野獸控制",
		["Marksmanship"] = "射擊",
		["Survival"] = "生存",
		-- Mage
		["Arcane"] = "秘法",
		["Fire"] = "火焰",
		["Frost"] = "冰霜",
		-- Paladin
		["Holy"] = "神聖",
		["Protection"] = "防護",
		["Retribution"] = "懲戒",
		-- Priest
		["Discipline"] = "戒律",
		-- ["Holy"] = "神聖", -- same as Paladin
		["Shadow"] = "暗影",
		-- Rogue
		["Assassination"] = "刺殺",
		["Combat"] = "戰鬥",
		["Subtlety"] = "敏銳",
		-- Shaman
		["Elemental"] = "元素",
		["Enhancement"] = "增強",
		-- ["Restoration"] = "恢復", -- same as Druid
		-- Warrior
		["Arms"] = "武器",
		["Fury"] = "狂怒",
		-- ["Protection"] = "防護", -- same as Paladin
		-- Warlock
		["Affliction"] = "痛苦",
		["Demonology"] = "惡魔學識",
		["Destruction"] = "毀滅",
	}
end)

BabbleSpellTree:RegisterTranslations("esES", function()
	return {
	    -- All classes
	    ["Hybrid"] = "Híbrido",

		-- Druid
		["Balance"] = "Equilibrio",
		["Feral Combat"] = "Combate Feral",
		["Restoration"] = "Restauraci\195\179n",
		-- Hunter
		["Beast Mastery"] = "Dominio de bestias",
		["Marksmanship"] = "Punter\195\173a",
		["Survival"] = "Supervivencia",
		-- Mage
		["Arcane"] = "Arcano",
		["Fire"] = "Fuego",
		["Frost"] = "Escarcha",
		-- Paladin
		["Holy"] = "Sagrado",
		["Protection"] = "Protecci\195\179n",
		["Retribution"] = "Reprensi\195\179n",
		-- Priest
		["Discipline"] = "Disciplina",
		-- ["Holy"] = "Sagrado", -- same as Paladin
		["Shadow"] = "Sombras",
		-- Rogue
		["Assassination"] = "Asesinato",
		["Combat"] = "Combate",
		["Subtlety"] = "Sutileza",
		-- Shaman
		["Elemental"] = "Elemental",
		["Enhancement"] = "Mejora",
		-- ["Restoration"] = "Restauraci\195\179n", -- same as Druid
		-- Warrior
		["Arms"] = "Armas",
		["Fury"] = "Furia",
		-- ["Protection"] = "Protecci\195\179n", -- same as Paladin
		-- Warlock
		["Affliction"] = "Aflicci\195\179n",
		["Demonology"] = "Demonolog\195\173a",
		["Destruction"] = "Destrucci\195\179n",
	}
end)
-- Translater: StingerSoft
BabbleSpellTree:RegisterTranslations("ruRU", function()
	return {
	    -- All classes
	    ["Hybrid"] = "Гибрид",

		-- Druid
		["Balance"] = "Баланс",
		["Feral Combat"] = "Сила зверя",
		["Restoration"] = "Исцеление",
		-- Hunter
		["Beast Mastery"] = "Чувство зверя",
		["Marksmanship"] = "Стрельба",
		["Survival"] = "Выживание",
		-- Mage
		["Arcane"] = "Тайная магия",
		["Fire"] = "Огонь",
		["Frost"] = "Лед",
		-- Paladin
		["Holy"] = "Свет",
		["Protection"] = "Защита",
		["Retribution"] = "Возмездие",
		-- Priest
		["Discipline"] = "Послушание",
		--["Holy"] = "Свет", -- одинаково с Паладином
		["Shadow"] = "Темная магия",
		-- Rogue
		["Assassination"] = "Убийство",
		["Combat"] = "Бой",
		["Subtlety"] = "Скрытность",
		-- Shaman
		["Elemental"] = "Укрощение стихии",
		["Enhancement"] = "Совершенствование",
		--["Restoration"] = "Исцеление", -- одинаково с Друидом
		-- Warrior
		["Arms"] = "Оружие",
		["Fury"] = "Неистовство",
		--["Protection"] = "Защита", --  одинаково с Паладином
		-- Warlock
		["Affliction"] = "Колдовство",
		["Demonology"] = "Демонология",
		["Destruction"] = "Разрушение",
	}
end)

BabbleSpellTree:Debug()
BabbleSpellTree:SetStrictness(true)

AceLibrary:Register(BabbleSpellTree, MAJOR_VERSION, MINOR_VERSION)
BabbleSpellTree = nil
