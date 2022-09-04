local replicatedStorage = game:GetService("ReplicatedStorage")
local eventsFolder = replicatedStorage.Events
local laser_damage = 10
-- This is the hit proximity
local max_proximity = 10

-- This function searches the players character for the weapon and returns the handle object, if the weapon is found.
local function getPlayersToolHandle(player)
	local weapon = player.Character:FindFirstChildOfClass("Tool")
	if weapon then
		return weapon:FindFirstChild("Handle")
	end
end

local function isHitValid(playerFired, characterToDamage, hitPosition)
	-- Validate distance between the character hit and the hitPosition
	-- Calculates the distance between the character and the hit position, if the distance is > max_proximity then return false.
	local characterHitProximity = (characterToDamage.HumanoidRootPart.Position - hitPosition).Magnitude
	if characterHitProximity > max_proximity then
		return false
	end
	
	-- Checks if the player shoots something that's not a character, then assume something intercepted the rays path, and call it a valid shot.
	local toolHandle = getPlayersToolHandle(playerFired) -- ges the toolHandle of the player that fired
	if toolHandle then
		local rayLength = (hitPosition - toolHandle.Position).Magnitude -- Gets the distance between toolHandle and hitPosition
		local rayDirection = (hitPosition - toolHandle.Position).Unit -- Gets the direction of the rayCast, from the toolHandles position
		local raycastParams = RaycastParams.new()
		RaycastParams.FilderDescendantsInstances = {playerFired.Character}
		
		-- Getting the result of the laser itself, and what it made contact with
		local rayResult = game:GetService("Workspace"):Raycast(toolHandle.Position, rayDirection * rayLength, raycastParams)
		
		-- If an instance was hit that was not the character then ignore the shot
		if rayResult and not rayResult.Instance:IsDescendantOf(characterToDamage) then
			return false -- Ignores if the shot was not at a character
		end
	end
	
	return true
end

-- This function runs the players rayCast into the server, so it can display across other clients screen.
local function playerFiredLaser(playerFired, endPosition)
	local toolHandle = getPlayersToolHandle(playerFired)
	if toolHandle then
		eventsFolder.LaserFired:FireAllClients(playerFired, toolHandle, endPosition)
	end
end

-- Creating a function that allows the laser to damage the character we shoot.
function damageCharacter(playerFired, characterToDamage, hitPosition)
	local humanoid = characterToDamage:FindFirstChild("Humanoid")
	local validShot = isHitValid(playerFired, characterToDamage, hitPosition)
	if humanoid and validShot then
		-- Remove the health from the characters humanoid
		humanoid.Health -= laser_damage
	end
end

-- Passing the damageCharacter() function into the remoteEvent, so it can run on the server.
eventsFolder.DamageCharacter.OnServerEvent:Connect(damageCharacter)
-- Passing the playerFiredLaser() function into the remoteEvent, so it can run on the server.
eventsFolder.LaserFired.OnServerEvent:Connect(playerFiredLaser)