----begin_license--
--
--Copyright 	2013 	Søren Vissing Jørgensen.
--			2014	Søren Vissing Jørgensen, Center for Bio-Robotics, SDU, MMMI.  
--
--This file is part of RANA.
--
--RANA is free software: you can redistribute it and/or modify
--it under the terms of the GNU General Public License as published by
--the Free Software Foundation, either version 3 of the License, or
--(at your option) any later version.
--
--RANA is distributed in the hope that it will be useful,
--but WITHOUT ANY WARRANTY; without even the implied warranty of
--MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--GNU General Public License for more details.
--
--You should have received a copy of the GNU General Public License
--along with RANA.  If not, see <http://www.gnu.org/licenses/>.
--
----end_license--


posX = 0
posY = 0
ID = 0
macroF = 0
timeRes = 0

frequency = 0 -- amount of blinks pr. second.
blink_duration = 0.10 --amount of seconds a blik takes

S_Active = ""
S_Blinking  ="sBlinking"
S_Adjusting ="sAdjusting"
S_FindNeighbour ="sFindNeighbour"
S_Stop = "sStop"

blinkColor1 = {255,255,0}
blinkColor2 = {200,200,0}
radius = 0

countDown = 0.001
median	= 0


serialize = require "lib_table"
draw = require "lib_draw" 

-- Init of the lua frog, function calwled upon initilization of the LUA auton:
function initAuton(x, y, id, macroFactor, timeResolution)

	--get the environment size
	env_width, env_height = l_getEnvironmentSize()
	
	
	--posX = (env_width/12) * (id%12)
	--l_debug("test"..id%12)
	--l_debug("width"..posX.." : "..env_width/12)
	--iposY = env_height / (math.floor(id/10)+1)
	posY = y
	posX = x

	ID = id

	macroF = macroFactor
	timeRes = timeResolution

	countDown = l_getRandomFloat(0.1,1)
	blink_duration = l_getRandomFloat(0.05,0.1)
	
	radius = l_getMersenneInteger(4,5)

	S_Active = S_Stop
	
	--l_debug("Agent #: " .. id .. " has been initialized")
	--shorestring = l_getSharedString("shoreColor")
	--l_debug("Shared string is "..shorestring)

	--shoreColor = serialize.deserialize(l_getSharedString("shoreColor"))

	--convergence = l_getRandomFloat(1.2,3.5)


end

-- Event Handling:
function handleEvent(origX, origY, origID, origDesc, origTable)
	
	if origDesc == "blink_duration" then
		
		local ltable = serialize.deserialize(origTable)

		if ltable.blink_duration > blink_duration then
			median = median + 1
		elseif ltable.blink_duration < blink_duration then
			median = median - 1
		end

		if origID ==1 and S_Active == S_Blinking and countDown > 0.001 then

			countDown = countDown - 1

		end

	end
	
	return 0,0,0,"null"
end	

--Determine whether or not this Auton will initiate an event.
function initiateEvent()

	countDown = countDown - (macroF * timeRes)
		
	if countDown <= 0 then

		if S_Active == S_Blinking then

			draw.setColors(blinkColor1,blinkColor2)
			draw.circle(posX,posY,radius, true)
			
			countDown = blink_duration

			S_Active = S_Stop

		elseif S_Active == S_Stop then

			--remove the blink:
			draw.setColors({0,0,0}, {0,0,0})
			draw.circle(posX, posY, radius, true)

			S_Active = S_Adjusting

			local table  = "{blink_duration="..blink_duration .."}"
					
			return 0, table, "blink_duration", 0

		elseif S_Active == S_Adjusting then

			if median > 1 then 
				blink_duration = blink_duration + l_getRandomFloat(0.001,0.002)
			elseif median < 1 then
				blink_duration = blink_duration - l_getRandomFloat(0.001,0.002)
			end

			median = 0

			countDown = blink_duration + 0.05
			S_Active = S_Blinking
		end		

	end
		
	
	return 0,0,0,"null"
end


function getSyncData()
	return posX, posY
end

function simDone()
	l_debug("Agent #: " .. ID .. " is done\n")
end

function scan(color, radius)

	for i = -radius, radius,1 do
		for j = -radius, radius,1 do

			local red, green, blue = l_checkMap(posX+i,posY+j)
			local color = {red,green,blue}

			--l_debug(color[1]..":"..color[2]..":"..color[3])
			--l_debug(shoreColor[1]..":"..shoreColor[2]..":"..shoreColor[3])
	
			if(compareColors(color ,shoreColor)== false) then
				return false
			end

		end

	end

	return true

end

function compareColors(color1, color2)
	
	return (color1[1]==color2[1]) 
	and (color1[2]==color2[2]) 
	and (color1[3]==color2[3])
		

end
