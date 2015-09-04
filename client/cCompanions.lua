class "cCompanions"

function cCompanions:__init()
	self:initVars()
	Events:Subscribe("PostTick", self, self.onPostTick)
	Events:Subscribe("ModuleUnload", self, self.onModuleUnload)
end

function cCompanions:initVars()
	self.actors = {}
	self.bikes = {[21] = true, [43] = true, [61] = true, [74] = true, [89] = true, [90] = true}
	self.models = {31, 60, 65}
end

-- Events
function cCompanions:onPostTick()
	local checked = {}
	for vehicle in Client:GetVehicles() do
		if IsValid(vehicle) and self.bikes[vehicle:GetModelId()] then
			local vehicleId = vehicle:GetId() + 1
			local actor = self.actors[vehicleId]
			if IsValid(actor, false) then
				if IsValid(actor, true) then
					if vehicle:GetDriver() then
						actor:SetPosition(vehicle:GetPosition() + vehicle:GetAngle() * Vector3(0, 0.95, 0.7 - vehicle:GetLinearVelocity():Length() / 30))
						actor:SetAngle(vehicle:GetAngle())
						actor:SetBaseState(AnimationState.SRidingMc)
					else
						actor:SetPosition(vehicle:GetPosition() + Vector3(0.6, 0, 0.2))
						actor:SetAngle(Angle((vehicleId % 10) * 0.314, 0, 0))
						actor:SetBaseState(AnimationState.SUprightIdle)
					end
					actor:DisableAutoAim()
				else
					actor:Remove()
					self.actors[vehicleId] = nil
				end
			else
				self.actors[vehicleId] = ClientActor.Create(AssetLocation.Game,
				{
					model_id = self.models[(vehicleId % #self.models) + 1],
					position = vehicle:GetPosition(),
					angle = vehicle:GetAngle()
				})
			end
			checked[vehicleId] = true
		end
	end
	for vehicleId, actor in pairs(self.actors) do
		if not checked[vehicleId] then
			if IsValid(actor, false) then actor:Remove() end
			self.actors[vehicleId] = nil
		end
	end
end

function cCompanions:onModuleUnload()
	for _, actor in pairs(self.actors) do
		if IsValid(actor, false) then actor:Remove() end
	end
end

cCompanions = cCompanions()
