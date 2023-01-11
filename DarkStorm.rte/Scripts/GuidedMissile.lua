function Create(self)
	self.userRange = 20
	self.liftMultiplier = 0.01
	self.liftMaximum = 0.35
	self.target = nil
	self.targetRange = 1200
	self.Team = -1
	self.minAltitude = 200
	self.maxAdjust = 10
	self.angleThreshold = 0.01
	self.burstRange = self.Sharpness --set in .ini

	--get firer team and firing angle
	local checkVect = Vector(0, 0)
	checkVect.X = math.cos(self.RotAngle) * self.userRange * -1
	checkVect.Y = math.sin(self.RotAngle) * self.userRange
	local userID = SceneMan:CastMORay(self.Pos, checkVect, -1, -2, -1, false, 0)
	local baseUserID = -1
	if userID ~= 255 then
		baseUserID = MovableMan:GetRootMOID(userID)
		local baseUser = MovableMan:GetMOFromID(baseUserID)
		if baseUser:IsActor() then
			self.Team = baseUser.Team
			self.RotAngle = ToActor(baseUser):GetAimAngle(true)
			local speed = self.Vel.Magnitude
			self.Vel.X = math.cos(self.RotAngle) * speed
			self.Vel.Y = math.sin(self.RotAngle) * speed * -1
		end
	end

	--find the intended target
	checkVect.X = math.cos(self.RotAngle) * self.targetRange
	checkVect.Y = math.sin(self.RotAngle) * self.targetRange * -1
	local targetID = SceneMan:CastMORay(self.Pos, checkVect, baseUserID, -2, -1, false, 2)
	if targetID ~= 255 then
		--target found, store target and prepare for guidance
		local baseTargetID = MovableMan:GetRootMOID(targetID)
		self.target = MovableMan:GetMOFromID(baseTargetID)
	end
end

function Update(self)
	--calculate lift
	local lift = math.abs(self.Vel.X) * self.liftMultiplier
	if lift > self.liftMaximum then
		lift = self.liftMaximum
	end
	self.Vel.Y = self.Vel.Y - lift

	--calculate guidance
	if MovableMan:ValidMO(self.target) then
		--check proximity
		local checkVect = SceneMan:ShortestDistance(self.Pos, self.target.Pos, true)
		local strikePoint = Vector(0, 0)
		SceneMan:CastFindMORay(self.Pos, checkVect, self.target.ID, strikePoint, -1, false, 0)
		local strikeVect = SceneMan:ShortestDistance(self.Pos, strikePoint, true)
		local dist = strikeVect.Magnitude
		if dist <= self.burstRange then
			--detonate if close
			self:GibThis()
		else
			--otherwise, adjust flight angle
			local distVect = SceneMan:ShortestDistance(self.Pos, self.target.Pos, true)
			dist = distVect.Magnitude
			local dotProd = (distVect.X * self.Vel.X) + (-distVect.Y * -self.Vel.Y)
			local speed = math.sqrt(self.Vel.X ^ 2 + self.Vel.Y ^ 2)

			--get angle between velocity vector and vector from self to target
			local angle = math.acos(dotProd / (dist * speed))
			if angle < 0 then
				angle = -angle
			end
			if angle > math.pi then
				angle = math.pi - angle
			end

			--get basic angle adjustment value
			local adjust = math.sin(angle) * speed
			if adjust > self.maxAdjust then
				adjust = self.maxAdjust
			end

			--get velocity and distance angles
			local velAngle = self.Vel.AbsRadAngle
			local distAngle = distVect.AbsRadAngle

			--set up positive and negative adjustments
			local distAnglePlus = distAngle + angle
			local distAngleMinus = distAngle - angle
			if distAnglePlus > math.pi then
				distAnglePlus = distAnglePlus - (math.pi * 2)
			end
			if distAngleMinus < -math.pi then
				distAngleMinus = distAngleMinus + (math.pi * 2)
			end

			--get the adjustment value
			local adjustAngle = 0
			local adjustVector = Vector(0, 0)
			if distAnglePlus < velAngle + self.angleThreshold and distAnglePlus > velAngle - self.angleThreshold then
				adjustAngle = distAngle - (math.pi / 2)
				adjustVector.X = math.cos(adjustAngle) * adjust
				adjustVector.Y = -(math.sin(adjustAngle) * adjust)
			elseif
				distAngleMinus < velAngle + self.angleThreshold and distAngleMinus > velAngle - self.angleThreshold
			then
				adjustAngle = distAngle + (math.pi / 2)
				adjustVector.X = math.cos(adjustAngle) * adjust
				adjustVector.Y = -(math.sin(adjustAngle) * adjust)
			end

			--adjust angle and velocity
			self.Vel = self.Vel + adjustVector
			self.RotAngle = math.atan2(-self.Vel.Y, self.Vel.X)
		end
	else
		--no target, just detonate in proximity of any enemy
		for actor in MovableMan.Actors do
			if actor.Team ~= self.Team then
				local checkVect = SceneMan:ShortestDistance(self.Pos, actor.Pos, true)
				local strikePoint = Vector(0, 0)
				SceneMan:CastFindMORay(self.Pos, checkVect, actor.ID, strikePoint, -1, false, 0)
				local strikeVect = SceneMan:ShortestDistance(self.Pos, strikePoint, true)
				local dist = strikeVect.Magnitude
				if dist <= self.burstRange then
					self:GibThis()
				end
			end
		end
	end
end
