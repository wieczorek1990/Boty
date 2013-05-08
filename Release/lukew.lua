--lukew.lua
-- Bot names should be 'BOT_NAME_PREFIX%d' where %d in <1, N>

-- Setup these before qualifications
BOT_NAME_PREFIX = 'lukew'
WIDTH = 1024
HEIGHT = 768
-- Config
START_HEALTH = 0
SAFE_LEN = 150
WEAPON_CHANGE_LEN = 100
ENEMIES_2_LEN = 75
ENEMIES_3_LEN = 100
SMALL_ERROR_MARGIN_LEN = 8
BIG_ERROR_MARGIN_LEN = 64
weaponsArea = { Enumerations.Shotgun, Enumerations.RocketLuncher }
weaponsShort = { Enumerations.Shotgun, Enumerations.RocketLuncher, Enumerations.Railgun, Enumerations.Chaingun }
weaponsLong = { Enumerations.Railgun, Enumerations.RocketLuncher, Enumerations.Shotgun, Enumerations.Chaingun }
-- Runtime
destination = {}
lastPosition = {}
walkingMode = {}
enemyLastPosition = {}

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
	if closestLength < SAFE_LEN and closest ~= nil then
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
	enemiesCount = enemies:size()

	-- Cofanie przy blokadzie
	if vectorEqual(lastPosition[botNumber], position) then
		dest = Vector4d(agent:randomDouble()*WIDTH, agent:randomDouble()*HEIGHT, 0, 0)
		agent:moveTo(dest)
	end

	-- Wybór broni
	enemy = getClosestEnemy(enemies, position)
	if enemy ~= nil then
		diff = enemy:getPosition() - position
		diffLen = diff:length()
--		io.write(string.format('diffLen=%d\n', diffLen))
		if diffLen < WEAPON_CHANGE_LEN then
			chooseWeapon(agent, actorKnowledge, weaponsShort)
		else
			chooseWeapon(agent, actorKnowledge, weaponsLong)
		end
	else
		chooseWeapon(agent, actorKnowledge, weaponsShort)
	end
	
	diff = destination[botNumber] - position
	diffLen = diff:length()
	if walkingMode[botNumber] == 0 then
		error = SMALL_ERROR_MARGIN_LEN
	else
		error = BIG_ERROR_MARGIN_LEN
	end
	destReached = diffLen < error
	trigActive = getClosestActiveTrigger(nav, position)
	trigWeapon = getClosestTrigger(nav, position, Trigger.Weapon)
	trigHealth = getClosestTrigger(nav, position, Trigger.Health)
	-- ¯ycie
	if lowHealth(actorKnowledge) and trigHealth ~= nil then
--		io.write('Low health!\n')
		if destReached then
			dest = trigHealth:getPosition()
			destination[botNumber] = dest
			agent:moveTo(dest)
			walkingMode[botNumber] = 0
		end
	-- Amunicja
	elseif outOfAmmo(actorKnowledge) and trigWeapon ~= nil then
--		io.write('Out of ammo!\n')
		if destReached then
			dest = trigWeapon:getPosition()
			destination[botNumber] = dest
			agent:moveTo(dest)
			walkingMode[botNumber] = 0
		end
	-- Bliski trigger
	elseif trigActive ~= nil then
--		io.write('Trigger close.\n')
		if destReached then
			dest = trigActive:getPosition()
			destination[botNumber] = dest
			agent:moveTo(dest)
			walkingMode[botNumber] = 0
		end
	-- Przeciwnicy
	elseif enemiesCount > 0 then
--		io.write('Enemies!\n')
		dir = enemy:getPosition() - position
		if dir:length() > SAFE_LEN then
			agent:moveDirection(dir)
		end
	-- Chodzenie po mapie
	else
		if destReached then
			lastDest = destination[botNumber]
			repeat
				trig = nav:getTrigger(math.random(0, nav:getNumberOfTriggers() - 1)) --optimist
				dest = trig:getPosition()
			until not vectorEqual(lastDest, dest)
			destination[botNumber] = dest
			agent:moveTo(dest)
			walkingMode[botNumber] = 1
		end
	end
	
	-- Strzelanie
	if enemiesCount > 0 then
		denseShooting = false
		if enemiesCount > 1 then
			e0 = enemies:at(0):getPosition()
			e1 = enemies:at(1):getPosition()
			if enemiesCount == 2 then
--				io.write('2 enemies!')
				c = (e0 + e1) / 2
				v0 = c - e0
				v1 = c - e1
				sumLen = v0:length() + v1:length()
				if sumLen < ENEMIES_2_LEN then
					shotPos = c
					denseShooting = true
				end
			else
--				io.write('3 enemies!')
				e2 = enemies:at(2):getPosition()
				c = (e0 + e1 + e2) / 3
				v0 = c - e0
				v1 = c - e1
				v2 = c - e2
				sumLen = v0:length() + v1:length() + v2:length()
				if sumLen < ENEMIES_3_LEN then
					shotPos = c
					denseShooting = true
				end
			end
--			io.write(string.format('sumLen=%d\n', sumLen))
		end
		if not denseShooting then
			d = Vector4d(0, 0, 0, 0)
			eLastPos = enemyLastPosition[enemy:getName()]
			if eLastPos ~= nil then
				diff = enemy:getPosition() - eLastPos
				diffLen = diff:length()
				if diffLen < SMALL_ERROR_MARGIN_LEN then
					d = diff
				end
			end
			if actorKnowledge:getWeaponType() == Enumerations.Chaingun then
				shotPos = enemy:getPosition() + (d * 5)
			else 
				shotPos = enemy:getPosition() + (d * 2)
			end
		end
		agent:shootAtPoint(shotPos)
	end
	for i=0,enemiesCount-1 do
		e = enemies:at(i)
		enemyLastPosition[e:getName()] = e:getPosition()
	end
	lastPosition[botNumber] = position

--	io.write(string.format('%d:\n', botNumber))
--	io.write('Position: ')
--	showVector(position)
--	io.write('Destination: ')
--	showVector(destination[botNumber])
--	io.write(string.format("weapon = %d\n", actorKnowledge:getWeaponType()))
--	io.write(string.format('ammo = %d\n', actorKnowledge:getAmmo(actorKnowledge:getWeaponType())))
--	for i=0,3 do
--		io.write(string.format("%d -> %d\n", i, actorKnowledge:getAmmo(i)))
--	end
--	io.write(string.format('diffLen=%d\n', diffLen))
end

function lukewonStart(agent, actorKnowledge, time)
 	math.randomseed(os.time())
	botNumber = getBotNumber(actorKnowledge)
	position = actorKnowledge:getPosition()
	START_HEALTH = actorKnowledge:getHealth()
	chooseWeapon(agent, actorKnowledge, weaponsShort)
	destination[botNumber] = position
	lastPosition[botNumber] = Vector4d(-1, -1, -1, -1)
	walkingMode[botNumber] = 0
--	io.write(string.format('%d (start):\n', botNumber))
end