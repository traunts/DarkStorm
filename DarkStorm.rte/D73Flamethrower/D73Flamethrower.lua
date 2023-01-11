function Create(self)
	self.userRange = 20;
	self.fireVelocity = 1;
	self.spread = 0.1;
	self.muzzleOffset = 15;
	self.reloadTime = 4000;
	self.refireTime = 0;
	self.capacity = 100;
	
	--find user
	local checkVect = Vector(0,0);
	checkVect.X = math.cos(self.RotAngle) * self.userRange * -1;
	checkVect.Y = math.sin(self.RotAngle) * self.userRange;
	local userID = SceneMan:CastMORay(self.Pos, checkVect, -1, -2, -1, false, 0);
	local user = nil;
	if userID ~= 255 then
		user = MovableMan:GetMOFromID(MovableMan:GetRootMOID(userID));
	end
	
	if MovableMan:ValidMO(user) and user:IsActor() then
		local disruption = nil;
		for particle in MovableMan.Particles do
			if particle.PresetName == "EMP Disruption" then
				local distVect = SceneMan:ShortestDistance(user.Pos, particle.Pos, true);
				local dist = distVect.Magnitude;
				if dist <= self.userRange then
					disruption = particle;
					break;
				end
			end
		end
	
		if not(MovableMan:ValidMO(disruption)) then
			user = ToActor(user);
			local userCont = user:GetController();
			local aimAngle = user:GetAimAngle(true);
			
			local reload = nil;
			for particle in MovableMan.Particles do
				if particle.PresetName == "D73 Flamethrower Reload" then
					local distVect = SceneMan:ShortestDistance(user.Pos, particle.Pos, true);
					local dist = distVect.Magnitude;
					if dist <= self.userRange then
						reload = particle;
						break;
					end
				end
			end
				
			if MovableMan:ValidMO(reload) then
				--reloading
				reload.Mass = reload.Mass + TimerMan.DeltaTimeMS;
				
				if UInputMan:KeyPressed(secondaryFireKeyNum) then
					local empty = CreateAEmitter("D73 Flamethrower Empty Sound Emitter");
					empty.Pos = self.Pos;
					MovableMan:AddParticle(empty);
				end
				
				userCont:SetState(Controller.WEAPON_FIRE, false);
				
				if reload.Mass > self.reloadTime then
					reload.Lifetime = 1;
							
					local loading = CreateAEmitter("D73 Flamethrower Load Sound Emitter");
					loading.Pos = self.Pos;
					MovableMan:AddParticle(loading);
					
					for i = 0, MovableMan:GetMOIDCount() do
						if MovableMan:GetRootMOID(i) == user.ID then
							local object = MovableMan:GetMOFromID(i);
							if object.PresetName == "D73 Flamethrower Indicator Green" then
								object.Scale = 1;
							elseif object.PresetName == "D73 Flamethrower Indicator Yellow" or object.PresetName == "D73 Flamethrower Indicator Red" or object.PresetName == "D73 Flamethrower Indicator Blue" then
								object.Scale = 0;
							end
						end
					end
				end
			else
				--not reloading
				if userCont:IsPlayerControlled(-1) then
					--get secondary fire key
					secondaryFireKeyNum = -1;
					if userCont.Player == 0 and PlayerOneDarkStormSecondaryFire ~= nil then
						secondaryFireKeyNum = PlayerOneDarkStormSecondaryFire;
					elseif userCont.Player == 1 and PlayerTwoDarkStormSecondaryFire ~= nil then
						secondaryFireKeyNum = PlayerTwoDarkStormSecondaryFire;
					elseif userCont.Player == 2 and PlayerThreeDarkStormSecondaryFire ~= nil then
						secondaryFireKeyNum = PlayerThreeDarkStormSecondaryFire;
					elseif userCont.Player == 3 and PlayerFourDarkStormSecondaryFire ~= nil then
						secondaryFireKeyNum = PlayerFourDarkStormSecondaryFire;
					end
				
					local refire = nil;
					for particle in MovableMan.Particles do
						if particle.PresetName == "D73 Flamethrower Refire" then
							local distVect = SceneMan:ShortestDistance(user.Pos, particle.Pos, true);
							local dist = distVect.Magnitude;
							if dist <= self.userRange then
								refire = particle;
								break;
							end
						end
					end
					
					if MovableMan:ValidMO(refire) then
						--can't fire, still refire
						refire.Mass = refire.Mass + 1;
									
						if refire.Mass > self.refireTime then
							refire.Lifetime = 1;
						end
					else
						if UInputMan:KeyHeld(secondaryFireKeyNum) then
							--trigger pulled
							local noFired = 0;
							for particle in MovableMan.Particles do
								if particle.PresetName == "D73 Flamethrower Fired" then
									local distVect = SceneMan:ShortestDistance(user.Pos, particle.Pos, true);
									local dist = distVect.Magnitude;
									if dist <= self.userRange then
										noFired = noFired + 1;
									end
								end
							end
							
							if noFired >= self.capacity then
								--empty, do reloading
								for particle in MovableMan.Particles do
									if particle.PresetName == "D73 Flamethrower Fired" then
										local distVect = SceneMan:ShortestDistance(user.Pos, particle.Pos, true);
										local dist = distVect.Magnitude;
										if dist <= self.userRange then
											particle.Lifetime = 1;
										end
									end
								end
								
								local shot = CreateAEmitter("D73 Flamethrower Unload Sound Emitter");
								shot.Pos = self.Pos;
								MovableMan:AddParticle(shot);
								
								reload = CreateMOPixel("D73 Flamethrower Reload");
								reload.Pos = user.Pos;
								MovableMan:AddParticle(reload);
						
								for i = 0, MovableMan:GetMOIDCount() do
									if MovableMan:GetRootMOID(i) == user.ID then
										local object = MovableMan:GetMOFromID(i);
										if object.PresetName == "D73 Flamethrower Indicator Blue" then
											object.Scale = 1;
										elseif object.PresetName == "D73 Flamethrower Indicator Green" or object.PresetName == "D73 Flamethrower Indicator Yellow" or object.PresetName == "D73 Flamethrower Indicator Red" then
											object.Scale = 0;
										end
									end
								end
							else
								local shot = CreateAEmitter("Flamethrower Igniting Fire Emitter");
								shot.Pos.X = self.Pos.X + math.cos(aimAngle) * self.muzzleOffset;
								shot.Pos.Y = self.Pos.Y + math.sin(aimAngle) * self.muzzleOffset * -1;
								shot.Vel.X = math.cos(aimAngle) * self.fireVelocity;
								shot.Vel.Y = math.sin(aimAngle) * self.fireVelocity * -1;
								local posSpread = self.spread * math.random();
								local negSpread = -self.spread * math.random();
								shot.RotAngle = aimAngle + posSpread + negSpread;
								shot:SetWhichMOToNotHit(user, 1000);
								MovableMan:AddParticle(shot);
								
								local flash = CreateMOSRotating("Muzzle Flash D73 Flamethrower");
								flash.Pos.X = self.Pos.X + math.cos(aimAngle) * self.muzzleOffset;
								flash.Pos.Y = self.Pos.Y + math.sin(aimAngle) * self.muzzleOffset * -1;
								flash.RotAngle = aimAngle;
								MovableMan:AddParticle(flash);
								
								local shot = CreateAEmitter("D73 Flamethrower Shot Sound Emitter");
								shot.Pos.X = self.Pos.X + math.cos(aimAngle) * self.muzzleOffset;
								shot.Pos.Y = self.Pos.Y + math.sin(aimAngle) * self.muzzleOffset * -1;
								MovableMan:AddParticle(shot);
								
								fired = CreateMOPixel("D73 Flamethrower Fired");
								fired.Pos = user.Pos;
								MovableMan:AddParticle(fired);
								
								fired = CreateMOPixel("D73 Flamethrower Refire");
								fired.Pos = user.Pos;
								MovableMan:AddParticle(fired);
						
								if noFired + 1 >= self.capacity then
									for i = 0, MovableMan:GetMOIDCount() do
										if MovableMan:GetRootMOID(i) == user.ID then
											local object = MovableMan:GetMOFromID(i);
											if object.PresetName == "D73 Flamethrower Indicator Red" then
												object.Scale = 1;
											elseif object.PresetName == "D73 Flamethrower Indicator Green" or object.PresetName == "D73 Flamethrower Indicator Yellow" or object.PresetName == "D73 Flamethrower Indicator Blue" then
												object.Scale = 0;
											end
										end
									end
								elseif noFired + 1 >= self.capacity / 2 then
									for i = 0, MovableMan:GetMOIDCount() do
										if MovableMan:GetRootMOID(i) == user.ID then
											local object = MovableMan:GetMOFromID(i);
											if object.PresetName == "D73 Flamethrower Indicator Yellow" then
												object.Scale = 1;
											elseif object.PresetName == "D73 Flamethrower Indicator Green" or object.PresetName == "D73 Flamethrower Indicator Red" or object.PresetName == "D73 Flamethrower Indicator Blue" then
												object.Scale = 0;
											end
										end
									end
								end
							end
						end
					end
				end
			end
		end
	end
		
	self.Lifetime = 1;
end