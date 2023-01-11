function Create(self)
	self.checkOffset = Vector(0, -100)
end

function Update(self)
	local targetID = SceneMan:CastMORay(self.Pos, self.checkOffset, self.ID, -2, 0, true, 0)
	if
		targetID ~= 255
		and MovableMan:GetMOFromID(targetID).PresetName ~= "D64ClusterMine Mine"
		and MovableMan:GetMOFromID(MovableMan:GetRootMOID(targetID)):IsActor()
	then
		self:GibThis()
	end

	self.ToSettle = false
	self.Age = 0
end

function Destroy(self)
	local explosion = CreateAEmitter("D64ClusterMine Mine Explosion Emitter")
	explosion.Pos = self.Pos
	MovableMan:AddParticle(explosion)
end
