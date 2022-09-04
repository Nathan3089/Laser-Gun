-- Since we called the FireAllClients event, that means all clients will receive an event from the server to render their laser beam.
-- Because of this, that will cause all players to display two laser beams, and to avoid that, we will ignore the players laser if shot by another player.
-- If the localPlayer is not the player who shot (you), then this script allows the laser beams start/endPosition will be from the other players toolHandle
-- If we didn't do this, the laser would render from the other player, and for all localPlayers on the server.

    local players = game:GetService("Players")
    local replicatedStorage = game:GetService("ReplicatedStorage")
    local laserModule = require(script.Parent:WaitForChild("LaserRenderer"))
    
    local eventsFolder = replicatedStorage.Events
    
    -- Displays another players laser, instead of their own.
    local function createPlayerLaser(playerWhoShot, toolHandle, endPosition)
    
        -- Makes sure the player who shot, is another player, and makes the RayCast appropriate for the position of the other player.
        if playerWhoShot ~= players.LocalPlayer then
            laserModule.createLaster(toolHandle, endPosition)
        end
    end
    
    eventsFolder.LaserFired.OnClientEvent:Connect(createPlayerLaser)