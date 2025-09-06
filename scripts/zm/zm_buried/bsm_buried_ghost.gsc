#include maps\mp\zombies\_zm_utility;
#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\zombies\_zm_spawner;
#include maps\mp\zombies\_zm_ai_ghost;

main()
{
	if(GetDvar("zeGamemode") != "survival")
		return;
	replacefunc(maps\mp\zombies\_zm_ai_ghost::ghost_round_think, ::ghost_round_think);
	replacefunc(maps\mp\zombies\_zm_ai_ghost::init_ghost_spawners, ::init_ghost_spawners);
}

init_ghost_spawners()
{
	level.ghost_spawners = getentarray( "ghost_zombie_spawner", "script_noteworthy" );
	if ( level.ghost_spawners.size == 0 )
	{
		return 0;
	}
	array_thread( level.ghost_spawners, ::add_spawn_function, ::prespawn );
	_a131 = level.ghost_spawners;
	_k131 = getFirstArrayKey( _a131 );
	while ( isDefined( _k131 ) )
	{
		spawner = _a131[ _k131 ];
		if ( spawner.targetname == "female_ghost" )
		{
			level.female_ghost_spawner = spawner;
		}
		_k131 = getNextArrayKey( _a131, _k131 );
	}
	return 1;
}

prespawn()
{
	self endon( "death" );
	level endon( "intermission" );
	self maps\mp\zombies\_zm_ai_ghost_ffotd::prespawn_start();
	self.startinglocation = self.origin;
	self.animname = "ghost_zombie";
	self.audio_type = "ghost";
	self.has_legs = 1;
	self.no_gib = 1;
	self.ignore_enemy_count = 1;
	self.ignore_equipment = 1;
	self.ignore_claymore = 0;
	self.force_killable_timer = 0;
	self.noplayermeleeblood = 1;
	self.paralyzer_hit_callback = ::paralyzer_callback;
	self.paralyzer_slowtime = 0;
	self.paralyzer_score_time_ms = getTime();
	self.ignore_slowgun_anim_rates = undefined;
	self.reset_anim = ::ghost_reset_anim;
	self.custom_springpad_fling = ::ghost_springpad_fling;
	self.bookcase_entering_callback = ::bookcase_entering_callback;
	self.ignore_subwoofer = 1;
	self.ignore_headchopper = 1;
	self.ignore_spring_pad = 1;
	recalc_zombie_array();
	self setphysparams( 15, 0, 72 );
	self.cant_melee = 1;
	if ( isDefined( self.spawn_point ) )
	{
		spot = self.spawn_point;
		if ( !isDefined( spot.angles ) )
		{
			spot.angles = ( 1, 1, 1 );
		}
		self forceteleport( spot.origin, spot.angles );
	}
	self set_zombie_run_cycle( "run" );
	self setanimstatefromasd( "zm_move_run" );
	self.actor_damage_func = ::ghost_damage_func;
	self.deathfunction = ::ghost_death_func;
	self.maxhealth = level.ghost_health;
	self.health = level.ghost_health;
	self.zombie_init_done = 1;
	self notify( "zombie_init_done" );
	self.allowpain = 0;
	self.ignore_nuke = 1;
	self animmode( "normal" );
	self orientmode( "face enemy" );
	self bloodimpact( "none" );
	self disableaimassist();
	self.forcemovementscriptstate = 0;
	self maps\mp\zombies\_zm_spawner::zombie_setup_attack_properties();
	if ( isDefined( self.is_spawned_in_ghost_zone ) && self.is_spawned_in_ghost_zone )
	{
		self.pathenemyfightdist = 0;
	}
	self maps\mp\zombies\_zm_spawner::zombie_complete_emerging_into_playable_area();
	self setfreecameralockonallowed( 0 );
	self.startinglocation = self.origin;
	if ( isDefined( level.ghost_custom_think_logic ) )
	{
		self [[ level.ghost_custom_think_logic ]]();
	}
	self.bad_path_failsafe = maps\mp\zombies\_zm_ai_ghost_ffotd::ghost_bad_path_failsafe;
	self thread ghost_think();
	self.attack_time = 0;
	self.ignore_inert = 1;
	self.subwoofer_burst_func = ::subwoofer_burst_func;
	self.subwoofer_fling_func = ::subwoofer_fling_func;
	self.subwoofer_knockdown_func = ::subwoofer_knockdown_func;
	self maps\mp\zombies\_zm_ai_ghost_ffotd::prespawn_end();
}

ghost_death_func()
{
	if ( get_current_ghost_count() == 0 && level.zombie_total == 0 )
	{
		level.ghost_round_last_ghost_origin = self.origin;
		level notify("last_ghost_down");
	}
	self stoploopsound( 1 );
	self playsound( "zmb_ai_ghost_death" );
	self setclientfield( "ghost_impact_fx", 1 );
	self setclientfield( "ghost_fx", 1 );
	self thread prepare_to_die();
	if ( isDefined( self.extra_custom_death_logic ) )
	{
		self thread [[ self.extra_custom_death_logic ]]();
	}
	qrate = self getclientfield( "anim_rate" );
	self setanimstatefromasd( "zm_death" );
	self thread wait_ghost_ghost( self getanimlengthfromasd( "zm_death", 0 ) );
	maps\mp\animscripts\zm_shared::donotetracks( "death_anim" );
	if ( isDefined( self.is_spawned_in_ghost_zone ) && self.is_spawned_in_ghost_zone )
	{
		level.zombie_ghost_count--;

		if ( isDefined( self.favoriteenemy ) )
		{
			if ( isDefined( self.favoriteenemy.ghost_count ) && self.favoriteenemy.ghost_count > 0 )
			{
				self.favoriteenemy.ghost_count--;

			}
		}
	}
	player = undefined;
	if ( is_player_valid( self.attacker ) )
	{
		give_player_rewards( self.attacker );
		player = self.attacker;
	}
	else
	{
		if ( isDefined( self.attacker ) && is_player_valid( self.attacker.owner ) )
		{
			give_player_rewards( self.attacker.owner );
			player = self.attacker.owner;
		}
	}
	if ( isDefined( player ) )
	{
		player maps\mp\zombies\_zm_stats::increment_client_stat( "buried_ghost_killed", 0 );
		player maps\mp\zombies\_zm_stats::increment_player_stat( "buried_ghost_killed" );
	}
	self delete();
	return 1;
}

ghost_round_think()
{
	flag_init( "ghost_round" );
	level.next_ghost_round = level.round_number + randomintrange( 4, 7 );
	old_spawn_func = level.round_spawn_func;
	old_wait_func = level.round_wait_func;
	while ( 1 )
	{
		level waittill( "between_round_over" );
		if ( level.round_number == level.next_ghost_round )
		{
			level.music_round_override = 1;
			old_spawn_func = level.round_spawn_func;
			old_wait_func = level.round_wait_func;
			ghost_round_start();
			level.round_spawn_func = ::ghost_round_spawning;
			level.round_wait_func = ::ghost_round_wait;
			thread sndghostroundmus();
			thread sndghostroundmus_end();
			level.zombie_ghost_round_states.is_started = 1;
			level.next_ghost_round = level.round_number + randomintrange( 4, 7 );
		}
		else if ( flag( "ghost_round" ) )
		{
			level.zombie_ghost_round_states.is_started = 0;
			ghost_round_stop();
			level.round_spawn_func = old_spawn_func;
			level.round_wait_func = old_wait_func;
			level.music_round_override = 0;
		}
	}
}

ghost_round_spawning()
{
	level endon( "intermission" );
	level endon( "ghost_round_ending" );
	if(level.intermission)
		return;
	level.ghost_intermission = 1;
	wait 2;
	max = get_players().size * 6;
	level thread ghost_round_aftermath();
	level.zombie_total = max;
	increase_ghost_health();
	while ( 1 )
	{
		if(level.zombie_total <= 0)
			break;
		players = get_players();
		valid_players = array_randomize( players );
		spawn_point = find_ghost_spawn(valid_players[0]);
		if(!isdefined(spawn_point))
			continue;
		ghost_ai = spawn_zombie( level.female_ghost_spawner, level.female_ghost_spawner.targetname, spawn_point );
		if ( isDefined( ghost_ai ) )
		{
			ghost_ai setclientfield( "ghost_fx", 3 );
			ghost_ai.spawn_point = spawn_point;
			ghost_ai.is_ghost = 1;
			ghost_ai.find_target = 1;
			level.zombie_total--;
			level.zombie_ghost_count++;
		}
		else
		{
			continue;
		}
		wait 1;
	}
}

find_ghost_spawn(player)
{
	while(1)
	{
		point = level.zombie_spawn_locations[RandomInt(level.zombie_spawn_locations.size-1)];
		if(!player maps\mp\zombies\_zm_zonemgr::is_player_in_zone(point.zone_name) || point.script_string != "find_flesh")
			continue;
		else
			return point;
	}
}

sndghostroundmus()
{
	level endon( "ghost_round_ending" );
	ent = spawn( "script_origin", ( 1, 1, 1 ) );
	level.sndroundwait = 1;
	ent thread sndghostroundmus_end();
	ent endon( "sndGhostRoundEnd" );
	ent playsound( "mus_ghost_round_start" );
	wait 11;
	ent playloopsound( "mus_ghost_round_loop", 3 );
}
sndghostroundmus_end()
{
	level waittill( "ghost_round_ending" );
	self notify( "sndGhostRoundEnd" );
	self stoploopsound( 1 );
	self playsoundwithnotify( "mus_ghost_round_over", "stingerDone" );
	self waittill( "stingerDone" );
	self delete();
	level.sndroundwait = 0;
}

ghost_round_wait() //checked matches cerberus output
{
	level endon( "restart_round" );
	/*
/#
	if ( getDvarInt( "zombie_cheat" ) == 2 || getDvarInt( "zombie_cheat" ) >= 4 )
	{
		level waittill( "forever" );
#/
	}
	*/
	wait 1;
	if ( flag( "ghost_round" ) )
	{
		wait 7;
		while ( level.ghost_intermission )
		{
			wait 0.5;
		}
	}
}

ghost_round_start()
{
	flag_set( "ghost_round" );
	level notify( "ghost_round_starting" );
	//clientnotify( "ghost_start" );
}

ghost_round_stop()
{
	flag_clear( "ghost_round" );
}

ghost_round_aftermath()
{
	level waittill("last_ghost_down");
	level notify( "ghost_round_ending" );
	power_up_origin = level.ghost_round_last_ghost_origin;
	level thread maps\mp\zombies\_zm_powerups::specific_powerup_drop( "full_ammo", power_up_origin );
	wait 2;
	level.ghost_intermission = 0;
	level.zombie_ghost_round_states.is_started = 0;
}