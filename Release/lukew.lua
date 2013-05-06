--lukew.lua
-- Bot names should be 'BOT_NAME_PREFIX%d' where %d in <1, N>

BOT_NAME_PREFIX = 'lukew'
START_HEALTH = 0
SAFE_LEN = 128
weaponsShort = { Enumerations.Shotgun, Enumerations.RocketLuncher, Enumerations.Railgun, Enumerations.Chaingun }
weaponsLong = { Enumerations.Railgun, Enumerations.RocketLuncher, Enumerations.Shotgun, Enumerations.Chaingun }

function showVector(vector)
    io.write(string.format('(%3d, %3d, %3d, %3d)\n', vector:value(0), vector:value(1), vector:value(2), vector:value(3)))
end

function getBotNumber(actorKnowledge)
	number = string.gsub(actorKnowledge:getName(), BOT_NAME_PREFIX, '')
	return tonumber(number)
end

function randVector(min, max)
	return Vector4d(math.random(min, max), math.random(min, max), 0, 0)
end

function vectorEqual(vec1, vec2)
	if vec1:value(0) ~= vec2:value(0)
		or vec1:value(1) ~= vec2:value(1) then
--		or vec1:value(2) ~= vec2:value(2)
--		or vec1:value(3) ~= vec2:value(3) then
		return false
	end
	return true
end

function getClosestActiveTrigger(nav, position)
	closest = -1
	if nav:getNumberOfTriggers() > 0 then
		for current=0, nav:getNumberOfTriggers() - 1 do
			trig = nav:getTrigger(current)
			if trig:isActive() then
				distance = trig:getPosition() - position
				length = distance:length()
				if closest ~= -1 then
					if length < closestLength then
						closest = current
						closestLength = length
					end
				else
					closest = current
					closestLength = length
				end
			end
		end
	end
	if closestLength < SAFE_LEN then
		return closest
	else
		return -1
	end
end

function getPerpendicularVector(vector)
	return Vector4d(-vector:value(1), vector:value(0), 0, 0)
end

function circlePos(enemyPos, r, a)
	x = enemyPos:value(0) + r * math.cos(math.rad(a))
	y = enemyPos:value(1) + r * math.sin(math.rad(a))
	return Vector4d(x, y, 0, 0)
end

function nextAngle()
	return math.random(-180, 180)
end

function randomSign()
	x = math.random(0, 1)
	if x > 0.5 then
		return 1
	else
		return -1
	end
end

function chooseWeapon(agent, actorKnowledge, weapons)
	for k,weapon in pairs(weapons) do
		if (actorKnowledge:getWeaponType() == weapon and actorKnowledge:getAmmo(weapon) ~= 0) then
			break
		end
		if (actorKnowledge:getWeaponType() ~= weapon and actorKnowledge:getAmmo(weapon) ~= 0) then
			agent:selectWeapon(weapon);
			break
		end
	end
end

function lukewwhatTo(agent, actorKnowledge, time)
	botNumber = getBotNumber(actorKnowledge)
	position = actorKnowledge:getPosition()
	nav = actorKnowledge:getNavigation()



	io.write(string.format('%d:\n', botNumber))
--	io.write('Position: ')
--	showVector(position)
--	io.write(string.format("weapon = %d\n", actorKnowledge:getWeaponType()))
--	io.write(string.format('ammo = %d\n', actorKnowledge:getAmmo(actorKnowledge:getWeaponType())))
--	for i=0,3 do
--		io.write(string.format("%d -> %d\n", i, actorKnowledge:getAmmo(i)))
--	end
end

function lukewonStart(agent, actorKnowledge, time)
	botNumber = getBotNumber(actorKnowledge)
	position = actorKnowledge:getPosition()
	START_HEALTH = actorKnowledge:getHealth()
	chooseWeapon(agent, actorKnowledge, weaponsShort)
	io.write(string.format('%d (start):\n', botNumber))
end
