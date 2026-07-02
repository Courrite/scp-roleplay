-- using recursion because the scheduler lags on loops
--[[
	this thing works on rejoin, team switch (if the team is inside canJail)
	restarting breaks the wait so keep this in mind
]]

local solitaryParts = "SolitaryParts"
local tagged = f(solitaryParts):GetChildren()

local confinedPlayers = {}
local confinementTimes = {}
local lastTeams = {}

local canJail = {
	["Class - Disposable"] = true
}
local confinementTimeCd = 60
local confinementTeam = "Solitary Confinement"

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

	if getTeam(plrName) == confinementTeam then
		runCommand("score " .. plrName .. " " .. math.floor(confinementTimeCd - (os.clock() - confinementTime)))
	end

	if getTeam(plrName) == confinementTeam then
		runCommand("rtag " .. plrName .. " Solitary Confinement")
	end

	if canJail[getTeam(plrName)] then
		setTeam(plrName, confinementTeam)
		runCommand("respawn " .. plrName)
	end

	if os.clock() - confinementTime >= confinementTimeCd then
		if getTeam(plrName) and lastTeams[plrName] and getTeam(plrName) == confinementTeam then
			setTeam(plrName, lastTeams[plrName])
		end

		lastTeams[plrName] = nil
		confinementTimes[plrName] = nil
	
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
		if not canJail[getTeam(plr)] then return end
	
		table.insert(confinedPlayers, plr)
		confinementTimes[plr] = os.clock()
		lastTeams[plr] = getTeam(plr)
	
		setTeam(plr, confinementTeam)
		runCommand("respawn " .. plr)
	end)

	connectParts()
end
connectParts()
