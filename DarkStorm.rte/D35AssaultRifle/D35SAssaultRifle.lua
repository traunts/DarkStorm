function Create(self)
	self.userRange = 20;
	self.fireVelocity = 60;
	self.spread = 0.01;
	self.recoil = 0.1;
	self.muzzleOffset = 12;
	self.reloadTime = 2000;
	self.refireTime = 5;
	self.capacity = 20;
	
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
				if particle.PresetName == "D35-S Assault Rifle Reload" then
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
					local empty = CreateAEmitter("D35-S Assault Rifle Empty Sound Emitter");
					empty.Pos = self.Pos;
					MovableMan:AddParticle(empty);
				end
				
				userCont:SetState(Controller.WEAPON_FIRE, false);
				
				if reload.Mass > self.reloadTime then
					reload.Lifetime = 1;
							
					local loading = CreateAEmitter("D35-S Assault Rifle Load Sound Emitter");
					loading.Pos = self.Pos;
					MovableMan:AddParticle(loading);
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
						if particle.PresetName == "D35-S Assault Rifle Refire" then
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
						if UInputMan:KeyHeld(secondaryFireKeyNum) and not(userCont:IsState(Controller.WEAPON_FIRE)) then
							--trigger pulled
							local noFired = 0;
							for particle in MovableMan.Particles do
								if particle.PresetName == "D35-S Assault Rifle Fired" then
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
									if particle.PresetName == "D35-S Assault Rifle Fired" then
										local distVect = SceneMan:ShortestDistance(user.Pos, particle.Pos, true);
										local dist = distVect.Magnitude;
										if dist <= self.userRange then
											particle.Lifetime = 1;
										end
									end
								end
								
								local shot = CreateAEmitter("D35-S Assault Rifle Unload Sound Emitter");
								shot.Pos = self.Pos;
								MovableMan:AddParticle(shot);
								
								reload = CreateMOPixel("D35-S Assault Rifle Reload");
								reload.Pos = user.Pos;
								MovableMan:AddParticle(reload);
							else
								local shot = CreateMOPixel("6mm Subsonic Caseless");
								shot.Pos.X = self.Pos.X + math.cos(aimAngle) * self.muzzleOffset;
								shot.Pos.Y = self.Pos.Y + math.sin(aimAngle) * self.muzzleOffset * -1;
								local posSpread = self.spread * math.random();
								local negSpread = -self.spread * math.random();
								local curSpread = posSpread + negSpread;
								local posRecoil = self.recoil * math.random();
								local negRecoil = -self.recoil * math.random();
								local curRecoil = posRecoil + negRecoil;
								if userCont:IsState(Controller.AIM_SHARP) then
									curRecoil = curRecoil / 2;
								end
								if userCont:IsState(Controller.BODY_CROUCH) then
									curRecoil = curRecoil / 2;
								end
								shot.Vel.X = math.cos(aimAngle + curSpread + curRecoil) * self.fireVelocity;
								shot.Vel.Y = math.sin(aimAngle + curSpread + curRecoil) * self.fireVelocity * -1;
								shot:SetWhichMOToNotHit(user, 1000);
								MovableMan:AddParticle(shot);
								
								local shot = CreateAEmitter("D35-S Assault Rifle Shot Sound Emitter");
								shot.Pos.X = self.Pos.X + math.cos(aimAngle) * self.muzzleOffset;
								shot.Pos.Y = self.Pos.Y + math.sin(aimAngle) * self.muzzleOffset * -1;
								MovableMan:AddParticle(shot);
								
								fired = CreateMOPixel("D35-S Assault Rifle Fired");
								fired.Pos = user.Pos;
								MovableMan:AddParticle(fired);
								
								fired = CreateMOPixel("D35-S Assault Rifle Refire");
								fired.Pos = user.Pos;
								MovableMan:AddParticle(fired);
							end
						end
					end
				end
			end
		end
	end
		
	self.Lifetime = 1;
end