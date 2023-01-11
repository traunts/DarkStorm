require("AI/NativeHumanAI")
function Create(self)
	self.AI = NativeHumanAI:Create(self)
	InitializeKeys()

	self.healTimer = Timer()
	self.healTime = 2000
	self.maxHealth = 100

	self.minForce = 0
	self.maxForce = 50000
	self.punchForce = self.minForce
	self.chargeFactor = 20
	self.punch = nil
	self.checkPunch = false
	self.lightPunchRange = 37
	self.mediumPunchRange = 40
	self.heavyPunchRange = 48
	self.punchRange = self.mediumPunchRange
	self.normalOffset = Vector(0, -5)
	self.punchOffset = self.normalOffset

	self.iconOffset = Vector(-6, -27)
	self.icon = nil

	self.meterOffset = Vector(10, -27)
	self.chargeMeter = nil
	self.cooldownMeter = nil

	self.punchAnimTime = 30
	self.punchAnimTimer = Timer()

	self.doubleTapTime = 250
	self.doubleTapTimer = Timer()
	self.doubleTapSide = false

	self.grappleTarget = nil
	self.grappleOffset = 20
	self.liftStrength = 500

	self.gravTester = CreateMOPixel("Grav Tester")
	self.gravTester.Pos = Vector(self.Pos.X, self.Pos.Y - 3)
	self.gravTester.Vel = Vector(0, 0)
	MovableMan:AddParticle(self.gravTester)
	self.gravAcc = 0

	self.strikeMaxVel = 400

	self.phase = 0

	self.jumpForce = 3000
	self.shortJumpFactor = 0.65
	self.shortJumpTime = 100
	self.shortJumpTimer = Timer()
	self.jump = false
	self.jumpForceVect = Vector(0, 0)
	self.maxJumpAltitude = 35
	self.runJumpAngle = math.pi / 3

	self.packRange = 30
	self.packTime = 1000
	self.packTimer = Timer()
	self.dropPackTime = 250
	self.dropPackTimer = Timer()
	self.dropPackVel = 5
	self.packMass = 15
end

function Update(self)
	if not (self:IsDead()) then
		--get gravity acceleration
		if self.gravAcc == 0 and MovableMan:ValidMO(self.gravTester) then
			if self.gravTester.Vel.Y > 0 then
				self.gravAcc = self.gravTester.Vel.Y
			end
		end

		--get velocity factor
		local velFactor = GetPPM() * TimerMan.DeltaTimeSecs

		--get controller
		local ownCont = self:GetController()

		--get melee key
		meleeKeyNum = -1
		if ownCont.Player == 0 and PlayerOneDarkStormMelee ~= nil then
			meleeKeyNum = PlayerOneDarkStormMelee
		elseif ownCont.Player == 1 and PlayerTwoDarkStormMelee ~= nil then
			meleeKeyNum = PlayerTwoDarkStormMelee
		elseif ownCont.Player == 2 and PlayerThreeDarkStormMelee ~= nil then
			meleeKeyNum = PlayerThreeDarkStormMelee
		elseif ownCont.Player == 3 and PlayerFourDarkStormMelee ~= nil then
			meleeKeyNum = PlayerFourDarkStormMelee
		end

		--healz!
		if self.healTimer:IsPastSimMS(self.healTime) then
			self.Health = self.Health + 1
			if self.Health > self.maxHealth then
				self.Health = self.maxHealth
			end
			self.healTimer = Timer()
		end

		--handle double taps
		if ownCont:IsState(Controller.PRESS_LEFT) or ownCont:IsState(Controller.PRESS_RIGHT) then
			if not (self.doubleTapTimer:IsPastSimMS(self.doubleTapTime)) then
				self.doubleTapSide = true
			end
			self.doubleTapTimer:Reset()
		end

		--equip ammo supply
		if self.packTimer:IsPastSimMS(self.packTime) then
			local noPack = true
			local object = nil
			for i = 0, MovableMan:GetMOIDCount() do
				if MovableMan:GetRootMOID(i) == self.ID then
					object = MovableMan:GetMOFromID(i)
					if
						(
							object.PresetName == "D38GatlingGun Pack"
							or object.PresetName == "D107RevolverLaser Pack"
							or object.PresetName == "D52GrenadeMachineGun HE Pack"
							or object.PresetName == "D52GrenadeMachineGun EMP Pack"
							or object.PresetName == "D52GrenadeMachineGun Incendiary Pack"
						) and object.Scale == 1
					then
						noPack = false
						break
					end
				end
			end
			if noPack then
				--no ammo pack, look for one
				for device in MovableMan.Items do
					if
						device.PresetName == "D38 Gatling Gun 6mm Caseless Supply"
						or device.PresetName == "D107 Revolver Laser 50kW FCG Supply"
						or device.PresetName == "D52 Grenade Machine Gun HE Grenade Supply"
						or device.PresetName == "D52 Grenade Machine Gun EMP Grenade Supply"
						or device.PresetName == "D52 Grenade Machine Gun Incendiary Grenade Supply"
					then
						local distVect = SceneMan:ShortestDistance(self.Pos, device.Pos, true)
						local dist = distVect.Magnitude
						if dist <= self.packRange then
							--a pack is nearby, equip it
							if device.PresetName == "D38 Gatling Gun 6mm Caseless Supply" then
								for i = 0, MovableMan:GetMOIDCount() do
									if MovableMan:GetRootMOID(i) == self.ID then
										object = MovableMan:GetMOFromID(i)
										if object.PresetName == "D38GatlingGun Pack" and object.Scale == 0 then
											object.Scale = 1
											object.Mass = self.packMass
											device.Lifetime = 1

											local load = CreateAEmitter("Oni Ammo Pack Load")
											load.Pos = object.Pos
											MovableMan:AddParticle(load)

											break
										end
									end
								end
							elseif device.PresetName == "D107 Revolver Laser 50kW FCG Supply" then
								for i = 0, MovableMan:GetMOIDCount() do
									if MovableMan:GetRootMOID(i) == self.ID then
										object = MovableMan:GetMOFromID(i)
										if object.PresetName == "D107RevolverLaser Pack" and object.Scale == 0 then
											object.Scale = 1
											object.Mass = self.packMass
											device.Lifetime = 1

											local load = CreateAEmitter("Oni Ammo Pack Load")
											load.Pos = object.Pos
											MovableMan:AddParticle(load)

											break
										end
									end
								end
							elseif device.PresetName == "D52 Grenade Machine Gun HE Grenade Supply" then
								for i = 0, MovableMan:GetMOIDCount() do
									if MovableMan:GetRootMOID(i) == self.ID then
										object = MovableMan:GetMOFromID(i)
										if
											object.PresetName == "D52GrenadeMachineGun HE Pack"
											and object.Scale == 0
										then
											object.Scale = 1
											object.Mass = self.packMass
											device.Lifetime = 1

											local load = CreateAEmitter("Oni Ammo Pack Load")
											load.Pos = object.Pos
											MovableMan:AddParticle(load)

											break
										end
									end
								end
							elseif device.PresetName == "D52 Grenade Machine Gun EMP Grenade Supply" then
								for i = 0, MovableMan:GetMOIDCount() do
									if MovableMan:GetRootMOID(i) == self.ID then
										object = MovableMan:GetMOFromID(i)
										if
											object.PresetName == "D52GrenadeMachineGun EMP Pack"
											and object.Scale == 0
										then
											object.Scale = 1
											object.Mass = self.packMass
											device.Lifetime = 1

											local load = CreateAEmitter("Oni Ammo Pack Load")
											load.Pos = object.Pos
											MovableMan:AddParticle(load)

											break
										end
									end
								end
							elseif device.PresetName == "D52 Grenade Machine Gun Incendiary Grenade Supply" then
								for i = 0, MovableMan:GetMOIDCount() do
									if MovableMan:GetRootMOID(i) == self.ID then
										object = MovableMan:GetMOFromID(i)
										if
											object.PresetName == "D52GrenadeMachineGun Incendiary Pack"
											and object.Scale == 0
										then
											object.Scale = 1
											object.Mass = self.packMass
											device.Lifetime = 1

											local load = CreateAEmitter("Oni Ammo Pack Load")
											load.Pos = object.Pos
											MovableMan:AddParticle(load)

											break
										end
									end
								end
							end
						end
					end
				end
			else
				--ammo pack equipped, check for double-tap down to drop it
				if ownCont:IsState(Controller.PRESS_DOWN) then
					if self.dropPackTimer:IsPastSimMS(self.dropPackTime) then
						self.dropPackTimer:Reset()
					else
						local pack = nil
						if object.PresetName == "D38GatlingGun Pack" then
							pack = CreateHeldDevice("D38 Gatling Gun 6mm Caseless Supply")
						elseif object.PresetName == "D107RevolverLaser Pack" then
							pack = CreateHeldDevice("D107 Revolver Laser 50kW FCG Supply")
						elseif object.PresetName == "D52GrenadeMachineGun HE Pack" then
							pack = CreateHeldDevice("D52 Grenade Machine Gun HE Grenade Supply")
						elseif object.PresetName == "D52GrenadeMachineGun EMP Pack" then
							pack = CreateHeldDevice("D52 Grenade Machine Gun EMP Grenade Supply")
						elseif object.PresetName == "D52GrenadeMachineGun Incendiary Pack" then
							pack = CreateHeldDevice("D52 Grenade Machine Gun Incendiary Grenade Supply")
						end

						if pack ~= nil then
							pack.Pos = object.Pos
							pack.Vel.X = self.dropPackVel
							if not self.HFlipped then
								pack.Vel.X = pack.Vel.X * -1
							end
							pack.Vel.Y = 0
							MovableMan:AddItem(pack)

							pack:SetWhichMOToNotHit(self, 1000)
							self:SetWhichMOToNotHit(pack, 1000)

							local unload = CreateAEmitter("Oni Ammo Pack Unload")
							unload.Pos = object.Pos
							MovableMan:AddParticle(unload)

							object.Scale = 0
							object.Mass = 0
							self.packTimer:Reset()
						end
					end
				end
			end
		end

		--handle jumping
		if self.jump then
			if
				not (self.shortJumpTimer:IsPastSimMS(self.shortJumpTime)) and not (
					ownCont:IsState(Controller.BODY_JUMP)
				)
			then
				--short jump
				self.jumpForceVect = self.jumpForceVect * self.shortJumpFactor
				local jumpMass = self.Mass
				if MovableMan:ValidMO(self.grappleTarget) then
					jumpMass = jumpMass + self.grappleTarget.Mass
				end
				self.Vel = self.jumpForceVect / jumpMass
				self.jump = false
			elseif self.shortJumpTimer:IsPastSimMS(self.shortJumpTime) then
				--big jump
				local jumpMass = self.Mass
				if MovableMan:ValidMO(self.grappleTarget) then
					jumpMass = jumpMass + self.grappleTarget.Mass
				end
				self.Vel = self.jumpForceVect / jumpMass
				self.jump = false
			end
		elseif ownCont:IsState(Controller.BODY_JUMPSTART) then
			if self:GetAltitude(0, 0) <= self.maxJumpAltitude then
				--jump normally
				if ownCont:IsState(Controller.MOVE_LEFT) then
					local jumpAngle = math.pi - self.runJumpAngle
					self.jumpForceVect.X = math.cos(jumpAngle) * self.jumpForce
					self.jumpForceVect.Y = math.sin(jumpAngle) * self.jumpForce * -1
				elseif ownCont:IsState(Controller.MOVE_RIGHT) then
					self.jumpForceVect.X = math.cos(self.runJumpAngle) * self.jumpForce
					self.jumpForceVect.Y = math.sin(self.runJumpAngle) * self.jumpForce * -1
				else
					self.jumpForceVect.X = 0
					self.jumpForceVect.Y = -self.jumpForce
				end

				local jumpMass = self.Mass
				if MovableMan:ValidMO(self.grappleTarget) then
					jumpMass = jumpMass + self.grappleTarget.Mass
				end
				local checkVect = self.jumpForceVect / jumpMass * velFactor
				local strikePoint = Vector(0, 0)
				local lastPoint = Vector(0, 0)
				if
					SceneMan:CastObstacleRay(self.Pos, checkVect, strikePoint, lastPoint, self.ID, self.Team, -1, 0) < 0
				then
					--no obstruction
					self.jump = true
					self.shortJumpTimer:Reset()
				end
			end
		end

		if self.phase == 0 then
			--melee key pressed, make chage meter
			if
				UInputMan:KeyHeld(meleeKeyNum)
				and ownCont.Player ~= -1
				and not (ownCont:IsState(Controller.WEAPON_RELOAD))
			then
				self.icon = CreateMOSParticle("D4Punch Icon")
				self.icon.Pos = self.Pos + self.iconOffset
				self.icon.Frame = 0
				MovableMan:AddParticle(self.icon)

				self.chargeMeter = CreateMOSParticle("Charge Meter")
				self.chargeMeter.Pos = self.Pos + self.meterOffset
				self.chargeMeter.Frame = ((self.punchForce - self.minForce) / (self.maxForce - self.minForce))
					* (self.chargeMeter.FrameCount - 1)
				MovableMan:AddParticle(self.chargeMeter)

				self.phase = 1
			end
		elseif self.phase == 1 then
			--keep charging punch until melee key released
			if
				UInputMan:KeyHeld(meleeKeyNum)
				and ownCont.Player ~= -1
				and not (ownCont:IsState(Controller.WEAPON_RELOAD))
			then
				self.punchForce = self.punchForce + ((self.maxForce - self.minForce) / self.chargeFactor)
				if self.punchForce > self.maxForce then
					self.punchForce = self.maxForce
				end
			else
				if MovableMan:ValidMO(self.grappleTarget) then
					--if currently grappling, just throw whatever is held
					local throwSpeed = math.sqrt(self.punchForce / self.grappleTarget.Mass) / velFactor
					local throwVel = Vector(0, 0)
					throwVel.X = math.cos(self:GetAimAngle(true)) * throwSpeed
					throwVel.Y = math.sin(self:GetAimAngle(true)) * throwSpeed * -1
					self.grappleTarget.Vel = self.Vel + throwVel

					--release target
					self.grappleTarget:SetWhichMOToNotHit(self, 500)
					self:SetWhichMOToNotHit(self.grappleTarget, 500)
					self.grappleTarget = nil

					--switch to cooldown meter
					if MovableMan:ValidMO(self.icon) then
						self.icon.Frame = 1
						self.icon.Pos = self.Pos + self.iconOffset
						self.icon:NotResting()
						self.icon.Age = 0
						self.icon.ToSettle = false
					end
					if MovableMan:ValidMO(self.chargeMeter) then
						self.chargeMeter.Lifetime = 1
						self.chargeMeter = nil
					end

					self.cooldownMeter = CreateMOSParticle("Cooldown Meter")
					self.cooldownMeter.Pos = self.Pos + self.meterOffset
					self.cooldownMeter.Frame = ((self.punchForce - self.minForce) / (self.maxForce - self.minForce))
						* (self.cooldownMeter.FrameCount - 1)
					MovableMan:AddParticle(self.cooldownMeter)

					self.phase = 3
				else
					--if a direction was double-tapped, grapple. Otherwise, punch in the direction the actor is aiming
					if self.doubleTapSide and not (self.doubleTapTimer:IsPastSimMS(self.doubleTapTime)) then
						--double tap, so try to grapple
						local checkVect = Vector(0, 0)
						checkVect.X = math.cos(self:GetAimAngle(true)) * self.mediumPunchRange
						checkVect.Y = math.sin(self:GetAimAngle(true)) * self.mediumPunchRange * -1
						local targetID = SceneMan:CastMORay(
							self.Pos + self.normalOffset,
							checkVect,
							self.ID,
							self.Team,
							-1,
							false,
							0
						)
						if targetID ~= 255 then
							--found something
							local targetBaseID = MovableMan:GetRootMOID(targetID)
							local target = MovableMan:GetMOFromID(targetBaseID)
							if target.Mass <= self.liftStrength and target.PinStrength <= 0 then
								--it's loose, and light enough to lift, grab it
								self.grappleTarget = target
								self.grappleTarget:SetWhichMOToNotHit(self, -1)
								self:SetWhichMOToNotHit(self.grappleTarget, -1)
							end
						end

						--ditch the charge meter since it didn't do anything
						if MovableMan:ValidMO(self.icon) then
							self.icon.Lifetime = 1
							self.icon = nil
						end
						if MovableMan:ValidMO(self.chargeMeter) then
							self.chargeMeter.Lifetime = 1
							self.chargeMeter = nil
						end

						self.punchForce = 0

						self.phase = 0
					else
						--no double tap, set up punch
						local punchSound = nil
						if self.punchForce > (self.maxForce - self.minForce) * (2 / 3) then
							self.punch = CreateMOSRotating("D4Punch Heavy")
							punchSound = CreateAEmitter("D4Punch Heavy Sound Emitter")
						elseif self.punchForce > (self.maxForce - self.minForce) / 3 then
							self.punch = CreateMOSRotating("D4Punch Medium")
							punchSound = CreateAEmitter("D4Punch Medium Sound Emitter")
						else
							self.punch = CreateMOSRotating("D4Punch Light")
							punchSound = CreateAEmitter("D4Punch Light Sound Emitter")
							self.checkPunch = true
							self.punchRange = self.lightPunchRange
						end

						self.punchAngle = self:GetAimAngle(true)
						self.punchOffset = self.normalOffset
						self.punch.RotAngle = self.punchAngle
						self.punch.Pos = self.Pos + self.punchOffset
						self.punch:SetWhichMOToNotHit(self, -1)
						MovableMan:AddParticle(self.punch)

						punchSound.Pos = self.punch.Pos
						MovableMan:AddParticle(punchSound)

						self.punchAnimTimer:Reset()
						self.phase = 2
					end
				end

				self.doubleTapSide = false
			end

			--update meter
			if MovableMan:ValidMO(self.icon) then
				self.icon.Pos = self.Pos + self.iconOffset
				self.icon:NotResting()
				self.icon.Age = 0
				self.icon.ToSettle = false
			end
			if MovableMan:ValidMO(self.chargeMeter) then
				self.chargeMeter.Pos = self.Pos + self.meterOffset
				self.chargeMeter.Frame = ((self.punchForce - self.minForce) / (self.maxForce - self.minForce))
					* (self.chargeMeter.FrameCount - 1)
				self.chargeMeter:NotResting()
				self.chargeMeter.Age = 0
				self.chargeMeter.ToSettle = false
			end
		elseif self.phase == 2 then
			if MovableMan:ValidMO(self.punch) then
				--update meter
				if MovableMan:ValidMO(self.icon) then
					self.icon.Pos = self.Pos + self.iconOffset
					self.icon:NotResting()
					self.icon.Age = 0
					self.icon.ToSettle = false
				end
				if MovableMan:ValidMO(self.chargeMeter) then
					self.chargeMeter.Pos = self.Pos + self.meterOffset
					self.chargeMeter:NotResting()
					self.chargeMeter.Age = 0
					self.chargeMeter.ToSettle = false
				end

				self.punch.Pos = self.Pos + self.punchOffset

				--animate punch
				if self.punchAnimTimer:IsPastSimMS(self.punchAnimTime) then
					if self.punch.PresetName == "D4Punch Light" then
						self.punch:GibThis()
					elseif self.punch.PresetName == "D4Punch Medium" then
						if self.punch.Frame < self.punch.FrameCount - 1 then
							self.punch.Frame = self.punch.Frame + 1
						else
							self.punch:GibThis()
						end
						if self.punch.Frame == 1 then
							self.checkPunch = true
							self.punchRange = self.mediumPunchRange
						end
					else
						if self.punch.Frame < self.punch.FrameCount - 1 then
							self.punch.Frame = self.punch.Frame + 1
						else
							self.punch:GibThis()
						end
						if self.punch.Frame == 2 then
							self.checkPunch = true
							self.punchRange = self.heavyPunchRange
						end
					end
					self.punchAnimTimer:Reset()
				end

				--calculate hit
				if self.checkPunch then
					local checkVect = Vector(0, 0)
					checkVect.X = math.cos(self.punchAngle) * self.punchRange
					checkVect.Y = math.sin(self.punchAngle) * self.punchRange * -1
					local checkPos = self.Pos + self.punchOffset
					local targetID = SceneMan:CastMORay(checkPos, checkVect, self.ID, self.Team, 0, false, 0)
					local target = MovableMan:GetMOFromID(targetID)
					local targetBaseID = MovableMan:GetRootMOID(targetID)
					if targetID ~= 255 and target.GetsHitByMOs then
						--target found, find where they were struck and apply force to that point
						local strikePoint = Vector(0, 0)
						if SceneMan:CastFindMORay(checkPos, checkVect, targetBaseID, strikePoint, -1, false, 0) then
							local forceVect = Vector(0, 0)
							forceVect.X = (math.cos(self.punchAngle) * self.punchForce) + (self.Mass * self.Vel.X)
							forceVect.Y = (math.sin(self.punchAngle) * self.punchForce * -1) + (self.Mass * self.Vel.Y)
							target:AddAbsForce(forceVect, strikePoint)

							local flash = nil
							local sound = nil
							local strikeOne = nil
							local strikeTwo = nil
							local strikeThree = nil
							local strikeVel = ((self.punchForce - self.minForce) / (self.maxForce - self.minForce))
								* self.strikeMaxVel
							if self.punch.PresetName == "D4Punch Light" then
								flash = CreateMOPixel("D4Punch Light Flash")
								sound = CreateAEmitter("D4Punch Light Hit Sound Emitter")
								strikeOne = CreateMOPixel("D4Punch Strike")
							elseif self.punch.PresetName == "D4Punch Medium" then
								flash = CreateMOPixel("D4Punch Medium Flash")
								sound = CreateAEmitter("D4Punch Medium Hit Sound Emitter")
								strikeOne = CreateMOPixel("D4Punch Strike")
								strikeTwo = CreateMOPixel("D4Punch Strike")
								strikeTwo.Pos = strikePoint
								strikeTwo.Vel.X = self.Vel.X + math.cos(self.punchAngle) * strikeVel
								strikeTwo.Vel.Y = self.Vel.Y + math.sin(self.punchAngle) * strikeVel * -1
								strikeTwo:SetWhichMOToNotHit(self, -1)
								MovableMan:AddParticle(strikeTwo)
							else
								flash = CreateMOPixel("D4Punch Heavy Flash")
								sound = CreateAEmitter("D4Punch Heavy Hit Sound Emitter")
								strikeOne = CreateMOPixel("D4Punch Strike")
								strikeTwo = CreateMOPixel("D4Punch Strike")
								strikeThree = CreateMOPixel("D4Punch Strike")
								strikeTwo.Pos = strikePoint
								strikeTwo.Vel.X = self.Vel.X + math.cos(self.punchAngle) * strikeVel
								strikeTwo.Vel.Y = self.Vel.Y + math.sin(self.punchAngle) * strikeVel * -1
								strikeTwo:SetWhichMOToNotHit(self, -1)
								MovableMan:AddParticle(strikeTwo)
								strikeThree.Pos = strikePoint
								strikeThree.Vel.X = self.Vel.X + math.cos(self.punchAngle) * strikeVel
								strikeThree.Vel.Y = self.Vel.Y + math.sin(self.punchAngle) * strikeVel * -1
								strikeThree:SetWhichMOToNotHit(self, -1)
								MovableMan:AddParticle(strikeThree)
							end
							flash.Pos = strikePoint
							MovableMan:AddParticle(flash)
							sound.Pos = strikePoint
							MovableMan:AddParticle(sound)
							strikeOne.Pos = strikePoint
							strikeOne.Vel.X = self.Vel.X + math.cos(self.punchAngle) * strikeVel
							strikeOne.Vel.Y = self.Vel.Y + math.sin(self.punchAngle) * strikeVel * -1
							strikeOne:SetWhichMOToNotHit(self, -1)
							MovableMan:AddParticle(strikeOne)
						end
					else
						--no target, but make effects if it hits terrain
						local strikePoint = Vector(0, 0)
						local lastPoint = Vector(0, 0)
						if
							SceneMan:CastObstacleRay(
								checkPos,
								checkVect,
								strikePoint,
								lastPoint,
								self.ID,
								self.Team,
								-1,
								0
							) >= 0
						then
							local flash = nil
							local sound = nil
							local strikeOne = nil
							local strikeTwo = nil
							local strikeThree = nil
							local strikeVel = ((self.punchForce - self.minForce) / (self.maxForce - self.minForce))
								* self.strikeMaxVel
							if self.punch.PresetName == "D4Punch Light" then
								flash = CreateMOPixel("D4Punch Light Flash")
								sound = CreateAEmitter("D4Punch Light Hit Sound Emitter")
								strikeOne = CreateMOPixel("D4Punch Strike")
							elseif self.punch.PresetName == "D4Punch Medium" then
								flash = CreateMOPixel("D4Punch Medium Flash")
								sound = CreateAEmitter("D4Punch Medium Hit Sound Emitter")
								strikeOne = CreateMOPixel("D4Punch Strike")
								strikeTwo = CreateMOPixel("D4Punch Strike")
								strikeTwo.Pos = strikePoint
								strikeTwo.Vel.X = self.Vel.X + math.cos(self.punchAngle) * strikeVel
								strikeTwo.Vel.Y = self.Vel.Y + math.sin(self.punchAngle) * strikeVel * -1
								strikeTwo:SetWhichMOToNotHit(self, -1)
								MovableMan:AddParticle(strikeTwo)
							else
								flash = CreateMOPixel("D4Punch Heavy Flash")
								sound = CreateAEmitter("D4Punch Heavy Hit Sound Emitter")
								strikeOne = CreateMOPixel("D4Punch Strike")
								strikeTwo = CreateMOPixel("D4Punch Strike")
								strikeThree = CreateMOPixel("D4Punch Strike")
								strikeTwo.Pos = strikePoint
								strikeTwo.Vel.X = self.Vel.X + math.cos(self.punchAngle) * strikeVel
								strikeTwo.Vel.Y = self.Vel.Y + math.sin(self.punchAngle) * strikeVel * -1
								strikeTwo:SetWhichMOToNotHit(self, -1)
								MovableMan:AddParticle(strikeTwo)
								strikeThree.Pos = strikePoint
								strikeThree.Vel.X = self.Vel.X + math.cos(self.punchAngle) * strikeVel
								strikeThree.Vel.Y = self.Vel.Y + math.sin(self.punchAngle) * strikeVel * -1
								strikeThree:SetWhichMOToNotHit(self, -1)
								MovableMan:AddParticle(strikeThree)
							end
							flash.Pos = strikePoint
							MovableMan:AddParticle(flash)
							sound.Pos = strikePoint
							MovableMan:AddParticle(sound)
							strikeOne.Pos = strikePoint
							strikeOne.Vel.X = self.Vel.X + math.cos(self.punchAngle) * strikeVel
							strikeOne.Vel.Y = self.Vel.Y + math.sin(self.punchAngle) * strikeVel * -1
							strikeOne:SetWhichMOToNotHit(self, -1)
							MovableMan:AddParticle(strikeOne)
						end
					end
					self.checkPunch = false
				end
			else
				--switch to cooldown meter
				if MovableMan:ValidMO(self.icon) then
					self.icon.Frame = 1
					self.icon.Pos = self.Pos + self.iconOffset
					self.icon:NotResting()
					self.icon.Age = 0
					self.icon.ToSettle = false
				end
				if MovableMan:ValidMO(self.chargeMeter) then
					self.chargeMeter.Lifetime = 1
					self.chargeMeter = nil
				end

				self.cooldownMeter = CreateMOSParticle("Cooldown Meter")
				self.cooldownMeter.Pos = self.Pos + self.meterOffset
				self.cooldownMeter.Frame = ((self.punchForce - self.minForce) / (self.maxForce - self.minForce))
					* (self.cooldownMeter.FrameCount - 1)
				MovableMan:AddParticle(self.cooldownMeter)

				self.phase = 3
			end
		elseif self.phase == 3 then
			if self.punchForce <= self.minForce then
				if MovableMan:ValidMO(self.icon) then
					self.icon.Lifetime = 1
					self.icon = nil
				end
				if MovableMan:ValidMO(self.cooldownMeter) then
					self.cooldownMeter.Lifetime = 1
					self.cooldownMeter = nil
				end

				self.punchForce = self.minForce

				self.phase = 0
			else
				self.punchForce = self.punchForce - ((self.maxForce - self.minForce) / self.chargeFactor)

				if MovableMan:ValidMO(self.icon) then
					self.icon.Pos = self.Pos + self.iconOffset
					self.icon:NotResting()
					self.icon.Age = 0
					self.icon.ToSettle = false
				end
				if MovableMan:ValidMO(self.cooldownMeter) then
					self.cooldownMeter.Pos = self.Pos + self.meterOffset
					self.cooldownMeter.Frame = ((self.punchForce - self.minForce) / (self.maxForce - self.minForce))
						* (self.cooldownMeter.FrameCount - 1)
					self.cooldownMeter:NotResting()
					self.cooldownMeter.Age = 0
					self.cooldownMeter.ToSettle = false
				end
			end
		end

		if MovableMan:ValidMO(self.grappleTarget) then
			--can't shoot while holding something
			ownCont:SetState(Controller.WEAPON_FIRE, false)

			--update target position
			local holdOffset = Vector(self.normalOffset.X, self.normalOffset.Y)
			local holdVect = Vector(0, 0)
			holdVect.X = math.cos(self:GetAimAngle(true)) * self.grappleOffset
			holdVect.Y = math.sin(self:GetAimAngle(true)) * self.grappleOffset * -1
			self.grappleTarget.Pos = self.Pos + holdOffset + holdVect
			self.grappleTarget.Vel = Vector(0, 0)

			--keep target face away from grappler
			targetCont = nil
			if self.grappleTarget:IsActor() then
				local target = ToActor(self.grappleTarget)
				targetCont = target:GetController()
				targetCont:SetState(Controller.MOVE_LEFT, false)
				targetCont:SetState(Controller.MOVE_RIGHT, false)

				if self:GetAimAngle(true) <= math.pi / 2 then
					if target:GetAimAngle(true) > math.pi / 2 then
						targetCont:SetState(Controller.MOVE_RIGHT, true)
					end
					self.grappleTarget.RotAngle = self:GetAimAngle(false)
				elseif self:GetAimAngle(true) > math.pi / 2 then
					if target:GetAimAngle(true) <= math.pi / 2 then
						targetCont:SetState(Controller.MOVE_LEFT, true)
					end
					self.grappleTarget.RotAngle = -self:GetAimAngle(false)
				end
			else
				--keep target faced away from grappler
				if self.HFlipped then
					if self.grappleTarget.HFlipped ~= nil then
						self.grappleTarget.HFlipped = true
					end
					self.grappleTarget.RotAngle = -self:GetAimAngle(false)
				else
					if self.grappleTarget.HFlipped ~= nil then
						self.grappleTarget.HFlipped = false
					end
					self.grappleTarget.RotAngle = self:GetAimAngle(false)
				end
			end

			--simulate effects of extra weight on grappler
			local weightVect = Vector(0, 0)
			weightVect.Y = self.grappleTarget.Mass * (self.gravAcc / velFactor)
			self:AddAbsForce(weightVect, self.Pos + holdOffset)
		end

		if self.phase ~= 0 then
			ownCont:SetState(Controller.WEAPON_FIRE, false)
			ownCont:SetState(Controller.MOVE_LEFT, false)
			ownCont:SetState(Controller.MOVE_RIGHT, false)
		end
	else
		if MovableMan:ValidMO(self.punch) then
			self.punch.Lifetime = 1
		end
		if MovableMan:ValidMO(self.icon) then
			self.icon.Lifetime = 1
		end
		if MovableMan:ValidMO(self.chargeMeter) then
			self.chargeMeter.Lifetime = 1
		end
		if MovableMan:ValidMO(self.cooldownMeter) then
			self.cooldownMeter.Lifetime = 1
		end

		local noPack = true
		local object = nil
		for i = 0, MovableMan:GetMOIDCount() do
			if MovableMan:GetRootMOID(i) == self.ID then
				object = MovableMan:GetMOFromID(i)
				if
					(
						object.PresetName == "D38GatlingGun Pack"
						or object.PresetName == "D107RevolverLaser Pack"
						or object.PresetName == "D52GrenadeMachineGun Pack"
					) and object.Scale == 1
				then
					noPack = false
					break
				end
			end
		end
		if not noPack then
			local pack = nil
			if object.PresetName == "D38GatlingGun Pack" then
				pack = CreateHeldDevice("D38 Gatling Gun Ammo Supply")
			elseif object.PresetName == "D107RevolverLaser Pack" then
				pack = CreateHeldDevice("D107 Revolver Laser Ammo Supply")
			elseif object.PresetName == "D52GrenadeMachineGun Pack" then
				pack = CreateHeldDevice("D52 Grenade Machine Gun Ammo Supply")
			end

			if pack ~= nil then
				pack.Pos = object.Pos
				pack.Vel.X = self.dropPackVel
				if not self.HFlipped then
					pack.Vel.X = pack.Vel.X * -1
				end
				pack.Vel.Y = 0
				MovableMan:AddItem(pack)

				pack:SetWhichMOToNotHit(self, 1000)
				self:SetWhichMOToNotHit(pack, 1000)

				object.Scale = 0
				self.packTimer:Reset()
			end
		end
	end
end

function UpdateAI(self)
	self.AI:Update(self)
end

function Destroy(self)
	if MovableMan:ValidMO(self.punch) then
		self.punch.Lifetime = 1
	end
	if MovableMan:ValidMO(self.icon) then
		self.icon.Lifetime = 1
	end
	if MovableMan:ValidMO(self.chargeMeter) then
		self.chargeMeter.Lifetime = 1
	end
	if MovableMan:ValidMO(self.cooldownMeter) then
		self.cooldownMeter.Lifetime = 1
	end

	local noPack = true
	local object = nil
	for i = 0, MovableMan:GetMOIDCount() do
		if MovableMan:GetRootMOID(i) == self.ID then
			object = MovableMan:GetMOFromID(i)
			if
				(
					object.PresetName == "D38GatlingGun Pack"
					or object.PresetName == "D107RevolverLaser Pack"
					or object.PresetName == "D52GrenadeMachineGun Pack"
				) and object.Scale == 1
			then
				noPack = false
				break
			end
		end
	end
	if not noPack then
		local pack = nil
		if object.PresetName == "D38GatlingGun Pack" then
			pack = CreateHeldDevice("D38 Gatling Gun Ammo Supply")
		elseif object.PresetName == "D107RevolverLaser Pack" then
			pack = CreateHeldDevice("D107 Revolver Laser Ammo Supply")
		elseif object.PresetName == "D52GrenadeMachineGun Pack" then
			pack = CreateHeldDevice("D52 Grenade Machine Gun Ammo Supply")
		end

		if pack ~= nil then
			pack.Pos = object.Pos
			pack.Vel.X = self.dropPackVel
			if not self.HFlipped then
				pack.Vel.X = pack.Vel.X * -1
			end
			pack.Vel.Y = 0
			MovableMan:AddItem(pack)

			pack:SetWhichMOToNotHit(self, 1000)
			self:SetWhichMOToNotHit(pack, 1000)

			object.Scale = 0
			self.packTimer:Reset()
		end
	end
end
