function Create(self)
	self.healTimer = Timer();
	self.healTime = 2000;
	self.maxHealth = 100;
	
	self.shellA = CreateMOSRotating("D40Kotei Shell A");
	self.shellA.Pos = self.Pos;
	MovableMan:AddParticle(self.shellA);
	self.shellA:EraseFromTerrain();
	self.shellB = CreateMOSRotating("D40Kotei Shell B");
	self.shellB.Pos = self.Pos;
	MovableMan:AddParticle(self.shellB);
	self.shellB:EraseFromTerrain();
	
	self.shellATimer = Timer();
	self.shellBTimer = Timer();
	self.shellTime = 5000;
end

function Update(self)
	if not(self:IsDead()) then
		if self.healTimer:IsPastSimMS(self.healTime) then
			self.Health = self.Health + 1;
			if self.Health > self.maxHealth then
				self.Health = self.maxHealth;
			end
			self.healTimer = Timer();
		end
		
		if MovableMan:ValidMO(self.shellA) then
			self.shellATimer = Timer();
			self.shellA.Pos = self.Pos;
			self.shellA:EraseFromTerrain();
			self.shellA.Age = 0;
			self.shellA.ToSettle = false;
			if MovableMan:ValidMO(self.shellB) then
				self.shellBTimer = Timer();
				self.shellB.Pos = self.Pos;
				self.shellB:EraseFromTerrain();
				self.shellB.Age = 0;
				self.shellB.ToSettle = false;
			elseif self.shellBTimer:IsPastSimMS(self.shellTime) then
				self.shellB = CreateMOSRotating("D40Kotei Shell B");
				self.shellB.Pos = self.Pos;
				MovableMan:AddParticle(self.shellB);
				self.shellB:EraseFromTerrain();
			end
		elseif self.shellATimer:IsPastSimMS(self.shellTime) then
			self.shellA = CreateMOSRotating("D40Kotei Shell A");
			self.shellA.Pos = self.Pos;
			MovableMan:AddParticle(self.shellA);
			self.shellA:EraseFromTerrain();
			self.shellBTimer = Timer();
		else
			if MovableMan:ValidMO(self.shellB) then
				self.shellB:GibThis();
			end
		end
	else
		if MovableMan:ValidMO(self.shellA) then
			self.shellA:GibThis();
		end
		if MovableMan:ValidMO(self.shellB) then
			self.shellB:GibThis();
		end
	end
end

function Destroy(self)
	if MovableMan:ValidMO(self.shellA) then
		self.shellA:GibThis();
	end
	if MovableMan:ValidMO(self.shellB) then
		self.shellB:GibThis();
	end
end