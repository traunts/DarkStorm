function Create(self)
	self.target = nil
	self.posOffset = Vector(0, 0)
	self.isDone = false
	self.Lifetime = 60000
	self.lifeTimer = Timer()

	local targetID = SceneMan:CastMORay(self.Pos, Vector(1, 0), self.ID, -2, 0, true, 0)
	if targetID == 255 then
		targetID = SceneMan:CastMORay(self.Pos, Vector(-1, 0), self.ID, -2, 0, true, 0)
	end
	if targetID == 255 then
		targetID = SceneMan:CastMORay(self.Pos, Vector(0, 1), self.ID, -2, 0, true, 0)
	end
	if targetID == 255 then
		targetID = SceneMan:CastMORay(self.Pos, Vector(0, -1), self.ID, -2, 0, true, 0)
	end
	if targetID == 255 then
		targetID = SceneMan:CastMORay(self.Pos, Vector(1, 1), self.ID, -2, 0, true, 0)
	end
	if targetID == 255 then
		targetID = SceneMan:CastMORay(self.Pos, Vector(-1, -1), self.ID, -2, 0, true, 0)
	end
	if targetID == 255 then
		targetID = SceneMan:CastMORay(self.Pos, Vector(-1, 1), self.ID, -2, 0, true, 0)
	end
	if targetID == 255 then
		targetID = SceneMan:CastMORay(self.Pos, Vector(1, -1), self.ID, -2, 0, true, 0)
	end
	if targetID ~= 255 then
		self.target = MovableMan:GetMOFromID(MovableMan:GetRootMOID(targetID))
		if self.target:IsActor() then
			self.target.Mass = self.target.Mass + self.Mass
			self.posOffset = SceneMan:ShortestDistance(self.target.Pos, self.Pos, true)
		else
			self.target = nil
		end
	end
end

function Update(self)
	if MovableMan:ValidMO(self.target) then
		self.Pos = self.target.Pos + self.posOffset
		self:NotResting()
		self.Age = 0
		self.ToSettle = false

		if self.lifeTimer:IsPastSimMS(self.Lifetime) then
			self.target.Mass = self.target.Mass - self.Mass
			self.target = nil
		end
	elseif self.isDone == false then
		self.Lifetime = 1
		local midairCrystal = nil
		if self.PresetName == "Cryo Spray Actor Crystal A" then
			midairCrystal = CreateMOSRotating("Cryo Spray Midair Crystal A")
		elseif self.PresetName == "Cryo Spray Actor Crystal B" then
			midairCrystal = CreateMOSRotating("Cryo Spray Midair Crystal B")
		elseif self.PresetName == "Cryo Spray Actor Crystal C" then
			midairCrystal = CreateMOSRotating("Cryo Spray Midair Crystal C")
		elseif self.PresetName == "Cryo Spray Actor Crystal D" then
			midairCrystal = CreateMOSRotating("Cryo Spray Midair Crystal D")
		end
		midairCrystal.Pos = self.Pos
		MovableMan:AddParticle(midairCrystal)
		self.isDone = true
	end
end
