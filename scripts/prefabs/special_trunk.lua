local assets=
{
	Asset("ANIM", "anim/special_trunk.zip"),
	Asset("ATLAS", "images/inventoryimages/trunk_forest.xml"),
	Asset("ATLAS", "images/inventoryimages/trunk_frost.xml"),
	Asset("ATLAS", "images/inventoryimages/trunk_feathered.xml"),
	Asset("ATLAS", "images/inventoryimages/trunk_rocky.xml"),
	Asset("ATLAS", "images/inventoryimages/trunk_albino.xml"),
	Asset("ATLAS", "images/inventoryimages/trunk_nightmare.xml"),
}

local prefabs =
{
    "trunk_cooked",
    "spoiled_food",
	"magic_light",
}   

local INTENSITY = .5

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
            inst:AddTag("NOCLICK")
            inst.Light:Enable(false)
        end
    end
end

local function fadein(inst)
    local ismastersim = TheWorld.ismastersim
    if not ismastersim or resolvefaderate(inst._faderate:value()) <= 0 then
        if ismastersim then
            inst:RemoveTag("NOCLICK")
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
    if TheWorld.state.isnight and inst.components.inventoryitem.owner == nil then
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

local function OnIsNight(inst)
    inst:DoTaskInTime(2 + math.random(), updatelight)
end

function OnEatenForest(inst, eater)
	SpawnPrefab("green_spell_fx").Transform:SetPosition(eater.Transform:GetWorldPosition())
    local range = 30
    local pos = Vector3(eater.Transform:GetWorldPosition())
    local ents = TheSim:FindEntities(pos.x, pos.y, pos.z, range)
    for k, v in pairs(ents) do
        if v.components.pickable ~= nil then
            v.components.pickable:FinishGrowing()
        end

        if v.components.crop ~= nil then
            v.components.crop:DoGrow(TUNING.TOTAL_DAY_TIME * 3)
        end
        
        if v.components.growable ~= nil and v:HasTag("tree") and not v:HasTag("stump") then
            v.components.growable:DoGrowth()
        end
    end
    return true
end

local function DoAreaEffectFrost(inst, user, range, time)
	local x, y, z = user.Transform:GetWorldPosition()
    local ents = TheNet:GetPVPEnabled() and
                 TheSim:FindEntities(x, y, z, range, nil, { "playerghost" }, { "sleeper", "player" }) or
                 TheSim:FindEntities(x, y, z, range, { "sleeper" }, { "player" })
    for i, v in ipairs(ents) do
        if v ~= user and
            not (v.components.sleeper ~= nil and v.components.sleeper:IsAsleep()) and
            not (v.components.pinnable ~= nil and v.components.pinnable:IsStuck()) then
            if v.components.freezable ~= nil then
                v.components.freezable:Freeze(time)
            end
        end
    end
end

local function OnEatenFrost(inst, eater)
	eater:DoTaskInTime(0.5, function() SpawnPrefab("blue_spell_fx").Transform:SetPosition(eater.Transform:GetWorldPosition()) DoAreaEffectFrost(inst, eater, TUNING.FROST_TRUNK_FREEZE_RANGE, TUNING.FROST_TRUNK_FREEZE_TIME) end)
end

local function DoAreaEffectNightmare(inst, user, range, time)
	local x, y, z = user.Transform:GetWorldPosition()
    local ents = TheNet:GetPVPEnabled() and
                 TheSim:FindEntities(x, y, z, range, nil, { "playerghost" }, { "sleeper", "player" }) or
                 TheSim:FindEntities(x, y, z, range, { "sleeper" }, { "player" })
    for i, v in ipairs(ents) do
        if v ~= user and
            not (v.components.freezable ~= nil and v.components.freezable:IsFrozen()) and
            not (v.components.pinnable ~= nil and v.components.pinnable:IsStuck()) then
            if v.components.sleeper ~= nil then
                v.components.sleeper:AddSleepiness(10, time)
            elseif v.components.grogginess ~= nil then
                v.components.grogginess:AddGrogginess(10, time)
            else
                v:PushEvent("knockedout")
            end
        end
    end
end

local function OnEatenNightmare(inst, eater)
	eater:DoTaskInTime(0.5, function() SpawnPrefab("black_spell_fx").Transform:SetPosition(eater.Transform:GetWorldPosition()) DoAreaEffectNightmare(inst, eater, TUNING.NIGHTMARE_TRUNK_SLEEP_RANGE, TUNING.NIGHTMARE_TRUNK_SLEEP_TIME) end)
end

local function create_common(anim, cookable)
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
	inst.entity:AddNetwork()
    
	MakeInventoryPhysics(inst)
	
    inst.AnimState:SetBank("special_trunk")
    inst.AnimState:SetBuild("special_trunk")
    inst.AnimState:PlayAnimation(anim)
	
	if cookable then
        inst:AddTag("cookable")
    end
	
	inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
	
    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_MEDITEM

    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")

    inst:AddComponent("tradable")
	inst.components.tradable.goldvalue = TUNING.GOLD_VALUES.MEAT
	
    inst:AddComponent("edible")
    inst.components.edible.ismeat = true
    inst.components.edible.foodtype = FOODTYPE.MEAT
	
	if cookable then
        inst:AddComponent("cookable")
        inst.components.cookable.product = "trunk_cooked"
    end
	
    inst:AddComponent("perishable")
    inst.components.perishable.onperishreplacement = "spoiled_food"

    MakeHauntableLaunchAndPerish(inst)

    return inst
end

local function create_forest()
    local inst = create_common("idle_forest", true)
	
	if not TheWorld.ismastersim then
        return inst
    end
	
	inst.components.inventoryitem.atlasname = "images/inventoryimages/trunk_forest.xml"
	
    inst.components.edible.healthvalue = TUNING.HEALING_MEDSMALL
    inst.components.edible.hungervalue = -TUNING.CALORIES_LARGE
	inst.components.edible.sanityvalue = -TUNING.SANITY_MED
	
	inst.components.edible:SetOnEatenFn(OnEatenForest)

    inst.components.perishable:SetPerishTime(TUNING.PERISH_MED)
    inst.components.perishable:StartPerishing()

    return inst
end

local function create_frost()
    local inst = create_common("idle_frost", true)
	
	if not TheWorld.ismastersim then
        return inst
    end
	
	inst.components.inventoryitem.atlasname = "images/inventoryimages/trunk_frost.xml"
	
    inst.components.edible.healthvalue = TUNING.HEALING_MEDSMALL
    inst.components.edible.hungervalue = TUNING.CALORIES_TINY
	inst.components.edible.sanityvalue = -TUNING.SANITY_MEDLARGE
	inst.components.edible.temperaturedelta = -TUNING.FROST_TRUNK_TEMPERATURE_DELTA
    inst.components.edible.temperatureduration = TUNING.FROST_TRUNK_TEMPERATURE_TIME
	
	inst.components.edible:SetOnEatenFn(OnEatenFrost)

    inst.components.perishable:SetPerishTime(TUNING.PERISH_SLOW)
    inst.components.perishable:StartPerishing()

    return inst
end

local function create_feathered()
	local inst = create_common("idle_feathered", true)
	
	if not TheWorld.ismastersim then
        return inst
    end
	
	inst.components.inventoryitem.atlasname = "images/inventoryimages/trunk_feathered.xml"

    inst.components.edible.healthvalue = TUNING.HEALING_MEDSMALL
    inst.components.edible.hungervalue = TUNING.CALORIES_TINY
	inst.components.edible.sanityvalue = -TUNING.SANITY_MEDLARGE
	
    inst.components.perishable:SetPerishTime(TUNING.PERISH_MED)
    inst.components.perishable:StartPerishing()
	
	return inst
end

local function create_rocky()
	local inst = create_common("idle_rock", true)
	
	if not TheWorld.ismastersim then
        return inst
    end
	
	inst.components.inventoryitem.atlasname = "images/inventoryimages/trunk_rocky.xml"
	
    inst.components.edible.healthvalue = TUNING.HEALING_MEDSMALL
    inst.components.edible.hungervalue = TUNING.CALORIES_TINY
	inst.components.edible.sanityvalue = -TUNING.SANITY_LARGE
	
    inst.components.perishable:SetPerishTime(TUNING.PERISH_SLOW)
    inst.components.perishable:StartPerishing()

    return inst
end

local function create_nightmare()
	local inst = create_common("idle_nightmare", true)
	
	if not TheWorld.ismastersim then
        return inst
    end
	
	inst.components.inventoryitem.atlasname = "images/inventoryimages/trunk_nightmare.xml"
	
    inst.components.edible.healthvalue = TUNING.HEALING_TINY
    inst.components.edible.hungervalue = TUNING.CALORIES_TINY
	inst.components.edible.sanityvalue = -TUNING.SANITY_LARGE
	
	inst.components.edible:SetOnEatenFn(OnEatenNightmare)
	
    inst.components.perishable:SetPerishTime(TUNING.PERISH_MED)
    inst.components.perishable:StartPerishing()

    return inst
end

local function create_light(eater, lightprefab)
    if eater.wormlight ~= nil then
        if eater.wormlight.prefab == lightprefab then
            eater.wormlight.components.spell.lifetime = 0
            eater.wormlight.components.spell:ResumeSpell()
            return
        else
            eater.wormlight.components.spell:OnFinish()
        end
    end

    local light = SpawnPrefab(lightprefab)
    light.components.spell:SetTarget(eater)
    if light:IsValid() then
        if light.components.spell.target == nil then
            light:Remove()
        else
            light.components.spell:StartSpell()
        end
    end
end

local function OnEatenAlbino(inst, eater)
	SpawnPrefab("white_spell_fx").Transform:SetPosition(eater.Transform:GetWorldPosition())
	create_light(eater, "magic_light")
end

local function create_albino()
	local inst = create_common("idle_albino", true)
	
	inst.entity:AddLight()
	inst.Light:SetFalloff(0.7)
	inst.Light:SetIntensity(INTENSITY)
    inst.Light:SetRadius(0.5)
    inst.Light:SetColour(84/255, 122/255, 156/255)
    inst.Light:SetIntensity(0)
    inst.Light:Enable(false)
    inst.Light:EnableClientModulation(true)
	
	inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
	
	inst.AnimState:SetRayTestOnBB(true)
	
	inst._fadeval = net_float(inst.GUID, "trunk_albino._fadeval")
    inst._faderate = net_smallbyte(inst.GUID, "trunk_albino._faderate", "onfaderatedirty")
    inst._fadetask = nil
	
	inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        inst:ListenForEvent("onfaderatedirty", OnFadeRateDirty)
        return inst
    end
	
	inst.components.inventoryitem.atlasname = "images/inventoryimages/trunk_albino.xml"
	inst.components.inventoryitem:SetOnDroppedFn(ondropped)
    inst.components.inventoryitem:SetOnPickupFn(onpickup)
	
    inst.components.edible.healthvalue = TUNING.HEALING_MED
    inst.components.edible.hungervalue = TUNING.CALORIES_TINY
	inst.components.edible.sanityvalue = TUNING.SANITY_MEDLARGE
	inst.components.edible:SetOnEatenFn(OnEatenAlbino)
	
	inst.components.perishable:SetPerishTime(TUNING.PERISH_MED)
    inst.components.perishable:StartPerishing()
	
	inst:WatchWorldState("isnight", OnIsNight)

    updatelight(inst)
	
	return inst
end

local lightprefabs =
{
    "magic_light_fx",
}

local function light_resume(inst, time)
    inst.fx:setprogress(1 - time / inst.components.spell.duration)
end

local function light_start(inst)
    inst.fx:setprogress(0)
end

local function pushbloom(inst, target)
    if target.components.bloomer ~= nil then
        target.components.bloomer:PushBloom(inst, "shaders/anim.ksh", -1)
    else
        target.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    end
end

local function popbloom(inst, target)
    if target.components.bloomer ~= nil then
        target.components.bloomer:PopBloom(inst)
    else
        target.AnimState:ClearBloomEffectHandle()
    end
end

local function light_ontarget(inst, target)
    if target == nil or target:HasTag("playerghost") or target:HasTag("overcharge") then
        inst:Remove()
        return
    end

    local function forceremove()
        inst.components.spell_x:OnFinish()
    end

    target.wormlight = inst
    inst.Follower:FollowSymbol(target.GUID, "", 0, 0, 0)
    inst:ListenForEvent("onremove", forceremove, target)
    inst:ListenForEvent("death", function() inst.fx:setdead() end, target)

    if target:HasTag("player") then
        inst:ListenForEvent("ms_becameghost", forceremove, target)
        if target:HasTag("electricdamageimmune") then
            inst:ListenForEvent("ms_overcharge", forceremove, target)
        end
        inst.persists = false
    else
        inst.persists = not target:HasTag("critter")
    end

    pushbloom(inst, target)

    if target.components.rideable ~= nil then
        local rider = target.components.rideable:GetRider()
        if rider ~= nil then
            pushbloom(inst, rider)
            inst.fx.entity:SetParent(rider.entity)
        else
            inst.fx.entity:SetParent(target.entity)
        end

        inst:ListenForEvent("riderchanged", function(target, data)
            if data.oldrider ~= nil then
                popbloom(inst, data.oldrider)
                inst.fx.entity:SetParent(target.entity)
            end
            if data.newrider ~= nil then
                pushbloom(inst, data.newrider)
                inst.fx.entity:SetParent(data.newrider.entity)
            end
        end, target)
    else
        inst.fx.entity:SetParent(target.entity)
    end
end

local function light_onfinish(inst)
    local target = inst.components.spell.target
    if target ~= nil then
        target.wormlight = nil

        popbloom(inst, target)

        if target.components.rideable ~= nil then
            local rider = target.components.rideable:GetRider()
            if rider ~= nil then
                popbloom(inst, rider)
            end
        end
    end
end

local function light_onremove(inst)
    inst.fx:Remove()
end

local function light_commonfn(duration, fxprefab)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddFollower()
    inst:Hide()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst:AddComponent("spell")
    inst.components.spell.spellname = "moonlight"
    inst.components.spell.duration = duration
    inst.components.spell.ontargetfn = light_ontarget
    inst.components.spell.onstartfn = light_start
    inst.components.spell.onfinishfn = light_onfinish
    inst.components.spell.resumefn = light_resume
    inst.components.spell.removeonfinish = true

    inst.persists = false
    inst.fx = SpawnPrefab(fxprefab)
    inst.OnRemoveEntity = light_onremove

    return inst
end

local function lightfn()
    return light_commonfn(TUNING.ALBINO_TRUNK_LIGHT_DURATION, "magic_light_fx")
end

local function OnUpdateLight(inst, dframes)
    local frame =
        inst._lightdead:value() and
        math.ceil(inst._lightframe:value() * .9 + inst._lightmaxframe * .1) or
        (inst._lightframe:value() + dframes)

    if frame >= inst._lightmaxframe then
        inst._lightframe:set_local(inst._lightmaxframe)
        inst._lighttask:Cancel()
        inst._lighttask = nil
    else
        inst._lightframe:set_local(frame)
    end

    inst.Light:SetRadius(TUNING.ALBINO_TRUNK_LIGHT_RADIUS * (1 - inst._lightframe:value() / inst._lightmaxframe))
end

local function OnLightDirty(inst)
    if inst._lighttask == nil then
        inst._lighttask = inst:DoPeriodicTask(FRAMES, OnUpdateLight, nil, 1)
    end
    OnUpdateLight(inst, 0)
end

local function setprogress(inst, percent)
    inst._lightframe:set(math.max(0, math.min(inst._lightmaxframe, math.floor(percent * inst._lightmaxframe + .5))))
    OnLightDirty(inst)
end

local function setdead(inst)
    inst._lightdead:set(true)
    inst._lightframe:set(inst._lightframe:value())
end

local function lightfx_commonfn(duration)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.Light:SetRadius(0)
    inst.Light:SetIntensity(.8)
    inst.Light:SetFalloff(.5)
    inst.Light:SetColour(84/255, 122/255, 156/255)
    inst.Light:Enable(true)
    inst.Light:EnableClientModulation(true)
	
    inst._lightmaxframe = math.floor(duration / FRAMES + .5)
    inst._lightframe = net_ushortint(inst.GUID, "magic_light_fx._lightframe", "lightdirty")
    inst._lightframe:set(inst._lightmaxframe)
    inst._lightdead = net_bool(inst.GUID, "magic_light_fx._lightdead")
    inst._lighttask = nil

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        inst:ListenForEvent("lightdirty", OnLightDirty)

        return inst
    end

    inst.setprogress = setprogress
    inst.setdead = setdead
    inst.persists = false

    return inst
end

local function lightfxfn()
    return lightfx_commonfn(TUNING.ALBINO_TRUNK_LIGHT_DURATION)
end

return Prefab("common/inventory/trunk_forest", create_forest, assets, prefabs),
	   Prefab("common/inventory/trunk_frost", create_frost, assets, prefabs),
	   Prefab("common/inventory/trunk_feathered", create_feathered, assets, prefabs),
	   Prefab("common/inventory/trunk_rocky", create_rocky, assets, prefabs),
	   Prefab("common/inventory/trunk_nightmare", create_nightmare, assets, prefabs),
	   Prefab("common/inventory/trunk_albino", create_albino, assets, prefabs),
	   Prefab("magic_light", lightfn, nil, lightprefabs),
       Prefab("magic_light_fx", lightfxfn)