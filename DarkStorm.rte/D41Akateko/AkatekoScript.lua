function Create(self)
	self.aimThreshold = 0.3

	self.sensorRange = 600
	self.target = nil

	self.healTimer = Timer()
	self.healTime = 2000
	self.maxHealth = 100
end

function Update(self)
	if not (self:IsDead()) then
		--healz!
		if self.healTimer:IsPastSimMS(self.healTime) then
			self.Health = self.Health + 1
			if self.Health > self.maxHealth then
				self.Health = self.maxHealth
			end
			self.healTimer = Timer()
		end

		local ownCont = self:GetController()

		if not (ownCont:IsPlayerControlled(-1)) then
			if not (MovableMan:ValidMO(self.target)) then
				--no target, look for one
				local targetDist = self.sensorRange
				for actor in MovableMan.Actors do
					local distVect = SceneMan:ShortestDistance(self.Pos, actor.Pos, true)
					local distance = distVect.Magnitude
					if actor.Team ~= self.Team and not (actor:IsDead()) then
						--enemy actor found within range, see if its closer than others and not obstructed by terrain
						local foundPoint = Vector(0, 0)
						local found = SceneMan:CastFindMORay(self.Pos, distVect, actor.ID, foundPoint, 128, false, 0)
						if found and distance <= targetDist then
							--save closest unobstructed actor
							targetDist = distance
							self.target = actor
						end
					end
				end
			else
				local distVect = SceneMan:ShortestDistance(self.Pos, self.target.Pos, true)
				local distance = distVect.Magnitude
				local foundPoint = Vector(0, 0)
				local found = SceneMan:CastFindMORay(self.Pos, distVect, self.target.ID, foundPoint, 128, false, 0)
				if self.target:IsDead() or not found or distance > self.sensorRange then
					--target died, went out of range, or terrain got in the way, drop target
					self.target = nil
				end
			end

			--target was found or still exists, aim and fire
			if MovableMan:ValidMO(self.target) then
				local distVect = SceneMan:ShortestDistance(self.Pos, self.target.Pos, true)
				local actorAngle = distVect.AbsRadAngle
				if actorAngle > math.pi / 2 or actorAngle < math.pi / -2 then
					ownCont:SetState(Controller.MOVE_LEFT, true)
				else
					ownCont:SetState(Controller.MOVE_RIGHT, true)
				end
				if actorAngle > math.pi / 2 then
					actorAngle = math.pi - actorAngle
				end
				if actorAngle < math.pi / -2 then
					actorAngle = (math.pi * -1) - actorAngle
				end
				self:SetAimAngle(actorAngle)
				ownCont:SetState(Controller.WEAPON_FIRE, true)
			else
				ownCont:SetState(Controller.WEAPON_FIRE, false)
			end
		end

		if self:GetAimAngle(false) > self.aimThreshold then
			ownCont:SetState(Controller.WEAPON_FIRE, false)
			self:SetAimAngle(self.aimThreshold)
			self.target = nil
		end
	else
		self.PinStrength = 0
		self.ToSettle = 1
	end
end
