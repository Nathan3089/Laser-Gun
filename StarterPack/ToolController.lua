local players = game:GetService("Players")
local userInputService = game:GetService("UserInputService")
local replicatedStorage = game:GetService("ReplicatedStorage")
local laserModule = require(players.LocalPlayer.PlayerScripts.LaserRenderer)

local w = game:GetService("Workspace")

local tool = script.Parent
local eventsFolder = replicatedStorage.Events

local max_distance = 1000 -- This is the farthest the mouseLocation can record your mouseLocation in studs.
local max_laserDistance = 500 -- The ray will not exceed 500 studs.
local fire_rate = 0.3
local timeOfPreviousShot = 0 -- Records when the player last shot their weapon.

-- Checks if enough time has passed since the previous shot was fired.
local function canShoot()
	local currentTime = tick() -- Records time in seconds.
	
	-- If the previous shot was fired for less than the fire_rate, then dont fire.
	-- This means the player is trying to fire their weapon too quickly.
	-- Else, if the previous shot was fired after the fire_rate time, then fire.
	if currentTime - timeOfPreviousShot < fire_rate then
		return false
	end
	return true
end

local function getMouseLocation()
	local mouseLocation = userInputService:GetMouseLocation() -- Gets the players 2D Mouse location from their screen.
	-- This function has two properties, X,Y.
	
	-- Utilizing the mouseLocation, this will create a new Ray at the given arguments, X,Y.
	-- Without the arguments of mouseLocation, we would not know where to pinpoint this new Ray, therefor arguments = Vital.
	local screenToRay = w.CurrentCamera:ViewportPointToRay(mouseLocation.X, mouseLocation.Y)
	local directionVector = screenToRay.Direction * max_distance -- Returns the ray from the start position, and exceeds infinitely in the direction of fire.
	local rayResults = w:Raycast(screenToRay.Origin, directionVector) -- Returns with the origin, and calculates the end of the Raycast Vector.
	
	if rayResults then
		-- Returns the 2D point of the intersection.
		return rayResults.Position
	else
		-- If no object was intersected by the Ray, then calculate the position at the end of the Ray.
		return screenToRay.Origin + directionVector
	end
end

local function fireWeapon()
	local mouseLocation = getMouseLocation()
	
	-- Returns with the distance between the mouseLocation and the Handle, and removes that distance from the Ray max_distance.
	local targetDirection = (mouseLocation - tool.Handle.Position).Unit
	
	-- This will be the direction of fire, multiplied by a max distance.
	-- Without the max_distance, we would not know where to stop the Ray.
	
	-- max_laserDistance makes the laser fire between your mouseLocation, and the start position, with a limit of how far the laser can exceed.
	-- Without having this, if we * max_distance, the laser will go as far as it can, in the direction of fire, instead of being limited.
	local directionVector = targetDirection * max_laserDistance
	local weaponRaycastParams = RaycastParams.new()
	
	-- This will ignore any characters to prevent them from being damaged by their own Raycast.
	weaponRaycastParams.FilterDescendantsInstances = {players.LocalPlayer.Character}
	
	-- Returns with a Raycast from the LocalPlayers Handle, in the direction of the Ray, to the position of the Raycast hit results.
	local weaponRaycastResults = w:Raycast(tool.Handle.Position, directionVector, weaponRaycastParams)
	
	-- Checks if any objects were hit between the start and end position of the Ray.
	local hitPosition
	if weaponRaycastResults then
		hitPosition = weaponRaycastResults.Position
		
		-- The Instance hit will be a child of the characterModel.
		-- If a humanoid is found in the Model then it's likely a players character was hit.
		local characterModel = weaponRaycastResults.Instance:FindFirstAncestorOfClass("Model")
		if characterModel then
			local humanoid = characterModel:FindFirstChild("Humanoid")
			if humanoid then
				eventsFolder.DamageCharacter:FireServer(characterModel, hitPosition) -- Calling the RemoteEvent, and firing it to the server.
			end
		end
	else
		-- Calculates the end position based on the maximum laser distance, since nothing was hit by the Ray.
		hitPosition = tool.Handle.Position + directionVector
	end
	-- Returns with updating the timeOfPreviousShot each time the weapon is fired.
	timeOfPreviousShot = tick()
	eventsFolder.LaserFired:FireServer(hitPosition) -- Calling the RemoteEvent, and firing it to the server.
	laserModule.createLaser(tool.Handle, hitPosition)
end

tool.Equipped:Connect(function()
	tool.Handle.Equip:Play()
end)

tool.Activated:Connect(function()
	if canShoot() then
		fireWeapon()
	end
end)
