class "KeyboardComponent" {
	extends "DisplayComponent",
	
	-- Override
	new = function (self, x,y, width,height)
		self:super(x,y, width,height)
		
		self.rainbow = true
		self.rainbowHueShift = 0.5
		
		self.blackKeyColourHSV = {0, 0, 0.2}
		self.blackKeyAlpha = 0.6
		
		self.whiteKeyColourHSV = {0, 0, 0.9}
		self.whiteKeyAlpha = 0.6
		
		self.brightKeyColourHSV = {0,1,1,0.5}
		self.brightKeyAlpha = 0.8
		
		-- TODO: adjust these values
		self.whiteHeadsUpperPartRatio = {
			[1] = 0.4,
			[3] = 0.6,
			[6] = 0.35,
			[8] = 0.5,
			[10] = 0.65
		}
		
		self.isPlayingKeys = {}
		for i = 0, 127 do
			self.isPlayingKeys[i] = false
		end
	end,
	
	-- Implement
	update = function (self, dt)
		------------------------------------------------------------------------
		-- Check which keys are being played
		local firstNonFinishedNoteIDInTracks = player:getfirstNonFinishedNoteIDInTracks()
		local song = player:getSong()
		local tracks = song:getTracks()
		local time = player:getTimeManager():getTime()
		
		for i = 0, 127 do
			self.isPlayingKeys[i] = false
		end
		
		for trackID = 1, #tracks do
			local track = tracks[trackID]
			
			if track:getEnabled() then
				local notes = tracks[trackID]:getNotes()
				for noteID = firstNonFinishedNoteIDInTracks[trackID], #notes do
					local note = notes[noteID]
					local noteTime = note:getTime()
					local noteLength = note:getLength()
					
					if noteTime > time then
						break
					else
						self.isPlayingKeys[note:getPitch()] = true
					end
				end
			end
		end
		------------------------------------------------------------------------
	end,
	
	-- Implement
	draw = function (self, lowestKey, highestKey, keyGap)
		local screenWidth = love.graphics.getWidth()
		local screenHeight = love.graphics.getHeight()
		local resolutionRatio = screenWidth / screenHeight
		local keyboardX = math.floor(screenWidth * self.x)
		local keyboardWidth = math.floor(screenWidth * self.width)
		local spaceForEachKey = screenHeight / (highestKey-lowestKey+1)
		local keyHeightRatio = 1 - keyGap
		
		for i = lowestKey, highestKey do
			local keyY = (highestKey-i) * spaceForEachKey
			local keyHeight = keyHeightRatio*spaceForEachKey
			local semitoneInOctave = i % 12
			
			if self:checkIsBlackKey(i) then
				self:setKeyColour(i, lowestKey, highestKey, true)
				love.graphics.rectangle("fill", self.x,keyY, keyboardWidth*0.65,keyHeight)
				
				self:setKeyColour(i+1, lowestKey, highestKey, false)
				love.graphics.rectangle(
					"fill",
					self.x+keyboardWidth*0.65+keyGap*spaceForEachKey,
					keyY-keyGap*spaceForEachKey,
					keyboardWidth*0.35-keyGap*spaceForEachKey,
					(keyHeight+2*keyGap*spaceForEachKey)*self.whiteHeadsUpperPartRatio[semitoneInOctave] - keyGap*spaceForEachKey/2
				)
				
				self:setKeyColour(i-1, lowestKey, highestKey, false)
				love.graphics.rectangle(
					"fill",
					self.x+keyboardWidth*0.65+keyGap*spaceForEachKey,
					keyY-keyGap*spaceForEachKey+(keyHeight+2*keyGap*spaceForEachKey)*self.whiteHeadsUpperPartRatio[semitoneInOctave] - keyGap*spaceForEachKey/2+keyGap*spaceForEachKey,
					keyboardWidth*0.35-keyGap*spaceForEachKey,
					(keyHeight+2*keyGap*spaceForEachKey)*(1-self.whiteHeadsUpperPartRatio[semitoneInOctave]) - keyGap*spaceForEachKey/2
				)
			else
				self:setKeyColour(i, lowestKey, highestKey, false)
				love.graphics.rectangle("fill", self.x,keyY, keyboardWidth,keyHeight)
			end
		end
	end,
	
	checkIsBlackKey = function (self, i)
		local semitoneInOctave = i % 12
		
		if semitoneInOctave == 1 or semitoneInOctave == 3 or semitoneInOctave == 6 or semitoneInOctave == 8 or semitoneInOctave == 10 then
			return true
		else
			return false
		end
	end,
	
	setKeyColour = function (self, i, lowestKey, highestKey, isBlackKey)
		if isBlackKey then
			if self.isPlayingKeys[i] == true then
				love.graphics.setColor(vivid.HSVtoRGB(((i-lowestKey) / highestKey + self.rainbowHueShift) % 1, self.brightKeyColourHSV[2], self.brightKeyColourHSV[3], self.brightKeyAlpha))
			else
				local r,g,b,a = self.blackKeyColourHSV[1], self.blackKeyColourHSV[2], self.blackKeyColourHSV[3], self.blackKeyAlpha
				love.graphics.setColor(vivid.HSVtoRGB(r,g,b,a))
			end
			
		else
			if self.isPlayingKeys[i] == true then
				love.graphics.setColor(vivid.HSVtoRGB(((i-lowestKey) / highestKey + self.rainbowHueShift) % 1, self.brightKeyColourHSV[2], self.brightKeyColourHSV[3], self.brightKeyAlpha))
			else
				local r,g,b,a = self.whiteKeyColourHSV[1], self.whiteKeyColourHSV[2], self.whiteKeyColourHSV[3], self.whiteKeyAlpha
				love.graphics.setColor(vivid.HSVtoRGB(r,g,b,a))
			end
		end
	end,
}