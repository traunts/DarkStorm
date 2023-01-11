function Create(self)
	self.trailSeparation = 20

	self.velThreshold = 200

	self.forceMult = 3000

	local speed = math.sqrt(self.Vel.X ^ 2 + self.Vel.Y ^ 2)
	if speed >= self.velThreshold then
		local velFactor = GetPPM() * TimerMan.DeltaTimeSecs
		local maxDist = speed * velFactor
		local checkVect = self.Vel * velFactor * -1 * 0.9
		local strikeVect = Vector(0, 0)
		local lastVect = Vector(0, 0)
		local trailDist = SceneMan:CastObstacleRay(self.Pos, checkVect, strikeVect, lastVect, self.ID, -2, -1, 0)
		if trailDist >= 0 then
			--something found, check if it's not terrain
			local targetID = SceneMan:CastMORay(self.Pos, checkVect, -1, -2, -1, false, 0)
			if targetID ~= 255 then
				--not terrain, apply force
				local target = MovableMan:GetMOFromID(targetID)
				local strikePoint = Vector(0, 0)
				if SceneMan:CastFindMORay(self.Pos, checkVect, targetID, strikePoint, -1, false, 0) then
					target:AddAbsForce((checkVect / velFactor) * self.Mass * self.forceMult * -1, strikePoint)
				end
			end
		else
			trailDist = maxDist
		end

		local trailAngle = math.atan2(checkVect.Y, -checkVect.X)
		for i = 0, trailDist, self.trailSeparation do
			local trail = CreateAEmitter("12mm Coil Gun Slug Trail Emitter")
			trail.Pos = self.Pos + (checkVect * (i / maxDist))
			trail.RotAngle = trailAngle
			MovableMan:AddParticle(trail)
		end
	end
end

function Update(self)
	local speed = math.sqrt(self.Vel.X ^ 2 + self.Vel.Y ^ 2)
	if speed >= self.velThreshold then
		local velFactor = GetPPM() * TimerMan.DeltaTimeSecs
		local maxDist = speed * velFactor
		local checkVect = self.Vel * velFactor
		local strikeVect = Vector(0, 0)
		local lastVect = Vector(0, 0)
		local trailDist = SceneMan:CastObstacleRay(self.Pos, checkVect, strikeVect, lastVect, self.ID, -2, -1, 0)
		if trailDist >= 0 then
			--something found, check if it's not terrain
			local targetID = SceneMan:CastMORay(self.Pos, checkVect, -1, -2, -1, false, 0)
			if targetID ~= 255 then
				--not terrain, apply force
				local target = MovableMan:GetMOFromID(targetID)
				local strikePoint = Vector(0, 0)
				if SceneMan:CastFindMORay(self.Pos, checkVect, targetID, strikePoint, -1, false, 0) then
					target:AddAbsForce((checkVect / velFactor) * self.Mass * self.forceMult, strikePoint)
				end
			end
		else
			trailDist = maxDist
		end

		local trailAngle = math.atan2(-checkVect.Y, checkVect.X)
		for i = trailDist, 0, -self.trailSeparation do
			local trail = CreateAEmitter("12mm Coil Gun Slug Trail Emitter")
			trail.Pos = self.Pos + (checkVect * (i / maxDist))
			trail.RotAngle = trailAngle
			MovableMan:AddParticle(trail)
		end
	end
end
