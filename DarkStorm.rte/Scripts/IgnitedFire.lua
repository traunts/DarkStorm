function Create(self)
	self.target = nil;
	
	self.damage = 1;
	
	self.damageTime = 2;
	self.damageTimer = Timer();
	
	self.burnTime = 5000;
	self.burnTimer = Timer();
	
	local closest = 10;
	for actor in MovableMan.Actors do
		local distVect = SceneMan:ShortestDistance(self.Pos, actor.Pos, true);
		local dist = distVect.Magnitude
		if dist <= closest and actor.ClassName ~= "ADoor" and actor.PresetName ~= "D2-F Tengu Bushi" and actor.PresetName ~= "D4-F Oni Bushi" and actor.PresetName ~= "D45Shishi" and actor.PresetName ~= "D45Shishi Constructor Top" and actor.PresetName ~= "D45Shishi Constructor Segment" and actor.PresetName ~= "D45Shishi Constructor" then
			closest = dist;
			self.target = actor;
		end
	end
	
	if self.target ~= nil then
		self.damageTime = self.target.Mass/self.damageTime;
	end
end

function Update(self)
	if MovableMan:ValidMO(self.target) then
		self.Pos = self.target.Pos;
		self:NotResting();
		self.Age = 0;
		self.ToSettle = false;
		
		if self.damageTimer:IsPastSimMS(self.damageTime) then
			self.target.Health = self.target.Health - self.damage;
			self.damageTimer:Reset();
		end
		
		if self.burnTimer:IsPastSimMS(self.burnTime) then
			self.target = nil;
			self.Lifetime = 1;
		end
	else
		self.Lifetime = 1;
	end
end