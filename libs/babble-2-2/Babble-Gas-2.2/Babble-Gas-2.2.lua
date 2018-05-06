--[[
Name: Babble-Gas-2.2
Revision: $Rev: 1315 $
Authors(s): hyperactiveChipmunk (hyperactiveChipmunk@gmail.com)
Website: www.wowace.com
Documentation: http://www.wowace.com/wiki/Babble-Gas-2.2
SVN: http://svn.wowace.com/wowace/trunk/Babble-2.2/Babble-Gas-2.2
Dependencies: AceLibrary, AceLocale-2.2
License: MIT
]]

local MAJOR_VERSION = "Babble-Gas-2.2"
local MINOR_VERSION = 90000 + tonumber(("$Revision: 1315 $"):match("(%d+)"))

if not AceLibrary then error(MAJOR_VERSION .. " requires AceLibrary") end
if not AceLibrary:HasInstance("AceLocale-2.2") then error(MAJOR_VERSION .. " requires AceLocale-2.2") end

local _, x = AceLibrary("AceLocale-2.2"):GetLibraryVersion()
MINOR_VERSION = MINOR_VERSION * 100000 + x

if not AceLibrary:IsNewVersion(MAJOR_VERSION, MINOR_VERSION) then return end

local BabbleGas = AceLibrary("AceLocale-2.2"):new(MAJOR_VERSION)

BabbleGas:RegisterTranslations("enUS", function() return {
-- Motes
	["Mote of Air"] = true,
	["Mote of Life"] = true,
	["Mote of Mana"] = true,
	["Mote of Shadow"] = true,
	["Mote of Water"] = true,
-- Types
	["Air"] = true,
	["Life"] = true,
	["Mana"] = true,
	["Shadow"] = true,
	["Water"] = true,
-- Nodes
	["Windy Cloud"] = true,
	["Swamp Gas"] = true,
	["Arcane Vortex"] = true,
	["Felmist"] = true,
} end)

BabbleGas:RegisterTranslations("koKR", function() return {
-- Motes
	["Mote of Air"] = "바람의 티끌",
	["Mote of Life"] = "생명의 티끌",
	["Mote of Mana"] = "마나의 티끌",
	["Mote of Shadow"] = "어둠의 티끌",
	["Mote of Water"] = "물의 티끌",
-- Types
	["Air"] = "바람",
	["Life"] = "생명",
	["Mana"] = "마나",
	["Shadow"] = "어둠",
	["Water"] = "물",
-- Nodes
	["Windy Cloud"] = "흩어지는 구름",
	["Swamp Gas"] = "늪지대 가스",
	["Arcane Vortex"] = "비전 소용돌이",
	["Felmist"] = "지옥 안개",
} end)

BabbleGas:RegisterTranslations("zhCN", function() return {
-- Motes
	["Mote of Air"] = "空气微粒",
	["Mote of Life"] = "生命微粒",
	["Mote of Mana"] = "法力微粒",
	["Mote of Shadow"] = "暗影微粒",
	["Mote of Water"] = "水之微粒",
-- Types
	["Air"] = "空气",
	["Life"] = "生命",
	["Mana"] = "法力",
	["Shadow"] = "暗影",
	["Water"] = "水",
-- Nodes
	["Windy Cloud"] = "气体云雾",
	["Swamp Gas"] = "沼泽毒气",
	["Arcane Vortex"] = "奥术漩涡",
	["Felmist"] = "魔雾",
} end)


BabbleGas:RegisterTranslations("zhTW", function() return {
-- Motes
	["Mote of Air"] = "空氣微粒",
	["Mote of Life"] = "生命微粒",
	["Mote of Mana"] = "法力微粒",
	["Mote of Shadow"] = "暗影微粒",
	["Mote of Water"] = "水源微粒",
-- Types
	["Air"] = "空氣",
	["Life"] = "生命",
	["Mana"] = "法力",
	["Shadow"] = "暗影",
	["Water"] = "水源",
-- Nodes
	["Windy Cloud"] = "多風之雲",
	["Swamp Gas"] = "沼氣",
	["Arcane Vortex"] = "秘法漩渦",
	["Felmist"] = "魔化霧",
} end)

BabbleGas:RegisterTranslations("frFR", function() return {
-- Motes
	["Mote of Air"] = "Granule d'air",
	["Mote of Life"] = "Granule de vie",
	["Mote of Mana"] = "Granule de mana",
	["Mote of Shadow"] = "Granule d'ombre",
	["Mote of Water"] = "Granule d'eau",
-- Types
	["Air"] = "Air",
	["Life"] = "Vie",
	["Mana"] = "Mana",
	["Shadow"] = "Ombre",
	["Water"] = "Eau",
-- Nodes
	["Windy Cloud"] = "Nuage venteux",
	["Swamp Gas"] = "Gaz des marais",
	["Arcane Vortex"] = "Vortex arcanique",
	["Felmist"] = "Gangrebrume",
} end)

BabbleGas:RegisterTranslations("esES", function() return {
-- Motes
--	["Mote of Air"] = true,
	["Mote of Life"] = "Mota de vida",
	["Mote of Mana"] = "Mota de maná",
	["Mote of Shadow"] = "Mota de sombra",
--	["Mote of Water"] = true,
-- Types
--	["Air"] = true,
	["Life"] = "Vida",
	["Mana"] = "Maná",
	["Shadow"] = "Sombra",
--	["Water"] = true,
-- Nodes
--	["Windy Cloud"] = true,
	["Swamp Gas"] = "Gas de pantano", -- fix
	["Arcane Vortex"] = "Vórtice arcano", -- fix
	["Felmist"] = "Niebla vil", -- fix
} end)

BabbleGas:RegisterTranslations("deDE", function() return {
-- Motes
	["Mote of Air"] = "Luftpartikel",
	["Mote of Life"] = "Lebenspartikel",
	["Mote of Mana"] = "Manapartikel",
	["Mote of Shadow"] = "Schattenpartikel",
	["Mote of Water"] = "Wasserpartikel",
-- Types
	["Air"] = "Luft",
	["Life"] = "Leben",
	["Mana"] = "Mana",
	["Shadow"] = "Schatten",
	["Water"] = "Wasser",
-- Nodes
	["Windy Cloud"] = "Windige Wolke",
	["Swamp Gas"] = "Sumpfgas",
	["Arcane Vortex"] = "Arkanvortex",
	["Felmist"] = "Teufelsnebel",
} end)
-- Translator: StingerSoft
BabbleGas:RegisterTranslations("ruRU", function() return {
-- Motes
	["Mote of Air"] = "Частичка Воздуха",
	["Mote of Life"] = "Частичка Жизни",
	["Mote of Mana"] = "Частичка Маны",
	["Mote of Shadow"] = "Частичка Тьмы",
	["Mote of Water"] = "Частичка Воды",
-- Types
	["Air"] = "Воздух",
	["Life"] = "Жизнь",
	["Mana"] = "Мана",
	["Shadow"] = "Тень",
	["Water"] = "Вода",
-- Nodes
	["Windy Cloud"] = "Грозовое облако",
	["Swamp Gas"] = "Болотный газ",
	["Arcane Vortex"] = "Волбшебное завихрение",
	["Felmist"] = "Туман Скверны",
} end)

BabbleGas:Debug()
BabbleGas:SetStrictness(true)

AceLibrary:Register(BabbleGas, MAJOR_VERSION, MINOR_VERSION)
BabbleGas = nil
