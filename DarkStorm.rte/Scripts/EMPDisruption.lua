function Create(self)
	self.checkRange = 50;
	self.target = null;
	self.disruptPower = self.Mass; --mass is set by whatever creates the disruption
	self.disruptTime = 0;
	self.disruptTimer = Timer();
	self.isDisrupting = true;
	
	for actor in MovableMan.Actors do
		local distVect = SceneMan:ShortestDistance(self.Pos, actor.Pos, true);
		local dist = distVect.Magnitude;
		if dist <= self.checkRange and actor.PresetName ~= "D2-E Tengu Bushi" and actor.PresetName ~= "D4-E Oni Bushi" and actor.PresetName ~= "D45Shishi" and actor.PresetName ~= "D45Shishi Constructor Top" and actor.PresetName ~= "D45Shishi Constructor Segment" and actor.PresetName ~= "D45Shishi Constructor" then
			self.checkRange = dist;
			self.target = actor;
		end
	end
	
	if MovableMan:ValidMO(self.target) then
		if self.target.Mass > 0 then
			self.disruptTime = (self.disruptPower / self.target.Mass);
		else
			self.disruptTime = self.disruptPower;
		end
	end
end

function Update(self)
	if MovableMan:ValidMO(self.target) and self.isDisrupting then
		if self.disruptTimer:IsPastSimMS(self.disruptTime) then
			self.target:SetControllerMode(Controller.CIM_AI, -1);
			self.Pos = self.target.Pos;
			self.Lifetime = 1;
			self.isDisrupting = false;
		else
			self.target:SetAimAngle(math.random(math.pi/-2, math.pi/2));
			self.target:SetControllerMode(Controller.CIM_DISABLED, -1);
			self.target:GetController():SetState(Controller.BODY_CROUCH, true);
			local rand = math.random(0,19);
			if rand == 0 then
				self.target:GetController():SetState(Controller.MOVE_LEFT, true);
			elseif rand == 1 then
				self.target:GetController():SetState(Controller.MOVE_RIGHT, true);
			end
			self.Age = 1;
			self:NotResting();
			self.ToSettle = false;
		end
	end
end