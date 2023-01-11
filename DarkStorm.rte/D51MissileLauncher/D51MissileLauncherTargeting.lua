function D51MissileLauncherTargeting(self, ownCont, equip, target)
	local sensorRange = 1200;
	local curTarget = target;
	
	if not(MovableMan:ValidMO(curTarget)) then
		--no target, look for one
		local targetDist = sensorRange;
		for actor in MovableMan.Actors do
			local distVect = SceneMan:ShortestDistance(self.Pos, actor.Pos, true);
			local distance = distVect.Magnitude;
			if actor.Team ~= self.Team and not(actor:IsDead()) then
				--enemy actor found within range, see if its closer than others and not obstructed by terrain
				local foundPoint = Vector(0,0);
				local found = SceneMan:CastFindMORay(self.Pos, distVect, actor.ID, foundPoint, 128, false, 0);
				if found and distance <= targetDist then
					--save closest unobstructed actor
					targetDist = distance;
					curTarget = actor;
				end
			end
		end
	else
		local distVect = SceneMan:ShortestDistance(self.Pos, curTarget.Pos, true);
		local distance = distVect.Magnitude;
		local foundPoint = Vector(0,0);
		local found = SceneMan:CastFindMORay(self.Pos, distVect, curTarget.ID, foundPoint, 128, false, 0);
		if curTarget:IsDead() or not(found) or distance > sensorRange then
			--target died, went out of range, or terrain got in the way, drop target
			curTarget = nil;
		end
	end
	
	--target was found or still exists, aim and fire
	if MovableMan:ValidMO(curTarget) then
		local distVect = SceneMan:ShortestDistance(self.Pos, curTarget.Pos, true);
		local actorAngle = distVect.AbsRadAngle;
		if actorAngle > math.pi / 2 or actorAngle < math.pi / -2 then
			ownCont:SetState(Controller.MOVE_LEFT, true);
		else
			ownCont:SetState(Controller.MOVE_RIGHT, true);
		end
		if actorAngle > math.pi / 2 then
			actorAngle = math.pi - actorAngle;
		end
		if actorAngle < math.pi / -2 then
			actorAngle = (math.pi * -1) - actorAngle;
		end
		self:SetAimAngle(actorAngle);
		equip:Activate();
	else
		equip:Deactivate();
	end
	
	return curTarget;
end