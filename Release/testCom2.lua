io.write("test")

counter = 0
function testCom2whatTo( agent, actorKnowledge, time)
	io.write("com2b\n")
	log( "counter", counter)
	io.write("com2e\n")
	enemies = actorKnowledge:getSeenFoes()
	if ( enemies:size() > 0) then
	   
	   dist = actorKnowledge:getPosition() - enemies:at(0):getPosition();
	   
	   if (dist:length() < 200) then
		dir = enemies:at(0):getDirection();
		agent:moveDirection( dir*(-1));
  	   end
	   
	end
end;

function testCom2onStart( agent, actorKnowledge, time)
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