function Create(self)
	InitializeKeys();

	self.healTimer = Timer();
	self.healTime = 2000;
	self.maxHealth = 100;

	self.FGEquip = nil;
	self.BGEquip = nil;
	self.FGName = "";
	self.BGName = "";
	self.target = nil;
	
	self.equipDist = 30;
	self.equipOffset = Vector(0, -6);
end

function Update(self)
	if not(self:IsDead()) then
		--healz!
		if self.healTimer:IsPastSimMS(self.healTime) then
			self.Health = self.Health + 1;
			if self.Health > self.maxHealth then
				self.Health = self.maxHealth;
			end
			self.healTimer = Timer();
		end
	
		local ownCont = self:GetController();
		
		--get secondary fire key
		secondaryFireKeyNum = -1;
		if ownCont.Player == 0 and PlayerOneDarkStormSecondaryFire ~= nil then
			secondaryFireKeyNum = PlayerOneDarkStormSecondaryFire;
		elseif ownCont.Player == 1 and PlayerTwoDarkStormSecondaryFire ~= nil then
			secondaryFireKeyNum = PlayerTwoDarkStormSecondaryFire;
		elseif ownCont.Player == 2 and PlayerThreeDarkStormSecondaryFire ~= nil then
			secondaryFireKeyNum = PlayerThreeDarkStormSecondaryFire;
		elseif ownCont.Player == 3 and PlayerFourDarkStormSecondaryFire ~= nil then
			secondaryFireKeyNum = PlayerFourDarkStormSecondaryFire;
		end
		
		if MovableMan:ValidMO(self.FGEquip) then
			if ownCont:IsPlayerControlled(-1) then
				--if a player is controlling, do regular firing
				if ownCont:IsState(Controller.WEAPON_FIRE) then
					self.FGEquip:Activate();
				else
					self.FGEquip:Deactivate();
				end
			else
				--if not, engage auto-targeting
				self:SetControllerMode(Controller.CIM_DISABLED, -1);
				ownCont:SetState(Controller.WEAPON_FIRE, false);
				if self.FGName == "D38-T Gatling Gun Active" then
					self.FGTarget = D38TGatlingGunTargeting(self, ownCont, self.FGEquip, self.target);
				elseif self.FGName == "D107-T Revolver Laser Active" then
					self.FGTarget = D107TRevolverLaserTargeting(self, ownCont, self.FGEquip, self.target);
				elseif self.FGName == "D51 Missile Launcher Active" then
					self.FGTarget = D51MissileLauncherTargeting(self, ownCont, self.FGEquip, self.target);
				end
			end
			
			self.FGEquip.HFlipped = self.HFlipped;
			self.FGEquip.RotAngle = self:GetAimAngle(false);
			if self.FGEquip.HFlipped then
				self.FGEquip.RotAngle = self.FGEquip.RotAngle * -1;
			end
			self.FGEquip.Pos = self.Pos + self.equipOffset;
		end
		
		if MovableMan:ValidMO(self.BGEquip) then
			if ownCont:IsPlayerControlled(-1) then
				--if a player is controlling, do regular firing
				if UInputMan:KeyHeld(secondaryFireKeyNum) then
					self.BGEquip:Activate();
				else
					self.BGEquip:Deactivate();
				end
			else
				--if not, engage auto-targeting
				self:SetControllerMode(Controller.CIM_DISABLED, -1);
				ownCont:SetState(Controller.WEAPON_FIRE, false);
				if self.BGName == "D38-T Gatling Gun Active" then
					self.BGTarget = D38TGatlingGunTargeting(self, ownCont, self.BGEquip, self.target);
				elseif self.BGName == "D107-T Revolver Laser Active" then
					self.BGTarget = D107TRevolverLaserTargeting(self, ownCont, self.BGEquip, self.target);
				elseif self.BGName == "D51 Missile Launcher Active" then
					self.BGTarget = D51MissileLauncherTargeting(self, ownCont, self.BGEquip, self.target);
				end
			end
			
			self.BGEquip.HFlipped = self.HFlipped;
			self.BGEquip.RotAngle = self:GetAimAngle(false);
			if self.BGEquip.HFlipped then
				self.BGEquip.RotAngle = self.BGEquip.RotAngle * -1;
			end
			self.BGEquip.Pos = self.Pos + self.equipOffset;
		end

		--equipping
		if not(MovableMan:ValidMO(self.FGEquip)) or not(MovableMan:ValidMO(self.BGEquip)) then
			for device in MovableMan.Items do
				if device.PresetName == "D107-T Revolver Laser" or device.PresetName == "D38-T Gatling Gun" or device.PresetName == "D51 Missile Launcher" then
					local distVect = SceneMan:ShortestDistance(self.Pos, device.Pos, true);
					if distVect.Magnitude <= self.equipDist then
						if not(MovableMan:ValidMO(self.FGEquip)) then
							self.FGEquip = CreateHDFirearm(device.PresetName .. " Active");
							self.FGName = self.FGEquip.PresetName;
							self.FGEquip.PresetName = "";
							self.FGEquip.HFlipped = self.HFlipped;
							self.FGEquip.RotAngle = self:GetAimAngle(false);
							if self.FGEquip.HFlipped then
								self.FGEquip.RotAngle = self.FGEquip.RotAngle * -1;
							end
							self.FGEquip.Pos = self.Pos + self.equipOffset;
							self.FGEquip.Team = self.Team;
							MovableMan:AddParticle(self.FGEquip);
							
							local sound = CreateAEmitter("D45Shishi Equip Sound Emitter");
							sound.Pos = Vector(self.Pos.X, self.Pos.Y);
							MovableMan:AddParticle(sound);
						else
							self.BGEquip = CreateHDFirearm(device.PresetName .. " Active");
							self.BGName = self.BGEquip.PresetName;
							self.BGEquip.PresetName = "";
							self.BGEquip.HFlipped = self.HFlipped;
							self.BGEquip.RotAngle = self:GetAimAngle(false);
							if self.BGEquip.HFlipped then
								self.BGEquip.RotAngle = self.BGEquip.RotAngle * -1;
							end
							self.BGEquip.Pos = self.Pos + self.equipOffset;
							self.BGEquip.Team = self.Team;
							MovableMan:AddParticle(self.BGEquip);
							
							local sound = CreateAEmitter("D45Shishi Equip Sound Emitter");
							sound.Pos = Vector(self.Pos.X, self.Pos.Y);
							MovableMan:AddParticle(sound);
						end
						
						device.Lifetime = 1;
						device.ToDelete = true;
						
						break;
					end
				end
			end
		end
	end
end

function Destroy(self)
	if MovableMan:ValidMO(self.FGEquip) then
		self.FGEquip:GibThis();
	end
	
	if MovableMan:ValidMO(self.BGEquip) then
		self.BGEquip:GibThis();
	end
end