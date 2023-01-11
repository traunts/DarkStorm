function Create(self)
	self.userRange = 20
	self.fireVelocity = 32

	local checkVect = Vector(0, 0)
	checkVect.X = math.cos(self.RotAngle) * self.userRange * -1
	checkVect.Y = math.sin(self.RotAngle) * self.userRange
	local userID = SceneMan:CastMORay(self.Pos, checkVect, self.ID, -2, -1, false, 0)
	local baseUserID = -1
	if userID ~= 255 then
		local baseUserID = MovableMan:GetRootMOID(userID)
		local user = MovableMan:GetMOFromID(baseUserID)
		if user:IsActor() then
			for i = 0, MovableMan:GetMOIDCount() do
				if MovableMan:GetRootMOID(i) == user.ID then
					local object = MovableMan:GetMOFromID(i)
					local grenade = nil
					if object.PresetName == "D52GrenadeMachineGun HE Pack" and object.Scale == 1 then
						grenade = CreateMOSRotating("40mm HE Grenade")
					elseif object.PresetName == "D52GrenadeMachineGun EMP Pack" and object.Scale == 1 then
						grenade = CreateMOSRotating("40mm EMP Grenade")
					elseif object.PresetName == "D52GrenadeMachineGun Incendiary Pack" and object.Scale == 1 then
						grenade = CreateMOSRotating("40mm Incendiary Grenade")
					end

					if grenade ~= nil then
						grenade.Pos.X = self.Pos.X
						grenade.Pos.Y = self.Pos.Y
						grenade.Vel.X = math.cos(self.RotAngle) * self.fireVelocity
						grenade.Vel.Y = math.sin(self.RotAngle) * self.fireVelocity * -1
						grenade.RotAngle = self.RotAngle
						grenade:SetWhichMOToNotHit(user, 1000)
						MovableMan:AddParticle(grenade)

						break
					end
				end
			end
		end
	end

	self.Lifetime = 1
end
