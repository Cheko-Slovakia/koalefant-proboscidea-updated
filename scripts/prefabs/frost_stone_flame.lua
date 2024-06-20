local assets =
{
	Asset("ANIM", "anim/frost_stone_flame.zip"),
	Asset("SOUND", "sound/common.fsb"),
}


local heats = {-10, -20, -30, -40}

local function GetHeatFn(inst)
	return heats[inst.components.firefx.level] or -20
end

local function fn()

    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddLight()
    inst.entity:AddNetwork()
	
	inst.AnimState:SetBank("campfire_fire")
    inst.AnimState:SetBuild("frost_stone_flame")
	inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst.AnimState:SetRayTestOnBB(true)

    inst:AddTag("FX")
	inst:AddTag("NOCLICK")
	inst:AddTag("HASHEATER")
	
	inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
	
    inst:AddComponent("heater")
    inst.components.heater.heatfn = GetHeatFn
    inst.components.heater:SetThermics(false, true)
    
    inst:AddComponent("firefx")
    inst.components.firefx.levels = 
	{
		{anim="level3", sound="dontstarve/common/nightlight", radius=3, intensity=.8, falloff=.33, colour = {0, 183/255, 1}, soundintensity=.3},
	}
	
	inst.AnimState:SetFinalOffset(-1)
	
    return inst
end

return Prefab( "common/fx/frost_stone_flame", fn, assets) 