local assets =
{
	Asset("ANIM", "anim/forest_seed.zip"),
	Asset("ATLAS", "images/inventoryimages/forest_seed.xml"),
}

local trees  = 
{
	"evergreen_short",
	"evergreen_sparse_short",
	"deciduoustree_short",
}

local materials = 
{
	"grass",
	"sapling",
	"flower",
	"flower_evil",
}

local food = 
{
	"berrybush",
	"berrybush2",
	"red_mushroom",
	"green_mushroom",
	"blue_mushroom",
	"flower",
	"flower_evil",
}

local function growplant(inst)
    inst.growtask = nil
    inst.growtime = nil
	inst.issapling:set(false)
	local random_plant = math.random(1,100)
	if random_plant <= 50 then
		local plant_prefab = GetRandomItem(trees)
		local plant = SpawnPrefab(plant_prefab) 
		local fx = SpawnPrefab("forest_seed_fx")
		if plant then 
			fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
			plant.Transform:SetPosition(inst.Transform:GetWorldPosition()) 
			plant:growfromseed()
			inst:Remove()
		end
	elseif random_plant > 50 and random_plant <= 80 then
		local plant_prefab = GetRandomItem(materials)
		local plant = SpawnPrefab(plant_prefab) 
		local fx = SpawnPrefab("forest_seed_fx")
		if plant then 
			fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
			plant.Transform:SetPosition(inst.Transform:GetWorldPosition()) 
			inst:Remove()
		end
	elseif random_plant > 80 then
		local plant_prefab = GetRandomItem(food)
		local plant = SpawnPrefab(plant_prefab)
		local fx = SpawnPrefab("forest_seed_fx")
		if plant then 
			fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
			plant.Transform:SetPosition(inst.Transform:GetWorldPosition()) 
			inst:Remove()
		end
	end
end

local function plant(inst, growtime)
    inst:RemoveComponent("inventoryitem")
    MakeHauntableIgnite(inst)
    RemovePhysicsColliders(inst)
    inst.AnimState:PlayAnimation("idle_planted")
    inst.SoundEmitter:PlaySound("dontstarve/wilson/plant_tree")
    inst.growtime = GetTime() + growtime
    inst.issapling:set(true)
    inst.growtask = inst:DoTaskInTime(growtime, growplant)
end

local function ondeploy (inst, pt) 
    inst = inst.components.stackable:Get()
    inst.Transform:SetPosition(pt:Get() )
    local timeToGrow = GetRandomWithVariance(TUNING.FOREST_SEED_GROWTIME.base, TUNING.FOREST_SEED_GROWTIME.random)
    plant(inst, timeToGrow)	
end

local function stopgrowing(inst)
    if inst.growtask then
        inst.growtask:Cancel()
        inst.growtask = nil
    end
    inst.growtime = nil
    inst.issapling:set(false)
end

local function restartgrowing(inst)
    if inst and not inst.growtask then
        local growtime = GetRandomWithVariance(TUNING.FOREST_SEED_GROWTIME.base, TUNING.FOREST_SEED_GROWTIME.random)
        inst.growtime = GetTime() + growtime
        inst.growtask = inst:DoTaskInTime(growtime, growplant)
    end
end

local function describe(inst)
    if inst.growtime then
        return "PLANTED"
	end
end

local function displaynamefn(inst)
    return STRINGS.NAMES[inst.issapling:value() and "FOREST_SEED_SAPLING" or "FOREST_SEED"]
end

local function OnSave(inst, data)
    if inst.growtime then
        data.growtime = inst.growtime - GetTime()
    end
end

local function OnLoad(inst, data)
    if data and data.growtime then
        plant(inst, data.growtime)
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("forest_seed")
    inst.AnimState:SetBuild("forest_seed")
    inst.AnimState:PlayAnimation("idle")
    
	inst.issapling = net_bool(inst.GUID, "issapling")
    inst.issapling:set(false)

	inst.displaynamefn = displaynamefn

    inst:AddTag("cattoy")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
	
	MakeDragonflyBait(inst, 3)
	
    inst:AddComponent("edible")
    inst.components.edible.foodtype = "WOOD"
    inst.components.edible.woodiness = 2

    inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = describe
    
    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.SMALL_FUEL
    
    MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
    inst:ListenForEvent("onignite", stopgrowing)
    inst:ListenForEvent("onextinguish", restartgrowing)
    MakeSmallPropagator(inst)
	
	inst:ListenForEvent("onignite", stopgrowing)
	inst:ListenForEvent("onextinguish", restartgrowing)
    
    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.atlasname = "images/inventoryimages/forest_seed.xml"
    
	MakeHauntableLaunchAndIgnite(inst)
	
    inst:AddComponent("deployable")
    inst.components.deployable:SetDeployMode(DEPLOYMODE.PLANT)
    inst.components.deployable.ondeploy = ondeploy
    
    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    return inst
end

return Prefab("common/inventory/forest_seed", fn, assets),
	   MakePlacer("common/forest_seed_placer", "forest_seed", "forest_seed", "idle_planted") 