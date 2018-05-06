--[[
Name: Babble-Faction-2.2
Revision: $Rev: 1315 $
Authors(s): Daviesh (oma_daviesh@hotmail.com)
Documentation: http://www.wowace.com/wiki/Babble-Faction-2.2
SVN: http://svn.wowace.com/wowace/trunk/Babble-2.2/Babble-Faction-2.2
Dependencies: AceLibrary, AceLocale-2.2
License: MIT
]]

local MAJOR_VERSION = "Babble-Faction-2.2"
local MINOR_VERSION = 90000 + tonumber(("$Revision: 1315 $"):match("(%d+)"))

if not AceLibrary then error(MAJOR_VERSION .. " requires AceLibrary") end
if not AceLibrary:HasInstance("AceLocale-2.2") then error(MAJOR_VERSION .. " requires AceLocale-2.2") end

local _, x = AceLibrary("AceLocale-2.2"):GetLibraryVersion()
MINOR_VERSION = MINOR_VERSION * 100000 + x

if not AceLibrary:IsNewVersion(MAJOR_VERSION, MINOR_VERSION) then return end

local BabbleFaction = AceLibrary("AceLocale-2.2"):new(MAJOR_VERSION)

BabbleFaction:RegisterTranslations("enUS", function() return {
	--Player Factions
	["Alliance"] = true,
	["Horde"] = true,

	-- Rep Factions
	["The Aldor"] = true,
	["Argent Dawn"] = true,
	["Ashtongue Deathsworn"] = true,
	["Bloodsail Buccaneers"] = true,
	["Brood of Nozdormu"] = true,
	["Cenarion Circle"] = true,
	["Cenarion Expedition"] = true,
	["The Consortium"] = true,
	["Darkmoon Faire"] = true,
	["The Defilers"] = true,
	["Frostwolf Clan"] = true,
	["Gelkis Clan Centaur"] = true,
	["Honor Hold"] = true,
	["Hydraxian Waterlords"] = true,
	["Keepers of Time"] = true,
	["Kurenai"] = true,
	["The League of Arathor"] = true,
	["Lower City"] = true,
	["The Mag'har"] = true,
	["Magram Clan Centaur"] = true,
	["Netherwing"] = true,
	["Ogri'la"] = true,
	["The Scale of the Sands"] = true,
	["The Scryers"] = true,
	["Silverwing Sentinels"] = true,
	["The Sha'tar"] = true,
	["Sha'tari Skyguard"] = true,
	["Shattered Sun Offensive"] = true,
	["Sporeggar"] = true,
	["Stormpike Guard"] = true,
	["Thorium Brotherhood"] = true,
	["Thrallmar"] = true,
	["Timbermaw Hold"] = true,
	["Tranquillien"] = true,
	["The Violet Eye"] = true,
	["Warsong Outriders"] = true,
	["Wintersaber Trainers"] = true,
	["Zandalar Tribe"] = true,

	--Rep Levels
	["Neutral"] = true,
	["Friendly"] = true,
	["Honored"] = true,
	["Revered"] = true,
	["Exalted"] = true,
} end)

BabbleFaction:RegisterTranslations("deDE", function() return {
	--Player Factions
	["Alliance"] = "Allianz",
	["Horde"] = "Horde",

  -- Rep Factions
	["The Aldor"] = "Die Aldor",
	["Argent Dawn"] = "Argentumdämmerung",
	["Ashtongue Deathsworn"] = "Die Todeshörigen",
	["Bloodsail Buccaneers"] = "Blutsegelbukaniere",
	["Brood of Nozdormu"] = "Nozdormus Brut",
	["Cenarion Circle"] = "Zirkel des Cenarius",
	["Cenarion Expedition"] = "Expedition des Cenarius",
	["The Consortium"] = "Das Konsortium",
	["Darkmoon Faire"] = "Dunkelmond-Jahrmarkt",
	["The Defilers"] = "Die Entweihten",
	["Frostwolf Clan"] = "Frostwolfklan",
	["Gelkis Clan Centaur"] = "Gelkisklan",
	["Honor Hold"] = "Ehrenfeste",
	["Hydraxian Waterlords"] = "Hydraxianer",
	["Keepers of Time"] = "Hüter der Zeit",
	["Kurenai"] = "Kurenai",
	["The League of Arathor"] = "Der Bund von Arathor",
	["Lower City"] = "Unteres Viertel",
	["The Mag'har"] = "Die Mag'har",
	["Magram Clan Centaur"] = "Magramklan",
	["Netherwing"] = "Netherschwingen",
	["Ogri'la"] = "Ogri'la",
	["The Scale of the Sands"] = "Die Wächter der Sande",
	["The Scryers"] = "Die Seher",
	["Silverwing Sentinels"] = "Silberschwingen",
	["The Sha'tar"] = "Die Sha'tar",
	["Sha'tari Skyguard"] = "Himmelswache der Sha'tari",
	["Shattered Sun Offensive"] = "Offensive der Zerschlagenen Sonne",
	["Sporeggar"] = "Sporeggar",
	["Stormpike Guard"] = "Sturmlanzengarde",
	["Thorium Brotherhood"] = "Thoriumbruderschaft",
	["Thrallmar"] = "Thrallmar",
	["Timbermaw Hold"] = "Holzschlundfeste",
	["Tranquillien"] = "Tristessa",
	["The Violet Eye"] = "Das Violette Auge",
	["Warsong Outriders"] = "Vorhut des Kriegshymnenklan",
	["Wintersaber Trainers"] = "Wintersäblerausbilder",
	["Zandalar Tribe"] = "Stamm der Zandalar",

	--Rep Levels
	["Neutral"] = "Neutral",
	["Friendly"] = "Freundlich",
	["Honored"] = "Wohlwollend",
	["Revered"] = "Respektvoll",
	["Exalted"] = "Ehrfürchtig",
} end)

BabbleFaction:RegisterTranslations("frFR", function() return {
	--Player Factions
	["Alliance"] = "Alliance",
	["Horde"] = "Horde",

	-- Rep Factions
	["The Aldor"] = "L'Aldor",
	["Argent Dawn"] = "Aube d'argent",
	["Ashtongue Deathsworn"] = "Ligemort cendrelangue",
	["Bloodsail Buccaneers"] = "La Voile sanglante",
	["Brood of Nozdormu"] = "Progéniture de Nozdormu",
	["Cenarion Circle"] = "Cercle cénarien",
	["Cenarion Expedition"] = "Expédition cénarienne",
	["The Consortium"] = "Le Consortium",
	["Darkmoon Faire"] = "Foire de Sombrelune",
	["The Defilers"] = "Les Profanateurs",
	["Frostwolf Clan"] = "Clan Loup-de-givre",
	["Gelkis Clan Centaur"] = "Centaures (Gelkis)",
	["Honor Hold"] = "Bastion de l'honneur",
	["Hydraxian Waterlords"] = "Les Hydraxiens",
	["Keepers of Time"] = "Gardiens du Temps",
	["Kurenai"] = "Kurenaï",
	["The League of Arathor"] = "La Ligue d'Arathor",
	["Lower City"] = "Ville basse",
	["The Mag'har"] = "Les Mag'har",
	["Magram Clan Centaur"] = "Centaures (Magram)",
	["Netherwing"] = "Aile-du-Néant",
	["Ogri'la"] = "Ogri'la",
	["The Scale of the Sands"] = "La Balance des sables",
	["The Scryers"] = "Les Clairvoyants",
	["Silverwing Sentinels"] = "Sentinelles d'Aile-argent",
	["The Sha'tar"] = "Les Sha'tar",
	["Sha'tari Skyguard"] = "Garde-ciel sha'tari",
	["Shattered Sun Offensive"] = "Opération Soleil brisé",
	["Sporeggar"] = "Sporeggar",
	["Stormpike Guard"] = "Garde Foudrepique",
	["Thorium Brotherhood"] = "Confrérie du thorium",
	["Thrallmar"] = "Thrallmar",
	["Timbermaw Hold"] = "Repaire des Grumegueules",
	["Tranquillien"] = "Tranquillien",
	["The Violet Eye"] = "L'Œil pourpre",
	["Warsong Outriders"] = "Voltigeurs Chanteguerre",
	["Wintersaber Trainers"] = "Éleveurs de sabres-d'hiver",
	["Zandalar Tribe"] = "Tribu Zandalar",

	--Rep Levels
	["Neutral"] = "Neutre",
	["Friendly"] = "Amical",
	["Honored"] = "Honoré",
	["Revered"] = "Révéré",
	["Exalted"] = "Exalté",
} end)

BabbleFaction:RegisterTranslations("zhTW", function() return {
	--Player Factions
	["Alliance"] = "聯盟",
	["Horde"] = "部落",

	-- Rep Factions
	["The Aldor"] = "奧多爾",
	["Argent Dawn"] = "銀色黎明",
	["Ashtongue Deathsworn"] = "灰舌死亡誓言者",
	["Bloodsail Buccaneers"] = "血帆海盜",
	["Brood of Nozdormu"] = "諾茲多姆的子嗣",
	["Cenarion Circle"] = "塞納里奧議會",
	["Cenarion Expedition"] = "塞納里奧遠征隊",
	["The Consortium"] = "聯合團",
	["Darkmoon Faire"] = "暗月馬戲團",
	["The Defilers"] = "污染者",
	["Frostwolf Clan"] = "霜狼氏族",
	["Gelkis Clan Centaur"] = "吉爾吉斯半人馬",
	["Honor Hold"] = "榮譽堡",
	["Hydraxian Waterlords"] = "海達希亞水元素",
	["Keepers of Time"] = "時光守望者",
	["Kurenai"] = "卡爾奈",
	["The League of Arathor"] = "阿拉索聯軍",
	["Lower City"] = "陰鬱城",
	["The Mag'har"] = "瑪格哈",
	["Magram Clan Centaur"] = "瑪格拉姆半人馬",
	["Netherwing"] = "虛空之翼",
	["Ogri'la"] = "歐格利拉",
	["The Scale of the Sands"] = "流沙之鱗",
	["The Scryers"] = "占卜者",
	["Silverwing Sentinels"] = "銀翼哨兵",
	["The Sha'tar"] = "薩塔",
	["Sha'tari Skyguard"] = "薩塔禦天者",
	["Shattered Sun Offensive"] = "破碎之日進攻部隊",
	["Sporeggar"] = "斯博格爾",
	["Stormpike Guard"] = "雷矛衛隊",
	["Thorium Brotherhood"] = "瑟銀兄弟會",
	["Thrallmar"] = "索爾瑪",
	["Timbermaw Hold"] = "木喉要塞",
	["Tranquillien"] = "安寧地",
	["The Violet Eye"] = "紫羅蘭之眼",
	["Warsong Outriders"] = "戰歌偵察騎兵",
	["Wintersaber Trainers"] = "冬刃豹訓練師",
	["Zandalar Tribe"] = "贊達拉部族",

	--Rep Levels
	["Neutral"] = "中立",
	["Friendly"] = "友好",
	["Honored"] = "尊敬",
	["Revered"] = "崇敬",
	["Exalted"] = "崇拜",
} end)

BabbleFaction:RegisterTranslations("zhCN", function() return {
	--Player Factions
	["Alliance"] = "联盟",
	["Horde"] = "部落",

  -- Rep Factions
	["The Aldor"] = "奥尔多",
	["Argent Dawn"] = "银色黎明",
	["Ashtongue Deathsworn"] = "灰舌死誓者",
	["Bloodsail Buccaneers"] = "血帆海盗",
	["Brood of Nozdormu"] = "诺兹多姆的子嗣",
	["Cenarion Circle"] = "塞纳里奥议会",
	["Cenarion Expedition"] = "塞纳里奥远征队",
	["The Consortium"] = "星界财团",
	["Darkmoon Faire"] = "暗月马戏团",
	["The Defilers"] = "污染者",
	["Frostwolf Clan"] = "霜狼氏族",
	["Gelkis Clan Centaur"] = "吉尔吉斯半人马",
	["Honor Hold"] = "荣耀堡",
	["Hydraxian Waterlords"] = "海达希亚水元素",
	["Keepers of Time"] = "时光守护者",
	["Kurenai"] = "库雷尼",
	["The League of Arathor"] = "阿拉索联军",
	["Lower City"] = "贫民窟",
	["The Mag'har"] = "玛格汉",
	["Magram Clan Centaur"] = "玛格拉姆半人马",
	["Netherwing"] = "灵翼之龙",
	["Ogri'la"] = "奥格瑞拉",
	["The Scale of the Sands"] = "流沙之鳞",
	["The Scryers"] = "占星者",
	["Silverwing Sentinels"] = "银翼哨兵",
	["The Sha'tar"] = "沙塔尔",
	["Sha'tari Skyguard"] = "沙塔尔天空卫士",
	["Shattered Sun Offensive"] = "破碎残阳",
	["Sporeggar"] = "孢子村",
	["Stormpike Guard"] = "雷矛卫队",
	["Thorium Brotherhood"] = "瑟银兄弟会",
	["Thrallmar"] = "萨尔玛",
	["Timbermaw Hold"] = "木喉要塞",
	["Tranquillien"] = "塔奎林",
	["The Violet Eye"] = "紫罗兰之眼",
	["Warsong Outriders"] = "战歌侦察骑兵",
	["Wintersaber Trainers"] = "冬刃豹训练师",
	["Zandalar Tribe"] = "赞达拉部族",

	--Rep Levels
	["Neutral"] = "中立",
	["Friendly"] = "友善",
	["Honored"] = "尊敬",
	["Revered"] = "崇敬",
	["Exalted"] = "崇拜",
} end)

BabbleFaction:RegisterTranslations("esES", function() return {
	--Player Factions
	["Alliance"] = "Alianza",
	["Horde"] = "Horda",

	-- Rep Factions
	["The Aldor"] = "Los Aldor",
	["Argent Dawn"] = "Alba Argenta",
	["Ashtongue Deathsworn"] = "Juramorte Lengua de ceniza",
	["Bloodsail Buccaneers"] = "Bucaneros Velasangre",
	["Brood of Nozdormu"] = "Linaje de Nozdormu", -- check
	["Cenarion Circle"] = "Círculo Cenarion",
	["Cenarion Expedition"] = "Expedición Cenarion",
	["The Consortium"] = "El Consorcio",
	["Darkmoon Faire"] = "Feria de la Luna Negra",
	["The Defilers"] = "Los Rapiñadores",
	["Frostwolf Clan"] = "Clan Lobo Gélido",
	["Gelkis Clan Centaur"] = "Centauro del clan Gelkis",
	["Honor Hold"] = "Bastión del Honor",
	["Hydraxian Waterlords"] = "Srs. del Agua de Hydraxis",
	["Keepers of Time"] = "Vigilantes del tiempo",
	["Kurenai"] = "Kurenai",
	["The League of Arathor"] = "Liga de Arathor",
	["Lower City"] = "Bajo Arrabal",
	["The Mag'har"] = "Los Mag'har",
	["Magram Clan Centaur"] = "Centauro del clan Magram",
	["Netherwing"] = "Ala Abisal",
	["Ogri'la"] = "Ogri'la",
	["The Scale of the Sands"] = "La Escama de las Arenas",
	["The Scryers"] = "Los Arúspices",
	["Silverwing Sentinels"] = "Centinelas Ala de Plata",
	["The Sha'tar"] = "Los Sha'tar",
	["Sha'tari Skyguard"] = "Guardia del cielo Sha'tari",
	["Shattered Sun Offensive"] = "Ofensiva Sol Devastado",
	["Sporeggar"] = "Esporaggar",
	["Stormpike Guard"] = "Guardia Pico Tormenta",
	["Thorium Brotherhood"] = "Hermandad del torio",
	["Thrallmar"] = "Thrallmar",
	["Timbermaw Hold"] = "Bastión Fauces de Madera",
	["Tranquillien"] = "Tranquilien",
	["The Violet Eye"] = "El Ojo Violeta",
	["Warsong Outriders"] = "Escoltas Grito de Guerra",
	["Wintersaber Trainers"] = "Entrenadores Sable de Invierno", -- check
	["Zandalar Tribe"] = "Tribu Zandalar",

	--Rep Levels
	["Neutral"] = "Neutral",
	["Friendly"] = "Amistoso",
	["Honored"] = "Honorable",
	["Revered"] = "Reverenciado",
	["Exalted"] = "Exaltado",
} end)

BabbleFaction:RegisterTranslations("koKR", function() return {
	--Player Factions
	["Alliance"] = "얼라이언스",
	["Horde"] = "호드",

	-- Rep Factions
	["The Aldor"] = "알도르 사제회",
	["Argent Dawn"] = "은빛 여명회",
	["Ashtongue Deathsworn"] = "잿빛혓바닥 결사단",
	["Bloodsail Buccaneers"] = "붉은 해적단",
	["Brood of Nozdormu"] = "노즈도르무 혈족",
	["Cenarion Circle"] = "세나리온 의회",
	["Cenarion Expedition"] = "세나리온 원정대",
	["The Consortium"] = "무역연합",
	["Darkmoon Faire"] = "다크문 유랑단",
	["The Defilers"] = "포세이큰 파멸단",
	["Frostwolf Clan"] = "서리늑대 부족",
	["Gelkis Clan Centaur"] = "겔키스 부족 켄타로우스",  -- Check
	["Honor Hold"] = "명예의 요새",
	["Hydraxian Waterlords"] = "히드락시안 물의 군주",
	["Keepers of Time"] = "시간의 수호자",
	["Kurenai"] = "쿠레나이",
	["The League of Arathor"] = "아라소르 연맹",
	["Lower City"] = "고난의 거리",
	["The Mag'har"] = "마그하르",
	["Magram Clan Centaur"] = "마그람 부족 켄타로우스",  -- Check
	["Netherwing"] = "황천의 용군단",
	["Ogri'la"] = "오그릴라",
	["The Scale of the Sands"] = "시간의 중재자",
	["The Scryers"] = "점술가 길드",
	["Silverwing Sentinels"] = "은빛날개 파수대",
	["The Sha'tar"] = "샤타르",
	["Sha'tari Skyguard"] = "샤타리 하늘경비대",
	["Shattered Sun Offensive"] = "무너진 태양 공격대",
	["Sporeggar"] = "스포어가르",
	["Stormpike Guard"] = "스톰파이크 경비대",
	["Thorium Brotherhood"] = "토륨 대장조합 ",
	["Thrallmar"] = "스랄마",
	["Timbermaw Hold"] = "나무구렁 요새",
	["Tranquillien"] = "트랜퀼리엔",
	["The Violet Eye"] = "보랏빛 눈의 감시자",
	["Warsong Outriders"] = "전쟁노래 정찰대",
	["Wintersaber Trainers"] = "눈호랑이 조련사",
	["Zandalar Tribe"] = "잔달라 부족",

	--Rep Levels
	["Neutral"] = "중립적",
	["Friendly"] = "약간 우호적",
	["Honored"] = "우호적",
	["Revered"] = "매우 우호적",
	["Exalted"] = "확고한 동맹",
} end)
-- Translater: GriffonHeart (updater: StingerSoft)
BabbleFaction:RegisterTranslations("ruRU", function() return {
	--Player Factions
	["Alliance"] = "Альянс",
	["Horde"] = "Орда",

  -- Rep Factions
	["The Aldor"] = "Алдоры",
	["Argent Dawn"] = "Серебряный Рассвет",
	["Ashtongue Deathsworn"] = "Пеплоусты-служители",
	["Bloodsail Buccaneers"] = "Пираты Кровавого Паруса",
	["Brood of Nozdormu"] = "Род Ноздорму",
	["Cenarion Circle"] = "Служители Ценариона",
	["Cenarion Expedition"] = "Экспедиция Ценариона",
	["The Consortium"] = "Консорциум",
	["Darkmoon Faire"] = "Ярмарка Новолуния",
	["The Defilers"] = "Осквернители",
	["Frostwolf Clan"] = "Клан Северного Волка",
	["Gelkis Clan Centaur"] = "Кентавры из племени Гелкис",
	["Honor Hold"] = "Оплот Чести",
	["Hydraxian Waterlords"] = "Гидраксианские Повелители Вод",
	["Keepers of Time"] = "Хранители Времени",
	["Kurenai"] = "Куренай",
	["The League of Arathor"] = "Лига Аратора",
	["Lower City"] = "Нижний Город",
	["The Mag'har"] = "Маг'хары",
	["Magram Clan Centaur"] = "Кентавры племени Маграм",
	["Netherwing"] = "Крылья Пустоверти",
	["Ogri'la"] = "Огри'ла",
	["The Scale of the Sands"] = "Песчаная Чешуя",
	["The Scryers"] = "Провидцы",
	["Silverwing Sentinels"] = "Среброкрылые Часовые",
	["The Sha'tar"] = "Ша'тар",
	["Sha'tari Skyguard"] = "Стражи Небес Ша'тар",
	["Shattered Sun Offensive"] = "Армия Расколотого Солнца",
	["Sporeggar"] = "Спореггар",
	["Stormpike Guard"] = "Стража Грозовой Вершины",
	["Thorium Brotherhood"] = "Братство Тория",
	["Thrallmar"] = "Траллмар",
	["Timbermaw Hold"] = "Древобрюхи",
	["Tranquillien"] = "Транквиллион",
	["The Violet Eye"] = "Аметистовое Око",
	["Warsong Outriders"] = "Всадники Песни Войны",
	["Wintersaber Trainers"] = "Укротители ледопардов",
	["Zandalar Tribe"] = "Племя Зандалар",

	--Rep Levels
	["Neutral"] = "Равнодушие",
	["Friendly"] = "Дружелюбие",
	["Honored"] = "Уважение",
	["Revered"] = "Почтение",
	["Exalted"] = "Превознесение",
} end)
	
BabbleFaction:Debug()
BabbleFaction:SetStrictness(true)

AceLibrary:Register(BabbleFaction, MAJOR_VERSION, MINOR_VERSION)
BabbleFaction = nil
