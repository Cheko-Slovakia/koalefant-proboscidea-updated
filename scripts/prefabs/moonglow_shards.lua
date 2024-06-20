local assets =
{
	Asset("ANIM", "anim/moonglow_shards.zip"),
	Asset("ATLAS", "images/inventoryimages/moonglow_shards.xml"),
}

local INTENSITY = .6

local function randomizefadein()
    return math.random(1, 31)
end

local function randomizefadeout()
    return math.random(32, 63)
end

local function immediatefadeout()
    return 0
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
    if TheWorld.state.isnight and not inst.components.playerprox:IsPlayerClose() and inst.components.inventoryitem.owner == nil then
        fadein(inst)
    else
        fadeout(inst)
    end
end

local function ondropped(inst)
    inst._fadeval:set(0)
    inst._faderate:set_local(immediatefadeout())
    fadein(inst)
    inst:DoTaskInTime(2 + math.random(), updatelight)
end


local function onpickup(inst)
    if inst._fadetask ~= nil then
        inst._fadetask:Cancel()
        inst._fadetask = nil
    end
    inst._fadeval:set_local(0)
    inst._faderate:set(immediatefadeout())
    inst.Light:SetIntensity(0)
    inst.Light:Enable(false)
end

local function ondeploy(inst, pt)
    inst = inst.components.stackable:Get()
    inst.Transform:SetPosition(pt:Get())
	inst.components.burnable:SetBurnTime(math.random(40, 75))
	inst.components.burnable:Ignite()
end

local function OnIsNight(inst)
    inst:DoTaskInTime(2 + math.random(), updatelight)
end

local function itemfn()
	local inst = CreateEntity()
	
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddPhysics()
    inst.entity:AddLight()
    inst.entity:AddNetwork()
	
	MakeInventoryPhysics(inst)
	
	inst:AddTag("eyeturret")
	
	inst.Light:SetFalloff(0.7)
    inst.Light:SetIntensity(INTENSITY)
    inst.Light:SetRadius(0.4)
    inst.Light:SetColour(84/255, 122/255, 156/255)
    inst.Light:SetIntensity(0)
    inst.Light:Enable(false)
    inst.Light:EnableClientModulation(true)

    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
	
    inst.AnimState:SetBank("moonglow_shards")
    inst.AnimState:SetBuild("moonglow_shards")
    inst.AnimState:PlayAnimation("idle")
	inst.AnimState:SetRayTestOnBB(true)
	
	inst._fadeval = net_float(inst.GUID, "moonglow_shards._fadeval")
    inst._faderate = net_smallbyte(inst.GUID, "moonglow_shards._faderate", "onfaderatedirty")
    inst._fadetask = nil

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        inst:ListenForEvent("onfaderatedirty", OnFadeRateDirty)
        return inst
    end
	
    inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

	inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.MED_LARGE_FUEL
    inst.components.fuel.fueltype = "CAVE"
    
    inst:AddComponent("burnable")
    inst.components.burnable:SetFXLevel(3)
    inst.components.burnable:SetBurnTime(math.random(40, 75))
    inst.components.burnable:AddBurnFX("moonglow_shard_flame", Vector3(0, 0.5, 0))
    inst.components.burnable:SetOnBurntFn(DefaultBurntFn)
	
	inst:AddComponent("playerprox")
	
	inst:AddComponent("inspectable")
	
	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.atlasname = "images/inventoryimages/moonglow_shards.xml"
	inst.components.inventoryitem:SetOnPickupFn(onpickup)
	inst.components.inventoryitem:SetOnDroppedFn(ondropped)
	
    inst:AddComponent("deployable")
	inst.components.deployable:SetDeployMode(DEPLOYMODE.ANYWHERE)
    inst.components.deployable.ondeploy = ondeploy
	  	
    inst.components.playerprox:SetDist(3,5)
    inst.components.playerprox:SetOnPlayerNear(updatelight)
    inst.components.playerprox:SetOnPlayerFar(updatelight)

	MakeHauntableLaunchAndIgnite(inst)
	
    inst:WatchWorldState("isnight", OnIsNight)

    updatelight(inst)
	
	return inst
end
return Prefab("common/inventory/moonglow_shards", itemfn, assets),
	   MakePlacer("common/moonglow_shards_placer", "moonglow_shards", "moonglow_shards", "idle")
