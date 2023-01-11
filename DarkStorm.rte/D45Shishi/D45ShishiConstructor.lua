function Create(self)
	self.oldVel = self.Vel;
	self.isActive = false;
	self.velTimer = Timer();
	self.velTime = 2000;
	
	self.depth = 12;
	self.buildPos = Vector(0,0);
	self.phase = 0;
	self.animTimer = Timer();
	self.animTime = 469;
	
	self.constTop = nil;
	self.topOffset = Vector(0,-8);
	self.topEndOffset = Vector(0,-40);
	self.buildNoise = nil;
	self.shihi = nil;
	self.shishiOffset = Vector(0, -24);
	
	self.segments = {};
	self.segCount = 0;
	self.segSeparation = 4;
end

function Update(self)
	ownCont = self:GetController();
	ownCont:SetState(Controller.MOVE_RIGHT, true);
	self:SetControllerMode(Controller.CIM_DISABLED, -1);
	
	if self.isActive then
		if self.phase == 0 then
			self.PinStrength = 99999;
			self.RotAngle = 0;
			local altitude = self:GetAltitude(0, 0);
			self.Pos.Y = self.Pos.Y + altitude + self.depth;
			self.buildPos = self.Pos;
			self.phase = 1;
			self:EraseFromTerrain();
			self.animTimer:Reset();
			
			self.constTop = CreateACrab("D45Shishi Constructor Top");
			self.constTop.Pos = self.Pos + self.topOffset;
			self.constTop.Team = self.Team;
			MovableMan:AddParticle(self.constTop);
			
			self.buildNoise = CreateAEmitter("D45Shishi Constructor Hum Emitter");
			self.buildNoise.Pos = self.Pos + self.topOffset;
			MovableMan:AddParticle(self.buildNoise);
		end
		self.Pos = self.buildPos;
		
		if self.phase == 1 and self.animTimer:IsPastSimMS(self.animTime) then
			if self.topOffset.Y <= self.topEndOffset.Y then
				local shishi = CreateACrab("D45Shishi");
				shishi.Team = self.Team;
				shishi.Pos = self.Pos + self.shishiOffset;
				MovableMan:AddActor(shishi);
				shishi:FlashWhite(1000);
				shishi:EraseFromTerrain();
				
				local alert = CreateAEmitter("D45Shishi Constructor Alert Emitter");
				alert.Pos = self.Pos + self.shishiOffset;
				MovableMan:AddParticle(alert);
				
				self.phase = 2;
				
				self:GibThis();
			else
				local currSegs = 0;
				for key,segment in pairs(self.segments) do
					if MovableMan:ValidMO(segment) then
						currSegs = currSegs + 1;
					end
				end
				if MovableMan:ValidMO(self.constTop) and currSegs == self.segCount then
					self.topOffset.Y = self.topOffset.Y - 1;
					self.constTop.Pos = self.Pos + self.topOffset;
					self.animTimer:Reset();
					self.constTop:EraseFromTerrain();
					
					if MovableMan:ValidMO(self.buildNoise) then
						self.buildNoise.Pos = self.Pos + self.topOffset;
					end
					
					if (self.topEndOffset.Y - self.topOffset.Y)%self.segSeparation == 0 then
						self.segments[self.segCount] = CreateACrab("D45Shishi Constructor Segment");
						self.segments[self.segCount].Pos = self.constTop.Pos;
						self.segments[self.segCount].Team = self.Team;
						MovableMan:AddParticle(self.segments[self.segCount]);
						self.segCount = self.segCount + 1;
					end
				else
					local death = CreateAEmitter("D45Shishi Constructor Death Sound Emitter");
					death.Pos = self.Pos;
					MovableMan:AddParticle(death);
				
					ActivityMan:GetActivity():ReportDeath(self.Team, 1);
					self:GibThis();
				end
			end
		end
		
		if self.phase ~= 2 then
			self:NotResting();
			self.Age = 0;
			self.ToSettle = false;
			self.ToDestroy = false;
			
			if MovableMan:ValidMO(self.constTop) then
				self.constTop:NotResting();
				self.constTop.Age = 0;
				self.constTop.ToSettle = false;
				self.constTop.ToDestroy = false;
			end
			
			for key,segment in pairs(self.segments) do
				if MovableMan:ValidMO(segment) then
					segment:NotResting();
					segment.Age = 0;
					segment.ToSettle = false;
					segment.ToDestroy = false;
				end
			end
			
			if MovableMan:ValidMO(self.buildNoise) then
				self.buildNoise:NotResting();
				self.buildNoise.Age = 0;
				self.buildNoise.ToSettle = false;
				self.buildNoise.ToDestroy = false;
			end
		end
	else
		self:NotResting();
		self.Age = 0;
		self.ToSettle = false;
		self.ToDestroy = false;
		
		if self.Vel.X ~= self.oldVel.X or self.Vel.Y ~= self.oldVel.Y then
			self.velTimer = Timer();
		end
		self.oldVel = self.Vel;
		
		if self.velTimer:IsPastSimMS(self.velTime) then
			self.isActive = true;
		end
	end
end

function Destroy(self)
	if not(ActivityMan:GetActivity():ActivityOver()) then
		if MovableMan:ValidMO(self.hum) then
			self.buildNoise.Lifetime = 1;
		end
		if MovableMan:ValidMO(self.constTop) then
			self.constTop:GibThis();
		end
		for keys,segment in pairs(self.segments) do
			if MovableMan:ValidMO(segment) then
				segment:GibThis();
			end
		end
		if MovableMan:ValidMO(self.buildNoise) then
			self.buildNoise.Lifetime = 1;
		end
	end
end