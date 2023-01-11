function Create(self)
	self.disruptRange = self.Sharpness --set in .ini
	self.disruptPower = self.Mass --set in .ini

	for actor in MovableMan.Actors do
		local checkVect = SceneMan:ShortestDistance(self.Pos, actor.Pos, true)
		local strikePoint = Vector(0, 0)
		SceneMan:CastFindMORay(self.Pos, checkVect, actor.ID, strikePoint, -1, false, 0)
		local strikeVect = SceneMan:ShortestDistance(self.Pos, strikePoint, true)
		local dist = strikeVect.Magnitude
		if
			dist <= self.disruptRange
			and actor.PresetName ~= "D2-E Tengu Bushi"
			and actor.PresetName ~= "D4-E Oni Bushi"
			and actor.PresetName ~= "D45Shishi"
			and actor.PresetName ~= "D45Shishi Constructor Top"
			and actor.PresetName ~= "D45Shishi Constructor Segment"
			and actor.PresetName ~= "D45Shishi Constructor"
		then
			local disrupt = CreateMOPixel("EMP Disruption")
			disrupt.Pos = actor.Pos
			disrupt.Mass = self.disruptPower
			MovableMan:AddParticle(disrupt)
		end
	end
end
