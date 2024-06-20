
local function DoSpawn(inst)
    local spawner = inst.components.periodicspawner_table
    if spawner then
		spawner.target_time = nil    
		spawner:TrySpawn()
        spawner:Start()
    end
end

local PeriodicSpawner_Table = Class(function(self, inst)
    self.inst = inst
    self.basetime = 40
    self.randtime = 60
    self.prefabs = {}
    
    self.range = nil
    self.density = nil
    self.spacing = nil
    
    self.onspawn = nil
    self.spawntest = nil
    
    self.spawnoffscreen = false
end)

function PeriodicSpawner_Table:SetPrefabs(prefabs)
     for k,v in pairs(prefabs) do
		table.insert(self.prefabs, v)
     end
end

function PeriodicSpawner_Table:SetRandomTimes(basetime, variance)
    self.basetime = basetime
    self.randtime = variance
end

function PeriodicSpawner_Table:SetDensityInRange(range, density)
    self.range = range
    self.density = density
end

function PeriodicSpawner_Table:SetMinimumSpacing(spacing)
    self.spacing = spacing
end

function PeriodicSpawner_Table:SetOnlySpawnOffscreen(offscreen)
    self.spawnoffscreen = offscreen
end

function PeriodicSpawner_Table:SetOnSpawnFn(fn)
    self.onspawn = fn
end

function PeriodicSpawner_Table:SetSpawnTestFn(fn)
    self.spawntest = fn
end

function PeriodicSpawner_Table:TrySpawn()
    local prefab = GetRandomItem(self.prefabs)
    if not self.inst:IsValid() or not prefab then
        return
    end

	if self.inst.components.sleeper then
		if self.inst.components.sleeper:IsAsleep( ) then
			return
		end
	end
	
    local canspawn = true
    
    if self.range or self.spacing then
        local pos = Vector3(self.inst.Transform:GetWorldPosition())
        local ents = TheSim:FindEntities(pos.x,pos.y,pos.z, self.range or self.spacing)
        local count = 0
        for k,v in pairs(ents) do
			for i,j in pairs(self.prefabs) do
				if not v:IsInLimbo() then
					if v.prefab == j then
						if self.spacing and v:GetDistanceSqToInst(self.inst) < self.spacing*self.spacing then
							canspawn = false
							break
						end
						count = count + 1
					end
				end
			end
        end
		
        if self.density and count >= self.density then
            canspawn = false
        end
    end
    
    if self.spawnoffscreen and not self.inst:IsAsleep() then
        canspawn = false
    end
    
    if self.spawntest then
        canspawn = canspawn and self.spawntest(self.inst)
    end

    if canspawn then
        local inst = SpawnPrefab(prefab)
        if self.onspawn then
            self.onspawn(self.inst, inst)
        end
        inst.Transform:SetPosition(self.inst.Transform:GetWorldPosition())
    end
    return canspawn
end

function PeriodicSpawner_Table:Start()
    local t = self.basetime + math.random()*self.randtime
    self.target_time = GetTime() + t
    self.task = self.inst:DoTaskInTime(t, DoSpawn)
end

function PeriodicSpawner_Table:Stop()
    self.target_time = nil
    if self.task then
        self.task:Cancel()
        self.task = nil
    end
end

function PeriodicSpawner_Table:LongUpdate(dt)
	if self.target_time then
		if self.task then
			self.task:Cancel()
			self.task = nil
		end
		local time_to_wait = self.target_time - GetTime() - dt
		
		if time_to_wait <= 0 then
			DoSpawn(self.inst)		
		else
			self.target_time = GetTime() + time_to_wait
			self.task = self.inst:DoTaskInTime(time_to_wait, DoSpawn)
		end
	end
end

return PeriodicSpawner_Table