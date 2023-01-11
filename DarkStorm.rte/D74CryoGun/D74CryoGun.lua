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
			if user.PresetName ~= "Cryo Oni" then
				local userCont = ToActor(user):GetController()
				userCont:SetState(Controller.WEAPON_FIRE, false)
			end
		end
	end

	self.Lifetime = 1
end
