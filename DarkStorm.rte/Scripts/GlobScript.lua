function Update(self)
	local crystalNum = math.random(0,3);
	local impactLocation = Vector(0,0);
	local velFactor = FrameMan.PPM * TimerMan.DeltaTimeSecs;
	local targetID = SceneMan:CastMORay(self.Pos, self.Vel * velFactor, self.ID, -2, 0, true, 5);
	local target = MovableMan:GetMOFromID(MovableMan:GetRootMOID(targetID));
	local crystal = nil;
	if targetID ~= 255 and target:IsActor() then
		SceneMan:CastFindMORay(self.Pos, self.Vel * velFactor, targetID, impactLocation, 0, true, 5);
		if target.PresetName ~= "D2-C Tengu Bushi" and target.PresetName ~= "D4-C Oni Bushi" and target.PresetName ~= "D45Shishi" and target.PresetName ~= "D45Shishi Constructor Top" and target.PresetName ~= "D45Shishi Constructor Segment" and target.PresetName ~= "D45Shishi Constructor" then
			if crystalNum == 0 then
				crystal = CreateMOSParticle("Cryo Spray Actor Crystal A");
			elseif crystalNum == 1 then
				crystal = CreateMOSParticle("Cryo Spray Actor Crystal B");
			elseif crystalNum == 2 then
				crystal = CreateMOSParticle("Cryo Spray Actor Crystal C");
			elseif crystalNum == 3 then
				crystal = CreateMOSParticle("Cryo Spray Actor Crystal D");
			end
		else
			if crystalNum == 0 then
				crystal = CreateMOSRotating("Cryo Spray Midair Crystal A");
			elseif crystalNum == 1 then
				crystal = CreateMOSRotating("Cryo Spray Midair Crystal B");
			elseif crystalNum == 2 then
				crystal = CreateMOSRotating("Cryo Spray Midair Crystal C");
			elseif crystalNum == 3 then
				crystal = CreateMOSRotating("Cryo Spray Midair Crystal D");
			end
		end
		crystal.Pos = impactLocation;
		local fog = CreateMOSParticle("Cryo Spray Fog Particle");
		fog.Pos = crystal.Pos;
		fog.Vel = Vector(0, -2);
		MovableMan:AddParticle(fog);
		MovableMan:AddParticle(crystal);
		self:GibThis();
	else
		if SceneMan:CastStrengthRay(self.Pos, self.Vel * velFactor, 0, impactLocation, 5, 0, true) then
			if crystalNum == 0 then
				crystal = CreateMOSRotating("Cryo Spray Terrain Crystal A");
			elseif crystalNum == 1 then
				crystal = CreateMOSRotating("Cryo Spray Terrain Crystal B");
			elseif crystalNum == 2 then
				crystal = CreateMOSRotating("Cryo Spray Terrain Crystal C");
			elseif crystalNum == 3 then
				crystal = CreateMOSRotating("Cryo Spray Terrain Crystal D");
			end
			crystal.Pos = impactLocation;
			local fog = CreateMOSParticle("Cryo Spray Fog Particle");
			fog.Pos = crystal.Pos;
			fog.Vel = Vector(0, -2);
			MovableMan:AddParticle(fog);
			MovableMan:AddParticle(crystal);
			self:GibThis();
		end
	end
end