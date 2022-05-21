--[[
	Name: WaterEffects
	Filename: CoreClassC.lua
	Author: Sam@ke
--]]

local classInstance = nil

CoreClassC = {}

function CoreClassC:constructor()
	outputChatBox("#EEEE22Watereffects was #22EE22started#EEEE22!", 255, 255, 255, true)
	
	self.screenWidth, self.screenHeight = guiGetScreenSize()
	self.screenSource = dxCreateScreenSource(self.screenWidth, self.screenHeight)
	self.waterNormal = dxCreateTexture("res/textures/waterNormal.png")
	self.waterDrop = dxCreateTexture("res/textures/waterDrop.png")
	self.wetSurfaceShader = dxCreateShader("res/shaders/waterEffects.fx")
	
	self.player = getLocalPlayer()
	self.element = nil
	self.effectIsStarted = "false"
	self.maxWetValue = 56
	self.wetValue = 0
	self.wetType = 1

	
	if (not self.screenSource) or (not self.waterNormal) or (not self.waterDrop) or (not self.wetSurfaceShader) then
		outputChatBox("Water effects shader couldnt created. Use '/debugscript 3' for further details!")
	end
	
	self.m_Update = bind(self.update, self)
	addEventHandler("onClientPreRender", root, self.m_Update)
end

function CoreClassC:update()
	if (self.screenSource) and (self.waterNormal) and (self.waterDrop) and (self.wetSurfaceShader) and (self.player) then
		self.screenSource:update()
		
		self.vehicle = self.player:getOccupiedVehicle()
		
		if (self.vehicle) then
			self.element = self.vehicle
			
			if (self.vehicle:getVehicleType() == "Boat") then
				self:setWetLevel(self.maxWetValue * 0.5, 1)
			end
		else
			self.element = self.player
		end

		if (self.element) and (isElement(self.element)) then
			if (getRainLevel() <= 0) then
				if (self.element:isInWater() == true) then
					self.effectIsStarted = "true"
				else
					if (self.effectIsStarted == "true") then
						self:setWetLevel(self.maxWetValue * 1, 2)
						self.effectIsStarted = "false"
					end
				end
			else
				local wetValue = getRainLevel()
				self:setWetLevel(self.maxWetValue * getRainLevel(), 1)			
			end
		end
		
		self.wetSurfaceShader:setValue("screenSource", self.screenSource)
		self.wetSurfaceShader:setValue("waterNormal", self.waterNormal)
		self.wetSurfaceShader:setValue("waterDrop", self.waterDrop)
		self.wetSurfaceShader:setValue("wetValue", self.wetValue)
		self.wetSurfaceShader:setValue("wetType", self.wetType)
		
		self.wetValue = self.wetValue - 0.5
		
		if (self.wetValue < 0) then
			self.wetValue = 0
		end

		dxDrawImage(0, 0, self.screenWidth, self.screenHeight, self.wetSurfaceShader)
	end
end

function CoreClassC:setWetLevel(amount, wetType)
	if (amount) and (wetType) then
		self.wetValue = amount
		self.wetType = wetType
	end
end

function CoreClassC:destructor()
	removeEventHandler("onClientPreRender", root, self.m_Update)
	
	if (self.screenSource) then
		self.screenSource:destroy()
		self.screenSource = nil
	end
	
	if (self.waterNormal) then
		self.waterNormal:destroy()
		self.waterNormal = nil
	end
	
	if (self.waterDrop) then
		self.waterDrop:destroy()
		self.waterDrop = nil
	end

	if (self.wetSurfaceShader) then
		self.wetSurfaceShader:destroy()
		self.wetSurfaceShader = nil
	end

	outputChatBox("#EEEE22Watereffects was #EE2222stopped#EEEE22!", 255, 255, 255, true)
end


addEventHandler("onClientResourceStart", resourceRoot, 
function()
	classInstance = new(CoreClassC)
end)


addEventHandler("onClientResourceStop", resourceRoot, 
function()
	if (classInstance) then
		delete(classInstance)
		classInstance = nil
	end
end)