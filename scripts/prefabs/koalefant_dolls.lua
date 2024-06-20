local assets=
{
	Asset("ANIM", "anim/koalefant_dolls.zip"),
	Asset("ATLAS", "images/inventoryimages/koalefant_albino_doll.xml"),
	Asset("ATLAS", "images/inventoryimages/koalefant_feathered_doll.xml"),
	Asset("ATLAS", "images/inventoryimages/koalefant_forest_doll.xml"),
	Asset("ATLAS", "images/inventoryimages/koalefant_frost_doll.xml"),
	Asset("ATLAS", "images/inventoryimages/koalefant_nightmare_doll.xml"),
	Asset("ATLAS", "images/inventoryimages/koalefant_rocky_doll.xml"),
	Asset("ATLAS", "images/inventoryimages/koalefant_summer_doll.xml"),
	Asset("ATLAS", "images/inventoryimages/koalefant_winter_doll.xml"),
}  

local function summerfn()
	local inst = CreateEntity()
	
    inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()
	
	MakeInventoryPhysics(inst)
	
	inst.AnimState:SetBank("koalefant_dolls")
	inst.AnimState:SetBuild("koalefant_dolls")
	inst.AnimState:PlayAnimation("koalefant_summer")
    
	inst:AddTag("molebait")
    inst:AddTag("cattoy")
	
	inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
	
	inst:AddComponent("inspectable")
	inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.atlasname = "images/inventoryimages/koalefant_summer_doll.xml"
	
	inst:AddComponent("tradable")
	inst.components.tradable.goldvalue = math.random(1,6)
	
	MakeHauntableLaunchAndSmash(inst)

    inst:AddComponent("bait")
	
	return inst
end

local function albinofn()
	local inst = CreateEntity()
	
    inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()
	
	MakeInventoryPhysics(inst)
	
	inst.AnimState:SetBank("koalefant_dolls")
	inst.AnimState:SetBuild("koalefant_dolls")
	inst.AnimState:PlayAnimation("koalefant_albino")
    
	inst:AddTag("molebait")
    inst:AddTag("cattoy")
	
	inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
	
	inst:AddComponent("inspectable")
	inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.atlasname = "images/inventoryimages/koalefant_albino_doll.xml"
	
	inst:AddComponent("tradable")
	inst.components.tradable.goldvalue = math.random(1,6)
	
	MakeHauntableLaunchAndSmash(inst)

    inst:AddComponent("bait")
	
	return inst
end

local function nightmarefn()
	local inst = CreateEntity()
	
    inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()
	
	MakeInventoryPhysics(inst)
	
	inst.AnimState:SetBank("koalefant_dolls")
	inst.AnimState:SetBuild("koalefant_dolls")
	inst.AnimState:PlayAnimation("koalefant_nightmare")
    
	inst:AddTag("molebait")
    inst:AddTag("cattoy")
	
	inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
	
	inst:AddComponent("inspectable")
	inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.atlasname = "images/inventoryimages/koalefant_nightmare_doll.xml"
	
	inst:AddComponent("tradable")
	inst.components.tradable.goldvalue = math.random(1,6)
	
	MakeHauntableLaunchAndSmash(inst)

    inst:AddComponent("bait")
	
	return inst
end

local function featheredfn()
	local inst = CreateEntity()
	
    inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()
	
	MakeInventoryPhysics(inst)
	
	inst.AnimState:SetBank("koalefant_dolls")
	inst.AnimState:SetBuild("koalefant_dolls")
	inst.AnimState:PlayAnimation("koalefant_feathered")
    
	inst:AddTag("molebait")
    inst:AddTag("cattoy")
	
	inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
	
	inst:AddComponent("inspectable")
	inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.atlasname = "images/inventoryimages/koalefant_feathered_doll.xml"
	
	inst:AddComponent("tradable")
	inst.components.tradable.goldvalue = math.random(1,6)
	
	MakeHauntableLaunchAndSmash(inst)

    inst:AddComponent("bait")
	
	return inst
end

local function forestfn()
	local inst = CreateEntity()
	
    inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()
	
	MakeInventoryPhysics(inst)
	
	inst.AnimState:SetBank("koalefant_dolls")
	inst.AnimState:SetBuild("koalefant_dolls")
	inst.AnimState:PlayAnimation("koalefant_forest")
    
	inst:AddTag("molebait")
    inst:AddTag("cattoy")
	
	inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
	
	inst:AddComponent("inspectable")
	inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.atlasname = "images/inventoryimages/koalefant_forest_doll.xml"
	
	inst:AddComponent("tradable")
	inst.components.tradable.goldvalue = math.random(1,6)
	
	MakeHauntableLaunchAndSmash(inst)

    inst:AddComponent("bait")
	
	return inst
end

local function frostfn()
	local inst = CreateEntity()
	
    inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()
	
	MakeInventoryPhysics(inst)
	
	inst.AnimState:SetBank("koalefant_dolls")
	inst.AnimState:SetBuild("koalefant_dolls")
	inst.AnimState:PlayAnimation("koalefant_frost")
    
	inst:AddTag("molebait")
    inst:AddTag("cattoy")
	
	inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
	
	inst:AddComponent("inspectable")
	inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.atlasname = "images/inventoryimages/koalefant_frost_doll.xml"
	
	inst:AddComponent("tradable")
	inst.components.tradable.goldvalue = math.random(1,6)
	
	MakeHauntableLaunchAndSmash(inst)

    inst:AddComponent("bait")
	
	return inst
end

local function rockyfn()
	local inst = CreateEntity()
	
    inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()
	
	MakeInventoryPhysics(inst)
	
	inst.AnimState:SetBank("koalefant_dolls")
	inst.AnimState:SetBuild("koalefant_dolls")
	inst.AnimState:PlayAnimation("koalefant_rocky")
    
	inst:AddTag("molebait")
    inst:AddTag("cattoy")
	
	inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
	
	inst:AddComponent("inspectable")
	inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.atlasname = "images/inventoryimages/koalefant_rocky_doll.xml"
	
	inst:AddComponent("tradable")
	inst.components.tradable.goldvalue = math.random(1,6)
	
	MakeHauntableLaunchAndSmash(inst)

    inst:AddComponent("bait")
	
	return inst
end

local function winterfn()
	local inst = CreateEntity()
	
    inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()
	
	MakeInventoryPhysics(inst)
	
	inst.AnimState:SetBank("koalefant_dolls")
	inst.AnimState:SetBuild("koalefant_dolls")
	inst.AnimState:PlayAnimation("koalefant_winter")
    
	inst:AddTag("molebait")
    inst:AddTag("cattoy")
	
	inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
	
	inst:AddComponent("inspectable")
	inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.atlasname = "images/inventoryimages/koalefant_winter_doll.xml"
	
	inst:AddComponent("tradable")
	inst.components.tradable.goldvalue = math.random(1,6)
	
	MakeHauntableLaunchAndSmash(inst)

    inst:AddComponent("bait")
	
	return inst
end


return Prefab( "common/inventory/koalefant_summer_doll", summerfn, assets),
	   Prefab( "common/inventory/koalefant_albino_doll", albinofn, assets),
	   Prefab( "common/inventory/koalefant_nightmare_doll", nightmarefn, assets),
	   Prefab( "common/inventory/koalefant_frost_doll", frostfn, assets),
	   Prefab( "common/inventory/koalefant_forest_doll", forestfn, assets),
	   Prefab( "common/inventory/koalefant_feathered_doll", featheredfn, assets),
	   Prefab( "common/inventory/koalefant_winter_doll", winterfn, assets),
	   Prefab( "common/inventory/koalefant_rocky_doll", rockyfn, assets)
	   