--lukew.lua
-- Bot names should be 'BOT_NAME_PREFIX%d' where %d in <1, N>

BOT_NAME_PREFIX = 'lukew'
SAFE_LEN = 128
SMALL_ERROR_MARGIN_LEN = 8
BIG_ERROR_MARGIN_LEN = 64
WIDTH = 1024
HEIGHT = 768

BLOCKING_FIX_TIME = 4
START_HEALTH = 0
weaponsShort = { Enumerations.Shotgun, Enumerations.RocketLuncher, Enumerations.Railgun, Enumerations.Chaingun }
weaponsLong = { Enumerations.Railgun, Enumerations.RocketLuncher, Enumerations.Shotgun, Enumerations.Chaingun }
destination = {}
lastPosition = {}
walkingMode = {}
blockingFix = {}

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

function getClosestTrigger(nav, position, type)
	closest = nil
	if nav:getNumberOfTriggers() > 0 then
		for current=0, nav:getNumberOfTriggers() - 1 do
			trig = nav:getTrigger(current)
			if trig:isActive() and trig:getType() == type then
				distance = trig:getPosition() - position
				length = distance:length()
				if closest ~= nil then
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
	if closest ~= nil then
		return nav:getTrigger(closest)
	else
		return nil
	end
end

function getClosestActiveTrigger(nav, position)
	closest = nil
	if nav:getNumberOfTriggers() > 0 then
		for current=0, nav:getNumberOfTriggers() - 1 do
			trig = nav:getTrigger(current)
			if trig:isActive() then
				distance = trig:getPosition() - position
				length = distance:length()
				if closest ~= nil then
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
		return nav:getTrigger(closest)
	else
		return nil
	end
end

function getClosestEnemy(enemies, position)
	if enemies:size() > 0 then
		min = enemies:at(0)
		diff = min:getPosition() - position
		minLen = diff:length()
		for i=0,enemies:size()-1 do
			enemy = enemies:at(i)
			diff = enemy:getPosition() - position
			diffLen = diff:length()
			if diffLen < minLen then
				minLen = diffLen
				min = enemy
			end
		end
		return min
	else
		return nil
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
	if x == 1 then
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

function lowHealth(actorKnowledge)
	return actorKnowledge:getHealth() < START_HEALTH / 3
end

function outOfAmmo(actorKnowledge)
	if actorKnowledge:getAmmo(Enumerations.RocketLuncher) == 0 and
		actorKnowledge:getAmmo(Enumerations.Railgun) == 0 and
		actorKnowledge:getAmmo(Enumerations.Shotgun) == 0 and
		actorKnowledge:getAmmo(Enumerations.Chaingun) == 0 then
		return true
	end
	return false
end

function lukewwhatTo(agent, actorKnowledge, time)
	botNumber = getBotNumber(actorKnowledge)
	position = actorKnowledge:getPosition()
	nav = actorKnowledge:getNavigation()
	enemies = actorKnowledge:getSeenFoes()

	if vectorEqual(lastPosition[botNumber], position) then
		dir = (actorKnowledge:getShortDestination() - position) * -1
		agent:moveDirection(dir)
		blockingFix[botNumber] = 1
	end
	if blockingFix[botNumber] >= 1 then
		blockingFix[botNumber] = blockingFix[botNumber] + 1
	end
	if blockingFix[botNumber] == BLOCKING_FIX_TIME then
		agent:moveTo(destination[botNumber])
		blockingFix[botNumber] = 0
	end	

	enemy = getClosestEnemy(enemies, position)
	if enemy ~= nil then
		diff = enemy:getPosition() - position
		diffLen = diff:length()
--		io.write(string.format('diffLen=%d\n', diffLen))
		if diffLen < SAFE_LEN then
			chooseWeapon(agent, actorKnowledge, weaponsShort)
		else
			chooseWeapon(agent, actorKnowledge, weaponsLong)
		end
	else
		chooseWeapon(agent, actorKnowledge, weaponsLong)
	end
	
	diff = destination[botNumber] - position
	diffLen = diff:length()
--	io.write(string.format('diffLen=%d\n', diffLen))
	if walkingMode[botNumber] == 0 then
		error = SMALL_ERROR_MARGIN_LEN
	else
		error = BIG_ERROR_MARGIN_LEN
	end
	destReached = diffLen < error
	trigger = getClosestActiveTrigger(nav, position)
	if lowHealth(actorKnowledge) then
		trig = getClosestTrigger(nav, position, Enumerations.Health) --here
		io.write('Low health!\n')
	elseif outOfAmmo(actorKnowledge) then
		io.write('Out of ammo!\n')
		trig = getClosestTrigger(nav, position, Enumerations.Weapon)
	elseif trigger ~= nil then
		io.write('Trigger close.\n')
		if destReached then
			dest = trigger:getPosition()
			destination[botNumber] = dest
			agent:moveTo(dest)
			walkingMode[botNumber] = 0
		end
	else
		if destReached then
			trig = nav:getTrigger(math.random(0, nav:getNumberOfTriggers() - 1)) --optimist
			dest = trig:getPosition()
			destination[botNumber] = dest
			agent:moveTo(dest)
			walkingMode[botNumber] = 1
		end
	end

	lastPosition[botNumber] = position

	io.write(string.format('%d:\n', botNumber))
	io.write('Position: ')
	showVector(position)
	io.write('Destination: ')
	showVector(destination[botNumber])
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
	chooseWeapon(agent, actorKnowledge, weaponsLong)
	destination[botNumber] = position
	lastPosition[botNumber] = position
	walkingMode[botNumber] = 0
	blockingFix[botNumber] = 0
	io.write(string.format('%d (start):\n', botNumber))
end
