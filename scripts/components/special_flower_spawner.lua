local Special_Flower_Spawner = Class(function(self, inst)
self.inst = inst
self.forest_locations = {}
self.swamp_locations = {}
self.firefly_flower = 0
self.evil_root = 0
end)

function Special_Flower_Spawner:GetSpawnLocations()  
    local ground = TheWorld()
    for i,node in ipairs(ground.topology.nodes) do
		local x = node.x
		local y = 0
		local z = node.y
		local tile = ground.Map:GetTileAtPoint(x, y, z)
			if not (ground.Map and tile == GROUND.IMPASSABLE or tile > GROUND.UNDERGROUND) and tile == GROUND.FOREST or tile == GROUND.DECIDUOUS then
				table.insert(self.forest_locations, {x = x, y = y, z = z})
			elseif not (ground.Map and tile == GROUND.IMPASSABLE or tile > GROUND.UNDERGROUND) and tile == GROUND.MARSH then
				table.insert(self.swamp_locations, {x = x, y = y, z = z})
			end
	end
end

function Special_Flower_Spawner:SpawnFireflyFlower()
	if #self.forest_locations == 0 then
		self:GetSpawnLocations()
		local num = math.random(1, #self.forest_locations)
		local x = self.forest_locations[num]["x"]
		local y = self.forest_locations[num]["y"]
		local z = self.forest_locations[num]["z"]
		local pt = Vector3(x,y,z)
		local ground = TheWorld() 
		local radius = 10	  
		local theta = math.random() * 2 * PI
		local result_offset = FindValidPositionByFan(theta, radius, 8, function(offset)
            local x,y,z = (pt + offset):Get()
			local tile = ground.Map:GetTileAtPoint((pt + offset):Get())
            local ents = TheSim:FindEntities(x,y,z , 1)
				if #ents <= 0 and tile == 7 or tile == 30 then 
					return true
				else 
					return false
				end
			end)
		if result_offset then 
			local tile = ground.Map:GetTileAtPoint((pt + result_offset):Get())
				if not (ground.Map and tile == GROUND.IMPASSABLE or tile > GROUND.UNDERGROUND) then
					local flower = SpawnPrefab("firefly_flower")
					flower.components.pickable:MakeBarren()
					flower.Transform:SetPosition((pt + result_offset):Get())
					self.firefly_flower = self.firefly_flower + 1
				end			
		end
	else
		local num = math.random(1, #self.forest_locations)
		local x = self.forest_locations[num]["x"]
		local y = self.forest_locations[num]["y"]
		local z = self.forest_locations[num]["z"]
		local pt = Vector3(x,y,z)
		local ground = TheWorld() 
		local radius = 10	  
		local theta = math.random() * 2 * PI
		local result_offset = FindValidPositionByFan(theta, radius, 8, function(offset)
            local x,y,z = (pt + offset):Get()
			local tile = ground.Map:GetTileAtPoint((pt + offset):Get())
            local ents = TheSim:FindEntities(x,y,z , 1)
				if #ents <= 0 and tile == 7 or tile == 30 then 
					return true
				else 
					return false
				end
			end)
		if result_offset then 
			local tile = ground.Map:GetTileAtPoint((pt + result_offset):Get())
				if not (ground.Map and tile == GROUND.IMPASSABLE or tile > GROUND.UNDERGROUND) then
					local flower = SpawnPrefab("firefly_flower")
					flower.components.pickable:MakeBarren()
					flower.Transform:SetPosition((pt + result_offset):Get())
					self.firefly_flower = self.firefly_flower + 1
				end			
		end
	end
end

function Special_Flower_Spawner:SpawnEvilRoot()
	if #self.swamp_locations == 0 then
		self:GetSpawnLocations()
		local num = math.random(1, #self.swamp_locations)
		local x = self.swamp_locations[num]["x"]
		local y = self.swamp_locations[num]["y"]
		local z = self.swamp_locations[num]["z"]
		local pt = Vector3(x,y,z)
		local ground = TheWorld() 
		local radius = 10	  
		local theta = math.random() * 2 * PI
		local result_offset = FindValidPositionByFan(theta, radius, 8, function(offset)
            local x,y,z = (pt + offset):Get()
			local tile = ground.Map:GetTileAtPoint((pt + offset):Get())
            local ents = TheSim:FindEntities(x,y,z , 1)
				if #ents <= 0 and tile == 8 then 
					return true
				else 
					return false
				end
			end)
		if result_offset then 
			local tile = ground.Map:GetTileAtPoint((pt + result_offset):Get())
				if not (ground.Map and tile == GROUND.IMPASSABLE or tile > GROUND.UNDERGROUND) then
					local flower = SpawnPrefab("evil_root")
					flower.components.pickable:MakeBarren()
					flower.Transform:SetPosition((pt + result_offset):Get())
					self.evil_root = self.evil_root + 1
					print("spawned evil root")
				end			
		end
	else
		local num = math.random(1, #self.swamp_locations)
		local x = self.swamp_locations[num]["x"]
		local y = self.swamp_locations[num]["y"]
		local z = self.swamp_locations[num]["z"]
		local pt = Vector3(x,y,z)
		local ground = TheWorld() 
		local radius = 10	  
		local theta = math.random() * 2 * PI
		local result_offset = FindValidPositionByFan(theta, radius, 8, function(offset)
            local x,y,z = (pt + offset):Get()
			local tile = ground.Map:GetTileAtPoint((pt + offset):Get())
            local ents = TheSim:FindEntities(x,y,z , 1)
				if #ents <= 0 and tile == 8 then 
					return true
				else 
					return false
				end
			end)
		if result_offset then 
			local tile = ground.Map:GetTileAtPoint((pt + result_offset):Get())
				if not (ground.Map and tile == GROUND.IMPASSABLE or tile > GROUND.UNDERGROUND ) then
					local flower = SpawnPrefab("evil_root")
					flower.components.pickable:MakeBarren()
					flower.Transform:SetPosition((pt + result_offset):Get())
					self.evil_root = self.evil_root + 1
				end			
		end
	end
end

function Special_Flower_Spawner:OnSave()
	local data = {}
	data.firefly_flower = self.firefly_flower
	data.evil_root = self.evil_root
	return data
end

function Special_Flower_Spawner:OnLoad(data)
	if data then 
		self.firefly_flower = data.firefly_flower or 0
		self.evil_root = data.evil_root	or 0
	end
end

return Special_Flower_Spawner