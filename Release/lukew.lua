--lukew.lua

function lukewwhatTo(agent, actorKnowledge, time)
	io.write(actorKnowledge:getName() .. ': ')
	position = actorKnowledge:getPosition()
	showVector(position)
	io.write('\n')
end

function lukewonStart(agent, actorKnowledge, time)
	io.write(actorKnowledge:getName() .. ' (start): ')

	io.write('\n')
end

function showVector(vector)
    io.write(string.format('(%3d, %3d, %3d, %3d)', vector:value(0), vector:value(1), vector:value(2), vector:value(3)))
end;