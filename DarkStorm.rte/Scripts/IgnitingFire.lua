function Create(self)
	self.particleCheckDistance = 10;
	self.maxMass = 300;
	
	self.frameZeroRadius = 3;
	self.frameOneRadius = 6;
	self.frameTwoRadius = 8;
	self.frameThreeRadius = 13;
	self.frameFourRadius = 21;
	self.frameFiveRadius = 21;
	self.frameSixRadius = 18;
	self.frameSevenRadius = 13;
	self.frameEightRadius = 11;
	self.frameNineRadius = 13;
	self.frameTenRadius = 13;
	self.frameElevenRadius = 12;
	self.frameTwelveRadius = 13;
end

function Update(self)
	local radius = 0;
	if self.Frame == 0 then
		radius = self.frameZeroRadius;
	elseif self.Frame == 1 then
		radius = self.frameOneRadius;
	elseif self.Frame == 2 then
		radius = self.frameTwoRadius;
	elseif self.Frame == 3 then
		radius = self.frameThreeRadius;
	elseif self.Frame == 4 then
		radius = self.frameFourRadius;
	elseif self.Frame == 5 then
		radius = self.frameFiveRadius;
	elseif self.Frame == 6 then
		radius = self.frameSixRadius;
	elseif self.Frame == 7 then
		radius = self.frameSevenRadius;
	elseif self.Frame == 8 then
		radius = self.frameEightRadius;
	elseif self.Frame == 9 then
		radius = self.frameNineRadius;
	elseif self.Frame == 10 then
		radius = self.frameTenRadius;
	elseif self.Frame == 11 then
		radius = self.frameElevenRadius;
	elseif self.Frame == 12 then
		radius = self.frameTwelveRadius;
	end
	
	for actor in MovableMan.Actors do
		if actor.ClassName ~= "ADoor" and actor.PresetName ~= "D2-F Tengu Bushi" and actor.PresetName ~= "D4-F Oni Bushi" and actor.PresetName ~= "D45Shishi" and actor.PresetName ~= "D45Shishi Constructor Top" and actor.PresetName ~= "D45Shishi Constructor Segment" and actor.PresetName ~= "D45Shishi Constructor" then
			local distVect = SceneMan:ShortestDistance(self.Pos, actor.Pos, true);
			local dist = distVect.Magnitude;
			local findPos = Vector(0,0);
			if SceneMan:CastFindMORay(self.Pos, distVect, actor.ID, findPos, 0, false, 5) then
				distVect = SceneMan:ShortestDistance(self.Pos, findPos, true);
				dist = distVect.Magnitude
				if dist <= radius then
					local flameFound = false;
					local burnFound = false;
					for particle in MovableMan.Particles do
						if actor.Mass <= self.maxMass and particle.PresetName == "Ignited Fire Emitter" and flameFound == false then
							distVect = SceneMan:ShortestDistance(particle.Pos, actor.Pos, true);
							dist = distVect.Magnitude
							if dist <= self.particleCheckDistance then
								flameFound = true;
							end
						elseif particle.PresetName == "Ignited Wound" and burnFound == false then
							distVect = SceneMan:ShortestDistance(particle.Pos, actor.Pos, true);
							dist = distVect.Magnitude
							if dist <= self.particleCheckDistance then
								burnFound = true;
							end
						end
						if burnFound and (flameFound or actor.Mass > self.maxMass) then
							break;
						end
					end
				
					if flameFound == false and actor.Mass <= self.maxMass then
						local flame = CreateAEmitter("Ignited Fire Emitter");
						flame.Pos = actor.Pos;
						MovableMan:AddParticle(flame);
					end	
					
					if burnFound == false then
						local burn = CreateMOPixel("Ignited Wound");
						burn.Pos = actor.Pos;
						MovableMan:AddParticle(burn);
					end
				end
			end
		end
	end
end