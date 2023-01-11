function Create(self)
	self.oldVel = self.Vel;
	self.velTimer = Timer();
	self.velTime = 1000;
end

function Update(self)
	if self.Vel.X ~= self.oldVel.X or self.Vel.Y ~= self.oldVel.Y then
		self.velTimer = Timer();
	end
	self.oldVel = self.Vel;
		
	if self.velTimer:IsPastSimMS(self.velTime) then
		self:GibThis();
	end
end

function Destroy(self)
	ActivityMan:GetActivity():ReportDeath(self.Team, -1);
end