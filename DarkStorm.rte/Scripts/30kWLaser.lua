function Create(self)
	self.userRange = 20
	self.laserRange = 1200
	self.hitVel = 50

	self.laserSeparation = 3
	self.soundSeparation = 200

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
		0,
		0
	)

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
		end
	end

	self.Lifetime = 1
end
