PrefabFiles = 
{
	"special_track",
	"specialdirtpile",
	"special_trunk",
	"frost_stone",
	"evil_root",
	"firefly_flower",
	"frost_stone_flame",
	"forest_seed",
	"moondust_fire",
	"moondust",
	"moonglow_shards",
	"moonglow_shard_flame",
	"koalefant_dolls",
	"mod_fx",
	"nightmare_crystals",
	"koalefantspecial",
}

Assets = 
{
	Asset("ATLAS", "images/firefly_flower_blooming.xml"),
	Asset("ATLAS", "images/firefly_flower_dead.xml"),
	Asset("ATLAS", "images/evil_root_blooming.xml"),
	Asset("ATLAS", "images/evil_root_dead.xml"),
}

AddMinimapAtlas("images/firefly_flower_blooming.xml")
AddMinimapAtlas("images/firefly_flower_dead.xml")
AddMinimapAtlas("images/evil_root_blooming.xml")
AddMinimapAtlas("images/evil_root_dead.xml")

GLOBAL.STRINGS.NAMES.KOALEFANT_SUMMER_DOLL = "Tiny Summer Koalefant"
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.KOALEFANT_SUMMER_DOLL = "Aww"
	
GLOBAL.STRINGS.NAMES.KOALEFANT_ALBINO_DOLL = "Tiny Albino Koalefant"
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.KOALEFANT_ALBINO_DOLL = "Wish I could sleep like that."
	
GLOBAL.STRINGS.NAMES.KOALEFANT_NIGHTMARE_DOLL = "Tiny Nightmare Koalefant"
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.KOALEFANT_NIGHTMARE_DOLL = "Why so sad?"
	
GLOBAL.STRINGS.NAMES.KOALEFANT_FOREST_DOLL = "Tiny Forest Koalefant"
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.KOALEFANT_FOREST_DOLL = "Something alive is trapped in this doll."
	
GLOBAL.STRINGS.NAMES.KOALEFANT_FROST_DOLL = "Tiny Frost Koalefant"
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.KOALEFANT_FROST_DOLL = "Feeling cosy? Good for you!"

GLOBAL.STRINGS.NAMES.KOALEFANT_ROCKY_DOLL = "Tiny Rocky Koalefant"
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.KOALEFANT_ROCKY_DOLL = "Not so tough now!"
	
GLOBAL.STRINGS.NAMES.KOALEFANT_WINTER_DOLL = "Tiny Winter Koalefant"
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.KOALEFANT_WINTER_DOLL = "You shall be my new friend."
	
GLOBAL.STRINGS.NAMES.KOALEFANT_FEATHERED_DOLL = "Tiny Feathered Koalefant"
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.KOALEFANT_FEATHERED_DOLL = "It has a little bird."

GLOBAL.STRINGS.NAMES.SPECIALDIRTPILE = "Suspicious Dirt Pile"
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.SPECIALDIRTPILE = "It's a pile of dirt... or IS it?"
GLOBAL.STRINGS.CHARACTERS.WENDY.DESCRIBE.SPECIALDIRTPILE = "Oh look. More dirt."
GLOBAL.STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.SPECIALDIRTPILE = "Unhygienic!"
GLOBAL.STRINGS.CHARACTERS.WILLOW.DESCRIBE.SPECIALDIRTPILE = "Who just leaves dirt lying around in the forest?"
GLOBAL.STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.SPECIALDIRTPILE = "Dirty dirt."
GLOBAL.STRINGS.CHARACTERS.WX78.DESCRIBE.SPECIALDIRTPILE = "UNKNOWN PILE FORMAT"
GLOBAL.STRINGS.CHARACTERS.WAXWELL.DESCRIBE.SPECIALDIRTPILE = "That looks out-of-place."
GLOBAL.STRINGS.CHARACTERS.WOODIE.DESCRIBE.SPECIALDIRTPILE = "Hey! A clue!"
GLOBAL.STRINGS.CHARACTERS.WEBBER.DESCRIBE.SPECIALDIRTPILE = "A pile of dirt. I bet it's hiding something."
GLOBAL.STRINGS.CHARACTERS.WATHGRITHR.DESCRIBE.SPECIALDIRTPILE = "A small hill of earth."

GLOBAL.STRINGS.NAMES.KOALEFANT_FOREST = "Forest Koalefant"
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.KOALEFANT_FOREST = "The colour of his coat hides him well."

GLOBAL.STRINGS.NAMES.TRUNK_FOREST = "Forest Trunk"
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.TRUNK_FOREST = "Nature is whispering secrets."

GLOBAL.STRINGS.NAMES.FOREST_SEED = "Forest Seed"
GLOBAL.STRINGS.NAMES.FOREST_SEED_SAPLING = "Forest Seed Sapling"

GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.FOREST_SEED = 
	{
		GENERIC = "I can hear a tiny plant inside it, trying to get out.",
		PLANTED = "What shall it be?",
	}

GLOBAL.TUNING.FOREST_SEED_GROWTIME = {base = 2 * GLOBAL.TUNING.TOTAL_DAY_TIME, random = 0.25 * GLOBAL.TUNING.TOTAL_DAY_TIME}

GLOBAL.STRINGS.NAMES.KOALEFANT_FEATHERED = "Feathered Koalefant"
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.KOALEFANT_FEATHERED = "I would be impressed if he could fly away."

GLOBAL.STRINGS.NAMES.TRUNK_FEATHERED = "Feathered Trunk"
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.TRUNK_FEATHERED = "It feels light to hold it."

GLOBAL.STRINGS.NAMES.KOALEFANT_ROCKY = "Rocky Koalefant"
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.KOALEFANT_ROCKY = "He looks rather angry."

GLOBAL.STRINGS.NAMES.TRUNK_ROCKY = "Rocky Trunk"
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.TRUNK_ROCKY = "I don't want to carry this all day. "

GLOBAL.STRINGS.NAMES.KOALEFANT_NIGHTMARE = "Nightmare Koalefant"
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.KOALEFANT_NIGHTMARE = "Something is odd about this one."

GLOBAL.STRINGS.NAMES.TRUNK_NIGHTMARE = "Nightmare Trunk"
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.TRUNK_NIGHTMARE = "I have a bad feeling about this."

GLOBAL.TUNING.NIGHTMARE_TRUNK_SLEEP_RANGE = 20
GLOBAL.TUNING.NIGHTMARE_TRUNK_SLEEP_TIME = 20

GLOBAL.STRINGS.NAMES.NIGHTMARE_CRYSTALS = "Nightmare Crystals"
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.NIGHTMARE_CRYSTALS = "Evil."

GLOBAL.TUNING.NIGHTMARE_CRYSTALS_FERTILIZE = 160
GLOBAL.TUNING.NIGHTMARE_CRYSTALS_SOILCYCLES = 6

GLOBAL.STRINGS.NAMES.KOALEFANT_ALBINO = "Albino Koalefant"
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.KOALEFANT_ALBINO = "His eyes are bad."

GLOBAL.STRINGS.NAMES.TRUNK_ALBINO = "Albino Trunk"
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.TRUNK_ALBINO = "It's so bright it makes my eyes hurt."
GLOBAL.TUNING.ALBINO_TRUNK_LIGHT_DURATION = 120
GLOBAL.TUNING.ALBINO_TRUNK_LIGHT_RADIUS = 3

GLOBAL.STRINGS.NAMES.MOONDUST = "Moondust"
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.MOONDUST = "Boom!"
GLOBAL.TUNING.MOONDUST_DAMAGE = 30

GLOBAL.STRINGS.NAMES.MOONGLOW_SHARDS = "Moonglow Shards"
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.MOONGLOW_SHARDS = "Glowing like the moon."

GLOBAL.STRINGS.NAMES.KOALEFANT_FROST = "Frost Koalefant"
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.KOALEFANT_FROST = "He has frosty winter pelt."

GLOBAL.STRINGS.NAMES.TRUNK_FROST = "Frost Trunk"
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.TRUNK_FROST = "It makes the air freeze around it."

GLOBAL.TUNING.FROST_TRUNK_FREEZE_RANGE = 20
GLOBAL.TUNING.FROST_TRUNK_FREEZE_TIME = 20
GLOBAL.TUNING.FROST_TRUNK_TEMPERATURE_DELTA = 40
GLOBAL.TUNING.FROST_TRUNK_TEMPERATURE_TIME = 30

GLOBAL.STRINGS.NAMES.FROST_STONE = "Frost Stone"
GLOBAL.STRINGS.CHARACTERS.GENERIC.DESCRIBE.FROST_STONE = "It has cold fire burning in it's core."

GLOBAL.TUNING.KOALEFANTSPECIAL_TARGET_DIST = 20
GLOBAL.TUNING.KOALEFANTSPECIAL_CHASE_DIST = 30

GLOBAL.TUNING.FOREST_TRUNK_GROWTH_RANGE = 20

GLOBAL.TUNING.SPECIAL_HUNT_SPAWN_DIST = 40
GLOBAL.TUNING.SPECIAL_HUNT_COOLDOWN = TUNING.TOTAL_DAY_TIME * 1.5
GLOBAL.TUNING.SPECIAL_HUNT_COOLDOWNDEVIATION = TUNING.TOTAL_DAY_TIME * .4

GLOBAL.TUNING.SPECIAL_HUNT_RESET_TIME = 6

GLOBAL.TUNING.SPECIAL_TRACK_ANGLE_DEVIATION = 30
GLOBAL.TUNING.SPECIAL_MIN_HUNT_DISTANCE = 300 -- you can't find a new beast without being at least this far from the last one
GLOBAL.TUNING.SPECIAL_MAX_DIRT_DISTANCE = 200 -- if you get this far away from your dirt pile, you probably aren't going to see it any time soon, so remove it and place a new one

GLOBAL.TUNING.MIN_JOINED_SPECIAL_HUNT_DISTANCE = 70

GLOBAL.TUNING.SPECIALHUNT_ALTERNATE_BEAST_CHANCE_MIN = 0.05
GLOBAL.TUNING.SPECIALHUNT_ALTERNATE_BEAST_CHANCE_MAX = 0.33

local dolls =
{
	"koalefant_summer_doll",
	"koalefant_nightmare_doll",
	"koalefant_albino_doll",
	"koalefant_feathered_doll",
	"koalefant_rocky_doll",
	"koalefant_frost_doll",
	"koalefant_winter_doll",
	"koalefant_forest_doll",
}
		
function TumbleweedPrefabPostInit(inst)
	if not GLOBAL.TheWorld.ismastersim then
		return inst
	end
	
	local function DropDoll(inst)
		local num = math.random(1, 40)
		if num == 40 then
			doll = GLOBAL.SpawnPrefab(GLOBAL.GetRandomItem(dolls))
			doll.Transform:SetPosition(inst.Transform:GetWorldPosition())
		end
	end

	inst:ListenForEvent("picked", function() DropDoll(inst) end)
end
	
AddPrefabPostInit("tumbleweed", TumbleweedPrefabPostInit)
	
function MoundPrefabPostInit(inst)
	if not GLOBAL.TheWorld.ismastersim then
		return inst
	end
	
	local function DropDoll(inst)
		local num = math.random(1, 40)
		if num == 40 then
			doll = GLOBAL.GetRandomItem(dolls)
			inst.components.lootdropper:SpawnLootPrefab(doll)
		end
	end
	inst:ListenForEvent("worked", function() DropDoll(inst) end)
end
	
AddPrefabPostInit("mound", MoundPrefabPostInit)

function WorldPrefabPostInit(inst)
	if inst:HasTag("forest") then
		inst:AddComponent("specialhunter")
	end
end

if GLOBAL.TheNet:GetIsServer() then
	AddPrefabPostInit("world", WorldPrefabPostInit)
end

