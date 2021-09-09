#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;

init()
{
	thread onplayerconnected();
}

onplayerconnected()
{
	level endon("end_game");
	for(;;)
	{
		level waittill("connected", player);
		player thread exo_suit();
		player SetMoveSpeedScale(1.5);
	}
}

exo_suit()
{
	self endon("disconnect");
	level endon("end_game");
	self.sprint_boost = 0;
	self.jump_boost = 0;
	while(1)
	{
		if( !self IsOnGround() )
		{
			if(self JumpButtonPressed() || self SprintButtonPressed())
			{
				wait 0.05;
				continue;
			}
			self.sprint_boost = 0;
			self.jump_boost = 0;
			while( !self IsOnGround() )
			{
				if( self JumpButtonPressed() && self.jump_boost < 1 )
				{
					self.is_flying_jetpack = true;
					self.jump_boost++;
					angles = self getplayerangles();
					angles = (0,angles[1],0);
					
					self.loop_value = 3;
					
					if( IsDefined(self.loop_value))
					{
						Earthquake( 0.22, .9, self.origin, 850 );
						direction = AnglesToUp(angles) * 750;
						self thread land();
						for(l = 0; l < self.loop_value; l++)
						{
							self SetVelocity( self getVelocity() + direction );
							wait .1;
						}
					}
				}
				if( self SprintButtonPressed() && self.sprint_boost < 1 )
				{
					self.is_flying_jetpack = true;
					self.sprint_boost++;
					angles = self getplayerangles();
					angles = (0,angles[1],0);
					
					self.loop_value = 1;
					
					if( IsDefined(self.loop_value))
					{
						Earthquake( 0.22, .9, self.origin, 850 );
						if(self.jump_boost == 1)
							direction = AnglesToForward(angles) * 250;
						else
							direction = AnglesToForward(angles) * 500;
						self thread land();
						for(l = 0; l < self.loop_value; l++)
						{
							self SetVelocity( self getVelocity() + direction );
							wait .1;
						}
					}
					while( !self isOnGround() )
						wait .05;
				}
			wait .1;
			}
		}
	wait .1;
	}
}

land()
{
	while( !self IsOnGround() )
		wait .1;
	self AllowMelee(true);
	self.is_flying_jetpack = false;
}