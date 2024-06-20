local brain = require "brains/koalefantbrain"
local coward = require "brains/cowardbrain"

local assets=
{
	Asset("ANIM", "anim/koalefant_basic.zip"),
    Asset("ANIM", "anim/koalefant_actions.zip"),
    Asset("ANIM", "anim/koalefant_feathered_build.zip"),
	Asset("ANIM", "anim/koalefant_rocky_build.zip"),
	Asset("ANIM", "anim/koalefant_forest_build.zip"),
	Asset("ANIM", "anim/koalefant_nightmare_build.zip"),
	Asset("ANIM", "anim/koalefant_albino_build.zip"),
	Asset("ANIM", "anim/koalefant_frost_build.zip"),
	Asset("SOUND", "sound/koalefant.fsb"),
}

local prefabs =
{
	"robin", "crow", "robin_winter", "meat", "feather_robin", "feather_crow", "feather_robin_winter", "trunk_nightmare", "trunk_frost", "trunk_forest", "trunk_feathered",
	"trunk_albino", "trunk_rocky", "fireflies", "nightmarefuel", "monstermeat", "poop", "marble", "plantmeat", "forest_seed", "moonglow_shards", "nightmare_crystals", "frost_stone",
}

local koalefant_feathered_periodic_items = 
{
	"feather_crow", "feather_robin",
}

local koalefant_frost_periodic_items = 
{
	"ice", "frost_stone",
}

local koalefant_forest_periodic_items = 
{
	"carrot_seeds", "corn_seeds", "durian_seeds", "pumpkin_seeds", "eggplant_seeds", "pomegranate_seeds",
}

local koalefant_rocky_periodic_items = 
{
	"flint", "rocks", "marble", "nitre",
}

local koalefant_albino_periodic_items = 
{
	"moonglow_shards", "moondust",
}

local koalefant_nightmare_periodic_items = 
{
	"flower_evil", "nightmare_crystals",
}

local loot_feathered = {"meat", "meat", "robin", "robin", "robin", "robin", "crow" ,"crow", "crow" ,"robin_winter", "robin_winter", "feather_robin", "feather_robin", "feather_robin", "feather_robin", "feather_crow", "feather_crow", "feather_crow", "feather_robin_winter", "feather_robin_winter", "trunk_feathered",}
local loot_rocky = {"meat","meat","rocks","rocks","rocks","rocks","rocks","rocks", "marble", "marble", "marble","trunk_rock",}
local loot_forest = {"plantmeat", "plantmeat", "fireflies", "fireflies", "forest_seed", "forest_seed", "forest_seed", "trunk_forest",}
local loot_nightmare = {"monstermeat", "monstermeat", "nightmare_crystals", "nightmare_crystals", "nightmarefuel", "nightmarefuel", "nightmarefuel", "trunk_nightmare",}
local loot_albino = {"meat", "monstermeat", "moondust", "moondust", "moonglow_shards", "moonglow_shards", "moonglow_shards", "trunk_albino",}
local loot_frost = {"meat","meat", "frost_stone", "frost_stone", "ice", "ice", "ice", "ice", "trunk_frost",}

local WAKE_TO_RUN_DISTANCE = 10
local SLEEP_NEAR_ENEMY_DISTANCE = 14

local function ShouldWakeUp(inst)
    return DefaultWakeTest(inst) or inst:IsNear(ThePlayer, WAKE_TO_RUN_DISTANCE)
end

local function ShouldSleep(inst)
    return DefaultSleepTest(inst) and not inst:IsNear(ThePlayer, SLEEP_NEAR_ENEMY_DISTANCE)
end

local function retarget_nightmare(inst)
    return FindEntity(inst, TUNING.KOALEFANTSPECIAL_TARGET_DIST, function(guy)
        return guy.components.sanity:IsCrazy() and inst.components.combat:CanTarget(guy)
    end, { "player" }, { "playerghost" })
end

local function retargetfn(inst)
    return FindEntity(inst, TUNING.KOALEFANTSPECIAL_TARGET_DIST, function(guy)
        return inst.components.combat:CanTarget(guy) 
    end,
    nil,
    {"wall","koalefant"}
    )
end

local function KeepTarget(inst, target)
    return distsq(Vector3(target.Transform:GetWorldPosition()), Vector3(inst.Transform:GetWorldPosition())) < TUNING.KOALEFANT_CHASE_DIST * TUNING.KOALEFANT_CHASE_DIST
end

local function OnNewTarget(inst, data)
    if inst.components.sleeper:IsAsleep() then
        inst.components.sleeper:WakeUp()
    end
end

local function ShareTargetFn(dude)
    return dude:HasTag("koalefant") and not dude:HasTag("player") and not dude.components.health:IsDead()
end

local function OnAttacked(inst, data)
    inst.components.combat:SetTarget(data.attacker)
    inst.components.combat:ShareTarget(data.attacker, 30, ShareTargetFn, 5)
end

local function ShouldSleepFrost(inst)
    return inst.components.sleeper:GetTimeAwake() > TUNING.TOTAL_DAY_TIME*2
end

local function ShouldWakeUpFrost(inst)
    return inst.components.sleeper:GetTimeAsleep() > TUNING.TOTAL_DAY_TIME*.5
end

local function GetHeatFn(inst)
	if inst.components.sleeper:IsAsleep() then
		return -40
	else 
		return 0
	end
end

local INTENSITY = .7

local function randomizefadein()
    return math.random(1, 31)
end

local function randomizefadeout()
    return math.random(32, 63)
end

local function resolvefaderate(x)
    return (x == 0 and 0)
        or (x < 32 and INTENSITY * FRAMES / (3 + (x - 1) / 15))
        or INTENSITY * FRAMES / ((32 - x) / 31 - .75)
end

local function updatefade(inst, rate)
    inst._fadeval:set_local(math.clamp(inst._fadeval:value() + rate, 0, INTENSITY))

    inst.Light:SetIntensity(inst._fadeval:value())

    if rate == 0 or
        (rate < 0 and inst._fadeval:value() <= 0) or
        (rate > 0 and inst._fadeval:value() >= INTENSITY) then
        inst._fadetask:Cancel()
        inst._fadetask = nil
        if inst._fadeval:value() <= 0 and TheWorld.ismastersim then
            inst.Light:Enable(false)
        end
    end
end

local function fadein(inst)
    local ismastersim = TheWorld.ismastersim
    if not ismastersim or resolvefaderate(inst._faderate:value()) <= 0 then
        if ismastersim then
            inst.Light:Enable(true)
            inst._faderate:set(randomizefadein())
        end
        if inst._fadetask ~= nil then
            inst._fadetask:Cancel()
        end
        local rate = resolvefaderate(inst._faderate:value()) * math.clamp(1 - inst._fadeval:value() / INTENSITY, 0, 1)
        inst._fadetask = inst:DoPeriodicTask(FRAMES, updatefade, nil, rate)
        if not ismastersim then
            updatefade(inst, rate)
        end
    end
end

local function fadeout(inst)
    local ismastersim = TheWorld.ismastersim
    if not ismastersim or resolvefaderate(inst._faderate:value()) > 0 then
        if ismastersim then
            inst._faderate:set(randomizefadeout())
        end
        if inst._fadetask ~= nil then
            inst._fadetask:Cancel()
        end
        local rate = resolvefaderate(inst._faderate:value()) * math.clamp(inst._fadeval:value() / INTENSITY, 0, 1)
        inst._fadetask = inst:DoPeriodicTask(FRAMES, updatefade, nil, rate)
        if not ismastersim then
            updatefade(inst, rate)
        end
    end
end

local function OnFadeRateDirty(inst)
    local rate = resolvefaderate(inst._faderate:value())
    if rate > 0 then
        fadein(inst)
    elseif rate < 0 then
        fadeout(inst)
    elseif inst._fadetask ~= nil then
        inst._fadetask:Cancel()
        inst._fadetask = nil
        inst._fadeval:set_local(0)

        inst.Light:SetIntensity(0)
    end
end

local function updatelight(inst)
    if TheWorld.state.isnight then
        fadein(inst)
    else
        fadeout(inst)
    end
end

local function create_base(sim)
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddDynamicShadow()
    inst.entity:AddNetwork()

    MakeCharacterPhysics(inst, 100, .75)
    
    inst.DynamicShadow:SetSize(4.5, 2)
    inst.Transform:SetSixFaced()

    MakeCharacterPhysics(inst, 100, .75)
    
	inst:AddTag("koalefant")
    inst:AddTag("animal")
    inst:AddTag("largecreature")
	
	inst.AnimState:SetBank("koalefant")
    inst.AnimState:PlayAnimation("idle_loop", true)
    
	if not TheWorld.ismastersim then
        return inst
    end
	
	inst.entity:SetPristine()
	
    inst:AddComponent("eater")
    inst.components.eater:SetDiet({ FOODTYPE.VEGGIE }, { FOODTYPE.VEGGIE })
    
    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "beefalo_body"
    inst.components.combat:SetDefaultDamage(TUNING.KOALEFANT_DAMAGE)
 
    inst:AddComponent("health")

    inst:AddComponent("lootdropper")
	
    inst:AddComponent("inspectable")
    
    inst:AddComponent("knownlocations")
    
    MakeLargeBurnableCharacter(inst, "beefalo_body")
    MakeLargeFreezableCharacter(inst, "beefalo_body")

	MakeHauntablePanic(inst)
	
    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = 1.5
    inst.components.locomotor.runspeed = 7
    
    inst:AddComponent("sleeper")
    inst.components.sleeper:SetResistance(3)
    inst.components.sleeper:SetSleepTest(ShouldSleep)
    inst.components.sleeper:SetWakeTest(ShouldWakeUp)
    
    inst:SetStateGraph("SGkoalefant")
	
    return inst
end

local function create_feathered()
	local inst = create_base()
	
	if not TheWorld.ismastersim then
        return inst
    end
	
	inst:AddComponent("attackmemory")
	------------------------------------------------
	inst.AnimState:SetBuild("koalefant_feathered_build")
    inst.components.lootdropper:SetLoot(loot_feathered)
	inst.components.health:SetMaxHealth(700)
    ------------------------------------------------
	inst:AddComponent("periodicspawner_table")
    inst.components.periodicspawner_table:SetPrefabs(koalefant_feathered_periodic_items)
    inst.components.periodicspawner_table:SetRandomTimes(200, 120)
    inst.components.periodicspawner_table:SetDensityInRange(20, 2)
    inst.components.periodicspawner_table:SetMinimumSpacing(8)
    inst.components.periodicspawner_table:Start()
	
	inst:SetBrain(coward)
	
	return inst
end

local function create_rocky()
	local inst = create_base()
	
	inst:AddTag("scarytoprey")
	
	if not TheWorld.ismastersim then
        return inst
    end
	
	------------------------------------------------
	inst:AddComponent("periodicspawner_table")
    inst.components.periodicspawner_table:SetPrefabs(koalefant_rocky_periodic_items)
    inst.components.periodicspawner_table:SetRandomTimes(280, 30)
    inst.components.periodicspawner_table:SetDensityInRange(20, 2)
    inst.components.periodicspawner_table:SetMinimumSpacing(8)
    inst.components.periodicspawner_table:Start()
	------------------------------------------------
	inst.AnimState:SetBuild("koalefant_rocky_build")
    inst.components.lootdropper:SetLoot(loot_rocky)
	inst.components.health:SetMaxHealth(1600)
	inst.components.combat:SetKeepTargetFunction(KeepTarget)
    inst:ListenForEvent("newcombattarget", OnNewTarget)
    inst:ListenForEvent("attacked", OnAttacked)
	inst.components.combat:SetRetargetFunction(3, retargetfn)
	------------------------------------------------
	inst.components.locomotor.walkspeed = 1
    inst.components.locomotor.runspeed = 5
	
	inst:SetBrain(brain)
	
	return inst	
end

local function create_forest()
	local inst = create_base()
	
	if not TheWorld.ismastersim then
        return inst
    end
	
	------------------------------------------------
	inst:AddComponent("periodicspawner_table")
    inst.components.periodicspawner_table:SetPrefabs(koalefant_forest_periodic_items)
    inst.components.periodicspawner_table:SetRandomTimes(240,50)
    inst.components.periodicspawner_table:SetDensityInRange(20, 2)
    inst.components.periodicspawner_table:SetMinimumSpacing(8)
    inst.components.periodicspawner_table:Start()
	------------------------------------------------
	inst.AnimState:SetBuild("koalefant_forest_build")
    inst.components.lootdropper:SetLoot(loot_forest)
	inst.components.health:SetMaxHealth(1100)
    inst.components.combat:SetKeepTargetFunction(KeepTarget)
    inst:ListenForEvent("attacked", OnAttacked)
	
	inst:SetBrain(brain)
	
	return inst
end

local function create_nightmare()
	local inst = create_base()
	
	if not TheWorld.ismastersim then
        return inst
    end
	
	------------------------------------------------
	inst:AddComponent("periodicspawner_table")
    inst.components.periodicspawner_table:SetPrefabs(koalefant_nightmare_periodic_items)
    inst.components.periodicspawner_table:SetRandomTimes(235, 100)
    inst.components.periodicspawner_table:SetDensityInRange(20, 2)
    inst.components.periodicspawner_table:SetMinimumSpacing(8)
    inst.components.periodicspawner_table:Start()
	------------------------------------------------
	inst.AnimState:SetBuild("koalefant_nightmare_build")
	inst.AnimState:SetMultColour(1, 1, 1, 0.7)
    inst.components.lootdropper:SetLoot(loot_nightmare)
    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aura = -TUNING.SANITYAURA_LARGE
	inst.components.health:SetMaxHealth(1400)
	inst.components.combat:SetRetargetFunction(1, retarget_nightmare)
    inst.components.combat:SetKeepTargetFunction(KeepTarget)
    inst:ListenForEvent("newcombattarget", OnNewTarget)
    inst:ListenForEvent("attacked", OnAttacked)
	inst.components.sleeper.nocturnal = true
	
	inst:SetBrain(brain)
	
	return inst
end

local function create_albino()
	local inst = create_base()

	inst.entity:AddLight()
    inst.Light:SetFalloff(0.4)
    inst.Light:SetIntensity(INTENSITY)
    inst.Light:SetRadius(2.5)
    inst.Light:SetColour(84/255, 122/255, 156/255)
    inst.Light:SetIntensity(0)
    inst.Light:Enable(false)
    inst.Light:EnableClientModulation(true)
	
	inst._fadeval = net_float(inst.GUID, "koalefant_albino._fadeval")
    inst._faderate = net_smallbyte(inst.GUID, "koalefant_albino._faderate", "onfaderatedirty")
    inst._fadetask = nil
	
    if not TheWorld.ismastersim then
        inst:ListenForEvent("onfaderatedirty", OnFadeRateDirty)
        return inst
    end
	
	------------------------------------------------
	inst:AddComponent("periodicspawner_table")
    inst.components.periodicspawner_table:SetPrefabs(koalefant_albino_periodic_items)
    inst.components.periodicspawner_table:SetRandomTimes(265, 80)
    inst.components.periodicspawner_table:SetDensityInRange(20, 2)
    inst.components.periodicspawner_table:SetMinimumSpacing(8)
    inst.components.periodicspawner_table:Start()
	------------------------------------------------
	inst.AnimState:SetBuild("koalefant_albino_build")
    inst.components.lootdropper:SetLoot(loot_albino)
	inst.components.health:SetMaxHealth(1200)
    inst.components.combat:SetKeepTargetFunction(KeepTarget)
    inst:ListenForEvent("attacked", OnAttacked)
	inst.components.sleeper.nocturnal = true
	
	inst:SetBrain(brain)
	
	inst:WatchWorldState("isnight", updatelight)

	updatelight(inst)
	
	return inst
end

local function create_frost()
	local inst = create_base()
	
	inst:AddTag("HASHEATER")
	
	if not TheWorld.ismastersim then
        return inst
    end
	
	------------------------------------------------
	inst:AddComponent("periodicspawner_table")
    inst.components.periodicspawner_table:SetPrefabs(koalefant_frost_periodic_items)
    inst.components.periodicspawner_table:SetRandomTimes(280, 120)
    inst.components.periodicspawner_table:SetDensityInRange(20, 2)
    inst.components.periodicspawner_table:SetMinimumSpacing(8)
    inst.components.periodicspawner_table:Start()
	------------------------------------------------
    inst:AddComponent("heater")
    inst.components.heater.heatfn = GetHeatFn
    inst.components.heater:SetThermics(false, true)
	------------------------------------------------
	inst.components.sleeper:SetSleepTest(ShouldSleepFrost)
    inst.components.sleeper:SetWakeTest(ShouldWakeUpFrost)
	------------------------------------------------
	inst.AnimState:SetBuild("koalefant_frost_build")
    inst.components.lootdropper:SetLoot(loot_frost)
	inst.components.health:SetMaxHealth(1400)
    inst.components.combat:SetKeepTargetFunction(KeepTarget)
	inst:ListenForEvent("attacked", OnAttacked)
	
	inst:SetBrain(brain)
	
	return inst
end

return Prefab( "forest/animals/koalefant_feathered", create_feathered, assets, prefabs),
	   Prefab( "forest/animals/koalefant_rocky", create_rocky, assets, prefabs),
	   Prefab( "forest/animals/koalefant_forest", create_forest, assets, prefabs),
	   Prefab( "forest/animals/koalefant_nightmare", create_nightmare, assets, prefabs),
	   Prefab( "forest/animals/koalefant_frost", create_frost, assets, prefabs),
	   Prefab( "forest/animals/koalefant_albino", create_albino, assets, prefabs)