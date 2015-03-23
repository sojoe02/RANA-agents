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

local ID

-- Init of the lua frog, function called upon initilization of the LUA auton:
function initAuton(x, y, id, macroFactor, timeResolution)

	posX = 0
	posY = 0

	ID = id

	l_debug(macroFactor.." : "..timeResolution)
	

	path, filename = l_getAgentPath()
	env_width, env_height = l_getEnvironmentSize()

	--build the environment(using the environment library):
	local env = require "lib_env_lake"
	local table = require "lib_table"

	env.buildEnvironment()
	local waterColor, shoreColor, landColor = env.getColors()

	l_addSharedString("shoreColor", table.serialize(shoreColor))

	local frog_filename = "01-frog.lua"
	local amount = 50
	
	l_debug("FrogController with ID: " .. id .. " will generate ".. amount.." frogs")
	
	for i=1, amount do
		--take a gamble on where the agents will start from:
		local direction = l_getMersenneInteger(1,4)
		local aPosX = 0
		local aPosY = 0

		if direction == 1 then
			aPosX = env_width
			aPosY = l_getRandomInteger(1,env_height)

		elseif direction == 2 then
			aPosY = l_getRandomInteger(1,env_height)

		elseif direction == 3 then
			aPosX = l_getRandomInteger(1,env_width)

		elseif direction == 4 then
			aPosY = env_height
			aPosX = l_getRandomInteger(1,env_width)
		end

		l_addAgent(aPosX, aPosY, 0, path, frog_filename)
	end

end

-- Event Handling:
function handleEvent(origX, origY, origID, origDesc, origTable)

	l_removeAgent(ID)

	return 0,0,0,"null"
end	

--Determine whether or not this Auton will initiate an event.
function initiateEvent()
	return 0,0,0,"null"
end


function getSyncData()
	return posX, posY
end

function simDone()
	--l_debug("Agent #: " .. ID .. " is done\n")
end

