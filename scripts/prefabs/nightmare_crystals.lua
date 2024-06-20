local assets = 
{
	Asset("ANIM", "anim/nightmare_crystals.zip"),
	Asset("ATLAS", "images/inventoryimages/nightmare_crystals.xml"),
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)
	
	inst.AnimState:SetBank("nightmare_crystals")
    inst.AnimState:SetBuild("nightmare_crystals")
    inst.AnimState:PlayAnimation("idle")
	
	MakeDragonflyBait(inst, 3)
	
	inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

	inst:AddComponent("inspectable")
	
	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.atlasname = "images/inventoryimages/nightmare_crystals.xml"
	
	inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM
	
	inst:AddComponent("fuel")
	inst.components.fuel.fueltype = FUELTYPE.NIGHTMARE
    inst.components.fuel.fuelvalue = TUNING.LARGE_FUEL
	
   	MakeSmallBurnable(inst, TUNING.MED_BURNTIME)
    MakeSmallPropagator(inst)
 
	inst:AddComponent("fertilizer")
    inst.components.fertilizer.fertilizervalue = TUNING.NIGHTMARE_CRYSTALS_FERTILIZE
    inst.components.fertilizer.soil_cycles = TUNING.NIGHTMARE_CRYSTALS_SOILCYCLES
	
	MakeHauntableLaunchAndIgnite(inst)

	return inst
end

return Prefab("nightmare_crystals", fn, assets)