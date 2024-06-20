local assets =
{
	Asset("ANIM", "anim/moondust.zip"),
	Asset("ATLAS", "images/inventoryimages/moondust.xml"),
}

local prefabs =
{
    "explode_small",
	"purple_multifirework",
	"purple_singlefirework",
	"blue_multifirework",
	"blue_singlefirework",
	"red_multifirework",
	"red_singlefirework",	
}

local fireworks = 
{
	"purple_multifirework",
	"purple_singlefirework",
	"blue_multifirework",
	"blue_singlefirework",
	"red_multifirework",
	"red_singlefirework",
}

local function OnIgniteFn(inst)
    inst.SoundEmitter:PlaySound("dontstarve/common/blackpowder_fuse_LP", "hiss")
	local firework = SpawnPrefab(GetRandomItem(fireworks))
	firework.Transform:SetPosition(inst.Transform:GetWorldPosition())
end

local function OnExtinguishFn(inst)
    inst.SoundEmitter:KillSound("hiss")
end

local function OnExplodeFn(inst)
    local pos = Vector3(inst.Transform:GetWorldPosition())
    inst.SoundEmitter:KillSound("hiss")
    inst.SoundEmitter:PlaySound("dontstarve/common/blackpowder_explo")
	local num = math.random(15, 35)
	for k = 1, num do
		local theta = math.random() * 2 * PI
		local radius = math.random(1,8)
		local result_offset = FindValidPositionByFan(theta, radius, 4, function(offset)
		local x,y,z = (pos + offset):Get()
		local ents = TheSim:FindEntities(x,y,z , 1)
		if #ents <= 2 then 
			return true
		else 
			return false
		end
		end)
		if result_offset then
			local delay = math.random(2, 4)
			local firework = SpawnPrefab(GetRandomItem(fireworks))
			inst:DoTaskInTime(delay, firework.Transform:SetPosition((pos + result_offset):Get()))
		end
	end
	SpawnPrefab("explode_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
end

local function OnPutInInv(inst, owner)
    if owner.prefab == "mole" then
        inst.components.explosive:OnBurnt()
    end
end

local function fn()
	local inst = CreateEntity()
	
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()
	
    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("moondust")
    inst.AnimState:SetBuild("moondust")
    inst.AnimState:PlayAnimation("idle")
    
	inst:AddTag("molebait")
	
	inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
	
    inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("inspectable")
    
	inst:AddComponent("burnable")
    inst.components.burnable:SetFXLevel(2)
    inst.components.burnable:SetBurnTime(3+math.random()*3)
    inst.components.burnable:AddBurnFX("moondust_fire", Vector3(0, 0, 0))
    inst.components.burnable:SetOnBurntFn(DefaultBurntFn)
	inst.components.burnable:SetOnExtinguishFn(OnExtinguishFn)
	
    MakeSmallPropagator(inst)
	
	inst.components.burnable:SetOnBurntFn(nil)
    inst.components.burnable:SetOnIgniteFn(OnIgniteFn)
    inst.components.burnable:SetOnExtinguishFn(OnExtinguishFn)
	
	inst:AddComponent("explosive")
    inst.components.explosive:SetOnExplodeFn(OnExplodeFn)
	inst.components.explosive.lightonexplode = false
    inst.components.explosive.explosivedamage = TUNING.MOONDUST_DAMAGE
    
    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.atlasname = "images/inventoryimages/moondust.xml"
    inst.components.inventoryitem:SetOnPutInInventoryFn(OnPutInInv)
	
	inst:AddComponent("bait")
	
	MakeHauntableLaunchAndIgnite(inst)
	 
    return inst
end

return Prefab( "common/inventory/moondust", fn, assets, prefabs) 
