--------------------------------------------------------------------------
--[[ specialhunter class definition ]]
--------------------------------------------------------------------------

return Class(function(self, inst)

assert(TheWorld.ismastersim, "Special Hunter should not exist on client")

local SPECIAL_HUNT_UPDATE = 3

local MIN_SPECIAL_TRACKS = 6
local MAX_SPECIAL_TRACKS = 12

local TOOCLOSE_TO_SPECIAL_HUNT_SQ = (TUNING.MIN_JOINED_SPECIAL_HUNT_DISTANCE) * (TUNING.MIN_JOINED_SPECIAL_HUNT_DISTANCE)

local _dirt_prefab = "specialdirtpile"
local _track_prefab = "special_track"

local _beast_prefab_feather = "koalefant_feathered"
local _beast_prefab_forest = "koalefant_forest"
local _beast_prefab_rocky = "koalefant_rocky"
local _beast_prefab_frost = "koalefant_frost"
local _beast_prefab_nightmare = "koalefant_nightmare"
local _beast_prefab_albino = "koalefant_albino"

local _alternate_beasts = {"warg", "spat"}

local trace = function() end

--------------------------------------------------------------------------
--[[ Member variables ]]
--------------------------------------------------------------------------

--Public
self.inst = inst
    
-- Private
local _activeplayers = {}
local _activespecialhunts = {}

local OnUpdateSpecialHunt

--------------------------------------------------------------------------
--[[ Private member functions ]]
--------------------------------------------------------------------------

local function GetMaxSpecialHunts()
	return #_activeplayers
end

local function RemoveDirt(specialhunt)
	assert(specialhunt)
    trace("SpecialHunter:RemoveDirt")
    if specialhunt.lastdirt then
        trace("   removing old dirt")
        specialhunt.lastdirt:Remove()
        specialhunt.lastdirt = nil
    else
        trace("   nothing to remove")
    end
end


local function StopSpecialHunt(specialhunt)
	assert(specialhunt)
    trace("SpecialHunter:StopSpecialHunt")

    RemoveDirt(specialhunt)

    if specialhunt.specialhunttask then
        trace("   stopping")
        specialhunt.specialhunttask:Cancel()
        specialhunt.specialhunttask = nil
		
    else
        trace("   nothing to stop")
    end
end

local function BeginSpecialHunt(specialhunt)
	assert(specialhunt)
    trace("SpecialHunter:BeginSpecialHunt")

    specialhunt.specialhunttask = self.inst:DoPeriodicTask(SPECIAL_HUNT_UPDATE, function() OnUpdateSpecialHunt(specialhunt) end)
    if specialhunt.specialhunttask then
        trace("The Special Hunt Begins!")
    else
        trace("The Special Hunt ... failed to begin.")
    end

end

local function StopCooldown(specialhunt)
	assert(specialhunt)
    trace("SpecialHunter:StopCooldown")
    if specialhunt.cooldowntask then
        trace("    stopping")
        specialhunt.cooldowntask:Cancel()
        specialhunt.cooldowntask = nil
        specialhunt.cooldowntime = nil
    else
        trace("    nothing to stop")
    end
end

local function OnCooldownEnd(specialhunt)
	assert(specialhunt)
    trace("SpecialHunter:OnCooldownEnd")
    
    StopCooldown(specialhunt) -- clean up references
    StopSpecialHunt(specialhunt)

    BeginSpecialHunt(specialhunt)
end

local function RemoveSpecialHunt(specialhunt)
    StopSpecialHunt(specialhunt)
	for i,v in ipairs(_activespecialhunts) do
		if v == specialhunt then
			table.remove(_activespecialhunts, i)
			return
		end
	end
	assert(false)
end

local function StartCooldown(specialhunt, cooldown)
	assert(specialhunt)
    local cooldown = cooldown or math.random(TUNING.SPECIAL_HUNT_COOLDOWN - TUNING.SPECIAL_HUNT_COOLDOWNDEVIATION, TUNING.SPECIAL_HUNT_COOLDOWN + TUNING.SPECIAL_HUNT_COOLDOWNDEVIATION)
    trace("SpecialHunter:StartCooldown", cooldown)

    StopSpecialHunt(specialhunt)
    StopCooldown(specialhunt)

	if #_activespecialhunts > GetMaxSpecialHunts() then
		RemoveSpecialHunt(specialhunt)
		return
	end

    if cooldown and cooldown > 0 then
        trace("The SpecialHunt begins in", cooldown)
		specialhunt.activeplayer = nil
        specialhunt.lastdirt = nil
        specialhunt.lastdirttime = nil

        specialhunt.cooldowntask = self.inst:DoTaskInTime(cooldown, function() OnCooldownEnd(specialhunt) end)
        specialhunt.cooldowntime = GetTime() + cooldown
    end
end


local function StartSpecialHunt()
    trace("SpecialHunter:StartSpecialHunt")
	-- Given the way special hunt is used, it should really be its own class now
	local newspecialhunt = {
						lastdirt = nil,
						direction = nil,
						activeplayer = nil,
					}
	table.insert(_activespecialhunts, newspecialhunt)
	local startspecialhunt = math.random(TUNING.SPECIAL_HUNT_COOLDOWN - TUNING.SPECIAL_HUNT_COOLDOWNDEVIATION, TUNING.SPECIAL_HUNT_COOLDOWN + TUNING.SPECIAL_HUNT_COOLDOWNDEVIATION)
    self.inst:DoTaskInTime(0, function(inst) StartCooldown(newspecialhunt, startspecialhunt) end)
	return newspecialhunt
end

local function GetSpawnPoint(pt, radius, specialhunt)
    trace("SpecialHunter:GetSpawnPoint", tostring(pt), radius)

    local angle = specialhunt.direction
    if angle then
        local offset = Vector3(radius * math.cos( angle ), 0, -radius * math.sin( angle ))
        local spawn_point = pt + offset
        trace(string.format("SpecialHunter:GetSpawnPoint RESULT %s, %2.2f", tostring(spawn_point), angle/DEGREES))
        return spawn_point
    end

end

local function SpawnDirt(pt,specialhunt)
	assert(specialhunt)
    trace("SpecialHunter:SpawnDirt")

    local spawn_pt = GetSpawnPoint(pt, TUNING.SPECIAL_HUNT_SPAWN_DIST, specialhunt)
    if spawn_pt then
        local spawned = SpawnPrefab(_dirt_prefab)
        if spawned then
            spawned.Transform:SetPosition(spawn_pt:Get())
            specialhunt.lastdirt = spawned
            specialhunt.lastdirttime = GetTime()
            return true
        end
    end
    trace("SpecialHunter:SpawnDirt FAILED")
    return false
end

local function GetRunAngle(pt, angle, radius)
    local offset, result_angle = FindWalkableOffset(pt, angle, radius, 14, true)
    if result_angle then
        return result_angle
    end
end


local function GetNextSpawnAngle(pt, direction, radius)
    trace("SpecialHunter:GetNextSpawnAngle", tostring(pt), radius)

    local base_angle = direction or math.random() * 2 * PI
    local deviation = math.random(-TUNING.SPECIAL_TRACK_ANGLE_DEVIATION, TUNING.SPECIAL_TRACK_ANGLE_DEVIATION)*DEGREES

    local start_angle = base_angle + deviation
    trace(string.format("   original: %2.2f, deviation: %2.2f, starting angle: %2.2f", base_angle/DEGREES, deviation/DEGREES, start_angle/DEGREES))

    local angle = GetRunAngle(pt, start_angle, radius)
    trace(string.format("SpecialHunter:GetSpawnPoint RESULT %s", tostring(angle and angle/DEGREES)))
    return angle
end

local function StartDirt(specialhunt,position)
	assert(specialhunt)

    trace("SpecialHunter:StartDirt")

    RemoveDirt(specialhunt)

    local pt = position --Vector3(player.Transform:GetWorldPosition())

    specialhunt.numtrackstospawn = math.random(MIN_SPECIAL_TRACKS, MAX_SPECIAL_TRACKS)
    specialhunt.trackspawned = 0
    specialhunt.direction = GetNextSpawnAngle(pt, nil, TUNING.SPECIAL_HUNT_SPAWN_DIST)
    if specialhunt.direction then
        trace(string.format("   first angle: %2.2f", specialhunt.direction/DEGREES))

        trace("    numtrackstospawn", specialhunt.numtrackstospawn)

        -- it's ok if this spawn fails, because we'll keep trying every SPECIAL_specialhunt_UPDATE
		local spawnRelativeTo =  pt
        if SpawnDirt(spawnRelativeTo, specialhunt) then
            trace("Special Suspicious dirt placed for player ")
        end
    else
        trace("Failed to find suitable special dirt placement point")
    end
end

-- are we too close to the last dirtpile of a specialhunt?
local function IsNearSpecialHunt(player)
	for i,specialhunt in ipairs(_activespecialhunts) do
		if specialhunt.lastdirt then
            local dirtpos = Point(specialhunt.lastdirt.Transform:GetWorldPosition())
            local playerpos = Point(player.Transform:GetWorldPosition())
            local dsq = distsq(dirtpos, playerpos)
			if dsq <= TOOCLOSE_TO_SPECIAL_HUNT_SQ then
				return true
			end
		end
	end
	return false
end

-- something went unrecoverably wrong, try again after a breif pause
local function ResetHunt(specialhunt, washedaway)
	assert(specialhunt)
    trace("SpecialHunter:ResetSpecialHunt - The Special Hunt was a dismal failure, please stand by...")
	if specialhunt.activeplayer then
	    specialhunt.activeplayer:PushEvent("huntlosttrail", {washedaway=washedaway})
	end

    StartCooldown(specialhunt, TUNING.SPECIAL_HUNT_RESET_TIME)
end

-- Don't be tricked by the name. This is not called every frame
OnUpdateSpecialHunt = function(specialhunt)
	assert(specialhunt)

    trace("SpecialHunter:OnUpdateSpecialHunt")
if specialhunt.lastdirttime then
		if specialhunt.huntedbeast == nil and specialhunt.trackspawned >= 1 then
			local wet = TheWorld.state.wetness > 15 or TheWorld.state.israining
			if (wet and (GetTime() - specialhunt.lastdirttime) > (.75*TUNING.SEG_TIME))
				or (GetTime() - specialhunt.lastdirttime) > (1.25*TUNING.SEG_TIME) then
        
				-- check if the player is currently active in any other hunts
				local playerIsInOtherSpecialHunt = false
				for i,v in ipairs(_activespecialhunts) do
					if v ~= specialhunt and v.activeplayer and specialhunt.activeplayer then
						if v.activeplayer == specialhunt.activeplayer then
							playerIsInOtherSpecialHunt = true
						end
					end
				end
				
				-- if the player is still active in another hunt then end this one quietly
				if playerIsInOtherSpecialHunt then
					StartCooldown(specialhunt)
				else
					ResetHunt(specialhunt, wet) --Wash the tracks away but only if the player has seen at least 1 track
				end
				
				return
			end
        end
    end

    if not specialhunt.lastdirt then
		-- pick a player that is available, meaning, not being the active participant in a hunt
		local specialhuntingPlayers = {}	
		for i,v in ipairs(_activespecialhunts) do
			if v.activeplayer then
				specialhuntingPlayers[v.activeplayer] = true
			end
		end

		local eligiblePlayers = {}
		for i,v in ipairs(_activeplayers) do
			if not specialhuntingPlayers[v] and not IsNearSpecialHunt(v) then
				table.insert(eligiblePlayers, v)
			end
		end
		if #eligiblePlayers == 0 then
			-- Maybe next time?
			return
		end
		local player = eligiblePlayers[math.random(1,#eligiblePlayers)]
		trace("Start special hunt for player",player)
		local position = Vector3(player.Transform:GetWorldPosition())
        -- do a 50/50 chance of starting a new hunt or waiting for a player to get closer
        if math.random() < 0.5 then
            StartDirt(specialhunt,position)
        end
    else
		-- if no player near enough, then give up this hunt and start a new one
        local x,y,z = specialhunt.lastdirt.Transform:GetWorldPosition()
		
		if not IsAnyPlayerInRange(x,y,z,TUNING.SPECIAL_MAX_DIRT_DISTANCE) then
			-- try again rather soon
			StartCooldown(specialhunt, 0.1)
		end
    end

end

local function OnBeastDeath(specialhunt,spawned)
    trace("SpecialHunter:OnBeastDeath")
	specialhunt.specialhuntedbeast = nil
    StartCooldown(specialhunt)
end

local function GetAlternateBeastChance()
    local day = GetTime()/TUNING.TOTAL_DAY_TIME
    local chance = Lerp(TUNING.SPECIALHUNT_ALTERNATE_BEAST_CHANCE_MIN, TUNING.SPECIALHUNT_ALTERNATE_BEAST_CHANCE_MAX, day/100)
    chance = math.clamp(chance, TUNING.SPECIALHUNT_ALTERNATE_BEAST_CHANCE_MIN, TUNING.SPECIALHUNT_ALTERNATE_BEAST_CHANCE_MAX)
    return chance
end

local function SpawnSpecialHuntedBeast(specialhunt, pt)
	assert(specialhunt)
    trace("SpecialHunter:SpawnSpecialHuntedBeast")
        
    local spawn_pt = GetSpawnPoint(pt, TUNING.SPECIAL_HUNT_SPAWN_DIST, specialhunt)
    if spawn_pt then
        if math.random() > GetAlternateBeastChance() then
          	if TheWorld.state.isnight and TheWorld.state.isfullmoon then
				specialhunt.specialhuntedbeast = SpawnPrefab(_beast_prefab_albino)
			elseif TheWorld.state.isnight and TheWorld.state.moonphase == "new" then
				specialhunt.specialhuntedbeast = SpawnPrefab(_beast_prefab_nightmare)
			elseif TheWorld.state.isspring then
				specialhunt.specialhuntedbeast = SpawnPrefab(_beast_prefab_feather)
			elseif TheWorld.state.issummer then
				specialhunt.specialhuntedbeast = SpawnPrefab(_beast_prefab_rocky)
			elseif TheWorld.state.isautumn then
				specialhunt.specialhuntedbeast = SpawnPrefab(_beast_prefab_forest)
			elseif TheWorld.state.iswinter then
				specialhunt.specialhuntedbeast = SpawnPrefab(_beast_prefab_frost)	
			end
        else
            local beastPrefab = GetRandomItem(_alternate_beasts)
            specialhunt.specialhuntedbeast = SpawnPrefab(beastPrefab)
        end

        if specialhunt.specialhuntedbeast then
            trace("Kill the Beast!")
            specialhunt.specialhuntedbeast.Physics:Teleport(spawn_pt:Get())
            self.inst:ListenForEvent("death", function(inst, data) OnBeastDeath(specialhunt, specialhunt.specialhuntedbeast) end, specialhunt.specialhuntedbeast)
            return true
        end
    end
    trace("SpecialHunter:SpawnSpecialHuntedBeast FAILED")
    return false
end

local function SpawnTrack(spawn_pt, specialhunt)
    trace("SpecialHunter:SpawnTrack")

    if spawn_pt then
        local next_angle = GetNextSpawnAngle(spawn_pt, specialhunt.direction, TUNING.SPECIAL_HUNT_SPAWN_DIST)
        if next_angle then
            local spawned = SpawnPrefab(_track_prefab)
            if spawned then
                spawned.Transform:SetPosition(spawn_pt:Get())

                specialhunt.direction = next_angle

                trace(string.format("   next angle: %2.2f", specialhunt.direction/DEGREES))
                spawned.Transform:SetRotation(specialhunt.direction/DEGREES - 90)

                specialhunt.trackspawned = specialhunt.trackspawned + 1
                trace(string.format("   spawned %u/%u", specialhunt.trackspawned, specialhunt.numtrackstospawn))
                return true
            end
        end
    end
    trace("SpecialHunter:SpawnTrack FAILED")
    return false
end



--------------------------------------------------------------------------
--[[ Private event handlers ]]
--------------------------------------------------------------------------

local function KickOffSpecialHunt()
	-- schedule start of a new specialhunt
	if #_activespecialhunts < GetMaxSpecialHunts() then
		StartSpecialHunt()
	end 
end

local function OnPlayerJoined(src, player)
	for i,v in ipairs(_activeplayers) do
		if v == player then
			return
		end
	end
	table.insert(_activeplayers, player)
	-- one specialhunt per player. 
	KickOffSpecialHunt()
end

local function OnPlayerLeft(src, player)
	for i,v in ipairs(_activeplayers) do
		if v == player then
			table.remove(_activeplayers, i)
			return
		end
	end
end

--------------------------------------------------------------------------
--[[ Initialization ]]
--------------------------------------------------------------------------


for i, v in ipairs(AllPlayers) do
	OnPlayerJoined(self, v)
end

inst:ListenForEvent("ms_playerjoined", OnPlayerJoined, TheWorld)
inst:ListenForEvent("ms_playerleft", OnPlayerLeft, TheWorld)

--------------------------------------------------------------------------
--[[ Public member functions ]]
--------------------------------------------------------------------------

-- if anything fails during this step, it's basically unrecoverable, since we only have this one chance
-- to spawn whatever we need to spawn.  if that fails, we need to restart the whole process from the beginning
-- and hope we end up in a better place
function self:OnDirtInvestigated(pt, doer)
	assert(doer)

    trace("SpecialHunter:OnDirtInvestigated (by "..tostring(doer)..")")

	local specialhunt = nil
	-- find the specialhunt this pile belongs to
	for i,v in ipairs(_activespecialhunts) do
		local pos = v.lastdirt and v.lastdirt:GetPosition()
		if v.lastdirt and v.lastdirt:GetPosition() == pt then
			specialhunt = v
			break
		end
	end

	if not specialhunt then
		-- we should probably do something intelligent here.
		trace("yikes, no matching special hunt found for investigated dirtpile")
		return
	end

	specialhunt.activeplayer = doer

    if specialhunt.numtrackstospawn and specialhunt.numtrackstospawn > 0 then
        if SpawnTrack(pt,specialhunt) then
            trace("    ", specialhunt.trackspawned, specialhunt.numtrackstospawn)
            if specialhunt.trackspawned < specialhunt.numtrackstospawn then
                if SpawnDirt(pt, specialhunt) then
                    trace("...good job, you found a track!")
                else
                    trace("SpawnDirt FAILED! RESETTING")
                    Resetspecialhunt(specialhunt)
                end
            elseif specialhunt.trackspawned == specialhunt.numtrackstospawn then
                if SpawnSpecialHuntedBeast(specialhunt,pt) then
                    trace("...you found the last track, now find the beast!")
                    specialhunt.activeplayer:PushEvent("huntbeastnearby")
                    StopSpecialHunt(specialhunt)
                else
                    trace("SpawnSpecialHuntedBeast FAILED! RESETTING")
                    ResetSpecialHunt(specialhunt)
                end
            end
        else
            trace("SpawnTrack FAILED! RESETTING")
            ResetSpecialHunt(specialhunt)
        end
    end
end

--------------------------------------------------------------------------
--[[ Debug ]]
--------------------------------------------------------------------------

function self:GetDebugString()
    local str = ""
    
	for i,playerdata in pairs(_activeplayers) do
	    str = str.." Cooldown: ".. (self.cooldowntime and string.format("%2.2f", math.max(1, self.cooldowntime - GetTime())) or "-")
    	if not self.lastdirt then
	        str = str.." No last dirt."
    	    str = str.." Distance: ".. (playerdata.distance and string.format("%2.2f", playerdata.distance) or "-")
        	str = str.."/"..tostring(TUNING.SPECIAL_MIN_HUNT_DISTANCE)
	    else
    	    str = str.." Dirt"
        	str = str.." Distance: ".. (playerdata.distance and string.format("%2.2f", playerdata.distance) or "-")
	        str = str.."/"..tostring(TUNING.SPECIAL_MAX_DIRT_DISTANCE)
    	end
	end
    return str
end

end)
