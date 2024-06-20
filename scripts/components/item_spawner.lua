local Item_Spawner = Class(function(self, inst)
    self.inst = inst
	self.inst:ListenForEvent("nighttime", function() self:SpawnItem() end, GetWorld())
end)

function Item_Spawner:SpawnItem()
	if self.inst.components.pickable.canbepicked == true then
		local number = GetClock().numcycles
		if (number % 2 == 0) then
			local random_chance = math.random(1,2)
			if random_chance == 2 then
				local ground = GetWorld()
				local pt = Vector3(self.inst.Transform:GetWorldPosition())
				local theta = math.random() * 2 * PI
				local radius = 2
				local result_offset = FindValidPositionByFan(theta, radius, 8, function(offset)
				local x,y,z = (pt + offset):Get()
				local ents = TheSim:FindEntities(x,y,z , 1)
					if #ents <= 0 then 
						return true
					else 
						return false
					end
				end)
				if result_offset then 
				local tile = ground.Map:GetTileAtPoint((pt + result_offset):Get())
					if not (ground.Map and tile == GROUND.IMPASSABLE or tile > GROUND.UNDERGROUND ) then
						local item = nil
						if self.inst:HasTag("firefly_flower") then
							item = SpawnPrefab("fireflies")
						elseif self.inst:HasTag("evil_root") then
							item = SpawnPrefab("flower_evil")
						end						
						item.Transform:SetPosition((pt + result_offset):Get())
					end
				end
			end
		end
	end
end

return Item_Spawner