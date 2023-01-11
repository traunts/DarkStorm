function Create(self)
	self.burstRange = self.Sharpness --set in .ini
	self.dettime = 3000
	self.dettimer = Timer()

	self.userRange = 20

	--find out who fired the weapon
	local checkVect = Vector(0, 0)
	checkVect.X = math.cos(self.RotAngle) * self.userRange * -1
	checkVect.Y = math.sin(self.RotAngle) * self.userRange
	local userID = SceneMan:CastMORay(self.Pos, checkVect, -1, -2, -1, false, 0)
	if userID ~= 255 then
		target = MovableMan:GetMOFromID(MovableMan:GetRootMOID(userID))
	end

	--if an actor was found, set this to the actor's team
	if MovableMan:ValidMO(target) and target:IsActor() then
		self.Team = target.Team
	else
		self.Team = -1
	end
end

function Update(self)
	self.Age = 0
	self.ToSettle = false
	self:NotResting()

	--Gib if an enemy unit is within burstRange pixels of the grenade
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

	--Gib when the detonation timer runs out
	if self.dettimer:IsPastSimMS(self.dettime) then
		self:GibThis()
	end
end
