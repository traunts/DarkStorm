require("Actors/AI/NativeHumanAI")
function Create(self)
	self.AI = NativeHumanAI:Create(self);

	InitializeKeys();

	self.healTimer = Timer();
	self.healTime = 2000;
	self.maxHealth = 100;
	
	self.slashSpeed = 50;
	self.slash = nil;
	self.slashOffset = Vector(0, -3);
	self.slashStartDistZero = 15;
	self.slashStartDistOne = 28;
	self.slashDist = 15;
	self.slashAnimTimer = Timer();
	self.slashAnimTime = 30;
	
	self.doubleTapTime = 250;
	self.doubleTapTimer = Timer();
	self.doubleTapSide = false;
	
	self.shockEnergyFactor = 8;
	self.shockPower = 6000;
	self.disruptPower = 281250;
	self.discharge = false;
	
	self.checkWidth = 20;
	self.checkHeight = 10;
	
	self.clingPos = Vector(0,0);
	self.clingOffset = 10;
	self.minClingAltitude = 40;
	
	self.phase = 0;
	
	self.gravTester = CreateMOPixel("Grav Tester");
	self.gravTester.Pos = Vector(self.Pos.X, self.Pos.Y - 3);
	self.gravTester.Vel = Vector(0,0);
	MovableMan:AddParticle(self.gravTester);
	self.gravAcc = 0;
	
	self.activeCamo = false;
	self.maxCamoEnergy = 1000;
	self.curCamoEnergy = self.maxCamoEnergy;
	self.camoEnergyLoss = 2;
	self.camoEnergyGain = 1;
	self.camoSwitchTimer = Timer();
	self.camoSwitchTime = 250;
	
	self.iconOffset = Vector(-6, -32);
	self.icon = nil;
	self.icon = CreateMOSParticle("D6Yuurei Energy Icon");
	self.icon.Pos = self.Pos + self.iconOffset;
	MovableMan:AddParticle(self.icon);
	
	self.meterOffset = Vector(10, -32);
	self.meter = nil;
	self.meter = CreateMOSParticle("Meter");
	self.meter.Pos = self.Pos + self.meterOffset;
	self.meter.Frame = self.meter.FrameCount - 1;
	MovableMan:AddParticle(self.meter);
	
	self.jumpForce = 2000;
	self.shortJumpFactor = 0.65;
	self.shortJumpTime = 100;
	self.shortJumpTimer = Timer();
	self.jump = false;
	self.jumpForceVect = Vector(0,0);
	self.maxJumpAltitude = 25;
	self.runJumpAngle = math.pi/3;
end

function Update(self)
	if not(self:IsDead()) then
		--get gravity acceleration
		if self.gravAcc == 0 and MovableMan:ValidMO(self.gravTester) then
			if self.gravTester.Vel.Y > 0 then
				self.gravAcc = self.gravTester.Vel.Y;
			end
		end
		
		--get velocity factor
		local velFactor = FrameMan.PPM * TimerMan.DeltaTimeSecs;
		
		--get the current controller
		local ownCont = self:GetController();
		
		--get melee key
		meleeKeyNum = -1;
		if ownCont.Player == 0 and PlayerOneDarkStormMelee ~= nil then
			meleeKeyNum = PlayerOneDarkStormMelee;
		elseif ownCont.Player == 1 and PlayerTwoDarkStormMelee ~= nil then
			meleeKeyNum = PlayerTwoDarkStormMelee;
		elseif ownCont.Player == 2 and PlayerThreeDarkStormMelee ~= nil then
			meleeKeyNum = PlayerThreeDarkStormMelee;
		elseif ownCont.Player == 3 and PlayerFourDarkStormMelee ~= nil then
			meleeKeyNum = PlayerFourDarkStormMelee;
		end
		
		--healz!
		if self.healTimer:IsPastSimMS(self.healTime) then
			self.Health = self.Health + 1;
			if self.Health > self.maxHealth then
				self.Health = self.maxHealth;
			end
			self.healTimer = Timer();
		end
		
		--handle camo activate/deactivate (when double-tap down)
		if ownCont:IsState(Controller.PRESS_DOWN) then
			if self.camoSwitchTimer:IsPastSimMS(self.camoSwitchTime) then
				self.camoSwitchTimer:Reset();
			else
				if self.activeCamo then
					self.activeCamo = false;
										
					local offSound = CreateAEmitter("D6Yuurei Camo Off Sound Emitter");
					offSound.Pos = self.Pos;
					MovableMan:AddParticle(offSound);
				else
					self.activeCamo = true;
					
					local onSound = CreateAEmitter("D6Yuurei Camo On Sound Emitter");
					onSound.Pos = self.Pos;
					MovableMan:AddParticle(onSound);
				end
			end
		end
		
		--handle double-tap sides
		if ownCont:IsState(Controller.PRESS_LEFT) or ownCont:IsState(Controller.PRESS_RIGHT) then
			if not(self.doubleTapTimer:IsPastSimMS(self.doubleTapTime)) then
				self.doubleTapSide = true;
			end
			self.doubleTapTimer:Reset();
		end
		
		--handle camo energy and camo icon animation
		if self.activeCamo then
			self.curCamoEnergy = self.curCamoEnergy - self.camoEnergyLoss;
			if self.curCamoEnergy <= 0 then
				self.curCamoEnergy = 0;
				self.activeCamo = false;
					
				local offSound = CreateAEmitter("D6Yuurei Camo Off Sound Emitter");
				offSound.Pos = self.Pos;
				MovableMan:AddParticle(offSound);
			end
		else
			self.curCamoEnergy = self.curCamoEnergy + self.camoEnergyGain;
			if self.curCamoEnergy > self.maxCamoEnergy then
				self.curCamoEnergy = self.maxCamoEnergy;
			end
		end
		
		--handle invisibility
		for i = 0, MovableMan:GetMOIDCount() do
			if MovableMan:GetRootMOID(i) == self.ID then
				local object = MovableMan:GetMOFromID(i);
				if not(object:IsDevice()) or (object:IsDevice() and (object.PresetName == "D35-S Assault Rifle" or object.PresetName == "D37-S Pistol")) then
					if self.activeCamo then
						object.Scale = 0;
					else
						object.Scale = 1;
					end
				end
			end
		end
		
		--update energy icon
		if MovableMan:ValidMO(self.icon) then
			self.icon.Pos = self.Pos + self.iconOffset;
			self.icon:NotResting();
			self.icon.Age = 0;
			self.icon.ToSettle = false;
		end
		
		--animate camo energy meter
		if MovableMan:ValidMO(self.meter) then
			self.meter.Pos = self.Pos + self.meterOffset;
			self.meter.Frame = (self.curCamoEnergy / self.maxCamoEnergy) * (self.meter.FrameCount - 1);
			self.meter:NotResting();
			self.meter.Age = 0;
			self.meter.ToSettle = false;
		end
		
		--handle jumping
		if self.jump then
			if not(self.shortJumpTimer:IsPastSimMS(self.shortJumpTime)) and not(ownCont:IsState(Controller.BODY_JUMP)) then
				--short jump
				self.jumpForceVect = self.jumpForceVect * self.shortJumpFactor;
				self.Vel = self.jumpForceVect / self.Mass;
				self.jump = false;
			elseif self.shortJumpTimer:IsPastSimMS(self.shortJumpTime) then
				--big jump
				self.Vel = self.jumpForceVect / self.Mass;
				self.jump = false
			end
		elseif ownCont:IsState(Controller.BODY_JUMPSTART) then
			if self:GetAltitude(0,0) <= self.maxJumpAltitude then
				--jump normally
				if ownCont:IsState(Controller.MOVE_LEFT) then
					local jumpAngle = math.pi - self.runJumpAngle;
					self.jumpForceVect.X = math.cos(jumpAngle) * self.jumpForce;
					self.jumpForceVect.Y = math.sin(jumpAngle) * self.jumpForce * -1;
				elseif ownCont:IsState(Controller.MOVE_RIGHT) then
					self.jumpForceVect.X = math.cos(self.runJumpAngle) * self.jumpForce;
					self.jumpForceVect.Y = math.sin(self.runJumpAngle) * self.jumpForce * -1;
				else
					self.jumpForceVect.X = 0;
					self.jumpForceVect.Y = -self.jumpForce;
				end
				
				local checkVect = self.jumpForceVect / self.Mass * velFactor;
				local strikePoint = Vector(0,0);
				local lastPoint = Vector(0,0);
				if SceneMan:CastObstacleRay(self.Pos, checkVect, strikePoint, lastPoint, self.ID, self.Team, -1, 0) < 0 then
					--no obstruction
					self.jump = true;
					self.shortJumpTimer:Reset();
				end
			elseif self.phase == 2 then
				--wall jump
				self.jumpForceVect.X = math.cos(self:GetAimAngle(true)) * self.jumpForce;
				self.jumpForceVect.Y = math.sin(self:GetAimAngle(true)) * self.jumpForce * -1;
				
				local checkVect = (self.jumpForceVect / self.Mass) * velFactor;
				local strikePoint = Vector(0,0);
				local lastPoint = Vector(0,0);
				if SceneMan:CastObstacleRay(self.Pos, checkVect, strikePoint, lastPoint, self.ID, self.Team, -1, 0) < 0 then
					--no obstruction
					self.jump = true;
					self.shortJumpTimer:Reset();
				end
			end
		end
	
		--handle melee attacks and wall clinging
		if self.phase == 0 then
			if UInputMan:KeyPressed(meleeKeyNum) and ownCont.Player ~= -1 and not(ownCont:IsState(Controller.WEAPON_RELOAD)) then
				local doSlash = false;
				local strikePoint = Vector(0,0);
				local lastPoint = Vector(0,0);
				if self:GetAltitude(0,0) > self.minClingAltitude then
					--see if there's something in the way
					local checkVect = Vector(math.cos(self:GetAimAngle(true)) * self.slashDist * 2, -math.sin(self:GetAimAngle(true)) * self.slashDist * 2);
					local checkPos = self.Pos + Vector(math.cos(self:GetAimAngle(true)) * self.slashStartDistZero, -math.sin(self:GetAimAngle(true)) * self.slashStartDistZero);
					local targetID = SceneMan:CastMORay(checkPos, checkVect, self.ID, self.Team, 0, false, 0);
					if targetID ~= 255 then
						--something is in the way
						doSlash = true;
					elseif SceneMan:CastObstacleRay(checkPos, checkVect, strikePoint, lastPoint, self.ID, self.Team, -1, 0) < 0 then
						--no terrain found
						doSlash = true;
					end
				else
					doSlash = true;
				end
				
				if doSlash then
					--do a regular slash
					self.slash = CreateMOSRotating("D94CombatKnife Slash");
					self.slash.Pos = self.Pos + self.slashOffset;
					self.slash.RotAngle = self:GetAimAngle(true);
					self.slash:SetWhichMOToNotHit(self, -1);
					MovableMan:AddParticle(self.slash);
				
					local slashSound = CreateAEmitter("D94CombatKnife Slash Sound Emitter");
					slashSound.Pos = self.Pos + self.slashOffset;
					MovableMan:AddParticle(slashSound);
					
					if self.doubleTapSide and not(self.doubleTapTimer:IsPastSimMS(self.doubleTapTime)) then
						self.discharge = true;
					end
					
					self.slashAnimTimer:Reset();
					self.phase = 1;
				else
					--cling
					local diffVect = self.Pos - strikePoint;
					local diffAngle = math.atan2(-diffVect.Y, diffVect.X);
					local offsetVect = Vector(math.cos(diffAngle) * self.clingOffset, -math.sin(diffAngle) * self.clingOffset);
					self.Pos = strikePoint + offsetVect;
					self.Vel = Vector(0,-self.gravAcc);
					
					local sound = CreateAEmitter("D94CombatKnife Cling Sound Emitter");
					sound.Pos = strikePoint;
					MovableMan:AddParticle(sound);
					
					self.phase = 2;
				end
				
				self.doubleTapSide = false;
			end
		elseif self.phase == 1 then
			if MovableMan:ValidMO(self.slash) then
				self.slash.Pos = self.Pos + self.slashOffset;
				
				--handle slash
				if self.slashAnimTimer:IsPastSimMS(self.slashAnimTime) then
					--find slash check starting distance
					local slashStartDist = self.slashStartDistZero;
					if self.slash.Frame == 1 then
						slashStartDist = self.slashStartDistOne;
					end
					
					--calculate hit
					local hit = false;
					local checkVect = Vector(math.cos(self.slash.RotAngle) * self.slashDist, -math.sin(self.slash.RotAngle) * self.slashDist);
					local checkPos = self.Pos + Vector(math.cos(self.slash.RotAngle) * slashStartDist, -math.sin(self.slash.RotAngle) * slashStartDist);
					local targetID = SceneMan:CastMORay(checkPos, checkVect, self.ID, self.Team, 0, false, 0);
					local targetBaseID = MovableMan:GetRootMOID(targetID);
					local target = MovableMan:GetMOFromID(targetBaseID);
					local strikePoint = Vector(0,0);
					if targetID ~= 255 then
						--target found
						if SceneMan:CastFindMORay(checkPos, checkVect, targetBaseID, strikePoint, -1, false, 0) then
							hit = true;
							
							--handle discharge
							if self.discharge and target:IsActor() and target.PresetName ~= "D2-E Tengu Bushi" and target.PresetName ~= "D4-E Oni Bushi" and target.PresetName ~= "D45Shishi" and target.PresetName ~= "D45Shishi Constructor Top" and target.PresetName ~= "D45Shishi Constructor Segment" and target.PresetName ~= "D45Shishi Constructor" then
								local damage = 0;
								local scale = 1;
								if self.curCamoEnergy < self.maxCamoEnergy / self.shockEnergyFactor then
									scale = self.curCamoEnergy/(self.maxCamoEnergy/self.shockEnergyFactor);
								end
										
								if target.Mass ~= 0 then
									damage = (self.shockPower * scale) / target.Mass;
								else
									damage = self.shockPower * scale;
								end
										
								ToActor(target).Health = ToActor(target).Health - damage;
										
								local shock = CreateMOPixel("EMP Disruption");
								shock.Pos = target.Pos;
								shock.Mass = self.disruptPower * scale;
								MovableMan:AddParticle(shock);
										
								local shockSound = CreateAEmitter("D94CombatKnife Discharge Sound Emitter");
								shockSound.Pos = strikePoint;
								MovableMan:AddParticle(shockSound);
										
								local shockEffect = CreateMOSParticle("D94CombatKnife Discharge");
								shockEffect.Pos = strikePoint;
								MovableMan:AddParticle(shockEffect);
										
								self.curCamoEnergy = self.curCamoEnergy - (self.maxCamoEnergy/self.shockEnergyFactor);
								if self.curCamoEnergy < 0 then
									self.curCamoEnergy = 0;
								end
								
								self.discharge = false;
							end
							
							self.slash.Frame = self.slash.FrameCount - 1;
						end
					else
						--no target, but handle striking terrain
						local lastPoint = Vector(0,0);
						if SceneMan:CastObstacleRay(checkPos, checkVect, strikePoint, lastPoint, self.ID, self.Team, -1, 0) >= 0 then
							hit = true;
						end
					end
					
					if hit then
						local flash = nil;
						local flashNo = math.random(0,2);
						if flashNo == 0 then
							flash = CreateMOPixel("D94CombatKnife Stab Flash A");
						elseif flashNo == 1 then
							flash = CreateMOPixel("D94CombatKnife Stab Flash B");
						elseif flashNo == 2 then
							flash = CreateMOPixel("D94CombatKnife Stab Flash C");
						end
						flash.Pos = strikePoint;
						MovableMan:AddParticle(flash);
						
						local sound = CreateAEmitter("D94CombatKnife Stab Sound Emitter");
						sound.Pos = strikePoint;
						MovableMan:AddParticle(sound);
						
						local stab = CreateMOPixel("D94CombatKnife Stab");
						stab.Pos = strikePoint;
						stab.Vel = self.Vel + Vector(math.cos(self.slash.RotAngle) * self.slashSpeed, -math.sin(self.slash.RotAngle) * self.slashSpeed);
						stab:SetWhichMOToNotHit(self, -1);
						MovableMan:AddParticle(stab);
						local stabTwo = CreateMOPixel("D94CombatKnife Stab");
						stabTwo.Pos = strikePoint;
						stabTwo.Vel = self.Vel + Vector(math.cos(self.slash.RotAngle) * self.slashSpeed, -math.sin(self.slash.RotAngle) * self.slashSpeed);
						stabTwo:SetWhichMOToNotHit(self, -1);
						MovableMan:AddParticle(stabTwo);
						
						self.slash.Frame = self.slash.FrameCount - 1;
					end
				
					if self.slash.Frame < self.slash.FrameCount - 1 then
						self.slash.Frame = self.slash.Frame + 1;
					else
						self.slash:GibThis();
						if self.phase ~= 2 then
							self.phase = 0;
						end
					end
					
					self.slashAnimTimer:Reset();
				end
			else
				self.phase = 0;
			end
		elseif self.phase == 2 then
			if (UInputMan:KeyPressed(meleeKeyNum) and ownCont.Player ~= -1) or ownCont:IsState(Controller.BODY_JUMPSTART) or ownCont:IsState(Controller.WEAPON_RELOAD) then
				self.phase = 0;
			else
				self.Vel = Vector(0,-self.gravAcc);
			end
		end
		
		if self.phase ~= 0 then
			ownCont:SetState(Controller.MOVE_LEFT, false);
			ownCont:SetState(Controller.MOVE_RIGHT, false);
		end
	else
		if MovableMan:ValidMO(self.stab) then
			self.stab.Lifetime = 1;
		end
		if MovableMan:ValidMO(self.stabGraphic) then
			self.stabGraphic.Lifetime = 1;
		end
		if MovableMan:ValidMO(self.icon) then
			self.icon.Lifetime = 1;
		end
		if MovableMan:ValidMO(self.meter) then
			self.meter.Lifetime = 1;
		end
	end
end

function UpdateAI(self)
	self.AI:Update(self)
end

function Destroy(self)
	if MovableMan:ValidMO(self.stab) then
		self.stab.Lifetime = 1;
	end
	if MovableMan:ValidMO(self.stabGraphic) then
		self.stabGraphic.Lifetime = 1;
	end
	if MovableMan:ValidMO(self.icon) then
		self.icon.Lifetime = 1;
	end
	if MovableMan:ValidMO(self.meter) then
		self.meter.Lifetime = 1;
	end
end