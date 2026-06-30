-- idk how to make it morph with your actual avatar and not the rig
local function morph(plr, kzSize)
	if kzSize < 5  or kzSize > 25 then
		runCommand(":alert " .. plr .. " Invalid size.")
		return
	end

	runCommand(":load rig")
	local rig = f("rig")
	if not rig then
		runCommand(":alert " .. plr .. " Morph rig was not found.")
		return
	end
	rig:PivotTo(CFrame.new(Vector3.new(0, 10000, 0)))

	local denom = math.random()
	local denomStr = tostring(denom)
	denom *= 10 ^ (string.len(denomStr) - 2) -- the minus two accounts for the extra two zeroes at the end
	rig.Name = tostring(denom)

	local part = Instance.new("Part")
	part.Shape = 2
	part.CanCollide = false
	part.CanQuery = false
	part.Transparency = 0.75
	part.Color = Color3.fromRGB(255, 89, 89)
	part.Material = Enum.Material.Neon
	part.Size = Vector3.new(0.3, kzSize, kzSize)
	part.Massless = true -- allows the player to turn

	local size = rig:GetExtentsSize()
	local weld = Instance.new("Weld")
	weld.Part0 = rig.HumanoidRootPart
	weld.Part1 = part
	weld.C0 = CFrame.Angles(0, 0, math.pi / 2 ) * CFrame.new(Vector3.new(-size.Y / 1.7 + 0.1, 0, 0)) -- dividing by two would be the part inside the player's legs

	part.Parent = rig
	weld.Parent = rig.HumanoidRootPart

  	-- did this because loops in scprp suck ass, that shit would drop after just one cycle
	rig.LeftFoot:Destroy()
	rig.LeftUpperLeg:Destroy()
	rig.LeftLowerLeg:Destroy()
	rig.LeftHand:Destroy()
	rig.LeftUpperArm:Destroy()
	rig.LeftLowerArm:Destroy()
	rig.RightFoot:Destroy()
	rig.RightUpperLeg:Destroy()
	rig.RightLowerLeg:Destroy()
	rig.RightHand:Destroy()
	rig.RightUpperArm:Destroy()
	rig.RightLowerArm:Destroy()
	rig.LowerTorso:Destroy()
	rig.UpperTorso:Destroy()
	rig.Head:Destroy()

	task.wait(0.1) -- give scprp time to register the rig
	
	runCommand("morph " .. plr .. " " .. rig.Name)

	rig:Destroy()
end

event("chatted", function(data)
	local plr = data.Value[1]
	local msg = data.Value[2]
	
	if string.sub(msg, 1, 1) ~= ":"  then return end
	msg = string.sub(msg, 2)

	local args = string.split(msg, " ")
	if args[1] ~=  "killzone" then
		return
	end

	if not tonumber(args[2]) then
		runCommand(":alert " .. args[1] .. "Diameter is not a number.")
		return
	end

	morph(plr, tonumber(args[2]))
end)
