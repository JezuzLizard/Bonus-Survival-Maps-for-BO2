#include maps\mp\zombies\_zm_stats;
#include maps\mp\zombies\_zm_score;
#include maps\mp\zombies\_zm_weapons;
#include maps\mp\zombies\_zm_net;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\zombies\_zm_weap_tomahawk;
#include maps\mp\zm_alcatraz_weap_quest;

main()
{
	if(GetDvar("customMap") != "vanilla")
	{
		replacefunc(maps\mp\zombies\_zm_weap_tomahawk::init, ::init_tomahawk);
	}
}

init_tomahawk() //checked matches cerberus output
{
	registerclientfield( "toplayer", "tomahawk_in_use", 9000, 2, "int" );
	registerclientfield( "toplayer", "upgraded_tomahawk_in_use", 9000, 1, "int" );
	registerclientfield( "scriptmover", "play_tomahawk_fx", 9000, 2, "int" );
	registerclientfield( "actor", "play_tomahawk_hit_sound", 9000, 1, "int" );
	onplayerconnect_callback( ::tomahawk_on_player_connect );
	maps\mp\zombies\_zm_weapons::include_zombie_weapon( "bouncing_tomahawk_zm", 0 );
	maps\mp\zombies\_zm_weapons::include_zombie_weapon( "upgraded_tomahawk_zm", 0 );
	maps\mp\zombies\_zm_weapons::include_zombie_weapon( "zombie_tomahawk_flourish", 0 );
	maps\mp\zombies\_zm_weapons::add_zombie_weapon( "bouncing_tomahawk_zm", "zombie_tomahawk_flourish", &"ZOMBIE_WEAPON_SATCHEL_2000", 2000, "wpck_monkey", "", undefined, 1 );
	maps\mp\zombies\_zm_weapons::add_zombie_weapon( "upgraded_tomahawk_zm", "zombie_tomahawk_flourish", &"ZOMBIE_WEAPON_SATCHEL_2000", 2000, "wpck_monkey", "", undefined, 1 );
	level thread tomahawk_pickup();
	level.zombie_weapons_no_max_ammo = [];
	level.zombie_weapons_no_max_ammo[ "bouncing_tomahawk_zm" ] = 1;
	level.zombie_weapons_no_max_ammo[ "upgraded_tomahawk_zm" ] = 1;
	level.a_tomahawk_pickup_funcs = [];
	thread modified_location();
	thread modified_hellhound();
}

tomahawk_pickup() //checked matches cerberus output
{
	flag_wait( "soul_catchers_charged" );
	flag_init( "tomahawk_pickup_complete" );
	flag_init( "tomahawk_pickup_complete2" );
	door = getent( "tomahawk_room_door", "targetname" );
	door trigger_off();
	door connectpaths();
	s_pos_tomahawk = getstruct( "tomahawk_pickup_pos", "targetname" );
	m_tomahawk = spawn( "script_model", s_pos_tomahawk.origin );
	m_tomahawk.targetname = "spinning_tomahawk_pickup";
	m_tomahawk setmodel( "t6_wpn_zmb_tomahawk_world" );
	m_tomahawk setclientfield( "play_tomahawk_fx", 1 );
	m_tomahawk thread tomahawk_pickup_spin();
	m_tomahawk playloopsound( "amb_tomahawk_swirl" );
	s_pos_trigger = getstruct( "tomahawk_trigger_pos", "targetname" );
	trigger = spawn( "trigger_radius_use", s_pos_trigger.origin, 0, 100, 150 );
	trigger.script_noteworthy = "retriever_pickup_trigger";
	trigger usetriggerrequirelookat();
	trigger triggerignoreteam();
	trigger sethintstring( &"ZM_PRISON_TOMAHAWK_PICKUP" );
	trigger setcursorhint( "HINT_NOICON" );
	trigger_upgraded = spawn( "trigger_radius_use", s_pos_trigger.origin, 0, 100, 150 );
	trigger_upgraded usetriggerrequirelookat();
	trigger_upgraded triggerignoreteam();
	trigger_upgraded.script_noteworthy = "redeemer_pickup_trigger";
	trigger_upgraded sethintstring( &"ZM_PRISON_TOMAHAWK_UPGRADED_PICKUP" );
	trigger_upgraded setcursorhint( "HINT_NOICON" );
	/*
/#
	iprintlnbold( "GO FIND THE TOMAHAWK" );
#/
	*/
	trigger thread tomahawk_pickup_trigger();
	trigger_upgraded thread tomahawk_pickup_trigger();
	flag_set( "tomahawk_pickup_complete2" );
}

tomahawk_pickup_trigger() //checked changed to match cerberus output
{
	while ( 1 )
	{
		self waittill( "trigger", player );
		if ( isDefined( player.current_tactical_grenade ) && !issubstr( player.current_tactical_grenade, "tomahawk_zm" ) )
		{
			player takeweapon( player.current_tactical_grenade );
		}
		if ( player.current_tomahawk_weapon == "upgraded_tomahawk_zm" )
		{
			player disable_player_move_states( 1 );
			gun = player getcurrentweapon();
			level notify( "bouncing_tomahawk_zm_aquired" );
			player maps\mp\zombies\_zm_stats::increment_client_stat( "prison_tomahawk_acquired", 0 );
			player giveweapon( "zombie_tomahawk_flourish" );
			if ( isDefined ( level.customMap ) && level.customMap == "vanilla" )
			{
				player thread tomahawk_update_hud_on_last_stand();
			}
			player switchtoweapon( "zombie_tomahawk_flourish" );
			player waittill_any( "player_downed", "weapon_change_complete" );
			if ( self.script_noteworthy == "redeemer_pickup_trigger" )
			{
				player.redeemer_trigger = self;
				player setclientfieldtoplayer( "upgraded_tomahawk_in_use", 1 );
			}
			player switchtoweapon( gun );
			player enable_player_move_states();
			player.loadout.hastomahawk = 1;
			self setclientfieldtoplayer( "tomahawk_in_use", 1 );
			player giveweapon( "upgraded_tomahawk_zm" );
			player givemaxammo( "upgraded_tomahawk_zm" );
			player set_player_tactical_grenade( "upgraded_tomahawk_zm" );
			continue;
		}
		if ( !player hasweapon( "bouncing_tomahawk_zm" ) && !player hasweapon( "upgraded_tomahawk_zm" ) )
		{
			player disable_player_move_states( 1 );
			if ( !is_true( player.afterlife ) )
			{
				player giveweapon( player.current_tomahawk_weapon );
				player thread tomahawk_update_hud_on_last_stand();
				player thread tomahawk_tutorial_hint();
				player set_player_tactical_grenade( player.current_tomahawk_weapon );
				if ( self.script_noteworthy == "retriever_pickup_trigger" )
				{
					player.retriever_trigger = self;
				}
				player notify( "tomahawk_picked_up" );
				player setclientfieldtoplayer( "tomahawk_in_use", 1 );
				gun = player getcurrentweapon();
				level notify( "bouncing_tomahawk_zm_aquired" );
				player notify( "player_obtained_tomahawk" );
				player maps\mp\zombies\_zm_stats::increment_client_stat( "prison_tomahawk_acquired", 0 );
				player giveweapon( "zombie_tomahawk_flourish" );
				player switchtoweapon( "zombie_tomahawk_flourish" );
				player waittill_any( "player_downed", "weapon_change_complete" );
				if ( self.script_noteworthy == "redeemer_pickup_trigger" )
				{
					player setclientfieldtoplayer( "upgraded_tomahawk_in_use", 1 );
				}
				player switchtoweapon( gun );
			}
			player enable_player_move_states();
			wait 0.1;
		}
	}
}

tomahawk_on_player_connect() //checked matches cerberus output
{
	self.current_tomahawk_weapon = "bouncing_tomahawk_zm";
	self.current_tactical_grenade = "bouncing_tomahawk_zm";
	self thread watch_for_tomahawk_throw();
	self thread watch_for_tomahawk_charge();
	self thread tomahawk_upgrade_modified();
	self thread toggle_redeemer_modified();
}

modified_location()
{
	if ( isDefined ( level.customMap ) && level.customMap == "docks" )
	{
		tomahawk_effect = getstruct( "tomahawk_pickup_pos", "targetname" );
		tomahawk_effect.origin = ( 981.75, 5818.75, 314.125 );
	
		tomahawk_trigger = getstruct( "tomahawk_trigger_pos", "targetname" );
		tomahawk_trigger.origin = ( 981.75, 5818.75, 314.125 );
	
		tomahawk_upgraded = getent( "spinning_tomahawk_pickup", "targetname" );
		tomahawk_upgraded.origin = ( 981.75, 5818.75, 314.125 );
	
		tomahawk_hellhole_trigger = getent( "trig_cellblock_hellhole", "targetname" );
		tomahawk_hellhole_trigger.origin = ( -58.3, 7880.5, -69 );
	}
	else if ( isDefined ( level.customMap ) && level.customMap == "cellblock" )
    {
        tomahawk_effect = getstruct( "tomahawk_pickup_pos", "targetname" );
        tomahawk_effect.origin = ( 2157.05, 9287.64, 1608.13 );
        
        tomahawk_trigger = getstruct( "tomahawk_trigger_pos", "targetname" );
        tomahawk_trigger.origin = ( 2157.05, 9287.64, 1608.13 );
        
        tomahawk_upgraded = getent( "spinning_tomahawk_pickup", "targetname" );
        tomahawk_upgraded.origin = ( 2157.05, 9287.64, 1608.13 );
    }
    else if ( isDefined ( level.customMap ) && level.customMap == "rooftop" )
    {
        tomahawk_effect = getstruct( "tomahawk_pickup_pos", "targetname" );
        tomahawk_effect.origin = ( 2506.45, 9283.83, 1578.13 );
        
        tomahawk_trigger = getstruct( "tomahawk_trigger_pos", "targetname" );
        tomahawk_trigger.origin = ( 2506.45, 9283.83, 1578.13 );
        
        tomahawk_upgraded = getent( "spinning_tomahawk_pickup", "targetname" );
        tomahawk_upgraded.origin = ( 2506.45, 9283.83, 1578.13 );
        
        tomahawk_hellhole_trigger = getent( "trig_cellblock_hellhole", "targetname" );
        tomahawk_hellhole_trigger.origin = ( 2222.91, 9012.82, 1678.73 );
    }
}

tomahawk_upgrade_modified()
{
	level endon( "end_game");
	self endon( "disconnect" );
	
	level.tomahawkKillsRequired = getDvarIntDefault( "tomahawkKillsRequired", 35 );
	level.zombie_vars[ "tomahawkKillsRequired" ] = level.tomahawkKillsRequired;
	self.tomahawk_upgrade_kills = 0;
	while ( self.tomahawk_upgrade_kills < level.tomahawkKillsRequired )
	{
		self waittill( "got_a_tomahawk_kill" );
		self.tomahawk_upgrade_kills++;
	}
	wait 1;
	level thread maps\mp\zombies\_zm_audio::sndmusicstingerevent( "quest_generic" );
	e_org = spawn( "script_origin", self.origin + vectorScale( ( 0, 0, 1 ), 64 ) );
	e_org playsoundwithnotify( "zmb_easteregg_scream", "easteregg_scream_complete" );
	e_org waittill( "easteregg_scream_complete" );
	e_org delete();
	self notify( "hellhole_time" );
	self waittill( "tomahawk_in_hellhole" );
	if ( isDefined( self.retriever_trigger ) )
	{
		self.retriever_trigger setinvisibletoplayer( self );
	}
	else
	{
		trigger = getent( "retriever_pickup_trigger", "script_noteworthy" );
		self.retriever_trigger = trigger;
		self.retriever_trigger setinvisibletoplayer( self );
	}
	self takeweapon( "bouncing_tomahawk_zm" );
	self set_player_tactical_grenade( "none" );
	self notify( "tomahawk_upgraded_swap" );
	level thread maps\mp\zombies\_zm_audio::sndmusicstingerevent( "quest_generic" );
	e_org = spawn( "script_origin", self.origin + vectorScale( ( 0, 0, 1 ), 64 ) );
	e_org playsoundwithnotify( "zmb_easteregg_scream", "easteregg_scream_complete" );
	e_org waittill( "easteregg_scream_complete" );
	e_org delete();
	level waittill( "end_of_round" );
	tomahawk_pick = getent( "spinning_tomahawk_pickup", "targetname" );
	tomahawk_pick setclientfield( "play_tomahawk_fx", 2 );
	self.current_tomahawk_weapon = "upgraded_tomahawk_zm";
}

toggle_redeemer_modified()
{
	level endon( "end_game");
	self endon( "disconnect" );
	flag_wait( "tomahawk_pickup_complete2" );
	upgraded_tomahawk_trigger = getent( "redeemer_pickup_trigger", "script_noteworthy" );
	upgraded_tomahawk_trigger setinvisibletoplayer( self );
	tomahawk_model = getent( "spinning_tomahawk_pickup", "targetname" );
	while ( 1 )
	{
		if ( isDefined( self.current_tomahawk_weapon ) && self.current_tomahawk_weapon == "upgraded_tomahawk_zm" )
		{
			break;
		}
		else wait 1;
	}
	upgraded_tomahawk_trigger setvisibletoplayer( self );
	tomahawk_model setvisibletoplayer( self );
}

modified_hellhound()
{
	wait 3;
	level endon( "end_game");
	level.zombies_required = 0;
	level.zombies_required_total = getDvarIntDefault( "hellhoundKillsRequired", 18 );
	level.zombie_vars[ "hellhoundKillsRequired" ] = level.zombies_required_total;
	for(;;)
	{
		a_wolf_structs = getstructarray( "wolf_position", "targetname" );
		i = 0;
		while ( i < a_wolf_structs.size )
		{
			if ( a_wolf_structs[ i ].souls_received == 1 )
			{
				level.zombies_required++;
			}
			a_wolf_structs[ i ].souls_received = 0;
			i++;
		}
		if ( level.zombies_required == level.zombies_required_total )
		{
			a_wolf_structs = getstructarray( "wolf_position", "targetname" );
			i = 0;
			while ( i < a_wolf_structs.size )
			{
				a_wolf_structs[ i ].souls_received = 6;
				i++;
			}
			flag_set( "soul_catchers_charged" );
			level notify( "soul_catchers_charged" );
			level thread maps\mp\zombies\_zm_audio::sndmusicstingerevent( "quest_generic" );
			return;
		}
		else
		{
			wait 0.25;
		}
	}
}