local assets =
{
    Asset("ANIM", "anim/special_tracks.zip"),
    Asset("ANIM", "anim/special_smoke.zip"),
}

local prefabs =
{
     "special_smoke"
}

local AUDIO_HINT_MIN = 10
local AUDIO_HINT_MAX = 60

local function GetVerb(inst)
    return "INVESTIGATE"
end

local function OnInvestigated(inst, doer)
    local pt = Vector3(inst.Transform:GetWorldPosition())

    local specialhunter = TheWorld.components.specialhunter
	if specialhunter ~= nil then
		specialhunter:OnDirtInvestigated(pt, doer)
	end

    SpawnPrefab("special_smoke").Transform:SetPosition(pt:Get())
    inst:Remove()
end

local function create(sim)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst:AddTag("dirtpile")
    
    inst.AnimState:SetBank("track")
    inst.AnimState:SetBuild("koalefant_tracks")
    inst.AnimState:SetRayTestOnBB(true)
    inst.AnimState:PlayAnimation("idle_pile")
	
	inst.GetActivateVerb = GetVerb
	
	inst.entity:SetPristine()
	
	if not TheWorld.ismastersim then
        return inst
    end
    
    inst:AddComponent("inspectable")
    
    inst:AddComponent("activatable")    
    
    inst.components.activatable.OnActivate = OnInvestigated
    inst.components.activatable.inactive = true

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_SMALL)
    inst.components.hauntable:SetOnHauntFn(function(inst, haunter)
        OnInvestigated(inst, haunter)
        return true
    end)

    inst.persists = false
    return inst
end

return Prefab("forest/objects/specialdirtpile", create, assets, prefabs)