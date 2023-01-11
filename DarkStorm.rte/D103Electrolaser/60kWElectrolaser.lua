function Create(self)
	self.userRange = 20
	self.laserRange = 1200
	self.hitVel = 50

	self.laserSeparation = 3
	self.soundSeparation = 200

	self.shockWidth = 100
	self.shockHeight = 10
	self.shockPower = 8000
	self.disruptPower = 375000

	self.boltSeparation = 30
	self.boltMaxOffset = 10

	local checkVect = Vector(0, 0)
	checkVect.X = math.cos(self.RotAngle) * self.userRange * -1
	checkVect.Y = math.sin(self.RotAngle) * self.userRange
	local userID = SceneMan:CastMORay(self.Pos, checkVect, -1, -2, -1, false, 0)
	local baseUserID = -1
	local ignoreTeamNumber = -2
	if userID ~= 255 then
		baseUserID = MovableMan:GetRootMOID(userID)
		ignoreTeamNumber = MovableMan:GetMOFromID(baseUserID).Team
	end

	checkVect.X = math.cos(self.RotAngle) * self.laserRange
	checkVect.Y = math.sin(self.RotAngle) * self.laserRange * -1
	local strikePoint = Vector(0, 0)
	local lastPoint = Vector(0, 0)
	local dist = SceneMan:CastObstacleRay(
		self.Pos,
		checkVect,
		strikePoint,
		lastPoint,
		baseUserID,
		ignoreTeamNumber,
		-1,
		0
	)

	local discharge = false
	if dist >= 0 then
		local strikeVect = SceneMan:ShortestDistance(self.Pos, strikePoint, true)
		dist = strikeVect.Magnitude

		local glow = CreateMOPixel("30kW Laser Hit Glow")
		glow.Pos = strikePoint
		MovableMan:AddParticle(glow)
		local hit = CreateMOPixel("30kW Laser Hit")
		hit.Pos = strikePoint
		hit.Vel.X = math.cos(self.RotAngle) * self.hitVel
		hit.Vel.Y = math.sin(self.RotAngle) * self.hitVel * -1
		hit:SetWhichMOToNotHit(MovableMan:GetMOFromID(baseUserID), -1)
		MovableMan:AddParticle(hit)
		local hit2 = CreateMOPixel("30kW Laser Hit")
		hit2.Pos = strikePoint
		hit2.Vel.X = math.cos(self.RotAngle) * self.hitVel
		hit2.Vel.Y = math.sin(self.RotAngle) * self.hitVel * -1
		hit2:SetWhichMOToNotHit(MovableMan:GetMOFromID(baseUserID), -1)
		MovableMan:AddParticle(hit2)
		local hit3 = CreateMOPixel("30kW Laser Hit")
		hit3.Pos = strikePoint
		hit3.Vel.X = math.cos(self.RotAngle) * self.hitVel
		hit3.Vel.Y = math.sin(self.RotAngle) * self.hitVel * -1
		hit3:SetWhichMOToNotHit(MovableMan:GetMOFromID(baseUserID), -1)
		MovableMan:AddParticle(hit3)
		local hitSound = CreateAEmitter("30kW Laser Hit Sound Emitter")
		hitSound.Pos = strikePoint
		MovableMan:AddParticle(hitSound)

		--check if the thing struck was an object
		local targetID = SceneMan:CastMORay(self.Pos, checkVect, baseUserID, ignoreTeamNumber, -1, false, 0)
		if targetID ~= 255 then
			--target is an object
			local targetRootID = MovableMan:GetRootMOID(targetID)
			local target = MovableMan:GetMOFromID(targetRootID)

			local grounded = false
			local foundVector = Vector(0, 0)
			for i = target.Pos.X - self.shockWidth, target.Pos.X + self.shockWidth do
				local shockPoint = SceneMan:MovePointToGround(Vector(i, target.Pos.Y), 0, 1)
				if
					SceneMan:CastFindMORay(
						shockPoint,
						Vector(0, -self.shockHeight),
						target.ID,
						foundVector,
						-1,
						true,
						0
					)
				then
					--target is grounded
					discharge = true

					if
						target:IsActor()
						and target.PresetName ~= "D2-E Tengu Bushi"
						and target.PresetName ~= "D4-E Oni Bushi"
						and target.PresetName ~= "D45Shishi"
						and target.PresetName ~= "D45Shishi Constructor Top"
						and target.PresetName ~= "D45Shishi Constructor Segment"
						and target.PresetName ~= "D45Shishi Constructor"
					then
						--target is actor, do damage and paralyze
						local damage = 0

						if target.Mass ~= 0 then
							damage = self.shockPower / target.Mass
						else
							damage = self.shockPower
						end

						ToActor(target).Health = ToActor(target).Health - damage

						local shock = CreateMOPixel("EMP Disruption")
						shock.Pos = target.Pos
						shock.Mass = self.disruptPower
						MovableMan:AddParticle(shock)
					end

					break
				end
			end
		else
			--terrain struck
			discharge = true
		end

		--something grounded struck, create electrical effect
		if discharge then
			local lastBoltPoint = self.Pos
			for i = self.boltSeparation, dist - self.boltMaxOffset, self.boltSeparation do
				local boltPoint = Vector(0, 0)
				boltPoint = self.Pos + checkVect * (i / self.laserRange)
				local boltAngle = math.random(0, math.pi * 2)
				local boltOffset = math.random(0, self.boltMaxOffset)
				boltPoint.X = boltPoint.X + (math.cos(boltAngle) * boltOffset)
				boltPoint.Y = boltPoint.Y + (math.sin(boltAngle) * boltOffset * -1)
				local boltVect = SceneMan:ShortestDistance(lastBoltPoint, boltPoint, true)
				local boltDist = boltVect.Magnitude
				if boltDist ~= 0 then
					for j = 0, boltDist, self.laserSeparation do
						local bolt = CreateMOPixel("30kW Laser")
						bolt.Pos = lastBoltPoint + boltVect * (j / boltDist)
						MovableMan:AddParticle(bolt)
					end
				end
				lastBoltPoint = boltPoint
			end

			local boltVect = SceneMan:ShortestDistance(lastBoltPoint, strikePoint, true)
			local boltDist = boltVect.Magnitude
			if boltDist ~= 0 then
				for i = 0, boltDist, self.laserSeparation do
					local bolt = CreateMOPixel("30kW Laser")
					bolt.Pos = lastBoltPoint + boltVect * (i / boltDist)
					MovableMan:AddParticle(bolt)
				end
			end
		end
	else
		dist = self.laserRange
	end

	for i = 0, dist, self.laserSeparation do
		local laser = CreateMOPixel("30kW Laser")
		laser.Pos = self.Pos + checkVect * (i / self.laserRange)
		MovableMan:AddParticle(laser)

		if i % self.soundSeparation == 0 then
			local sound = CreateAEmitter("30kW Laser Sound Emitter")
			sound.Pos = self.Pos + checkVect * (i / self.laserRange)
			MovableMan:AddParticle(sound)

			--bolt was made, make a sound for it
			if discharge then
				local boltSound = CreateAEmitter("30kW Bolt Sound Emitter")
				boltSound.Pos = self.Pos + checkVect * (i / self.laserRange)
				MovableMan:AddParticle(boltSound)
			end
		end
	end

	self.Lifetime = 1
end
