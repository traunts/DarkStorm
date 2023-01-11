function Create(self)
	self.userRange = 20
	self.fireVelocity = 22
	self.shakeRange = 13
	self.sharpShakeRange = 5
	self.muzzleOffset = 10
	self.reloadTime = 2000

	--find user
	local checkVect = Vector(0, 0)
	checkVect.X = math.cos(self.RotAngle) * self.userRange * -1
	checkVect.Y = math.sin(self.RotAngle) * self.userRange
	local userID = SceneMan:CastMORay(self.Pos, checkVect, -1, -2, -1, false, 0)
	local user = nil
	if userID ~= 255 then
		user = MovableMan:GetMOFromID(MovableMan:GetRootMOID(userID))
	end

	if MovableMan:ValidMO(user) and user:IsActor() then
		local disruption = nil
		for particle in MovableMan.Particles do
			if particle.PresetName == "EMP Disruption" then
				local distVect = SceneMan:ShortestDistance(user.Pos, particle.Pos, true)
				local dist = distVect.Magnitude
				if dist <= self.userRange then
					disruption = particle
					break
				end
			end
		end

		if not (MovableMan:ValidMO(disruption)) then
			user = ToActor(user)
			local userCont = user:GetController()
			local aimAngle = user:GetAimAngle(true)

			local reload = nil
			for particle in MovableMan.Particles do
				if particle.PresetName == "D54 Grenade Launcher Reload" then
					local distVect = SceneMan:ShortestDistance(user.Pos, particle.Pos, true)
					local dist = distVect.Magnitude
					if dist <= self.userRange then
						reload = particle
						break
					end
				end
			end

			if MovableMan:ValidMO(reload) then
				--reloading
				reload.Mass = reload.Mass + TimerMan.DeltaTimeMS

				if UInputMan:KeyPressed(secondaryFireKeyNum) then
					local empty = CreateAEmitter("D54 Grenade Launcher Empty Sound Emitter")
					empty.Pos = self.Pos
					MovableMan:AddParticle(empty)
				end

				userCont:SetState(Controller.WEAPON_FIRE, false)

				if reload.Mass > self.reloadTime then
					reload.Lifetime = 1

					local loading = CreateAEmitter("D54 Grenade Launcher Load Sound Emitter")
					loading.Pos = self.Pos
					MovableMan:AddParticle(loading)

					for i = 0, MovableMan:GetMOIDCount() do
						if MovableMan:GetRootMOID(i) == user.ID then
							local object = MovableMan:GetMOFromID(i)
							if object.PresetName == "D54 Grenade Launcher Indicator Green" then
								object.Scale = 1
							elseif
								object.PresetName == "D54 Grenade Launcher Indicator Blue"
								or object.PresetName == "D54 Grenade Launcher Indicator Red"
							then
								object.Scale = 0
							end
						end
					end
				end
			else
				--not reloading
				if userCont:IsPlayerControlled(-1) then
					--get secondary fire key
					secondaryFireKeyNum = -1
					if userCont.Player == 0 and PlayerOneDarkStormSecondaryFire ~= nil then
						secondaryFireKeyNum = PlayerOneDarkStormSecondaryFire
					elseif userCont.Player == 1 and PlayerTwoDarkStormSecondaryFire ~= nil then
						secondaryFireKeyNum = PlayerTwoDarkStormSecondaryFire
					elseif userCont.Player == 2 and PlayerThreeDarkStormSecondaryFire ~= nil then
						secondaryFireKeyNum = PlayerThreeDarkStormSecondaryFire
					elseif userCont.Player == 3 and PlayerFourDarkStormSecondaryFire ~= nil then
						secondaryFireKeyNum = PlayerFourDarkStormSecondaryFire
					end

					if UInputMan:KeyPressed(secondaryFireKeyNum) then
						--trigger pulled
						local fired = nil
						for particle in MovableMan.Particles do
							if particle.PresetName == "D54 Grenade Launcher Fired" then
								local distVect = SceneMan:ShortestDistance(user.Pos, particle.Pos, true)
								local dist = distVect.Magnitude
								if dist <= self.userRange then
									fired = particle
									break
								end
							end
						end

						if MovableMan:ValidMO(fired) then
							--already fired, do reloading
							fired.Lifetime = 1

							local shot = CreateAEmitter("D54 Grenade Launcher Unload Sound Emitter")
							shot.Pos = self.Pos
							MovableMan:AddParticle(shot)

							reload = CreateMOPixel("D54 Grenade Launcher Reload")
							reload.Pos = user.Pos
							MovableMan:AddParticle(reload)

							for i = 0, MovableMan:GetMOIDCount() do
								if MovableMan:GetRootMOID(i) == user.ID then
									local object = MovableMan:GetMOFromID(i)
									if object.PresetName == "D54 Grenade Launcher Indicator Blue" then
										object.Scale = 1
									elseif
										object.PresetName == "D54 Grenade Launcher Indicator Green"
										or object.PresetName == "D54 Grenade Launcher Indicator Red"
									then
										object.Scale = 0
									end
								end
							end
						else
							--fire a shot
							local grenade = CreateMOSRotating("40mm EMP Grenade")
							grenade.Pos.X = self.Pos.X + math.cos(aimAngle) * self.muzzleOffset
							grenade.Pos.Y = self.Pos.Y + math.sin(aimAngle) * self.muzzleOffset * -1
							grenade.Vel.X = math.cos(aimAngle) * self.fireVelocity
							grenade.Vel.Y = math.sin(aimAngle) * self.fireVelocity * -1
							grenade.RotAngle = aimAngle
							grenade:SetWhichMOToNotHit(user, 1000)
							MovableMan:AddParticle(grenade)

							local flash = CreateMOSRotating("Muzzle Flash 40mm Underslung Grenade Launcher")
							flash.Pos.X = self.Pos.X + math.cos(aimAngle) * self.muzzleOffset
							flash.Pos.Y = self.Pos.Y + math.sin(aimAngle) * self.muzzleOffset * -1
							flash.RotAngle = aimAngle
							MovableMan:AddParticle(flash)

							local shot = CreateAEmitter("D54 Grenade Launcher Shot Sound Emitter")
							shot.Pos.X = self.Pos.X + math.cos(aimAngle) * self.muzzleOffset
							shot.Pos.Y = self.Pos.Y + math.sin(aimAngle) * self.muzzleOffset * -1
							MovableMan:AddParticle(shot)

							fired = CreateMOPixel("D54 Grenade Launcher Fired")
							fired.Pos = user.Pos
							MovableMan:AddParticle(fired)

							for i = 0, MovableMan:GetMOIDCount() do
								if MovableMan:GetRootMOID(i) == user.ID then
									local object = MovableMan:GetMOFromID(i)
									if object.PresetName == "D54 Grenade Launcher Indicator Red" then
										object.Scale = 1
									elseif
										object.PresetName == "D54 Grenade Launcher Indicator Green"
										or object.PresetName == "D54 Grenade Launcher Indicator Blue"
									then
										object.Scale = 0
									end
								end
							end
						end
					end
				end
			end
		end
	end

	self.Lifetime = 1
end
