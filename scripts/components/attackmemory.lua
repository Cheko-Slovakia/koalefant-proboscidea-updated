local AttackMemory = Class(function(self, inst)
    self.inst = inst
	self.attacked = false
	self.inst:ListenForEvent( "healthdelta", function() self:Attacked() end )
	self.inst:DoPeriodicTask(30, function() self:Reset() end)

end)

function AttackMemory:Attacked()
self.attacked = true
end 

function AttackMemory:Reset()
self.attacked = false
end 

return AttackMemory