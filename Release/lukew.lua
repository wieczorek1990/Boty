--lukew.lua
-- Bot names should be 'NAMEPREFIX%d' where %d in <1, N>

Modes = { alone=0, rendezvous=1, group=2 }

TEAMSIZE = 3
BUFFERSIZE = 2
NAMEPREFIX = 'lukew'

initialized = false
alive = {}
friendPositions = {}
enemyPositions = {}
botModes = {}

-- Prints vector nicely
function showVector(vector)
    io.write(string.format('(%3d, %3d, %3d, %3d)\n', vector:value(0), vector:value(1), vector:value(2), vector:value(3)))
end

-- Checks if vectors are equal
function notEqualVector(vector1, vector2)
	if vector1:value(0) ~= vector2:value(0) or
		vector1:value(1) ~= vector2:value(1) or
		vector1:value(2) ~= vector2:value(2) or
		vector1:value(3) ~= vector2:value(3) then
		return true
	end
	return false
end

-- Returns bot number from actorKnowledge
function getBotNumber(actorKnowledge)
	number = string.gsub(actorKnowledge:getName(), NAMEPREFIX, '')
	return tonumber(number)
end

-- Returns current leader bot number
function getLeaderNumber(actorKnowledge, time, botNumber)
	for i=1,TEAMSIZE do
		if alive[i] then
			return i
		end
	end
end

function lukewwhatTo(agent, actorKnowledge, time)
	local botNumber = getBotNumber(actorKnowledge)
	local position = actorKnowledge:getPosition()
	local leaderNumber = getLeaderNumber(actorKnowledge, time, botNumber)
	local self = actorKnowledge:getSelf()
	alive[botNumber] = notEqualVector(position, friendPositions[botNumber])
	friendPositions[botNumber] = position

--	if botModes[botNumber] == Mode.alone then
--	
--	elseif botModes[botNumber] == Mode.rendezvous then
--	
--	elseif botModes[botNumber] == Mode.group then
--		
--    else
--      error("invalid mode")
--	end

	io.write(string.format('%d:\n', botNumber))
	io.write(string.format('Leader = %d\n', leaderNumber));
end

-- Initializes friendPositions, enemyPositions, botModes, leaders
function lukewonStart(agent, actorKnowledge, time)
	local botNumber = getBotNumber(actorKnowledge)

	if not initialized then
		for i=1,TEAMSIZE do
			enemyPositions[i] = {}
			for j=1,BUFFERSIZE do
				enemyPositions[i][j] = 0
			end
		end
		initialized = true
	end
	
	botModes[botNumber] = Modes.alone
	alive[botNumber] = true
	friendPositions[botNumber] = actorKnowledge:getPosition()
	io.write(string.format('%d (start):\n', botNumber))
end
