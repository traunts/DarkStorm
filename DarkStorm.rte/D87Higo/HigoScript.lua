function Create(self)
	self.maxSpeed = 30;
	
	self.AIMode = Actor.AIMODE_STAY;
end

function Update(self)
	if not(self:IsInventoryEmpty()) then
		local inven = self:SwapPrevInventory(nil);
		while inven ~= nil do
			inven = self:SwapPrevInventory(nil);
		end
	end

	local speed = math.sqrt(self.Vel.X ^ 2 + self.Vel.Y ^ 2);
	if speed > self.maxSpeed then
		local velAngle = math.atan2(self.Vel.Y, self.Vel.X);
		self.Vel = Vector(math.cos(velAngle) * self.maxSpeed, math.sin(velAngle) * self.maxSpeed);
	end
end

function Destroy(self)
	ActivityMan:GetActivity():ReportDeath(self.Team, -1);
end