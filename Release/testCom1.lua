io.write("test")

counter = 0
function testCom1whatTo( agent, actorKnowledge, time)
	io.write("com2b\n")
	log( "counter", counter)
	io.write("com2e\n")
	
	
		
	navi = actorKnowledge:getNavigation()
        nof_triggers = navi:getNumberOfTriggers()
        for i = 0, nof_triggers - 1, 1 do
            trig = navi:getTrigger( i)
            if (  trig:isActive()) then
                --dist = actorKnowledge:getPosition() - trig:getPosition()
                --if ( dist:length() < 200) then
                    agent:moveTo( trig:getPosition())
                --end
            end
        end
	--enemies = actorKnowledge:getSeenFoes()
	--if ( enemies:size() > 0) then
	--	io.write("shooting");
	--	agent:moveTo( enemies:at(0):getPosition());
 	--	dist = actorKnowledge:getPosition() - enemies:at(0):getPosition();
  	--	if (dist:length() < 200) then
	--	end
	--end

end;

function testCom1onStart( agent, actorKnowledge, time)
end

function getActionName( action)

    if ( action == 5) then
        return "Waiting";
    elseif ( action == 4) then
        return "Reloading";
    elseif ( action == 3) then
        return "Dying";
    elseif ( action == 2) then
        return "ChangingWeapon";
    elseif ( action == 1) then
        return "Shooting";
    elseif ( action == 0) then
        return "Moving";
    end
    return "Unknown";
end;

function log( name, msg)
    io.write( name )
    io.write( ": ")
    io.write( msg)
    io.write( "\n")
end;

function showVector( vector)
    io.write( "(")
    io.write( vector:value(0))
    io.write( ",")
    io.write( vector:value(1))
    io.write( ",")
    io.write( vector:value(2))
    io.write( ",")
    io.write( vector:value(3))
    io.write( ");")
end;