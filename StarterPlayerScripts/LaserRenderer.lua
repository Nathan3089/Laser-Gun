local LaserRenderer = {} -- Name of the module

local w = game:GetService("Workspace")

-- Time that the laser is visible for
local shot_duration = 0.05

-- Creating a laser beam from a start position, towards an end position.
function LaserRenderer.createLaser(toolHandle, endPosition)
	local startPosition = toolHandle.Position -- This makes the start position of the laser be from the handle.
	
	-- Magnitude is getting the distance between the two positions. (startPosition, endPosition)
	local laserDistance = (startPosition - endPosition).Magnitude
	
	-- This allows us to make a CFrame point in the midpoint of startPosition, endPosition.
	-- (-lasetDistance/2) is the length from the midpoint, to the endPosition.
	local laserCFrame = CFrame.lookAt(startPosition, endPosition) * CFrame.new	(0,0, -laserDistance / 2)
	
	-- Creating the laser Instance.
	local laserPart = Instance.new("Part")
	
	-- LaserDistance basically makes the entire beam the length of the startPosition, endPosition.
	laserPart.Size = Vector3.new(0.2, 0.2, laserDistance)
	laserPart.CFrame = laserCFrame
	laserPart.Anchored = true
	laserPart.CanCollide = false
	laserPart.BrickColor = BrickColor.random()
	laserPart.Material = Enum.Material.Neon
	laserPart.Parent = w -- Workspace
	
	-- This basically cleans up, or removes the laser from being visible after the shot_duration is met. In this situation, its 0.05
	game:GetService("Debris"):AddItem(laserPart, shot_duration)
	
	-- Plays the weapons activate sound when shooting.
	local shootingSound = toolHandle:FindFirstChild("Activate")
	if shootingSound then
		shootingSound:Play()
	end
end

return LaserRenderer
