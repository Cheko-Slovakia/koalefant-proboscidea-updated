local assets = 
{
	Asset("ANIM", "anim/frost_stone.zip"),
	Asset("ATLAS", "images/inventoryimages/frost_stone.xml"),
}

local function ondeploy (inst, pt) 
	inst = inst.components.stackable:Get()
    inst.Transform:SetPosition(pt:Get())
	inst.components.burnable:SetBurnTime(math.random(40, 75))
	inst.components.burnable:Ignite()
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
	
    MakeInventoryPhysics(inst)
	
	inst.AnimState:SetBank("frost_stone")
    inst.AnimState:SetBuild("frost_stone")
    inst.AnimState:PlayAnimation("idle")
	
	inst:AddTag("eyeturret")
	
	inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
	
    inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("inspectable")
    
    inst:AddComponent("burnable")
    inst.components.burnable:SetFXLevel(1)
    inst.components.burnable:SetBurnTime(math.random(40, 75))
    inst.components.burnable:AddBurnFX("frost_stone_flame", Vector3(0, 0.5, 0))
    inst.components.burnable:SetOnBurntFn(DefaultBurntFn)
    
	inst:AddComponent("fuel")
	inst.components.fuel.fueltype = "CHEMICAL"
    inst.components.fuel.fuelvalue = TUNING.LARGE_FUEL
	
    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.atlasname = "images/inventoryimages/frost_stone.xml"
	
	inst:AddComponent("deployable")
	inst.components.deployable:SetDeployMode(DEPLOYMODE.ANYWHERE)
    inst.components.deployable.ondeploy = ondeploy
	
    return inst
end

return Prefab( "common/inventory/frost_stone", fn, assets),
	   MakePlacer("common/frost_stone_placer", "frost_stone", "frost_stone", "idle")