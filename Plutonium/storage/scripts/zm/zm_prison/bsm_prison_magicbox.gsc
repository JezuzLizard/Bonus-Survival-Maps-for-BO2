#include maps/mp/zombies/_zm_stats;
#include maps/mp/_demo;
#include maps/mp/zombies/_zm_audio;
#include maps/mp/zombies/_zm_score;
#include maps/mp/zombies/_zm_pers_upgrades_functions;
#include maps/mp/zombies/_zm_audio_announcer;
#include maps/mp/zombies/_zm_unitrigger;
#include maps/mp/zombies/_zm_weapons;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/_utility;
#include common_scripts/utility;
#include maps/mp/zombies/_zm_magicbox_lock;
#include maps/mp/zombies/_zm_magicbox;

main()
{
	replacefunc(maps/mp/zombies/_zm_magicbox::init, ::init_magicbox);
	replacefunc(maps/mp/zombies/_zm_magicbox::get_chest_pieces, ::get_chest_pieces);
}

init_magicbox() //modified function
{
	//begin debug code
	level.custom_zm_magicbox_loaded = 1;
	maps/mp/zombies/_zm_bot::init();
	if ( !isDefined( level.debugLogging_zm_magicbox ) )
	{
		level.debugLogging_zm_magicbox = 0;
	}
	//end debug code
	if ( !isDefined( level.chest_joker_model ) )
	{
		level.chest_joker_model = "zombie_teddybear";
		precachemodel( level.chest_joker_model );
	}
	
	if ( !isDefined( level.magic_box_zbarrier_state_func ) )
	{
		level.magic_box_zbarrier_state_func = ::process_magic_box_zbarrier_state;
	}
	
	if ( isDefined( level.using_locked_magicbox ) && level.using_locked_magicbox )
	{
		maps/mp/zombies/_zm_magicbox_lock::init();
	}
	if ( is_classic() )
	{
		level.chests = getstructarray( "treasure_chest_use", "targetname" );
		normalChests = level.chests;

		if (isDefined(level.customMap) && level.customMap == "docks")
		{
			level.chests = [];
			start_chest = spawnstruct();
			start_chest.origin = ( -423.33, 6952, 64.125 );
			start_chest.angles = ( 0, 10, 0 );
			start_chest.script_noteworthy = "start_chest";
			start_chest.zombie_cost = 950;
			level.chests[ 0 ] = start_chest;
			level.chests[ 1 ] = normalChests[ 3 ];
			treasure_chest_init("start_chest");
		}
		else if (isDefined(level.customMap) && level.customMap == "showers")
		{
			level.chests = [];
			start_chest = spawnstruct();
			start_chest.origin = ( 1755, 10678, 1144 );
			start_chest.angles = ( 0, 180, 0 );
			start_chest.script_noteworthy = "start_chest";
			start_chest.zombie_cost = 950;
			level.chests[ 0 ] = start_chest;
			//level.chests[ 1 ] = normalChests[ 3 ];
			treasure_chest_init("start_chest");
		}
		else if (isDefined(level.customMap) && level.customMap == "cellblock")
		{
			level.chests = [];
			level.chests[ 0 ] = normalChests[ 0 ];
			level.chests[ 1 ] = normalChests[ 1 ];
			treasure_chest_init("start_chest");
		}
		else if (isDefined(level.customMap) && level.customMap == "rooftop")
		{
			level.chests = [];
			start_chest = spawnstruct();
			start_chest.origin = ( 2249, 9869.5, 1704.1 );
			start_chest.angles = ( 0, -90, 0 );
			start_chest.script_noteworthy = "start_chest";
			start_chest.zombie_cost = 950;
			level.chests[ 0 ] = start_chest;
			level.chests[ 1 ] = normalChests[ 2 ];
			randy = RandomIntRange(0,3);
			if ( randy == 1 )
				treasure_chest_init( "start_chest" );
			else
				treasure_chest_init( "roof_chest" );
		}
		else
		{
			logprint("why?" + "\n");
			treasure_chest_init( "start_chest" );
		}
	}
	if ( level.createfx_enabled )
	{
		return;
	}
	registerclientfield( "zbarrier", "magicbox_glow", 1000, 1, "int" );
	registerclientfield( "zbarrier", "zbarrier_show_sounds", 9000, 1, "int" );
	registerclientfield( "zbarrier", "zbarrier_leave_sounds", 9000, 1, "int" );
	if ( !isDefined( level.magic_box_check_equipment ) )
	{
		level.magic_box_check_equipment = ::default_magic_box_check_equipment;
	}
	level thread magicbox_host_migration();
}

get_chest_pieces() //modified function
{
	self.chest_box = getent( self.script_noteworthy + "_zbarrier", "script_noteworthy" );
	if ( isDefined( level.customMap ) && level.customMap == "docks" && self.script_noteworthy == "start_chest" )
	{
		self.chest_box.origin = ( -423.33, 6952, 64.125 );
		self.chest_box.angles = ( 0, 10, 0 );
	}
	if ( isDefined( level.customMap ) && level.customMap == "rooftop" && self.script_noteworthy == "start_chest" )
	{
		self.chest_box.origin = ( 2249, 9869.5, 1704.1 );
		self.chest_box.angles = ( 0, -90, 0 );
	}
	if ( isDefined( level.customMap ) && level.customMap == "showers" && self.script_noteworthy == "start_chest" )
	{
		self.chest_box.origin = ( 1755, 10678, 1144 );
		self.chest_box.angles = ( 0, 180, 0 );
	}
	if ( self.chest_box.angles == ( 0, 92, 0 ) || self.chest_box.angles == ( 0, 90, 0 ) || self.chest_box.angles == ( 0, -90, 0 ) )
	{
		collision = spawn( "script_model", self.chest_box.origin );
		collision.angles = self.chest_box.angles;
		collision setmodel( "collision_clip_32x32x128" );
		collision disconnectpaths();
		collision = spawn( "script_model", self.chest_box.origin - ( 0, 32, 0 ) );
		collision.angles = self.chest_box.angles;
		collision setmodel( "collision_clip_32x32x128" );
		collision disconnectpaths();
		collision = spawn( "script_model", self.chest_box.origin + ( 0, 32, 0 ) );
		collision.angles = self.chest_box.angles;
		collision setmodel( "collision_clip_32x32x128" );
		collision disconnectpaths();
	}
	else if ( self.chest_box.angles == ( 0, 10, 0 ) || self.chest_box.angles == ( 0, 1, 0 ) || self.chest_box.angles == ( 0, 0, 0 ) || self.chest_box.angles == ( 0, 180, 0 ) || self.chest_box.angles == ( 0, -180, 0 ) || self.chest_box.angles == ( 0, -185, 0 ) )
	{
		collision = spawn( "script_model", self.chest_box.origin );
		collision.angles = self.chest_box.angles;
		collision setmodel( "collision_clip_32x32x128" );
		collision disconnectpaths();
		collision = spawn( "script_model", self.chest_box.origin - ( 32, 0, 0 ) );
		collision.angles = self.chest_box.angles;
		collision setmodel( "collision_clip_32x32x128" );
		collision disconnectpaths();
		collision = spawn( "script_model", self.chest_box.origin + ( 32, 0, 0 ) );
		collision.angles = self.chest_box.angles;
		collision setmodel( "collision_clip_32x32x128" );
		collision disconnectpaths();
	}
	self.chest_rubble = [];
	rubble = getentarray( self.script_noteworthy + "_rubble", "script_noteworthy" );
	for ( i = 0; i < rubble.size; i++ )
	{
		if ( distancesquared( self.origin, rubble[ i ].origin ) < 10000 )
		{
			self.chest_rubble[ self.chest_rubble.size ] = rubble[ i ];
		}
	}
	self.zbarrier = getent( self.script_noteworthy + "_zbarrier", "script_noteworthy" );
	if ( isDefined( self.zbarrier ) )
	{
		self.zbarrier zbarrierpieceuseboxriselogic( 3 );
		self.zbarrier zbarrierpieceuseboxriselogic( 4 );
	}
	self.unitrigger_stub = spawnstruct();
	self.unitrigger_stub.origin = self.origin + anglesToRight( self.angles * -22.5 );
	self.unitrigger_stub.angles = self.angles;
	self.unitrigger_stub.script_unitrigger_type = "unitrigger_box_use";
	self.unitrigger_stub.script_width = 104;
	self.unitrigger_stub.script_height = 60;
	self.unitrigger_stub.script_length = 60;
	self.unitrigger_stub.trigger_target = self;
	unitrigger_force_per_player_triggers( self.unitrigger_stub, 1 );
	self.unitrigger_stub.prompt_and_visibility_func = ::boxtrigger_update_prompt;
	self.zbarrier.owner = self;
}