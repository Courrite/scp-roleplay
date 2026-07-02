--[[
	Author: @AsterVreburn

	Description:
		A script that turns all the parts inside a group with a specific name
		into parts that confine certain teams upon being touched, this works
		both on rejoin, team switch and, if you set a spawnpoint, resetting too.
		
	Notes:
		- using recursion because the scheduler lags on loops
		- to make a team jailable put its name inside the CONFINEABLE table
		- restarting breaks the wait so keep this in mind
]]

local SOLITARY_PARTS_GROUP_NAME = "SolitaryParts" -- should be a model (group)
local CONFINEMENT_TIME = 10
local CONFINEMENT_TEAM = "Solitary Confinement"
local CONFINEABLE = {
	["Class - Disposable"] = true
}

local confinedPlayers = {}
local confinementTimes = {}
local lastTeams = {}
local resetScorePlrs = {}
local tagged = f(SOLITARY_PARTS_GROUP_NAME):GetChildren()

-- forward declare functions (otherwise they wont be able to call eachother)
local waitAndRepeat;
local checkAndRelease;

function restart()
	task.wait(1)

	task.spawn(checkAndRelease, 1)
end

function checkAndRelease(index)
	index = index or 1

	local plrName = confinedPlayers[index]
	
   -- no more plrs 
	if not plrName then
		return restart()
	end

	local confinementTime = confinementTimes[plrName] or 0
	local increment = 1

	-- i could make this look better but i am the laziest creature on earth so
	if getTeam(plrName) == CONFINEMENT_TEAM then
		runCommand("score " .. plrName .. " " .. math.floor(CONFINEMENT_TIME - (os.clock() - confinementTime)))
		resetScorePlrs[plrName] = nil
	elseif not resetScorePlrs[plrName] and getTeam(plrName) ~= CONFINEMENT_TEAM then
		resetScorePlrs[plrName] = true
		runCommand("score " .. plrName .. " 0")
	end

	if CONFINEABLE[getTeam(plrName)] then
		setTeam(plrName, CONFINEMENT_TEAM)
		runCommand("respawn " .. plrName)
	end

	if os.clock() - confinementTime >= CONFINEMENT_TIME then
		if getTeam(plrName) and lastTeams[plrName] and getTeam(plrName) == CONFINEMENT_TEAM then
			setTeam(plrName, lastTeams[plrName])
		end

		lastTeams[plrName] = nil
		confinementTimes[plrName] = nil
		resetScorePlrs[plrName] = nil
		table.remove(confinedPlayers, index)
		increment = 0 -- dont increment so we can check the next element
		
		runCommand("respawn "..plrName)
		runCommand("score " .. plrName .. " 0")
	end
	
	-- https://stackoverflow.com/questions/310974/what-is-tail-call-optimization
	return checkAndRelease(index + increment)
end

task.spawn(checkAndRelease, 1)

local tagIdx = 0
local function connectParts()
	tagIdx += 1
	local part = tagged[tagIdx]
	if not part then return end
	
	part.CanQuery = false
	part.Touched:Connect(function(plr)
		if not CONFINEABLE[getTeam(plr)] then return end
	
		table.insert(confinedPlayers, plr)
		confinementTimes[plr] = os.clock()
		lastTeams[plr] = getTeam(plr)
	
		setTeam(plr, CONFINEMENT_TEAM)
		runCommand("respawn " .. plr)
	end)

	connectParts()
end
connectParts()
