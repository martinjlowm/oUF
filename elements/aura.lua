--[[ Element: Auras

    Handles creation and updating of aura icons.

    Widget

    Auras   - A Frame to hold icons representing both buffs and debuffs.
    Buffs   - A Frame to hold icons representing buffs.
    Debuffs - A Frame to hold icons representing debuffs.

    Options

    .disableCooldown    - Disables the cooldown spiral. Defaults to false.
    .size               - Aura icon size. Defaults to 16.
    .onlyShowPlayer     - Only show auras created by player/vehicle.
    .showStealableBuffs - Display the stealable texture on buffs that can be
    stolen.
    .spacing            - Spacing between each icon. Defaults to 0.
    .['spacing-x']      - Horizontal spacing between each icon. Takes priority over
    `spacing`.
    .['spacing-y']      - Vertical spacing between each icon. Takes priority over
    `spacing`.
    .['growth-x']       - Horizontal growth direction. Defaults to RIGHT.
    .['growth-y']       - Vertical growth direction. Defaults to UP.
    .initialAnchor      - Anchor point for the icons. Defaults to BOTTOMLEFT.
    .filter             - Custom filter list for auras to display. Defaults to
    HELPFUL on buffs and HARMFUL on debuffs.

    Options Auras

    .numBuffs     - The maximum number of buffs to display. Defaults to 32.
    .numDebuffs   - The maximum number of debuffs to display. Defaults to 40.
    .gap          - Controls the creation of an invisible icon between buffs and
    debuffs. Defaults to false.
    .buffFilter   - Custom filter list for buffs to display. Takes priority over
    `filter`.
    .debuffFilter - Custom filter list for debuffs to display. Takes priority over
    `filter`.

    Options Buffs

    .num - Number of buffs to display. Defaults to 32.

    Options Debuffs

    .num - Number of debuffs to display. Defaults to 40.

    Examples

    -- Position and size
    local Buffs = CreateFrame("Frame", nil, self)
    Buffs:SetPoint("RIGHT", self, "LEFT")
    Buffs:SetSize(16 * 2, 16 * 16)

    -- Register with oUF
    self.Buffs = Buffs

    Hooks and Callbacks

]]

local parent = 'oUF'
local oUF = oUF

local VISIBLE = 1
local HIDDEN = 0

local _G = getfenv(0)

local spellIcons = {
	["Abolish Disease"] = "Spell_Nature_NullifyDisease",
	["Abolish Poison Effect"] = "Spell_Nature_NullifyPoison_02",
	["Abolish Poison"] = "Spell_Nature_NullifyPoison_02",
	["Activate MG Turret"] = "INV_Weapon_Rifle_10",
	["Adrenaline Rush"] = "Spell_Shadow_ShadowWordDominate",
	["Aftermath"] = "Spell_Fire_Fire",
	["Aggression"] = "Ability_Racial_Avatar",
	["Aimed Shot"] = "INV_Spear_07",
	["Alchemy"] = "Trade_Alchemy",
	["Ambush"] = "Ability_Rogue_Ambush",
	["Amplify Curse"] = "Spell_Shadow_Contagion",
	["Amplify Magic"] = "Spell_Holy_FlashHeal",
	["Ancestral Healing"] = "Spell_Nature_UndyingStrength",
	["Ancestral Knowledge"] = "Spell_Shadow_GrimWard",
	["Ancestral Spirit"] = "Spell_Nature_Regenerate",
	["Anger Management"] = "Spell_Holy_BlessingOfStamina",
	["Anticipation"] = "Spell_Nature_MirrorImage",
	["Aquatic Form"] = "Ability_Druid_AquaticForm",
	["Arcane Brilliance"] = "Spell_Holy_ArcaneIntellect",
	["Arcane Concentration"] = "Spell_Shadow_ManaBurn",
	["Arcane Explosion"] = "Spell_Nature_WispSplode",
	["Arcane Focus"] = "Spell_Holy_Devotion",
	["Arcane Instability"] = "Spell_Shadow_Teleport",
	["Arcane Intellect"] = "Spell_Holy_MagicalSentry",
	["Arcane Meditation"] = "Spell_Shadow_SiphonMana",
	["Arcane Mind"] = "Spell_Shadow_Charm",
	["Arcane Missiles"] = "Spell_Nature_StarFall",
	["Arcane Power"] = "Spell_Nature_Lightning",
	["Arcane Resistance"] = "Spell_Nature_StarFall",
	["Arcane Shot"] = "Ability_ImpalingBolt",
	["Arcane Subtlety"] = "Spell_Holy_DispelMagic",
	["Arctic Reach"] = "Spell_Shadow_DarkRitual",
	["Aspect of the Beast"] = "Ability_Mount_PinkTiger",
	["Aspect of the Cheetah"] = "Ability_Mount_JungleTiger",
	["Aspect of the Hawk"] = "Spell_Nature_RavenForm",
	["Aspect of the Monkey"] = "Ability_Hunter_AspectOfTheMonkey",
	["Aspect of the Pack"] = "Ability_Mount_WhiteTiger",
	["Aspect of the Wild"] = "Spell_Nature_ProtectionformNature",
	["Astral Recall"] = "Spell_Nature_AstralRecal",
	["Attack"] = "Temp",
	["Attacking"] = "Temp",
	["Auto Shot"] = "Ability_Whirlwind",
	["Axe Specialization"] = "INV_Axe_06",
	["Backstab"] = "Ability_BackStab",
	["Bane"] = "Spell_Shadow_DeathPact",
	["Banish"] = "Spell_Shadow_Cripple",
	["Barkskin Effect"] = "Spell_Nature_StoneClawTotem",
	["Barkskin"] = "Spell_Nature_StoneClawTotem",
	["Barrage"] = "Ability_UpgradeMoonGlaive",
	["Bash"] = "Ability_Druid_Bash",
	["Basic Campfire"] = "Spell_Fire_Fire",
	["Battle Shout"] = "Ability_Warrior_BattleShout",
	["Battle Stance Passive"] = "Ability_Warrior_OffensiveStance",
	["Battle Stance"] = "Ability_Warrior_OffensiveStance",
	["Bear Form"] = "Ability_Racial_BearForm",
	["Beast Lore"] = "Ability_Physical_Taunt",
	["Beast Slaying"] = "INV_Misc_Pelt_Bear_Ruin_02",
	["Beast Training"] = "Ability_Hunter_BeastCall02",
	["Benediction"] = "Spell_Frost_WindWalkOn",
	["Berserker Rage"] = "Spell_Nature_AncestralGuardian",
	["Berserker Stance Passive"] = "Ability_Racial_Avatar",
	["Berserker Stance"] = "Ability_Racial_Avatar",
	["Berserking"] = "Racial_Troll_Berserk",
	["Bestial Discipline"] = "Spell_Nature_AbolishMagic",
	["Bestial Swiftness"] = "Ability_Druid_Dash",
	["Bestial Wrath"] = "Ability_Druid_FerociousBite",
	["Bite"] = "Ability_Racial_Cannibalize",
	["Black Arrow"] = "Ability_TheBlackArrow",
	["Blackout"] = "Spell_Shadow_GatherShadows",
	["Blacksmithing"] = "Trade_BlackSmithing",
	["Blade Flurry"] = "Ability_Warrior_PunishingBlow",
	["Blast Wave"] = "Spell_Holy_Excorcism_02",
	["Blessed Recovery"] = "Spell_Holy_BlessedRecovery",
	["Blessing of Freedom"] = "Spell_Holy_SealOfValor",
	["Blessing of Kings"] = "Spell_Magic_MageArmor",
	["Blessing of Light"] = "Spell_Holy_PrayerOfHealing02",
	["Blessing of Might"] = "Spell_Holy_FistOfJustice",
	["Blessing of Protection"] = "Spell_Holy_SealOfProtection",
	["Blessing of Sacrifice"] = "Spell_Holy_SealOfSacrifice",
	["Blessing of Salvation"] = "Spell_Holy_SealOfSalvation",
	["Blessing of Sanctuary"] = "Spell_Nature_LightningShield",
	["Blessing of Wisdom"] = "Spell_Holy_SealOfWisdom",
	["Blind"] = "Spell_Shadow_MindSteal",
	["Blinding Powder"] = "INV_Misc_Ammo_Gunpowder_02",
	["Blink"] = "Spell_Arcane_Blink",
	["Blizzard"] = "Spell_Frost_IceStorm",
	["Block"] = "Ability_Defend",
	["Blood Craze"] = "Spell_Shadow_SummonImp",
	["Blood Frenzy"] = "Ability_GhoulFrenzy",
	["Blood Fury"] = "Racial_Orc_BerserkerStrength",
	["Blood Pact"] = "Spell_Shadow_BloodBoil",
	["Bloodrage"] = "Ability_Racial_BloodRage",
	["Bloodthirst"] = "Spell_Nature_BloodLust",
	["Booming Voice"] = "Spell_Nature_Purge",
	["Bow Specialization"] = "INV_Weapon_Bow_12",
	["Bows"] = "INV_Weapon_Bow_05",
	["Bright Campfire"] = "Spell_Fire_Fire",
	["Brutal Impact"] = "Ability_Druid_Bash",
	["Burning Soul"] = "Spell_Fire_Fire",
	["Call Pet"] = "Ability_Hunter_BeastCall",
	["Call of Flame"] = "Spell_Fire_Immolation",
	["Call of Thunder"] = "Spell_Nature_CallStorm",
	["Camouflage"] = "Ability_Stealth",
	["Cannibalize"] = "Ability_Racial_Cannibalize",
	["Cat Form"] = "Ability_Druid_CatForm",
	["Cataclysm"] = "Spell_Fire_WindsofWoe",
	["Chain Heal"] = "Spell_Nature_HealingWaveGreater",
	["Chain Lightning"] = "Spell_Nature_ChainLightning",
	["Challenging Roar"] = "Ability_Druid_ChallangingRoar",
	["Challenging Shout"] = "Ability_BullRush",
	["Charge Rage Bonus Effect"] = "Ability_Warrior_Charge",
	["Charge"] = "Ability_Warrior_Charge",
	["Cheap Shot"] = "Ability_CheapShot",
	["Chilled"] = "Spell_Frost_IceStorm",
	["Claw"] = "Ability_Druid_Rake",
	["Cleanse"] = "Spell_Holy_Renew",
	["Clearcasting"] = "Spell_Shadow_ManaBurn",
	["Cleave"] = "Ability_Warrior_Cleave",
	["Clever Traps"] = "Spell_Nature_TimeStop",
	["Closing"] = "Temp",
	["Cloth"] = "INV_Chest_Cloth_21",
	["Cobra Reflexes"] = "Spell_Nature_GuardianWard",
	["Cold Blood"] = "Spell_Ice_Lament",
	["Cold Snap"] = "Spell_Frost_WizardMark",
	["Combat Endurance"] = "Spell_Nature_AncestralGuardian",
	["Combustion"] = "Spell_Fire_SealOfFire",
	["Command"] = "Ability_Warrior_WarCry",
	["Concentration Aura"] = "Spell_Holy_MindSooth",
	["Concussion Blow"] = "Ability_ThunderBolt",
	["Concussion"] = "Spell_Fire_Fireball",
	["Concussive Shot"] = "Spell_Frost_Stun",
	["Cone of Cold"] = "Spell_Frost_Glacier",
	["Conflagrate"] = "Spell_Fire_Fireball",
	["Conjure Food"] = "INV_Misc_Food_10",
	["Conjure Mana Agate"] = "INV_Misc_Gem_Emerald_01",
	["Conjure Mana Citrine"] = "INV_Misc_Gem_Opal_01",
	["Conjure Mana Jade"] = "INV_Misc_Gem_Emerald_02",
	["Conjure Mana Ruby"] = "INV_Misc_Gem_Ruby_01",
	["Conjure Water"] = "INV_Drink_06",
	["Consecration"] = "Spell_Holy_InnerFire",
	["Consume Shadows"] = "Spell_Shadow_AntiShadow",
	["Convection"] = "Spell_Nature_WispSplode",
	["Conviction"] = "Spell_Holy_RetributionAura",
	["Cooking"] = "INV_Misc_Food_15",
	["Corruption"] = "Spell_Shadow_AbominationExplosion",
	["Counterattack"] = "Ability_Warrior_Challange",
	["Counterspell"] = "Spell_Frost_IceShock",
	["Cower"] = "Ability_Druid_Cower",
	["Create Firestone (Lesser)"]="INV_Ammo_FireTar",
	["Create Firestone"]="INV_Ammo_FireTar",
	["Create Firestone (Greater)"]="INV_Ammo_FireTar",
	["Create Firestone (Major)"]="INV_Ammo_FireTar",
	["Create Healthstone (Minor)"]="INV_Stone_04",
	["Create Healthstone (Lesser)"]="INV_Stone_04",
	["Create Healthstone"]="INV_Stone_04",
	["Create Healthstone (Greater)"]="INV_Stone_04",
	["Create Healthstone (Major)"]="INV_Stone_04",
	["Create Soulstone (Minor)"]="Spell_Shadow_SoulGem",
	["Create Soulstone (Lesser)"]="Spell_Shadow_SoulGem",
	["Create Soulstone"]="Spell_Shadow_SoulGem",
	["Create Soulstone (Greater)"]="Spell_Shadow_SoulGem",
	["Create Soulstone (Major)"]="Spell_Shadow_SoulGem",
	["Create Spellstone"]="INV_Misc_Gem_Sapphire_01",
	["Create Spellstone (Greater)"]="INV_Misc_Gem_Sapphire_01",
	["Create Spellstone (Major)"]="INV_Misc_Gem_Sapphire_01",
	["Crippling Poison II"] = "Ability_PoisonSting",
	["Crippling Poison"] = "Ability_PoisonSting",
	["Critical Mass"] = "Spell_Nature_WispHeal",
	["Crossbows"] = "INV_Weapon_Crossbow_01",
	["Cruelty"] = "Ability_Rogue_Eviscerate",
	["Cultivation"] = "INV_Misc_Flower_01",
	["Cure Disease"] = "Spell_Holy_NullifyDisease",
	["Cure Poison"] = "Spell_Nature_NullifyPoison",
	["Curse of Agony"] = "Spell_Shadow_CurseOfSargeras",
	["Curse of Doom Effect"] = "Spell_Shadow_AuraOfDarkness",
	["Curse of Doom"] = "Spell_Shadow_AuraOfDarkness",
	["Curse of Exhaustion"] = "Spell_Shadow_GrimWard",
	["Curse of Idiocy"] = "Spell_Shadow_MindRot",
	["Curse of Recklessness"] = "Spell_Shadow_UnholyStrength",
	["Curse of Shadow"] = "Spell_Shadow_CurseOfAchimonde",
	["Curse of Tongues"] = "Spell_Shadow_CurseOfTounges",
	["Curse of Weakness"] = "Spell_Shadow_CurseOfMannoroth",
	["Curse of the Elements"] = "Spell_Shadow_ChillTouch",
	["Dagger Specialization"] = "INV_Weapon_ShortBlade_05",
	["Daggers"] = "Ability_SteelMelee",
	["Dampen Magic"] = "Spell_Nature_AbolishMagic",
	["Dark Pact"] = "Spell_Shadow_DarkRitual",
	["Darkness"] = "Spell_Shadow_Twilight",
	["Dash"] = "Ability_Druid_Dash",
	["Deadly Poison II"] = "Ability_Rogue_DualWeild",
	["Deadly Poison III"] = "Ability_Rogue_DualWeild",
	["Deadly Poison IV"] = "Ability_Rogue_DualWeild",
	["Deadly Poison V"] = "Ability_Rogue_DualWeild",
	["Deadly Poison"] = "Ability_Rogue_DualWeild",
	["Death Coil"] = "Spell_Shadow_DeathCoil",
	["Death Wish"] = "Spell_Shadow_DeathPact",
	["Deep Wounds"] = "Ability_BackStab",
	["Defense"] = "Ability_Racial_ShadowMeld",
	["Defensive Stance Passive"] = "Ability_Warrior_DefensiveStance",
	["Defensive Stance"] = "Ability_Warrior_DefensiveStance",
	["Defensive State 2"] = "Ability_Defend",
	["Defensive State"] = "Ability_Defend",
	["Defiance"] = "Ability_Warrior_InnerRage",
	["Deflection"] = "Ability_Parry",
	["Demon Armor"] = "Spell_Shadow_RagingScream",
	["Demon Skin"] = "Spell_Shadow_RagingScream",
	["Demonic Embrace"] = "Spell_Shadow_Metamorphosis",
	["Demonic Sacrifice"] = "Spell_Shadow_PsychicScream",
	["Demoralizing Roar"] = "Ability_Druid_DemoralizingRoar",
	["Demoralizing Shout"] = "Ability_Warrior_WarCry",
	["Desperate Prayer"] = "Spell_Holy_Restoration",
	["Destructive Reach"] = "Spell_Shadow_CorpseExplode",
	["Detect Greater Invisibility"] = "Spell_Shadow_DetectInvisibility",
	["Detect Invisibility"] = "Spell_Shadow_DetectInvisibility",
	["Detect Lesser Invisibility"] = "Spell_Shadow_DetectLesserInvisibility",
	["Detect Magic"] = "Spell_Holy_Dizzy",
	["Detect Traps"] = "Ability_Spy",
	["Detect"] = "Ability_Hibernation",
	["Deterrence"] = "Ability_Whirlwind",
	["Devastation"] = "Spell_Fire_FlameShock",
	["Devotion Aura"] = "Spell_Holy_DevotionAura",
	["Devour Magic Effect"] = "Spell_Nature_Purge",
	["Devour Magic"] = "Spell_Nature_Purge",
	["Devouring Plague"] = "Spell_Shadow_BlackPlague",
	["Diplomacy"] = "INV_Misc_Note_02",
	["Dire Bear Form"] = "Ability_Racial_BearForm",
	["Disarm Trap"] = "Spell_Shadow_GrimWard",
	["Disarm"] = "Ability_Warrior_Disarm",
	["Disease Cleansing Totem"] = "Spell_Nature_DiseaseCleansingTotem",
	["Disenchant"] = "Spell_Holy_RemoveCurse",
	["Disengage"] = "Ability_Rogue_Feint",
	["Dismiss Pet"] = "Spell_Nature_SpiritWolf",
	["Dispel Magic"] = "Spell_Holy_DispelMagic",
	["Distract"] = "Ability_Rogue_Distract",
	["Distracting Shot"] = "Spell_Arcane_Blink",
	["Dive"] = "Spell_Shadow_BurningSpirit",
	["Divine Favor"] = "Spell_Holy_Heal",
	["Divine Fury"] = "Spell_Holy_SealOfWrath",
	["Divine Intellect"] = "Spell_Nature_Sleep",
	["Divine Intervention"] = "Spell_Nature_TimeStop",
	["Divine Protection"] = "Spell_Holy_Restoration",
	["Divine Shield"] = "Spell_Holy_DivineIntervention",
	["Divine Spirit"] = "Spell_Holy_DivineSpirit",
	["Divine Strength"] = "Ability_GolemThunderClap",
	["Dodge"] = "Spell_Nature_Invisibilty",
	["Drain Life"] = "Spell_Shadow_LifeDrain02",
	["Drain Mana"] = "Spell_Shadow_SiphonMana",
	["Drain Soul"] = "Spell_Shadow_Haunting",
	["Dual Wield Specialization"] = "Ability_DualWield",
	["Dual Wield"] = "Ability_DualWield",
	["Duel"] = "Temp",
	["Eagle Eye"] = "Ability_Hunter_EagleEye",
	["Earth Shock"] = "Spell_Nature_EarthShock",
	["Earthbind Totem"] = "Spell_Nature_StrengthOfEarthTotem02",
	["Efficiency"] = "Spell_Frost_WizardMark",
	["Elemental Focus"] = "Spell_Shadow_ManaBurn",
	["Elemental Fury"] = "Spell_Fire_Volcano",
	["Elemental Mastery"] = "Spell_Nature_WispHeal",
	["Elune's Grace"] = "Spell_Holy_ElunesGrace",
	["Elusiveness"] = "Spell_Magic_LesserInvisibilty",
	["Emberstorm"] = "Spell_Fire_SelfDestruct",
	["Enchanting"] = "Trade_Engraving",
	["Endurance Training"] = "Spell_Nature_Reincarnation",
	["Endurance"] = "Spell_Nature_UnyeildingStamina",
	["Engineering Specialization"] = "INV_Misc_Gear_01",
	["Engineering"] = "Trade_Engineering",
	["Enrage"] = "Ability_Druid_Enrage",
	["Enslave Demon"] = "Spell_Shadow_EnslaveDemon",
	["Entangling Roots"] = "Spell_Nature_StrangleVines",
	["Entrapment"] = "Spell_Nature_StrangleVines",
	["Escape Artist"] = "Ability_Rogue_Trip",
	["Evasion"] = "Spell_Shadow_ShadowWard",
	["Eventide"] = "Spell_Frost_Stun",
	["Eviscerate"] = "Ability_Rogue_Eviscerate",
	["Evocation"] = "Spell_Nature_Purge",
	["Execute"] = "INV_Sword_48",
	["Exorcism"] = "Spell_Holy_Excorcism_02",
	["Expansive Mind"] = "INV_Enchant_EssenceEternalLarge",
	["Explosive Trap Effect"] = "Spell_Fire_SelfDestruct",
	["Explosive Trap"] = "Spell_Fire_SelfDestruct",
	["Expose Armor"] = "Ability_Warrior_Riposte",
	["Eye for an Eye"] = "Spell_Holy_EyeforanEye",
	["Eye of Kilrogg"] = "Spell_Shadow_EvilEye",
	["Eyes of the Beast"] = "Ability_EyeOfTheOwl",
	["Fade"] = "Spell_Magic_LesserInvisibilty",
	["Faerie Fire"] = "Spell_Nature_FaerieFire",
	["Far Sight"] = "Spell_Nature_FarSight",
	["Fear Ward"] = "Spell_Holy_Excorcism",
	["Fear"] = "Spell_Shadow_Possession",
	["Feed Pet"] = "Ability_Hunter_BeastTraining",
	["Feedback"] = "Spell_Shadow_RitualOfSacrifice",
	["Feign Death"] = "Ability_Rogue_FeignDeath",
	["Feint"] = "Ability_Rogue_Feint",
	["Fel Concentration"] = "Spell_Shadow_FingerOfDeath",
	["Fel Domination"] = "Spell_Nature_RemoveCurse",
	["Fel Intellect"] = "Spell_Holy_MagicalSentry",
	["Fel Stamina"] = "Spell_Shadow_AntiShadow",
	["Felfire"] = "Spell_Fire_Fireball",
	["Feline Grace"] = "INV_Feather_01",
	["Feline Swiftness"] = "Spell_Nature_SpiritWolf",
	["Feral Aggression"] = "Ability_Druid_DemoralizingRoar",
	["Feral Charge"] = "Ability_Hunter_Pet_Bear",
	["Feral Instinct"] = "Ability_Ambush",
	["Ferocious Bite"] = "Ability_Druid_FerociousBite",
	["Ferocity"] = "INV_Misc_MonsterClaw_04",
	["Fetish"] = "INV_Misc_Horn_01",
	["Find Herbs"] = "INV_Misc_Flower_02",
	["Find Minerals"] = "Spell_Nature_Earthquake",
	["Find Treasure"] = "Racial_Dwarf_FindTreasure",
	["Fire Blast"] = "Spell_Fire_Fireball",
	["Fire Nova Totem"] = "Spell_Fire_SealOfFire",
	["Fire Power"] = "Spell_Fire_Immolation",
	["Fire Resistance Aura"] = "Spell_Fire_SealOfFire",
	["Fire Resistance Totem"] = "Spell_FireResistanceTotem_01",
	["Fire Resistance"] = "Spell_Fire_FireArmor",
	["Fire Shield"] = "Spell_Fire_FireArmor",
	["Fire Vulnerability"] = "Spell_Fire_SoulBurn",
	["Fire Ward"] = "Spell_Fire_FireArmor",
	["Fireball"] = "Spell_Fire_FlameBolt",
	["Firebolt"] = "Spell_Fire_FireBolt",
	["First Aid"] = "Spell_Holy_SealOfSacrifice",
	["Fishing Poles"] = "Trade_Fishing",
	["Fishing"] = "Trade_Fishing",
	["Fist Weapon Specialization"] = "INV_Gauntlets_04",
	["Fist Weapons"] = "INV_Gauntlets_04",
	["Flame Shock"] = "Spell_Fire_FlameShock",
	["Flame Throwing"] = "Spell_Fire_Flare",
	["Flamestrike"] = "Spell_Fire_SelfDestruct",
	["Flamethrower"] = "Spell_Fire_Incinerate",
	["Flametongue Totem"] = "Spell_Nature_GuardianWard",
	["Flametongue Weapon"] = "Spell_Fire_FlameTounge",
	["Flare"] = "Spell_Fire_Flare",
	["Flash Heal"] = "Spell_Holy_FlashHeal",
	["Flash of Light"] = "Spell_Holy_FlashHeal",
	["Flurry"] = "Ability_GhoulFrenzy",
	["Focused Casting"] = "Spell_Arcane_Blink",
	["Force of Will"] = "Spell_Nature_SlowingTotem",
	["Freezing Trap"] = "Spell_Frost_ChainsOfIce",
	["Frenzied Regeneration"] = "Ability_BullRush",
	["Frenzy"] = "INV_Misc_MonsterClaw_03",
	["Frost Armor"] = "Spell_Frost_FrostArmor02",
	["Frost Channeling"] = "Spell_Frost_Stun",
	["Frost Nova"] = "Spell_Frost_FrostNova",
	["Frost Resistance Aura"] = "Spell_Frost_WizardMark",
	["Frost Resistance Totem"] = "Spell_FrostResistanceTotem_01",
	["Frost Resistance"] = "Spell_Frost_FrostWard",
	["Frost Shock"] = "Spell_Frost_FrostShock",
	["Frost Trap"] = "Spell_Frost_FreezingBreath",
	["Frost Ward"] = "Spell_Frost_FrostWard",
	["Frostbite"] = "Spell_Frost_FrostArmor",
	["Frostbolt"] = "Spell_Frost_FrostBolt02",
	["Frostbrand Weapon"] = "Spell_Frost_FrostBrand",
	["Furious Howl"] = "Ability_Hunter_Pet_Wolf",
	["Furor"] = "Spell_Holy_BlessingOfStamina",
	["Garrote"] = "Ability_Rogue_Garrote",
	["Generic"] = "INV_Shield_09",
	["Ghost Wolf"] = "Spell_Nature_SpiritWolf",
	["Ghostly Strike"] = "Spell_Shadow_Curse",
	["Gift of Nature"] = "Spell_Nature_ProtectionformNature",
	["Gift of the Wild"] = "Spell_Nature_Regeneration",
	["Gouge"] = "Ability_Gouge",
	["Grace of Air Totem"] = "Spell_Nature_InvisibilityTotem",
	["Great Stamina"] = "Spell_Nature_UnyeildingStamina",
	["Greater Blessing of Kings"] = "Spell_Magic_GreaterBlessingofKings",
	["Greater Blessing of Light"] = "Spell_Holy_GreaterBlessingofLight",
	["Greater Blessing of Might"] = "Spell_Holy_GreaterBlessingofKings",
	["Greater Blessing of Salvation"] = "Spell_Holy_GreaterBlessingofSalvation",
	["Greater Blessing of Sanctuary"] = "Spell_Holy_GreaterBlessingofSanctuary",
	["Greater Blessing of Wisdom"] = "Spell_Holy_GreaterBlessingofWisdom",
	["Greater Heal"] = "Spell_Holy_GreaterHeal",
	["Grim Reach"] = "Spell_Shadow_CallofBone",
	["Grounding Totem"] = "Spell_Nature_GroundingTotem",
	["Grovel"] = "Temp",
	["Growl"] = "Ability_Physical_Taunt",
	["Guardian's Favor"] = "Spell_Holy_SealOfProtection",
	["Gun Specialization"] = "INV_Musket_03",
	["Guns"] = "INV_Weapon_Rifle_01",
	["Hammer of Justice"] = "Spell_Holy_SealOfMight",
	["Hammer of Wrath"] = "Ability_ThunderClap",
	["Hamstring"] = "Ability_ShockWave",
	["Harass"] = "Ability_Hunter_Harass",
	["Hardiness"] = "INV_Helmet_23",
	["Hawk Eye"] = "Ability_TownWatch",
	["Heal"] = "Spell_Holy_Heal",
	["Healing Focus"] = "Spell_Holy_HealingFocus",
	["Healing Light"] = "Spell_Holy_HolyBolt",
	["Healing Stream Totem"] = "INV_Spear_04",
	["Healing Touch"] = "Spell_Nature_HealingTouch",
	["Healing Wave"] = "Spell_Nature_MagicImmunity",
	["Health Funnel"] = "Spell_Shadow_LifeDrain",
	["Heart of the Wild"] = "Spell_Holy_BlessingOfAgility",
	["Hellfire Effect"] = "Spell_Fire_Incinerate",
	["Hellfire"] = "Spell_Fire_Incinerate",
	["Hemorrhage"] = "Spell_Shadow_LifeDrain",
	["Herbalism"] = "Spell_Nature_NatureTouchGrow",
	["Herb Gathering"] = "Spell_Nature_NatureTouchGrow",
	["Heroic Strike"] = "Ability_Rogue_Ambush",
	["Hex of Weakness"] = "Spell_Shadow_FingerOfDeath",
	["Hibernate"] = "Spell_Nature_Sleep",
	["Holy Fire"] = "Spell_Holy_SearingLight",
	["Holy Light"] = "Spell_Holy_HolyBolt",
	["Holy Nova"] = "Spell_Holy_HolyNova",
	["Holy Power"] = "Spell_Holy_Power",
	["Holy Reach"] = "Spell_Holy_Purify",
	["Holy Shield"] = "Spell_Holy_BlessingOfProtection",
	["Holy Shock"] = "Spell_Holy_SearingLight",
	["Holy Specialization"] = "Spell_Holy_SealOfSalvation",
	["Holy Wrath"] = "Spell_Holy_Excorcism",
	["Honorless Target"] = "Spell_Magic_LesserInvisibilty",
	["Horse Riding"] = "Spell_Nature_Swiftness",
	["Howl of Terror"] = "Spell_Shadow_DeathScream",
	["Humanoid Slaying"] = "Spell_Holy_PrayerOfHealing",
	["Hunter's Mark"] = "Ability_Hunter_SniperShot",
	["Hurricane"] = "Spell_Nature_Cyclone",
	["Ice Armor"] = "Spell_Frost_FrostArmor02",
	["Ice Barrier"] = "Spell_Ice_Lament",
	["Ice Block"] = "Spell_Frost_Frost",
	["Ice Shards"] = "Spell_Frost_IceShard",
	["Ignite"] = "Spell_Fire_Incinerate",
	["Illumination"] = "Spell_Holy_GreaterHeal",
	["Immolate"] = "Spell_Fire_Immolation",
	["Immolation Trap Effect"] = "Spell_Fire_FlameShock",
	["Immolation Trap"] = "Spell_Fire_FlameShock",
	["Impact"] = "Spell_Fire_MeteorStorm",
	["Impale"] = "Ability_SearingArrow",
	["Improved Ambush"] = "Ability_Rogue_Ambush",
	["Improved Arcane Explosion"] = "Spell_Nature_WispSplode",
	["Improved Arcane Missiles"] = "Spell_Nature_StarFall",
	["Improved Arcane Shot"] = "Ability_ImpalingBolt",
	["Improved Aspect of the Hawk"] = "Spell_Nature_RavenForm",
	["Improved Aspect of the Monkey"] = "Ability_Hunter_AspectOfTheMonkey",
	["Improved Backstab"] = "Ability_BackStab",
	["Improved Battle Shout"] = "Ability_Warrior_BattleShout",
	["Improved Berserker Rage"] = "Spell_Nature_AncestralGuardian",
	["Improved Blessing of Might"] = "Spell_Holy_FistOfJustice",
	["Improved Blessing of Wisdom"] = "Spell_Holy_SealOfWisdom",
	["Improved Blizzard"] = "Spell_Frost_IceStorm",
	["Improved Bloodrage"] = "Ability_Racial_BloodRage",
	["Improved Chain Heal"] = "Spell_Nature_HealingWaveGreater",
	["Improved Chain Lightning"] = "Spell_Nature_ChainLightning",
	["Improved Challenging Shout"] = "Ability_Warrior_Challange",
	["Improved Charge"] = "Ability_Warrior_Charge",
	["Improved Cheap Shot"] = "Ability_CheapShot",
	["Improved Cleave"] = "Ability_Warrior_Cleave",
	["Improved Concentration Aura"] = "Spell_Holy_MindSooth",
	["Improved Concussive Shot"] = "Spell_Frost_Stun",
	["Improved Cone of Cold"] = "Spell_Frost_Glacier",
	["Improved Corruption"] = "Spell_Shadow_AbominationExplosion",
	["Improved Counterspell"] = "Spell_Frost_IceShock",
	["Improved Curse of Agony"] = "Spell_Shadow_CurseOfSargeras",
	["Improved Curse of Exhaustion"] = "Spell_Shadow_GrimWard",
	["Improved Curse of Weakness"] = "Spell_Shadow_CurseOfMannoroth",
	["Improved Dampen Magic"] = "Spell_Nature_AbolishMagic",
	["Improved Deadly Poison"] = "Ability_Rogue_DualWeild",
	["Improved Demoralizing Shout"] = "Ability_Warrior_WarCry",
	["Improved Devotion Aura"] = "Spell_Holy_DevotionAura",
	["Improved Disarm"] = "Ability_Warrior_Disarm",
	["Improved Distract"] = "Ability_Rogue_Distract",
	["Improved Drain Life"] = "Spell_Shadow_LifeDrain02",
	["Improved Drain Mana"] = "Spell_Shadow_SiphonMana",
	["Improved Drain Soul"] = "Spell_Shadow_Haunting",
	["Improved Enrage"] = "Ability_Druid_Enrage",
	["Improved Enslave Demon"] = "Spell_Shadow_EnslaveDemon",
	["Improved Entangling Roots"] = "Spell_Nature_StrangleVines",
	["Improved Evasion"] = "Spell_Shadow_ShadowWard",
	["Improved Eviscerate"] = "Ability_Rogue_Eviscerate",
	["Improved Execute"] = "INV_Sword_48",
	["Improved Expose Armor"] = "Ability_Warrior_Riposte",
	["Improved Eyes of the Beast"] = "Ability_EyeOfTheOwl",
	["Improved Fade"] = "Spell_Magic_LesserInvisibilty",
	["Improved Feign Death"] = "Ability_Rogue_FeignDeath",
	["Improved Fire Blast"] = "Spell_Fire_Fireball",
	["Improved Fire Nova Totem"] = "Spell_Fire_SealOfFire",
	["Improved Fire Ward"] = "Spell_Fire_FireArmor",
	["Improved Fireball"] = "Spell_Fire_FlameBolt",
	["Improved Firebolt"] = "Spell_Fire_FireBolt",
	["Improved Firestone"] = "INV_Ammo_FireTar",
	["Improved Flamestrike"] = "Spell_Fire_SelfDestruct",
	["Improved Flametongue Weapon"] = "Spell_Fire_FlameTounge",
	["Improved Flash of Light"] = "Spell_Holy_FlashHeal",
	["Improved Frost Nova"] = "Spell_Frost_FreezingBreath",
	["Improved Frost Ward"] = "Spell_Frost_FrostWard",
	["Improved Frostbolt"] = "Spell_Frost_FrostBolt02",
	["Improved Frostbrand Weapon"] = "Spell_Frost_FrostBrand",
	["Improved Garrote"] = "Ability_Rogue_Garrote",
	["Improved Ghost Wolf"] = "Spell_Nature_SpiritWolf",
	["Improved Gouge"] = "Ability_Gouge",
	["Improved Grace of Air Totem"] = "Spell_Nature_InvisibilityTotem",
	["Improved Grounding Totem"] = "Spell_Nature_GroundingTotem",
	["Improved Hammer of Justice"] = "Spell_Holy_SealOfMight",
	["Improved Hamstring"] = "Ability_ShockWave",
	["Improved Healing Stream Totem"] = "INV_Spear_04",
	["Improved Healing Touch"] = "Spell_Nature_HealingTouch",
	["Improved Healing Wave"] = "Spell_Nature_MagicImmunity",
	["Improved Healing"] = "Spell_Holy_Heal02",
	["Improved Health Funnel"] = "Spell_Shadow_LifeDrain",
	["Improved Healthstone"] = "INV_Stone_04",
	["Improved Heroic Strike"] = "Ability_Rogue_Ambush",
	["Improved Hunter's Mark"] = "Ability_Hunter_SniperShot",
	["Improved Immolate"] = "Spell_Fire_Immolation",
	["Improved Imp"] = "Spell_Shadow_SummonImp",
	["Improved Inner Fire"] = "Spell_Holy_InnerFire",
	["Improved Instant Poison"] = "Ability_Poisons",
	["Improved Intercept"] = "Ability_Rogue_Sprint",
	["Improved Intimidating Shout"] = "Ability_GolemThunderClap",
	["Improved Judgement"] = "Spell_Holy_RighteousFury",
	["Improved Kick"] = "Ability_Kick",
	["Improved Kidney Shot"] = "Ability_Rogue_KidneyShot",
	["Improved Lash of Pain"] = "Spell_Shadow_Curse",
	["Improved Lay on Hands"] = "Spell_Holy_LayOnHands",
	["Improved Lesser Healing Wave"] = "Spell_Nature_HealingWaveLesser",
	["Improved Life Tap"] = "Spell_Shadow_BurningSpirit",
	["Improved Lightning Bolt"] = "Spell_Nature_Lightning",
	["Improved Lightning Shield"] = "Spell_Nature_LightningShield",
	["Improved Magma Totem"] = "Spell_Fire_SelfDestruct",
	["Improved Mana Burn"] = "Spell_Shadow_ManaBurn",
	["Improved Mana Shield"] = "Spell_Shadow_DetectLesserInvisibility",
	["Improved Mana Spring Totem"] = "Spell_Nature_ManaRegenTotem",
	["Improved Mark of the Wild"] = "Spell_Nature_Regeneration",
	["Improved Mend Pet"] = "Ability_Hunter_MendPet",
	["Improved Mind Blast"] = "Spell_Shadow_UnholyFrenzy",
	["Improved Moonfire"] = "Spell_Nature_StarFall",
	["Improved Nature's Grasp"] = "Spell_Nature_NaturesWrath",
	["Improved Overpower"] = "INV_Sword_05",
	["Improved Power Word: Fortitude"] = "Spell_Holy_WordFortitude",
	["Improved Power Word: Shield"] = "Spell_Holy_PowerWordShield",
	["Improved Prayer of Healing"] = "Spell_Holy_PrayerOfHealing02",
	["Improved Psychic Scream"] = "Spell_Shadow_PsychicScream",
	["Improved Pummel"] = "INV_Gauntlets_04",
	["Improved Regrowth"] = "Spell_Nature_ResistNature",
	["Improved Reincarnation"] = "Spell_Nature_Reincarnation",
	["Improved Rejuvenation"] = "Spell_Nature_Rejuvenation",
	["Improved Rend"] = "Ability_Gouge",
	["Improved Renew"] = "Spell_Holy_Renew",
	["Improved Retribution Aura"] = "Spell_Holy_AuraOfLight",
	["Improved Revenge"] = "Ability_Warrior_Revenge",
	["Improved Revive Pet"] = "Ability_Hunter_BeastSoothe",
	["Improved Righteous Fury"] = "Spell_Holy_SealOfFury",
	["Improved Rockbiter Weapon"] = "Spell_Nature_RockBiter",
	["Improved Rupture"] = "Ability_Rogue_Rupture",
	["Improved Sap"] = "Ability_Sap",
	["Improved Scorch"] = "Spell_Fire_SoulBurn",
	["Improved Scorpid Sting"] = "Ability_Hunter_CriticalShot",
	["Improved Seal of Righteousness"] = "Ability_ThunderBolt",
	["Improved Seal of the Crusader"] = "Spell_Holy_HolySmite",
	["Improved Searing Pain"] = "Spell_Fire_SoulBurn",
	["Improved Searing Totem"] = "Spell_Fire_SearingTotem",
	["Improved Serpent Sting"] = "Ability_Hunter_Quickshot",
	["Improved Shadow Bolt"] = "Spell_Shadow_ShadowBolt",
	["Improved Shadow Word: Pain"] = "Spell_Shadow_ShadowWordPain",
	["Improved Shield Bash"] = "Ability_Warrior_ShieldBash",
	["Improved Shield Block"] = "Ability_Defend",
	["Improved Shield Wall"] = "Ability_Warrior_ShieldWall",
	["Improved Shred"] = "Spell_Shadow_VampiricAura",
	["Improved Sinister Strike"] = "Spell_Shadow_RitualOfSacrifice",
	["Improved Slam"] = "Ability_Warrior_DecisiveStrike",
	["Improved Slice and Dice"] = "Ability_Rogue_SliceDice",
	["Improved Spellstone"] = "INV_Misc_Gem_Sapphire_01",
	["Improved Sprint"] = "Ability_Rogue_Sprint",
	["Improved Starfire"] = "Spell_Arcane_StarFire",
	["Improved Stoneclaw Totem"] = "Spell_Nature_StoneClawTotem",
	["Improved Stoneskin Totem"] = "Spell_Nature_StoneSkinTotem",
	["Improved Strength of Earth Totem"] = "Spell_Nature_EarthBindTotem",
	["Improved Succubus"] = "Spell_Shadow_SummonSuccubus",
	["Improved Sunder Armor"] = "Ability_Warrior_Sunder",
	["Improved Taunt"] = "Spell_Nature_Reincarnation",
	["Improved Thorns"] = "Spell_Nature_Thorns",
	["Improved Thunder Clap"] = "Ability_ThunderClap",
	["Improved Tranquility"] = "Spell_Nature_Tranquility",
	["Improved Vampiric Embrace"] = "Spell_Shadow_ImprovedVampiricEmbrace",
	["Improved Vanish"] = "Ability_Vanish",
	["Improved Voidwalker"] = "Spell_Shadow_SummonVoidWalker",
	["Improved Windfury Weapon"] = "Spell_Nature_Cyclone",
	["Improved Wing Clip"] = "Ability_Rogue_Trip",
	["Improved Wrath"] = "Spell_Nature_AbolishMagic",
	["Incinerate"] = "Spell_Fire_FlameShock",
	["Inferno"] = "Spell_Shadow_SummonInfernal",
	["Initiative"] = "Spell_Shadow_Fumble",
	["Inner Fire"] = "Spell_Holy_InnerFire",
	["Inner Focus"] = "Spell_Frost_WindWalkOn",
	["Innervate"] = "Spell_Nature_Lightning",
	["Insect Swarm"] = "Spell_Nature_InsectSwarm",
	["Inspiration"] = "Spell_Holy_LayOnHands",
	["Instant Poison II"] = "Ability_Poisons",
	["Instant Poison III"] = "Ability_Poisons",
	["Instant Poison IV"] = "Ability_Poisons",
	["Instant Poison V"] = "Ability_Poisons",
	["Instant Poison VI"] = "Ability_Poisons",
	["Instant Poison"] = "Ability_Poisons",
	["Intensity"] = "Spell_Fire_LavaSpawn",
	["Intercept"] = "Ability_Rogue_Sprint",
	["Intimidating Shout"] = "Ability_GolemThunderClap",
	["Intimidation"] = "Ability_Devour",
	["Iron Will"] = "Spell_Magic_MageArmor",
	["Judgement of Command"] = "Ability_Warrior_InnerRage",
	["Judgement of Justice"] = "Spell_Holy_SealOfWrath",
	["Judgement of Light"] = "Spell_Holy_HealingAura",
	["Judgement of Righteousness"] = "Ability_ThunderBolt",
	["Judgement of Wisdom"] = "Spell_Holy_RighteousnessAura",
	["Judgement of the Crusader"] = "Spell_Holy_HolySmite",
	["Judgement"] = "Spell_Holy_RighteousFury",
	["Kick"] = "Ability_Kick",
	["Kidney Shot"] = "Ability_Rogue_KidneyShot",
	["Killer Instinct"] = "Spell_Holy_BlessingOfStamina",
	["Kodo Riding"] = "Spell_Nature_Swiftness",
	["Lash of Pain"] = "Spell_Shadow_Curse",
	["Last Stand"] = "Spell_Holy_AshesToAshes",
	["Lasting Judgement"] = "Spell_Holy_HealingAura",
	["Lay on Hands"] = "Spell_Holy_LayOnHands",
	["Leader of the Pack"] = "Spell_Nature_UnyeildingStamina",
	["Leather"] = "INV_Chest_Leather_09",
	["Leatherworking"] = "INV_Misc_ArmorKit_17",
	["Lesser Heal"] = "Spell_Holy_LesserHeal",
	["Lesser Healing Wave"] = "Spell_Nature_HealingWaveLesser",
	["Lesser Invisibility"] = "Spell_Magic_LesserInvisibilty",
	["Lethal Shots"] = "Ability_SearingArrow",
	["Lethality"] = "Ability_CriticalStrike",
	["Levitate"] = "Spell_Holy_LayOnHands",
	["Libram"] = "INV_Misc_Book_11",
	["Life Tap"] = "Spell_Shadow_BurningSpirit",
	["Lightning Bolt"] = "Spell_Nature_Lightning",
	["Lightning Breath"] = "Spell_Nature_Lightning",
	["Lightning Mastery"] = "Spell_Lightning_LightningBolt01",
	["Lightning Reflexes"] = "Spell_Nature_Invisibilty",
	["Lightning Shield"] = "Spell_Nature_LightningShield",
	["Lightwell Renew"] = "Spell_Holy_SummonLightwell",
	["Lightwell"] = "Spell_Holy_SummonLightwell",
	["Long Daze"] = "Spell_Frost_Stun",
	["Mace Specialization"] = "INV_Mace_01",
	["Mace Stun Effect"] = "Spell_Frost_Stun",
	["Mage Armor"] = "Spell_MageArmor",
	["Magma Totem"] = "Spell_Fire_SelfDestruct",
	["Mail"] = "INV_Chest_Chain_05",
	["Malice"] = "Ability_Racial_BloodRage",
	["Mana Burn"] = "Spell_Shadow_ManaBurn",
	["Mana Shield"] = "Spell_Shadow_DetectLesserInvisibility",
	["Mana Spring Totem"] = "Spell_Nature_ManaRegenTotem",
	["Mana Tide Totem"] = "Spell_Frost_SummonWaterElemental",
	["Mangle"] = "Ability_Druid_Mangle.tga",
	["Mark of the Wild"] = "Spell_Nature_Regeneration",
	["Martyrdom"] = "Spell_Nature_Tranquility",
	["Master Demonologist"] = "Spell_Shadow_ShadowPact",
	["Master Summoner"] = "Spell_Shadow_ImpPhaseShift",
	["Master of Deception"] = "Spell_Shadow_Charm",
	["Maul"] = "Ability_Druid_Maul",
	["Mechanostrider Piloting"] = "Spell_Nature_Swiftness",
	["Meditation"] = "Spell_Nature_Sleep",
	["Melee Specialization"] = "INV_Axe_02",
	["Mend Pet"] = "Ability_Hunter_MendPet",
	["Mental Agility"] = "Ability_Hibernation",
	["Mental Strength"] = "Spell_Nature_EnchantArmor",
	["Mind Blast"] = "Spell_Shadow_UnholyFrenzy",
	["Mind Control"] = "Spell_Shadow_ShadowWordDominate",
	["Mind Flay"] = "Spell_Shadow_SiphonMana",
	["Mind Soothe"] = "Spell_Holy_MindSooth",
	["Mind Vision"] = "Spell_Holy_MindVision",
	["Mind-numbing Poison II"] = "Spell_Nature_NullifyDisease",
	["Mind-numbing Poison III"] = "Spell_Nature_NullifyDisease",
	["Mind-numbing Poison"] = "Spell_Nature_NullifyDisease",
	["Mining"] = "Trade_Mining",
	["Mocking Blow"] = "Ability_Warrior_PunishingBlow",
	["Mongoose Bite"] = "Ability_Hunter_SwiftStrike",
	["Monster Slaying"] = "INV_Misc_Head_Dragon_Black",
	["Moonfire"] = "Spell_Nature_StarFall",
	["Moonfury"] = "Spell_Nature_MoonGlow",
	["Moonglow"] = "Spell_Nature_Sentinal",
	["Moonkin Aura"] = "Spell_Nature_MoonGlow",
	["Moonkin Form"] = "Spell_Nature_ForceOfNature",
	["Mortal Shots"] = "Ability_PierceDamage",
	["Mortal Strike"] = "Ability_Warrior_SavageBlow",
	["Multi-Shot"] = "Ability_UpgradeMoonGlaive",
	["Murder"] = "Spell_Shadow_DeathScream",
	["Natural Armor"] = "Spell_Nature_SpiritArmor",
	["Natural Shapeshifter"] = "Spell_Nature_WispSplode",
	["Natural Weapons"] = "INV_Staff_01",
	["Nature Resistance Totem"] = "Spell_Nature_NatureResistanceTotem",
	["Nature Resistance"] = "Spell_Nature_ResistNature",
	["Nature's Focus"] = "Spell_Nature_HealingWaveGreater",
	["Nature's Grace"] = "Spell_Nature_NaturesBlessing",
	["Nature's Grasp"] = "Spell_Nature_NaturesWrath",
	["Nature's Reach"] = "Spell_Nature_NatureTouchGrow",
	["Nature's Swiftness"] = "Spell_Nature_RavenForm",
	["Nightfall"] = "Spell_Shadow_Twilight",
	["Omen of Clarity"] = "Spell_Nature_CrystalBall",
	["One-Handed Axes"] = "INV_Axe_01",
	["One-Handed Maces"] = "INV_Mace_01",
	["One-Handed Swords"] = "Ability_MeleeDamage",
	["One-Handed Weapon Specialization"] = "INV_Sword_20",
	["Opening - No Text"] = "Trade_Engineering",
	["Opening"] = "Trade_Engineering",
	["Opportunity"] = "Ability_Warrior_WarCry",
	["Overpower"] = "Ability_MeleeDamage",
	["Paranoia"] = "Spell_Shadow_AuraOfDarkness",
	["Parry"] = "Ability_Parry",
	["Pathfinding"] = "Ability_Mount_JungleTiger",
	["Perception"] = "Spell_Nature_Sleep",
	["Permafrost"] = "Spell_Frost_Wisp",
	["Pet Aggression"] = "Ability_Druid_Maul",
	["Pet Hardiness"] = "Ability_BullRush",
	["Pet Recovery"] = "Ability_Hibernation",
	["Pet Resistance"] = "Spell_Holy_BlessingOfAgility",
	["Phase Shift"] = "Spell_Shadow_ImpPhaseShift",
	["Pick Lock"] = "Spell_Nature_MoonKey",
	["Pick Pocket"] = "INV_Misc_Bag_11",
	["Piercing Howl"] = "Spell_Shadow_DeathScream",
	["Piercing Ice"] = "Spell_Frost_Frostbolt",
	["Plate Mail"] = "INV_Chest_Plate01",
	["Poison Cleansing Totem"] = "Spell_Nature_PoisonCleansingTotem",
	["Poisons"] = "Trade_BrewPoison",
	["Polearm Specialization"] = "INV_Weapon_Halbard_01",
	["Polearms"] = "INV_Spear_06",
	["Polymorph"] = "Spell_Nature_Polymorph",
	["Polymorph: Pig"] = "Spell_Magic_PolymorphPig",
	["Polymorph: Turtle"] = "Ability_Hunter_Pet_Turtle",
	["Portal: Darnassus"] = "Spell_Arcane_PortalDarnassus",
	["Portal: Ironforge"] = "Spell_Arcane_PortalIronForge",
	["Portal: Orgrimmar"] = "Spell_Arcane_PortalOrgrimmar",
	["Portal: Stormwind"] = "Spell_Arcane_PortalStormWind",
	["Portal: Thunder Bluff"] = "Spell_Arcane_PortalThunderBluff",
	["Portal: Undercity"] = "Spell_Arcane_PortalUnderCity",
	["Pounce Bleed"] = "Ability_Druid_SupriseAttack",
	["Pounce"] = "Ability_Druid_SupriseAttack",
	["Power Infusion"] = "Spell_Holy_PowerInfusion",
	["Power Word: Fortitude"] = "Spell_Holy_WordFortitude",
	["Power Word: Shield"] = "Spell_Holy_PowerWordShield",
	["Prayer of Fortitude"] = "Spell_Holy_PrayerOfFortitude",
	["Prayer of Healing"] = "Spell_Holy_PrayerOfHealing02",
	["Prayer of Shadow Protection"] = "Spell_Holy_PrayerofShadowProtection",
	["Prayer of Spirit"] = "Spell_Holy_PrayerofSpirit",
	["Precision"] = "Ability_Marksmanship",
	["Predatory Strikes"] = "Ability_Hunter_Pet_Cat",
	["Premeditation"] = "Spell_Shadow_Possession",
	["Preparation"] = "Spell_Shadow_AntiShadow",
	["Presence of Mind"] = "Spell_Nature_EnchantArmor",
	["Primal Fury"] = "Ability_Racial_Cannibalize",
	["Prowl"] = "Ability_Druid_SupriseAttack",
	["Psychic Scream"] = "Spell_Shadow_PsychicScream",
	["Pummel"] = "INV_Gauntlets_04",
	["Purge"] = "Spell_Nature_Purge",
	["Purification"] = "Spell_Frost_WizardMark",
	["Purify"] = "Spell_Holy_Purify",
	["Pursuit of Justice"] = "Spell_Holy_PersuitofJustice",
	["Pyroblast"] = "Spell_Fire_Fireball02",
	["Pyroclasm"] = "Spell_Fire_Volcano",
	["Quickness"] = "Ability_Racial_ShadowMeld",
	["Rain of Fire"] = "Spell_Shadow_RainOfFire",
	["Rake"] = "Ability_Druid_Disembowel",
	["Ram Riding"] = "Spell_Nature_Swiftness",
	["Ranged Weapon Specialization"] = "INV_Weapon_Rifle_06",
	["Rapid Concealment"] = "Ability_Ambush",
	["Rapid Fire"] = "Ability_Hunter_RunningShot",
	["Raptor Riding"] = "Spell_Nature_Swiftness",
	["Raptor Strike"] = "Ability_MeleeDamage",
	["Ravage"] = "Ability_Druid_Ravage",
	["Readiness"] = "Spell_Nature_Sleep",
	["Rebirth"] = "Spell_Nature_Reincarnation",
	["Recklessness"] = "Ability_CriticalStrike",
	["Reckoning"] = "Spell_Holy_BlessingOfStrength",
	["Redemption"] = "Spell_Holy_Resurrection",
	["Redoubt"] = "Ability_Defend",
	["Reflection"] = "Spell_Frost_WindWalkOn",
	["Regeneration"] = "Spell_Nature_Regenerate",
	["Regrowth"] = "Spell_Nature_ResistNature",
	["Reincarnation"] = "Spell_Nature_Reincarnation",
	["Rejuvenation"] = "Spell_Nature_Rejuvenation",
	["Relentless Strikes"] = "Ability_Warrior_DecisiveStrike",
	["Remorseless Attacks"] = "Ability_FiegnDead",
	["Remove Curse"] = "Spell_Holy_RemoveCurse",
	["Remove Insignia"] = "Temp",
	["Remove Lesser Curse"] = "Spell_Nature_RemoveCurse",
	["Rend"] = "Ability_Gouge",
	["Renew"] = "Spell_Holy_Renew",
	["Repentance"] = "Spell_Holy_PrayerOfHealing",
	["Resurrection"] = "Spell_Holy_Resurrection",
	["Retaliation"] = "Ability_Warrior_Challange",
	["Retribution Aura"] = "Spell_Holy_AuraOfLight",
	["Revenge Stun"] = "Ability_Warrior_Revenge",
	["Revenge"] = "Ability_Warrior_Revenge",
	["Reverberation"] = "Spell_Frost_FrostWard",
	["Revive Pet"] = "Ability_Hunter_BeastSoothe",
	["Righteous Fury"] = "Spell_Holy_SealOfFury",
	["Rip"] = "Ability_GhoulFrenzy",
	["Riposte"] = "Ability_Warrior_Challange",
	["Ritual of Doom Effect"] = "Spell_Arcane_PortalDarnassus",
	["Ritual of Doom"] = "Spell_Shadow_AntiMagicShell",
	["Ritual of Summoning"] = "Spell_Shadow_Twilight",
	["Rockbiter Weapon"] = "Spell_Nature_RockBiter",
	["Rogue Passive"] = "Ability_Stealth",
	["Ruin"] = "Spell_Shadow_ShadowWordPain",
	["Rupture"] = "Ability_Rogue_Rupture",
	["Ruthlessness"] = "Ability_Druid_Disembowel",
	["Sacrifice"] = "Spell_Shadow_SacrificialShield",
	["Safe Fall"] = "INV_Feather_01",
	["Sanctity Aura"] = "Spell_Holy_MindVision",
	["Sap"] = "Ability_Sap",
	["Savage Fury"] = "Ability_Druid_Ravage",
	["Savage Strikes"] = "Ability_Racial_BloodRage",
	["Scare Beast"] = "Ability_Druid_Cower",
	["Scatter Shot"] = "Ability_GolemStormBolt",
	["Scorch"] = "Spell_Fire_SoulBurn",
	["Scorpid Poison"] = "Ability_PoisonSting",
	["Scorpid Sting"] = "Ability_Hunter_CriticalShot",
	["Screech"] = "Ability_Hunter_Pet_Bat",
	["Seal Fate"] = "Spell_Shadow_ChillTouch",
	["Seal of Command"] = "Ability_Warrior_InnerRage",
	["Seal of Justice"] = "Spell_Holy_SealOfWrath",
	["Seal of Light"] = "Spell_Holy_HealingAura",
	["Seal of Righteousness"] = "Ability_ThunderBolt",
	["Seal of Wisdom"] = "Spell_Holy_RighteousnessAura",
	["Seal of the Crusader"] = "Spell_Holy_HolySmite",
	["Searing Light"] = "Spell_Holy_SearingLightPriest",
	["Searing Pain"] = "Spell_Fire_SoulBurn",
	["Searing Totem"] = "Spell_Fire_SearingTotem",
	["Seduction"] = "Spell_Shadow_MindSteal",
	["Sense Demons"] = "Spell_Shadow_Metamorphosis",
	["Sense Undead"] = "Spell_Holy_SenseUndead",
	["Sentry Totem"] = "Spell_Nature_RemoveCurse",
	["Serpent Sting"] = "Ability_Hunter_Quickshot",
	["Setup"] = "Spell_Nature_MirrorImage",
	["Shackle Undead"] = "Spell_Nature_Slow",
	["Shadow Affinity"] = "Spell_Shadow_ShadowWard",
	["Shadow Bolt"] = "Spell_Shadow_ShadowBolt",
	["Shadow Focus"] = "Spell_Shadow_BurningSpirit",
	["Shadow Mastery"] = "Spell_Shadow_ShadeTrueSight",
	["Shadow Protection"] = "Spell_Shadow_AntiShadow",
	["Shadow Reach"] = "Spell_Shadow_ChillTouch",
	["Shadow Resistance Aura"] = "Spell_Shadow_SealOfKings",
	["Shadow Resistance"] = "Spell_Shadow_AntiShadow",
	["Shadow Trance"] = "Spell_Shadow_Twilight",
	["Shadow Ward"] = "Spell_Shadow_AntiShadow",
	["Shadow Weaving"] = "Spell_Shadow_BlackPlague",
	["Shadow Word: Pain"] = "Spell_Shadow_ShadowWordPain",
	["Shadowburn"] = "Spell_Shadow_ScourgeBuild",
	["Shadowform"] = "Spell_Shadow_Shadowform",
	["Shadowguard"] = "Spell_Nature_LightningShield",
	["Shadowmeld Passive"] = "Ability_Ambush",
	["Shadowmeld"] = "Ability_Ambush",
	["Sharpened Claws"] = "INV_Misc_MonsterClaw_04",
	["Shatter"] = "Spell_Frost_FrostShock",
	["Shell Shield"] = "Ability_Hunter_Pet_Turtle",
	["Shield Bash"] = "Ability_Warrior_ShieldBash",
	["Shield Block"] = "Ability_Defend",
	["Shield Slam"] = "INV_Shield_05",
	["Shield Specialization"] = "INV_Shield_06",
	["Shield Wall"] = "Ability_Warrior_ShieldWall",
	["Shield"] = "INV_Shield_04",
	["Shoot Bow"] = "Ability_Marksmanship",
	["Shoot Crossbow"] = "Ability_Marksmanship",
	["Shoot Gun"] = "Ability_Marksmanship",
	["Shoot"] = "Ability_ShootWand",
	["Shred"] = "Spell_Shadow_VampiricAura",
	["Silence"] = "Spell_Shadow_ImpPhaseShift",
	["Silent Resolve"] = "Spell_Nature_ManaRegenTotem",
	["Sinister Strike"] = "Spell_Shadow_RitualOfSacrifice",
	["Siphon Life"] = "Spell_Shadow_Requiem",
	["Skinning"] = "INV_Misc_Pelt_Wolf_01",
	["Slam"] = "Ability_Warrior_DecisiveStrike",
	["Slice and Dice"] = "Ability_Rogue_SliceDice",
	["Slow Fall"] = "Spell_Magic_FeatherFall",
	["Smelting"] = "Spell_Fire_FlameBlades",
	["Smite"] = "Spell_Holy_HolySmite",
	["Soothe Animal"] = "Ability_Hunter_BeastSoothe",
	["Soothing Kiss"] = "Spell_Shadow_SoothingKiss",
	["Soul Fire"] = "Spell_Fire_Fireball02",
	["Soul Link"] = "Spell_Shadow_GatherShadows",
	["Soulstone Resurrection"] = "INV_Misc_Orb_04",
	["Spell Lock"] = "Spell_Shadow_MindRot",
	["Spell Warding"] = "Spell_Holy_SpellWarding",
	["Spirit Bond"] = "Ability_Druid_DemoralizingRoar",
	["Spirit Tap"] = "Spell_Shadow_Requiem",
	["Spirit of Redemption"] = "INV_Enchant_EssenceEternalLarge",
	["Spiritual Focus"] = "Spell_Arcane_Blink",
	["Spiritual Guidance"] = "Spell_Holy_SpiritualGuidence",
	["Spiritual Healing"] = "Spell_Nature_MoonGlow",
	["Sprint"] = "Ability_Rogue_Sprint",
	["Starfire"] = "Spell_Arcane_StarFire",
	["Starshards"] = "Spell_Arcane_StarFire",
	["Staves"] = "INV_Staff_08",
	["Stealth"] = "Ability_Stealth",
	["Stoneclaw Totem"] = "Spell_Nature_StoneClawTotem",
	["Stoneform"] = "Spell_Shadow_UnholyStrength",
	["Stoneskin Totem"] = "Spell_Nature_StoneSkinTotem",
	["Stormstrike"] = "Spell_Holy_SealOfMight",
	["Strength of Earth Totem"] = "Spell_Nature_EarthBindTotem",
	["Stuck"] = "Spell_Shadow_Teleport",
	["Subtlety"] = "Ability_EyeOfTheOwl",
	["Suffering"] = "Spell_Shadow_BlackPlague",
	["Summon Charger"] = "Ability_Mount_Charger",
	["Summon Dreadsteed"] = "Ability_Mount_Dreadsteed",
	["Summon Felhunter"] = "Spell_Shadow_SummonFelHunter",
	["Summon Felsteed"] = "Spell_Nature_Swiftness",
	["Summon Imp"] = "Spell_Shadow_SummonImp",
	["Summon Succubus"] = "Spell_Shadow_SummonSuccubus",
	["Summon Voidwalker"] = "Spell_Shadow_SummonVoidWalker",
	["Summon Warhorse"] = "Spell_Nature_Swiftness",
	["Sunder Armor"] = "Ability_Warrior_Sunder",
	["Suppression"] = "Spell_Shadow_UnsummonBuilding",
	["Surefooted"] = "Ability_Kick",
	["Survivalist"] = "Spell_Shadow_Twilight",
	["Sweeping Strikes"] = "Ability_Rogue_SliceDice",
	["Swipe"] = "INV_Misc_MonsterClaw_03",
	["Sword Specialization"] = "INV_Sword_27",
	["Tactical Mastery"] = "Spell_Nature_EnchantArmor",
	["Tailoring"] = "Trade_Tailoring",
	["Tainted Blood"] = "Spell_Shadow_LifeDrain",
	["Tame Beast"] = "Ability_Hunter_BeastTaming",
	["Tamed Pet Passive"] = "Ability_Mount_PinkTiger",
	["Taunt"] = "Spell_Nature_Reincarnation",
	["Teleport: Darnassus"] = "Spell_Arcane_TeleportDarnassus",
	["Teleport: Ironforge"] = "Spell_Arcane_TeleportIronForge",
	["Teleport: Moonglade"] = "Spell_Arcane_TeleportMoonglade",
	["Teleport: Orgrimmar"] = "Spell_Arcane_TeleportOrgrimmar",
	["Teleport: Stormwind"] = "Spell_Arcane_TeleportStormWind",
	["Teleport: Thunder Bluff"] = "Spell_Arcane_TeleportThunderBluff",
	["Teleport: Undercity"] = "Spell_Arcane_TeleportUnderCity",
	["The Human Spirit"] = "INV_Enchant_ShardBrilliantSmall",
	["Thick Hide"] = "INV_Misc_Pelt_Bear_03",
	["Thorns"] = "Spell_Nature_Thorns",
	["Throw"] = "Ability_Throw",
	["Throwing Specialization"] = "INV_ThrowingAxe_03",
	["Throwing Weapon Specialization"] = "INV_ThrowingKnife_01",
	["Thrown"] = "INV_ThrowingKnife_02",
	["Thunder Clap"] = "Spell_Nature_ThunderClap",
	["Thundering Strikes"] = "Ability_ThunderBolt",
	["Thunderstomp"] = "Ability_Hunter_Pet_Gorilla",
	["Tidal Focus"] = "Spell_Frost_ManaRecharge",
	["Tidal Mastery"] = "Spell_Nature_Tranquility",
	["Tiger Riding"] = "Spell_Nature_Swiftness",
	["Tiger's Fury"] = "Ability_Mount_JungleTiger",
	["Torment"] = "Spell_Shadow_GatherShadows",
	["Totem"] = "Spell_Nature_StoneClawTotem",
	["Totemic Focus"] = "Spell_Nature_MoonGlow",
	["Touch of Weakness"] = "Spell_Shadow_DeadofNight",
	["Toughness"] = "Spell_Holy_Devotion",
	["Track Beasts"] = "Ability_Tracking",
	["Track Demons"] = "Spell_Shadow_SummonFelHunter",
	["Track Dragonkin"] = "INV_Misc_Head_Dragon_01",
	["Track Elementals"] = "Spell_Frost_SummonWaterElemental",
	["Track Giants"] = "Ability_Racial_Avatar",
	["Track Hidden"] = "Ability_Stealth",
	["Track Humanoids"] = "Ability_Tracking",
	["Track Undead"] = "Spell_Shadow_DarkSummoning",
	["Tranquil Air Totem"] = "Spell_Nature_Brilliance",
	["Tranquil Spirit"] = "Spell_Holy_ElunesGrace",
	["Tranquility"] = "Spell_Nature_Tranquility",
	["Tranquilizing Shot"] = "Spell_Nature_Drowsy",
	["Trap Mastery"] = "Ability_Ensnare",
	["Travel Form"] = "Ability_Druid_TravelForm",
	["Tremor Totem"] = "Spell_Nature_TremorTotem",
	["Trueshot Aura"] = "Ability_TrueShot",
	["Turn Undead"] = "Spell_Holy_TurnUndead",
	["Two-Handed Axes and Maces"] = "INV_Axe_10",
	["Two-Handed Axes"] = "INV_Axe_04",
	["Two-Handed Maces"] = "INV_Mace_04",
	["Two-Handed Swords"] = "Ability_MeleeDamage",
	["Two-Handed Weapon Specialization"] = "INV_Axe_09",
	["Unarmed"] = "Ability_GolemThunderClap",
	["Unbreakable Will"] = "Spell_Magic_MageArmor",
	["Unbridled Wrath Effect"] = "Spell_Nature_StoneClawTotem",
	["Unbridled Wrath"] = "Spell_Nature_StoneClawTotem",
	["Undead Horsemanship"] = "Spell_Nature_Swiftness",
	["Underwater Breathing"] = "Spell_Shadow_DemonBreath",
	["Unending Breath"] = "Spell_Shadow_DemonBreath",
	["Unholy Power"] = "Spell_Shadow_ShadowWordDominate",
	["Unleashed Fury"] = "Ability_BullRush",
	["Unyielding Faith"] = "Spell_Holy_UnyieldingFaith",
	["Vampiric Embrace"] = "Spell_Shadow_UnsummonBuilding",
	["Vanish"] = "Ability_Vanish",
	["Vanished"] = "Ability_Vanish",
	["Vengeance"] = "Spell_Nature_Purge",
	["Vigor"] = "Spell_Nature_EarthBindTotem",
	["Vile Poisons"] = "Ability_Rogue_FeignDeath",
	["Vindication"] = "Spell_Holy_Vindication",
	["Viper Sting"] = "Ability_Hunter_AimedShot",
	["Volley"] = "Ability_Marksmanship",
	["Wand Specialization"] = "INV_Wand_01",
	["Wands"] = "Ability_ShootWand",
	["War Stomp"] = "Ability_WarStomp",
	["Water Breathing"] = "Spell_Shadow_DemonBreath",
	["Water Walking"] = "Spell_Frost_WindWalkOn",
	["Weakened Soul"] = "Spell_Holy_AshesToAshes",
	["Whirlwind"] = "Ability_Whirlwind",
	["Will of the Forsaken"] = "Spell_Shadow_RaiseDead",
	["Windfury Totem"] = "Spell_Nature_Windfury",
	["Windfury Weapon"] = "Spell_Nature_Cyclone",
	["Windwall Totem"] = "Spell_Nature_EarthBind",
	["Wing Clip"] = "Ability_Rogue_Trip",
	["Winter's Chill"] = "Spell_Frost_ChillingBlast",
	["Wisp Spirit"] = "Spell_Nature_WispSplode",
	["Wolf Riding"] = "Spell_Nature_Swiftness",
	["Wound Poison II"] = "INV_Misc_Herb_16",
	["Wound Poison III"] = "INV_Misc_Herb_16",
	["Wound Poison IV"] = "INV_Misc_Herb_16",
	["Wound Poison"] = "INV_Misc_Herb_16",
	["Wrath"] = "Spell_Nature_AbolishMagic",
	["Wyvern Sting"] = "INV_Spear_02"
}

local scanner = CreateFrame('GameTooltip', 'oUFAuraScanner', nil, 'GameTooltipTemplate')

do
    local buff_table = {}
    _G.UnitAura = function(unit, index, filter)
        local name, rank, texture, count, dispel_type, duration, expiration

        local now = GetTime()

        scanner:SetOwner(WorldFrame, 'ANCHOR_NONE')

        if filter == 'HARMFUL' then
            scanner:SetUnitDebuff(unit, index)
            texture, count = UnitDebuff(unit, index)
        else
            scanner:SetUnitBuff(unit, index)
            texture, count = UnitBuff(unit, index)
        end

        name = _G[scanner:GetName() .. 'TextLeft1']:GetText()

        if not name then
            return
        end

        local buff_index
        if unit == 'player' then
            buff_index = GetPlayerBuff(index - 1, filter)

            if buff_index > -1 then
                count = GetPlayerBuffApplications(buff_index)
                texture = GetPlayerBuffTexture(buff_index)
                duration = GetPlayerBuffTimeLeft(buff_index)
                dispel_type = GetPlayerBuffDispelType(buff_index)

                -- Find the maximum duration
                if name and (not buff_table[name] or (duration and duration > buff_table[name])) then
                    buff_table[name] = math.ceil(duration)
                end

                expiration = (now - ((buff_table[name] or 0) - duration)) + (buff_table[name] or 0)
                duration = buff_table[name] or duration
            end
        end

        if not texture then
            texture = spellIcons[name]
            texture = texture and 'Interface/Icons/' .. texture
        end

        scanner:Hide()

        return name, rank, texture, count, dispel_type, duration, expiration
    end
end

local UpdateTooltip = function(self)
    local unit = self:GetParent().__owner.unit

    local buff_index
    if unit == 'player' then
        buff_index = GetPlayerBuff(self:GetID() - 1, self.filter)
    end

    if self.isDebuff then
        if unit == 'player' then
            GameTooltip:SetPlayerBuff(buff_index)
        else
            GameTooltip:SetUnitDebuff(unit, self:GetID(), self.filter)
        end
    else
        if unit == 'player' then
            GameTooltip:SetPlayerBuff(buff_index)
        else
            GameTooltip:SetUnitBuff(unit, self:GetID(), self.filter)
        end
    end
end

local OnEnter = function()
    if(not this:IsVisible()) then return end

    GameTooltip:SetOwner(this, "ANCHOR_BOTTOMRIGHT")
    this:UpdateTooltip()
end

local OnLeave = function()
    GameTooltip:Hide()
end

local OnClick = function()
    if this:GetParent().__owner.unit == 'player' then
        CancelPlayerBuff(GetPlayerBuff(this:GetID() - 1, 'HELPFUL'))
    end
end

local createAuraIcon = function(icons, index)
    local button = CreateFrame('Button', '$parentButton'..index, icons)
    button:RegisterForClicks('RightButtonUp')


    -- A test for the time being. Apparently, SetPoint is buggy on cooldowns and
    -- returns an invalid size. Width and height must be set, explicitly.
    local size = icons.size or 16
    button:SetWidth(size)
    button:SetHeight(size)

    local cd = CreateFrame('Model', '$parentCooldown', button, 'CooldownFrameTemplate')
    cd:SetAllPoints(button)
    cd:SetWidth(size)
    cd:SetHeight(size)
    cd:SetPosition(-0.005, -0.005, 0)

    local icon = button:CreateTexture(nil, 'BORDER')
    icon:SetAllPoints(button)

    local count = button:CreateFontString(nil, 'OVERLAY')
    count:SetFontObject(NumberFontNormal)
    count:SetPoint('BOTTOMRIGHT', button, 'BOTTOMRIGHT', -1, 0)

    local overlay = button:CreateTexture(nil, 'OVERLAY')
    overlay:SetTexture('Interface\\Buttons\\UI-Debuff-Overlays')
    overlay:SetAllPoints(button)
    overlay:SetTexCoord(.296875, .5703125, 0, .515625)
    button.overlay = overlay

    local stealable = button:CreateTexture(nil, 'OVERLAY')
    stealable:SetTexture('Interface\\TargetingFrame\\UI-TargetingFrame-Stealable')
    stealable:SetPoint('TOPLEFT', -3, 3)
    stealable:SetPoint('BOTTOMRIGHT', 3, -3)
    stealable:SetBlendMode('ADD')
    button.stealable = stealable

    button.UpdateTooltip = UpdateTooltip
    button:SetScript('OnEnter', OnEnter)
    button:SetScript('OnLeave', OnLeave)
    button:SetScript('OnClick', OnClick)
    button:SetScript('OnHide', function() cd:Hide() end)

    button.icon = icon
    button.count = count
    button.cd = cd

    --[[ :PostCreateIcon(button)

        Callback which is called after a new aura icon button has been created.

        Arguments

        button - The newly created aura icon button.
    ]]
    if(icons.PostCreateIcon) then icons:PostCreateIcon(button) end

    return button
end

local customFilter = function(icons, unit, icon, name)
    if((icons.onlyShowPlayer and icon.isPlayer) or (not icons.onlyShowPlayer and name)) then
        return true
    end
end

local updateIcon = function(unit, icons, index, offset, filter, isDebuff, visible)
    local name, rank, texture, count, dispelType, duration, expiration, caster, isStealable,
    nameplateShowSelf, spellID, canApply, isBossDebuff, casterIsPlayer, nameplateShowAll,
    timeMod, effect1, effect2, effect3 = UnitAura(unit, index, filter)

    if (name) then
        local n = visible + offset + 1
        local icon = icons[n]
        if(not icon) then
            --[[ :CreateIcon(index)

                A function which creates the aura icon for a given index.

                Arguments

                index - The offset the icon should be created at.

                Returns

                A button used to represent aura icons.
            ]]
            local prev = icons.createdIcons
            icon = (icons.CreateIcon or createAuraIcon) (icons, n)

            -- XXX: Update the counters if the layout doesn't.
            if(prev == icons.createdIcons) then
                table.insert(icons, icon)
                icons.createdIcons = icons.createdIcons + 1
            end
        end

        local isPlayer
        if(caster == 'player' or caster == 'vehicle') then
            isPlayer = true
        end

        icon.owner = caster
        icon.filter = filter
        icon.isDebuff = isDebuff
        icon.isPlayer = isPlayer


        --[[ :CustomFilter(unit, icon, ...)

            Defines a custom filter which controls if the aura icon should be shown
            or not.

            Arguments

            self - The widget that holds the aura icon.
            unit - The unit that has the aura.
            icon - The button displaying the aura.
            ...  - The return values from
            [UnitAura](http://wowprogramming.com/docs/api/UnitAura).

            Returns

            A boolean value telling the aura element if it should be show the icon
            or not.
        ]]
        local show = (icons.CustomFilter or customFilter) (icons, unit, icon, name, rank, texture,
                                                           count, dispelType, duration, expiration, caster, isStealable, nameplateShowSelf, spellID,
                                                           canApply, isBossDebuff, casterIsPlayer, nameplateShowAll,timeMod, effect1, effect2, effect3)

        if(show) then
            -- We might want to consider delaying the creation of an actual cooldown
            -- object to this point, but I think that will just make things needlessly
            -- complicated.
            local cd = icon.cd
            if(cd and not icons.disableCooldown) then
                if (duration and duration > 0) then
                    CooldownFrame_SetTimer(cd, expiration - duration, duration, 1)
                    -- CooldownFrame_SetTimer(cd, GetTime(), 100, 1)
                    -- cd:SetCooldown(expiration - duration, duration)
                    cd:Show()
                else
                    cd:Hide()
                end
            end

            if((isDebuff and icons.showDebuffType) or (not isDebuff and icons.showBuffType) or icons.showType) then
                local color = DebuffTypeColor[dispelType] or DebuffTypeColor.none

                icon.overlay:SetVertexColor(color.r, color.g, color.b)
                icon.overlay:Show()
            else
                icon.overlay:Hide()
            end

            local stealable = not isDebuff and isStealable
            if(stealable and icons.showStealableBuffs and not UnitIsUnit('player', unit)) then
                icon.stealable:Show()
            else
                icon.stealable:Hide()
            end

            icon.icon:SetTexture(texture)
            icon.count:SetText((count and count > 1 and count))

            icon:EnableMouse(true)
            icon:SetID(index)
            icon:Show()

            --[[ :PostUpdateIcon(unit, icon, index, offest)

                Callback which is called after the aura icon was updated.

                Arguments

                self   - The widget that holds the aura icon.
                unit   - The unit that has the aura.
                icon   - The button that was updated.
                index  - The index of the aura.
                offset - The offset the button was created at.
            ]]
            if(icons.PostUpdateIcon) then
                icons:PostUpdateIcon(unit, icon, index, n)
            end

            return VISIBLE
        else
            return HIDDEN
        end
    end
end

--[[ :SetPosition(from, to)

    Function used to (re-)anchor aura icons. This function is only called when
    new aura icons have been created or if :PreSetPosition is defined.

    Arguments

    self - The widget that holds the aura icons.
    from - The aura icon before the new aura icon.
    to   - The current number of created icons.
]]
local SetPosition = function(icons, from, to)
    local sizex = (icons.size or 16) + (icons['spacing-x'] or icons.spacing or 0)
    local sizey = (icons.size or 16) + (icons['spacing-y'] or icons.spacing or 0)
    local anchor = icons.initialAnchor or "BOTTOMLEFT"
    local growthx = (icons["growth-x"] == "LEFT" and -1) or 1
    local growthy = (icons["growth-y"] == "DOWN" and -1) or 1
    local cols = math.floor(icons:GetWidth() / sizex + .5)

    for i = from, to do
        local button = icons[i]

        -- Bail out if the to range is out of scope.
        if(not button) then break end
        local col = math.fmod(i - 1, cols)
        local row = math.floor((i - 1) / cols)

        button:ClearAllPoints()
        button:SetPoint(anchor, icons, anchor, col * sizex * growthx, row * sizey * growthy)
    end
end

local filterIcons = function(unit, icons, filter, limit, isDebuff, offset, dontHide)
    if(not offset) then offset = 0 end
    local index = 1
    local visible = 0
    local hidden = 0
    while(visible < limit) do
        local result = updateIcon(unit, icons, index, offset, filter, isDebuff, visible)
        if(not result) then
            break
        elseif(result == VISIBLE) then
            visible = visible + 1
        elseif(result == HIDDEN) then
            hidden = hidden + 1
        end

        index = index + 1
    end

    if(not dontHide) then
        for i = visible + offset + 1, table.getn(icons) do
            icons[i]:Hide()
        end
    end

    return visible, hidden
end

local UpdateAuras = function(self, event, unit)
    unit = unit or self.unit

    if event ~= 'PLAYER_AURAS_CHANGED' and self.unit ~= unit then return end
    -- print({unit, event})
    local auras = self.Auras
    if (auras) then
        if(auras.PreUpdate) then auras:PreUpdate(unit) end

        local numBuffs = auras.numBuffs or 32
        local numDebuffs = auras.numDebuffs or 40
        local max = numBuffs + numDebuffs

        local visibleBuffs, hiddenBuffs = filterIcons(unit, auras, auras.buffFilter or auras.filter or 'HELPFUL', numBuffs, nil, 0, true)

        local hasGap
        if(visibleBuffs ~= 0 and auras.gap) then
            hasGap = true
            visibleBuffs = visibleBuffs + 1

            local icon = auras[visibleBuffs]
            if(not icon) then
                local prev = auras.createdIcons
                icon = (auras.CreateIcon or createAuraIcon) (auras, visibleBuffs)
                -- XXX: Update the counters if the layout doesn't.
                if(prev == auras.createdIcons) then
                    table.insert(auras, icon)
                    auras.createdIcons = auras.createdIcons + 1
                end
            end

            -- Prevent the icon from displaying anything.
            if(icon.cd) then icon.cd:Hide() end
            icon:EnableMouse(false)
            icon.icon:SetTexture()
            icon.overlay:Hide()
            icon.stealable:Hide()
            icon.count:SetText()
            icon:Show()

            --[[ :PostUpdateGapIcon(unit, icon, visibleBuffs)

                Callback which is called after an invisible aura icon has been
                created. This is only used by Auras when the `gap` option is enabled.

                Arguments

                self         - The widget that holds the aura icon.
                unit         - The unit that has the aura icon.
                icon         - The invisible aura icon / gap.
                visibleBuffs - The number of currently visible buffs.
            ]]
            if(auras.PostUpdateGapIcon) then
                auras:PostUpdateGapIcon(unit, icon, visibleBuffs)
            end
        end

        local visibleDebuffs, hiddenDebuffs = filterIcons(unit, auras, auras.debuffFilter or auras.filter or 'HARMFUL', numDebuffs, true, visibleBuffs)
        auras.visibleDebuffs = visibleDebuffs

        if(hasGap and visibleDebuffs == 0) then
            auras[visibleBuffs]:Hide()
            visibleBuffs = visibleBuffs - 1
        end

        auras.visibleBuffs = visibleBuffs
        auras.visibleAuras = auras.visibleBuffs + auras.visibleDebuffs

        local fromRange, toRange
        if(auras.PreSetPosition) then
            fromRange, toRange = auras:PreSetPosition(max)
        end

        if(fromRange or auras.createdIcons > auras.anchoredIcons) then
            (auras.SetPosition or SetPosition) (auras, fromRange or auras.anchoredIcons + 1, toRange or auras.createdIcons)
            auras.anchoredIcons = auras.createdIcons
        end

        if(auras.PostUpdate) then auras:PostUpdate(unit) end
    end

    local buffs = self.Buffs
    if(buffs) then
        if(buffs.PreUpdate) then buffs:PreUpdate(unit) end

        local numBuffs = buffs.num or 32
        local visibleBuffs, hiddenBuffs = filterIcons(unit, buffs, buffs.filter or 'HELPFUL', numBuffs)
        buffs.visibleBuffs = visibleBuffs

        local fromRange, toRange
        if(buffs.PreSetPosition) then
            fromRange, toRange = buffs:PreSetPosition(numBuffs)
        end

        if(fromRange or buffs.createdIcons > buffs.anchoredIcons) then
            (buffs.SetPosition or SetPosition) (buffs, fromRange or buffs.anchoredIcons + 1, toRange or buffs.createdIcons)
            buffs.anchoredIcons = buffs.createdIcons
        end

        if(buffs.PostUpdate) then buffs:PostUpdate(unit) end
    end

    local debuffs = self.Debuffs
    if(debuffs) then
        if(debuffs.PreUpdate) then debuffs:PreUpdate(unit) end

        local numDebuffs = debuffs.num or 40
        local visibleDebuffs, hiddenDebuffs = filterIcons(unit, debuffs, debuffs.filter or 'HARMFUL', numDebuffs, true)
        debuffs.visibleDebuffs = visibleDebuffs

        local fromRange, toRange
        if(debuffs.PreSetPosition) then
            fromRange, toRange = debuffs:PreSetPosition(numDebuffs)
        end

        if(fromRange or debuffs.createdIcons > debuffs.anchoredIcons) then
            (debuffs.SetPosition or SetPosition) (debuffs, fromRange or debuffs.anchoredIcons + 1, toRange or debuffs.createdIcons)
            debuffs.anchoredIcons = debuffs.createdIcons
        end

        if(debuffs.PostUpdate) then debuffs:PostUpdate(unit) end
    end
end

local Update = function(self, event, unit)
    if(self.unit ~= unit) then return end

    UpdateAuras(self, event, unit)

    -- Assume no event means someone wants to re-anchor things. This is usually
    -- done by UpdateAllElements and :ForceUpdate.
    if(event == 'ForceUpdate' or not event) then
        local buffs = self.Buffs
        if(buffs) then
            (buffs.SetPosition or SetPosition) (buffs, 1, buffs.createdIcons)
        end

        local debuffs = self.Debuffs
        if(debuffs) then
            (debuffs.SetPosition or SetPosition) (debuffs, 1, debuffs.createdIcons)
        end

        local auras = self.Auras
        if(auras) then
            (auras.SetPosition or SetPosition) (auras, 1, auras.createdIcons)
        end
    end
end

local ForceUpdate = function(element)
    return Update(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local Enable = function(self)
    if(self.Buffs or self.Debuffs or self.Auras) then
        self:RegisterEvent("UNIT_AURA", UpdateAuras)
        self:RegisterEvent("PLAYER_AURAS_CHANGED", UpdateAuras)

        local buffs = self.Buffs
        if(buffs) then
            buffs.__owner = self
            buffs.ForceUpdate = ForceUpdate

            buffs.createdIcons = 0
            buffs.anchoredIcons = 0
        end

        local debuffs = self.Debuffs
        if(debuffs) then
            debuffs.__owner = self
            debuffs.ForceUpdate = ForceUpdate

            debuffs.createdIcons = 0
            debuffs.anchoredIcons = 0
        end

        local auras = self.Auras
        if(auras) then
            auras.__owner = self
            auras.ForceUpdate = ForceUpdate

            auras.createdIcons = 0
            auras.anchoredIcons = 0
        end

        return true
    end
end

local Disable = function(self)
    if(self.Buffs or self.Debuffs or self.Auras) then
        self:UnregisterEvent("UNIT_AURA", UpdateAuras)
    end
end

oUF:AddElement('Aura', Update, Enable, Disable)
