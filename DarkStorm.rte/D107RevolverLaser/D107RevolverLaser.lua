function Create(self)
	self.userRange = 20

	local checkVect = Vector(0, 0)
	checkVect.X = math.cos(self.RotAngle) * self.userRange * -1
	checkVect.Y = math.sin(self.RotAngle) * self.userRange
	local userID = SceneMan:CastMORay(self.Pos, checkVect, self.ID, -2, -1, false, 0)
	local baseUserID = -1
	if userID ~= 255 then
		local baseUserID = MovableMan:GetRootMOID(userID)
		local user = MovableMan:GetMOFromID(baseUserID)
		if user:IsActor() then
			local userCont = ToActor(user):GetController()
			if
				user.PresetName ~= "D4 Oni Bushi"
				and user.PresetName ~= "D4-E Oni Bushi"
				and user.PresetName ~= "D4-F Oni Bushi"
				and user.PresetName ~= "D4-C Oni Bushi"
			then
				userCont:SetState(Controller.WEAPON_FIRE, false)
			else
				local canFire = false
				for i = 0, MovableMan:GetMOIDCount() do
					if MovableMan:GetRootMOID(i) == user.ID then
						local object = MovableMan:GetMOFromID(i)
						if object.PresetName == "D107RevolverLaser Pack" and object.Scale == 1 then
							canFire = true
							break
						end
					end
				end
				if not canFire then
					userCont:SetState(Controller.WEAPON_FIRE, false)
				end
			end
		end
	end

	self.Lifetime = 1
end
