local assets =
{
	Asset("ANIM", "anim/moonglow_shard_flame.zip"),
	Asset("SOUND", "sound/common.fsb"),
}

local firelevels = 
{
    {anim="level1", sound="dontstarve/common/nightlight", radius=2, intensity=.75, falloff=.33, colour = {84/255,  122/255, 156/255}, soundintensity=.1},
    {anim="level2", sound="dontstarve/common/nightlight", radius=2, intensity=.8, falloff=.33, colour = {84/255,  122/255, 156/255}, soundintensity=.3},
    {anim="level3", sound="dontstarve/common/nightlight", radius=2, intensity=.8, falloff=.33, colour = {84/255,  122/255, 156/255}, soundintensity=.6},
    {anim="level4", sound="dontstarve/common/nightlight", radius=2, intensity=.9, falloff=.33, colour = {84/255,  122/255, 156/255}, soundintensity=1},
}

local function fn()
	local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddLight()
    inst.entity:AddNetwork()
	
	inst.AnimState:SetBank("campfire_fire")
    inst.AnimState:SetBuild("moonglow_shard_flame")
	inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst.AnimState:SetRayTestOnBB(true)
 
    inst:AddTag("FX")
	inst:AddTag("NOCLICK")
	
	inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("firefx")
    inst.components.firefx.levels = firelevels
	
	inst.AnimState:SetFinalOffset(-1)
	 
    return inst
end

return Prefab( "common/fx/moonglow_shard_flame", fn, assets) 