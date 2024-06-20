local function Count(self)
	self.blooming_time = self.blooming_time + 1
	if self.blooming_time > 1 then 
		if self.inst:HasTag("firefly_flower") then

		elseif self.inst:HasTag("evil_root") then

		end
		self.inst:Remove()
	end
end

local Blooming = Class(function(self, inst)
    self.inst = inst
	self.blooming_time = 0
	
	self:WatchWorldState("cycles", Count)
end)

function Blooming:OnSave()
	local data = {}
	data.blooming_time = self.blooming_time
	return data
end

function Blooming:OnLoad(data)
	if data then
		self.blooming_time = data.blooming_time
	end
end

return Blooming
