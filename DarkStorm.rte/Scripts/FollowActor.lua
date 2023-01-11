function Create(self)
	self.userRange = 20;
	self.user = nil;
	
	for actor in MovableMan.Actors do
		local distVect = SceneMan:ShortestDistance(self.Pos, actor.Pos, true);
		local dist = distVect.Magnitude;
		if dist <= self.userRange then
			self.userRange = dist;
			self.user = actor;
		end
	end
	
	if MovableMan:ValidMO(self.user) then
		self.Pos = self.user.Pos;
	end
end

function Update(self)
	if MovableMan:ValidMO(self.user) and self.Lifetime > 1 then
		self.Pos = self.user.Pos;
		self:NotResting();
		self.Age = 0;
		self.ToSettle = false;
	else
		self.ToDelete = true;
	end
end