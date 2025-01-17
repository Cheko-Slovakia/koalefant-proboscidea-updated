require "behaviours/wander"
require "behaviours/faceentity"
require "behaviours/chaseandattack"
require "behaviours/panic"
require "behaviours/runaway"


local MAX_CHASE_TIME = 6
local WANDER_DIST_DAY = 20
local WANDER_DIST_NIGHT = 5

local RUN_AWAY_DIST = 6
local STOP_RUN_AWAY_DIST = 12
local START_FACE_DIST = 14
local KEEP_FACE_DIST = 20

local function GetFaceTargetFn(inst)
    local target = GetClosestInstWithTag("player", inst, START_FACE_DIST)
    if target and not target:HasTag("notarget") then
        return target
    end
end

local function KeepFaceTargetFn(inst, target)
    return inst:GetDistanceSqToInst(target) <= KEEP_FACE_DIST * KEEP_FACE_DIST and not target:HasTag("notarget")
end

local function ShouldRunAway(guy)
	return guy:HasTag("character") and not guy:HasTag("notarget")
end


local CowardBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

function CowardBrain:OnStart()
    
    local root = PriorityNode(
    {
        WhileNode( function() return self.inst.components.health.takingfiredamage end, "OnFire", Panic(self.inst)),
		WhileNode( function() return self.inst.components.attackmemory.attacked end, "attacked" , RunAway(self.inst, "scarytoprey", 15, 30)),
        --ChaseAndAttack(self.inst, MAX_CHASE_TIME),
        SequenceNode{
            FaceEntity(self.inst, GetFaceTargetFn, KeepFaceTargetFn, 0.5),
            RunAway(self.inst, ShouldRunAway, RUN_AWAY_DIST, STOP_RUN_AWAY_DIST)
        },
        FaceEntity(self.inst, GetFaceTargetFn, KeepFaceTargetFn),
        Wander(self.inst)
    }, .25)
    
    self.bt = BT(self.inst, root)
end

return CowardBrain