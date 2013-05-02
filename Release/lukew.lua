--lukew.lua

-- Bot names should be 'NAMEPREFIX%d' where %d in <1, N>
TEAMSIZE = 3
BUFFERSIZE = 2
NAMEPREFIX = 'lukew'
enemyPositions = {}
initialized = false

function getBotNumber(name)
	return string.gsub(name, NAMEPREFIX, '')
end

function lukewwhatTo(agent, actorKnowledge, time)
	botNumber = getBotNumber(actorKnowledge:getName())
	io.write(string.format('%d:', botNumber))
	position = actorKnowledge:getPosition()
	io.write('\n')
end

function lukewonStart(agent, actorKnowledge, time)
	botNumber = getBotNumber(actorKnowledge:getName())
	io.write(string.format('%d (start):', botNumber))
	if not initialized then
		for i=1,TEAMSIZE do
			enemyPositions[i] = {}
			for j=1,BUFFERSIZE do
				enemyPositions[i][j] = 0
			end
		end
		initialized = true
	end
	io.write('\n')
end

function showVector(vector)
    io.write(string.format('(%3d, %3d, %3d, %3d)', vector:value(0), vector:value(1), vector:value(2), vector:value(3)))
end;