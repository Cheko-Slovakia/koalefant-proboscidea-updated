local assets=
{
	Asset("ANIM", "anim/firefly_flower.zip"),
}

local prefabs =
{
    "petals",
}    

local function onpickedfn(inst, picker)
	if picker and picker.components.sanity then
		picker.components.sanity:DoDelta(TUNING.SANITY_MEDLARGE)
	end	
	inst:Remove()
end

local function BurntFn(inst)
	GetWorld().components.special_flower_spawner.fireflyflower = 0
    local ash = SpawnPrefab("ash")
    ash.Transform:SetPosition(inst.Transform:GetWorldPosition())
    inst:Remove()
end

local function makebarrenfn(inst)
	inst.MiniMapEntity:SetIcon("firefly_flower_dead.tex")
	inst.AnimState:PlayAnimation("dead")
end

local function makefullfn(inst)
	inst.MiniMapEntity:SetIcon("firefly_flower_blooming.tex")
	inst.AnimState:PlayAnimation("blooming")
end

local INTENSITY = .5

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
    if TheWorld.state.isnight and not inst.components.playerprox:IsPlayerClose() then
        fadein(inst)
    else
        fadeout(inst)
    end
end


local function OnIsNight(inst)
    inst:DoTaskInTime(2 + math.random(), updatelight)
end

local function fn()
	local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
	inst.entity:AddLight()
    inst.entity:AddNetwork()
	
	
	inst.Light:SetFalloff(1)
    inst.Light:SetIntensity(INTENSITY)
    inst.Light:SetRadius(1)
    inst.Light:SetColour(180/255, 195/255, 150/255)
    inst.Light:SetIntensity(0)
    inst.Light:Enable(false)
    inst.Light:EnableClientModulation(true)

    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
	
    inst.AnimState:SetBank("firefly_flower")
    inst.AnimState:SetBuild("firefly_flower")
    inst.AnimState:PlayAnimation("blooming")
    inst.AnimState:SetRayTestOnBB(true);
	
	inst._fadeval = net_float(inst.GUID, "firefly_flower._fadeval")
    inst._faderate = net_smallbyte(inst.GUID, "firefly_flower._faderate", "onfaderatedirty")
    inst._fadetask = nil
	
	inst:AddTag("firefly_flower")
	
	inst.entity:AddMiniMapEntity()
	
	inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        inst:ListenForEvent("onfaderatedirty", OnFadeRateDirty)
        return inst
    end
	
    inst:AddComponent("inspectable")
  
	inst:AddComponent("sanityaura")
    inst.components.sanityaura.aura = -TUNING.SANITYAURA_SMALL
	
	inst:AddComponent("playerprox")
	inst.components.playerprox:SetDist(3,5)
    inst.components.playerprox:SetOnPlayerNear(updatelight)
    inst.components.playerprox:SetOnPlayerFar(updatelight)
	
	MakeSmallBurnable(inst)
    MakeSmallPropagator(inst)
	
	MakeHauntableIgnite(inst)
	
	inst:WatchWorldState("isnight", OnIsNight)

    updatelight(inst)
	
    return inst
end
return Prefab( "forest/objects/firefly_flower", fn, assets, prefabs) 
