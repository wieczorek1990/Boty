
counter = 0
function dumb200whatTo( agent, actorKnowledge, time)
  self = actorKnowledge:getSelf()
  weapon = actorKnowledge:getWeaponType()
  weapon = weapon + 1
  if (weapon == 5) then
	weapon = 0;
  end
  agent:selectWeapon( weapon)

  enemies = actorKnowledge:getSeenFoes()
  if ( enemies:size() > 0) then
     dir = enemies:at(0):getPosition() - actorKnowledge:getPosition()
     --self:setDirection( enemies:at(0):getDirection())
     --showVector( self:getDirection())--enemies:at(0):getPosition())
     --agent:moveDirection( enemies:at(0):getDirection())
     agent:rotate( dir)
     io.write( "on trzyma ", enemies:at(0):getWeaponType(), "\n")
  end
  
end;

function dumb200onStart( agent, actorKnowledge, time)
io.write("dumb2 started\n")
  io.write("dumb1 started\n")
  io.write("counter: ")
  io.write( counter)
  io.write( "\n")
  counter = counter + 1
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