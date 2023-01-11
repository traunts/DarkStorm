function Create(self)
	self.userRange = 20;
	self.laserRange = 1200;
	
	local checkVect = Vector(0,0);
	checkVect.X = math.cos(self.RotAngle) * self.userRange * -1;
	checkVect.Y = math.sin(self.RotAngle) * self.userRange;
	local userID = SceneMan:CastMORay(self.Pos, checkVect, self.ID, -2, -1, false, 0);
	local baseUserID = -1;
	if userID ~= 255 then
		baseUserID = MovableMan:GetRootMOID(userID);
		local user = MovableMan:GetMOFromID(baseUserID);
		if user:IsActor() then
			local strikePoint = Vector(0,0);
			local lastPoint = Vector(0,0);
			local dist = 0;
			local aimAngle = ToActor(user):GetAimAngle(true);
			
			checkVect.X = math.cos(aimAngle) * self.laserRange;
			checkVect.Y = math.sin(aimAngle) * self.laserRange * -1;
			dist = SceneMan:CastObstacleRay(self.Pos, checkVect, strikePoint, lastPoint, baseUserID, MovableMan:GetMOFromID(baseUserID).Team, -1, 0);
			if dist >= 0 then
				local point = CreateMOPixel("Laser Pointer Point");
				point.Pos = strikePoint;
				MovableMan:AddParticle(point);
			end
		end
	end
		
	self.Lifetime = 1;
end