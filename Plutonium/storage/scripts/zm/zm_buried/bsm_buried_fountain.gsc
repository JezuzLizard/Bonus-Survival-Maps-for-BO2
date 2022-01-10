#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;
#include maps/mp/zm_buried_classic;
#include maps/mp/zm_buried_fountain;

main()
{
	if(getDvar("customMap") == "vanilla")
		return;
	replacefunc(maps/mp/zm_buried_fountain::maze_fountain_think, ::maze_fountain_think);
	replacefunc(maps/mp/zm_buried_fountain::transport_player_to_start_zone, ::transport_player_to_start_zone);
}

maze_fountain_think()
{
	hide_maze_fountain_water();
	destroy_maze_fountain();
	flag_set( "fountain_transport_active" );
}

hide_maze_fountain_water()
{
	t_water = getent( "maze_fountain_water_trigger", "targetname" );
	t_water enablelinkto();
	m_water = getent( "maze_fountain_water", "targetname" );
	t_water linkto( m_water );
	m_water.origin = m_water.origin + (0,0,-475);
}

transport_player_to_start_zone()
{
	self endon( "death_or_disconnect" );
	if ( !isDefined( level._fountain_transporter ) )
	{
		level._fountain_transporter = spawnstruct();
		level._fountain_transporter.index = 0;
		level._fountain_transporter.end_points = getstructarray( "fountain_transport_end_location", "targetname" );
	}
	self playsoundtoplayer( "zmb_buried_teleport", self );
	self play_teleport_fx();
	self flash_screen_white();
	wait_network_frame();
	if ( level._fountain_transporter.index >= 8)
	{
		level._fountain_transporter.index = 0;
	}
	tries = 0;
	while ( positionwouldtelefrag( level._fountain_transporter.end_points[ level._fountain_transporter.index ].origin ) )
	{
		tries++;
		if ( tries >= 4 )
		{
			tries = 0;
			wait 0.05;
		}
		level._fountain_transporter.index++;
		if ( level._fountain_transporter.index >= level._fountain_transporter.end_points.size )
		{
			level._fountain_transporter.index = 0;
		}
	}
	if(isdefined(level.customMap) && level.customMap != "vanilla")
	{
		self setorigin( level.mazeSpawnpoints[ level._fountain_transporter.index ].origin );
		self setplayerangles( level.mazeSpawnpoints[ level._fountain_transporter.index ].angles );
	}
	self DoDamage(self.health + 1000, (0,0,0));
	level._fountain_transporter.index++;
	wait_network_frame();
	self play_teleport_fx();
	self thread flash_screen_fade_out();
	self maps/mp/zm_buried_classic::buried_set_start_area_lighting();
	self thread maps/mp/zombies/_zm_ai_ghost::behave_after_fountain_transport( self );
	self maps/mp/zombies/_zm_stats::increment_client_stat( "buried_fountain_transporter_used", 0 );
	self maps/mp/zombies/_zm_stats::increment_player_stat( "buried_fountain_transporter_used" );
	self notify( "player_used_fountain_teleporter" );
	wait_network_frame();
	wait_network_frame();
	self.is_in_fountain_transport_trigger = 0;
}