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

Energy_start = 0
Energy_max = 0
Strength = 0

S_Waiting="sWaiting"
S_Calling="sCalling"
S_Resting="sResting"
S_Moving="moving"
Active_State=S_Moving

targetColor = {0,0,0}

countDown=0

serialize = require "lib_serialize"

-- Environment variables:

--The event function module:
func = {}

function func.execute(name, index, ...)
	return func[name]["f"..index](...)
end

func.soundIntensity = {}
function func.soundIntensity.f2(...)

	local setPosX
	local setPosY
	local power

	setPosX, setPosY, power,time = ...
	local x = 0
	local y = 0

	if setPosX and setPosY then
		x = setPosX-posX
		y = setPosY-posY
	end

	if not power then power = 50 end
	if not time then time = 0 end

	--l_debug("X:"..x.." Y:"..y.." power:"..power)
	
	
	local A = math.pi*4*math.square(posX, posY, setPosX, setPosY)
	return power/A
end

--The event processing function, needed for postprocessing:
function processFunction(fromX, fromY, toX, toY,time, callTable)

	posX = fromX
	posY = fromY

	--load("ctable="..callTable)()
	--handle the relevant function:
	--if ctable.f_name == "soundIntensity" then
	--	if ctable.index == 2 then
	return func.execute("soundIntensity", 2,toX, toY, 50, time), 1
	--	end
	--end
end

-- Init of the lua frog, function called upon initilization of the LUA auton:
function initAuton(x, y, id, macroFactor, timeResolution)

	posX = x
	posY = y
	ID = id
	macroF = macroFactor

	timeRes = timeResolution

	countDown = l_getMersenneInteger(10,20)
	--get the environment size
	env_width, env_height = l_getEnvironmentSize()
	
	l_debug("Agent #: " .. id .. " has been initialized")
	shorestring = l_getSharedString("shoreColor")
	l_debug("Shared string is "..shorestring)

	shoreColor = serialize.loadTable(l_getSharedString("shoreColor"))

	convergence = l_getRandomFloat(1.2,3.5)


end

-- Event Handling:
function handleEvent(origX, origY, origID, origDesc, origTable)
	
	return 0,0,0,"null"
end	

--Determine whether or not this Auton will initiate an event.
function initiateEvent()

	countDown = countDown - (1/(macroF * timeRes))

	if countDown <= 0 then

		if Active_State == S_Moving then

			if scan(shoreColor,2) then
				Active_State == S_Waiting
			else 
				move(3, convergence)
			end
				
		elseif Active_State == S_Waiting then
			
			countDown = 3
			Active_State = S_Calling
			return 343, "", "call", 0

		elseif Active_State == S_Calling then
			
			countDown = 20
			Active_State = S_Resting
			

		elseif Active_State == S_Resting then
			
			countdown = 10--l_getMersenneInteger(30,60)
			Active_State = S_Waiting

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

function move(speed, convergence)

	local distance = macroF * timeRes * speed

	--move towards the center of the map:
	if posX < env_width/convergence then
		posX = posX + distance
	else
		posX = posX - distance
	end

	if posY < env_height/convergence then
		posY = posY + distance
	else
		posY = posY - distance
	end
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
