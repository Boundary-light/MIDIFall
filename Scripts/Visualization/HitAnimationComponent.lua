class "HitAnimationComponent" {
	extends "DisplayComponent",
	
	-- Override
	new = function (self, x,y, width,height)
		self:super(x,y, width,height)
		
		self.useRainbowcolor = false
		self.rainbowcolorHueShift = 0.5
		self.rainbowcolorSaturation = 0.8
		self.rainbowcolorValue = 0.8
		
		self.fadingOutSpeed = 1.0
		self.lengthScale = 1.0
		self.sizeScale = 1.0
		
		self.useDefaultTheme = true
		self.sprite = Sprite(
			love.graphics.newImage("Assets/Arrow left icon 4.png")
		)
	end,
	
	-- Implement
	update = function (self, dt)
	end,
	
	-- Implement
	draw = function (self, screenWidth,screenHeight, lowestKey, highestKey, keyGap)
		love.graphics.push()
		
		--//////// Common Infomation ////////
		local song = player:getSong()
		
		local sortedTracks = song:getSortedTracks()
		local time = player:getTimeManager():getTime()
		
		local timeDivision = song:getTimeDivision()
		local tempo = player:getTimeManager():getTempo()
		
		if self.orientation == 1 or self.orientation == 3 then
			if self.orientation == 1 then
				love.graphics.translate(0,self.height*screenHeight)
				love.graphics.scale(1,-1)
			end
			love.graphics.translate(screenWidth, 0)
			love.graphics.rotate(math.pi/2)
			
			screenWidth, screenHeight = screenHeight, screenWidth
			
		elseif self.orientation == 2 then
			love.graphics.translate(screenWidth, 0)
			love.graphics.scale(-1,1)
		end
		
		local spaceForEachKey = (self.height*screenHeight) / (highestKey-lowestKey+1)
		local keyHeightRatio = 1 - keyGap
		local absoluteKeyGap = keyGap*spaceForEachKey
		
		local leftBoundary = math.floor(self.x * screenWidth)
		local rightBoundary = leftBoundary + math.floor(self.width * screenWidth)
		
		local firstNonPlayedNoteIDInTracks = player:getFirstNonPlayedNoteIDInTracks()
		
		--//////// Main Section ////////
		love.graphics.translate(0, absoluteKeyGap/2)
		
		love.graphics.setScissor(leftBoundary, 0, rightBoundary-leftBoundary, screenHeight)
		
		for i, track in ipairs(sortedTracks) do
			local trackID = track:getID()
			
			if track:getEnabled() then
				local notes = track:getNotes()
				
				for noteID = firstNonPlayedNoteIDInTracks[trackID]-1, 1, -1 do
					
					local note = notes[noteID]
					local noteTime = note:getTime()
					local noteLength = note:getLength() or 0
					local notePitch = note:getPitch()
					
					if notePitch >= lowestKey and notePitch <= highestKey then
						local noteY = (highestKey-notePitch) * spaceForEachKey
						local noteHeight = math.max(((self.height*screenHeight) / (highestKey-lowestKey+1))*keyHeightRatio, 0)
						
						local h,s,v,a
						if self.useRainbowcolor then
							h,s,v = ((notePitch-lowestKey) / highestKey + self.rainbowcolorHueShift) % 1, self.rainbowcolorSaturation, self.rainbowcolorValue
						else
							h,s,v = unpack(track:getCustomcolorHSV())
						end
						
						local displacement = self.fadingOutSpeed * tempo * (time - noteTime) / timeDivision / 2
						
						local t = math.max(displacement, 0)
						local size
						a = 1 - math.clamp(displacement / 100, 0, 1)
						
						if a <= 0 then
							break
						end
						
						love.graphics.setColor(vivid.HSVtoRGB(h,s,v,a))
						
						love.graphics.push()
							love.graphics.translate(rightBoundary,noteY)
							love.graphics.translate(2*self.lengthScale*spaceForEachKey,0)
							
							if self.useDefaultTheme then
								size = spaceForEachKey*t/50
								size = size * self.sizeScale
								love.graphics.rectangle("fill", -size/2 -t*4 * self.lengthScale*spaceForEachKey/16, -size/2 + spaceForEachKey/2, size, size)
								
								love.graphics.push()
									size = spaceForEachKey*t/40
									size = size * self.sizeScale
									love.graphics.rectangle("fill", -size/2 -t*3 * self.lengthScale*spaceForEachKey/16, -size/2 + spaceForEachKey/2-(t^2)/200, size, size)
								love.graphics.pop()
								
								size = spaceForEachKey*t/30
								size = size * self.sizeScale
								love.graphics.rectangle("fill", -size/2 -t*2 * self.lengthScale*spaceForEachKey/16, -size/2 + spaceForEachKey/2+(t^2)/200, size, size, 0.2)
								
							else
								size = spaceForEachKey*t/50
								size = size * self.sizeScale
								self.sprite:draw(-size/2 -t*4 * self.lengthScale*spaceForEachKey/16, -size/2 + spaceForEachKey/2, size, size)
								
								love.graphics.push()
									size = spaceForEachKey*t/40
									size = size * self.sizeScale
									self.sprite:draw(-size/2 -t*3 * self.lengthScale*spaceForEachKey/16, -size/2 + spaceForEachKey/2-(t^2)/200, size, size)
								love.graphics.pop()
								
								size = spaceForEachKey*t/30
								size = size * self.sizeScale
								self.sprite:draw(-size/2 -t*2 * self.lengthScale*spaceForEachKey/16, -size/2 + spaceForEachKey/2+(t^2)/200, size, size, 0.2)
							end
						love.graphics.pop()
					end
				end
			end
		end
		
		love.graphics.setScissor()
		
		love.graphics.pop()
	end,
}