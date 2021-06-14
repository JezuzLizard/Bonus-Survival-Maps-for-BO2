#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;
#include maps/mp/zombies/_zm_buildables;
#include maps/mp/zombies/_zm_game_module;
#include maps/mp/zombies/_zm_ai_basic;
#include maps/mp/gametypes_zm/_weapons;
#include maps/mp/zombies/_zm_perks;
#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/gametypes_zm/_zm_gametype;

init()
{
	thread gscRestart();
	thread emptyLobbyRestart();
	thread map_rotation();
	thread override_map();
	thread setPlayersToSpectator();
	level.player_out_of_playable_area_monitor = 0;
	thread init_custom_map();
	thread setupWunderfizz();
	replacefunc(maps/mp/gametypes_zm/_zm_gametype::onspawnplayer, ::onspawnplayer);
	replacefunc(maps/mp/zombies/_zm_zonemgr::manage_zones, ::manage_zones);
	replacefunc(maps/mp/zombies/_zm_zonemgr::create_spawner_list, ::create_spawner_list);
	replacefunc(maps/mp/gametypes_zm/_zm_gametype::get_player_spawns_for_gametype, ::get_player_spawns_for_gametype);
	init_spawnpoints_for_custom_survival_maps();
	init_barriers_for_custom_maps();
	if ( level.script == "zm_tomb" && isDefined ( level.customMap ) && level.customMap != "vanilla" )
	{
		level thread turn_on_power_origins();
	}
	if ( isDefined ( level.customMap ) && level.customMap != "vanilla" )
	{
		setDvar( "scr_screecher_ignore_player", 1 );
	}
	level thread insta_kill_rounds_tracker();
	level.callbackactordamage = ::actor_damage_override_wrapper;
}

init_custom_map()
{
	level thread onplayerconnected();
	disable_pers_upgrades();
	flag_wait( "initial_blackscreen_passed" );
	thread init_buildables();
	wait 5;
	thread map_fixes();
}

onplayerconnected()
{
	for ( ;; )
	{
		level waittill( "connected", player );
		player thread addPerkSlot();
		player thread onplayerspawned();
		player thread perkHud();
		player thread [[ level.givecustomcharacters ]]();
		if ( isDefined ( level.HighRoundTracking ) && level.HighRoundTracking )
		{
			wait 5;
			player iprintln ( "High Round Record for this map: ^1" + level.HighRound );
			player iprintln ( "Record set by: ^1" + level.HighRoundPlayers );
		}
	}
}

perkHud()
{
	if(level.script != "zm_prison" && level.customMap != "vanilla")
		return;
	self endon("disconnect");
	self endon("end_game");
	self.perkText = self createText("Objective", 1, "LEFT", "TOP", -395, -10, 1, self getPerkDisplay());
	for(;;)
	{
		if(self.resetPerkHUD)
		{
			self.perkText setSafeText(self, self getPerkDisplay());
			self.resetPerkHUD = 0;
		}
		wait .1;
	}
}

getPerkDisplay()
{
	myperks = self get_perk_array(0);
	string = "PERKS: ";
	for(i=0;i<myperks.size;i++)
	{
		string = string + "\n" + getPerkName(myperks[i]);
	}
	return string;
}

addPerkSlot()
{
	perks = getPerks();
	killsNeeded = getDvarIntDefault( "perkSlotIncreaseKills", 0 );
	completedCount = 0;
	for(;;)
	{
		if(killsNeeded == 0)
			break;
		if((self.kills - (killsNeeded * completedCount)) >= killsNeeded)
		{
			self increment_player_perk_purchase_limit();
			self IPrintLnBold("You can now hold ^1" + self.player_perk_purchase_limit + " ^7perks!");
			completedCount++;
		}
		if((perks.size - level.perk_purchase_limit) <= completedCount)
			break;
		wait .1;
	}
}

onplayerspawned()
{
	self endon("disconnect");
	level endon("end_game");
	isFirstSpawn = true;
	for ( ;; )
	{
		self waittill( "spawned_player" );
		if(isFirstSpawn)
		{
			self initOverFlowFix();

			isFirstSpawn = false;
		}
		self thread disable_player_pers_upgrades();
		level notify ( "check_count" );
	}
}

map_fixes()
{
	if ( level.script == "zm_prison" && isDefined( level.customMap ) && level.customMap == "docks" )
	{
		level notify( "cable_puzzle_gate_afterlife" );
	}
	else if ( level.script == "zm_prison" && isDefined( level.customMap ) && level.customMap == "cellblock" )
	{
		level notify( "intro_powerup_activate" );
		level notify( "cell_1_powerup_activate" );
		level notify( "cell_2_powerup_activate" );
	}
}

disable_pers_upgrades() //credit to Jbleezy for this function
{
	//level waittill("initial_disable_player_pers_upgrades");

	level.pers_upgrades_keys = [];
	level.pers_upgrades = [];
}

disable_player_pers_upgrades() //credit to Jbleezy for this function
{
	flag_wait( "initial_blackscreen_passed" );

	if ( isDefined( self.pers_upgrades_awarded ) )
	{
		upgrade = getFirstArrayKey( self.pers_upgrades_awarded );
		while ( isDefined( upgrade ) )
		{
			self.pers_upgrades_awarded[ upgrade ] = 0;
			upgrade = getNextArrayKey( self.pers_upgrades_awarded, upgrade );
		}
	}

	if ( isDefined( level.pers_upgrades_keys ) )
	{
		index = 0;
		while ( index < level.pers_upgrades_keys.size )
		{
			str_name = level.pers_upgrades_keys[ index ];
			stat_index = 0;
			while ( stat_index < level.pers_upgrades[ str_name ].stat_names.size )
			{
				self maps/mp/zombies/_zm_stats::zero_client_stat( level.pers_upgrades[str_name].stat_names[ stat_index ], 0 );
				stat_index++;
			}
			index++;
		}
	}
	//level notify("initial_disable_player_pers_upgrades");
}

changecraftableoption( index )
{
	foreach (craftable in level.a_uts_craftables)
	{
		if (craftable.equipname == "open_table")
		{
			craftable thread setcraftableoption( index );
		}
	}
}

setcraftableoption( index )
{
	self endon("death");

	while (self.a_uts_open_craftables_available.size <= 0)
	{
		wait 0.05;
	}
	if (self.a_uts_open_craftables_available.size > 1)
	{
		self.n_open_craftable_choice = index;
		self.equipname = self.a_uts_open_craftables_available[self.n_open_craftable_choice].equipname;
		self.hint_string = self.a_uts_open_craftables_available[self.n_open_craftable_choice].hint_string;
		foreach (trig in self.playertrigger)
		{
			trig sethintstring( self.hint_string );
		}
	}
}

takecraftableparts( buildable )
{
	player = get_players()[ 0 ];
	foreach (stub in level.zombie_include_craftables)
	{
		if ( stub.name == buildable )
		{
			foreach (piece in stub.a_piecestubs)
			{
				piecespawn = piece.piecespawn;
				if ( isDefined( piecespawn ) )
				{
					player player_take_piece( piecespawn );
				}
			}

			return;
		}
	}
}

buildcraftable( buildable )
{
	player = get_players()[ 0 ];
	foreach (stub in level.a_uts_craftables)
	{
		if ( stub.craftablestub.name == buildable )
		{
			foreach (piece in stub.craftablespawn.a_piecespawns)
			{
				piecespawn = get_craftable_piece( stub.craftablestub.name, piece.piecename );
				if ( isDefined( piecespawn ) )
				{
					player player_take_piece( piecespawn );
				}
			}
			return;
		}
	}
}

get_craftable_piece( str_craftable, str_piece )
{
	foreach (uts_craftable in level.a_uts_craftables)
	{
		if ( uts_craftable.craftablestub.name == str_craftable )
		{
			foreach (piecespawn in uts_craftable.craftablespawn.a_piecespawns)
			{
				if ( piecespawn.piecename == str_piece )
				{
					return piecespawn;
				}
			}
		}
	}
	return undefined;
}

player_take_piece( piecespawn )
{
	piecestub = piecespawn.piecestub;
	damage = piecespawn.damage;

	if ( isDefined( piecestub.onpickup ) )
	{
		piecespawn [[ piecestub.onpickup ]]( self );
	}

	if ( isDefined( piecestub.is_shared ) && piecestub.is_shared )
	{
		if ( isDefined( piecestub.client_field_id ) )
		{
			level setclientfield( piecestub.client_field_id, 1 );
		}
	}
	else
	{
		if ( isDefined( piecestub.client_field_state ) )
		{
			self setclientfieldtoplayer( "craftable", piecestub.client_field_state );
		}
	}

	piecespawn piece_unspawn();
	piecespawn notify( "pickup" );

	if ( isDefined( piecestub.is_shared ) && piecestub.is_shared )
	{
		piecespawn.in_shared_inventory = 1;
	}

	self adddstat( "buildables", piecespawn.craftablename, "pieces_pickedup", 1 );
}

piece_unspawn()
{
	if ( isDefined( self.model ) )
	{
		self.model delete();
	}
	self.model = undefined;
	if ( isDefined( self.unitrigger ) )
	{
		thread maps/mp/zombies/_zm_unitrigger::unregister_unitrigger( self.unitrigger );
	}
	self.unitrigger = undefined;
}

init_buildables()
{
	if ( isDefined( level.customMap ) && level.customMap == "tunnel" || isDefined( level.customMap ) && level.customMap == "diner" || isDefined( level.customMap ) && level.customMap == "power" || isDefined( level.customMap ) && level.customMap == "cornfield" || isDefined( level.customMap ) && level.customMap == "house" )
	{
		wait 1;
		buildbuildable( "dinerhatch", 1 );
		buildbuildable( "pap", 1 );
		buildbuildable( "turbine" );
		buildbuildable( "electric_trap" );
		buildbuildable( "riotshield_zm", 1 );
		removebuildable( "jetgun_zm" );
		removebuildable( "powerswitch" );
		removebuildable( "sq_common" );
		removebuildable( "busladder" );
		removebuildable( "bushatch" );
		removebuildable( "cattlecatcher" );
	}
	if ( level.script == "zm_prison" && isDefined( level.customMap ) && level.customMap != "vanilla" )
	{
		wait 2;
		buildcraftable( "quest_key1" );
		buildcraftable( "alcatraz_shield_zm" );
		if ( isDefined( level.customMap ) && level.customMap == "cellblock" )
		{
			buildcraftable( "packasplat" );
			buildcraftable( "plane" );
		}
		else if ( isDefined ( level.customMap ) && level.customMap == "docks" )
		{
			buildcraftable( "plane" );
		}
		else if ( isDefined ( level.customMap ) && level.customMap == "rooftop" )
		{
			level thread build_plane_later();
			level thread prison_auto_refuel_plane();
		}
		changecraftableoption( 0 );
	}
}

buildbuildable( buildable, craft ) //credit to Jbleezy for this function
{
	if ( !isDefined( craft ) )
	{
		craft = 0;
	}

	player = get_players()[ 0 ];
	foreach ( stub in level.buildable_stubs )
	{
		if ( !isDefined( buildable ) || stub.equipname == buildable )
		{
			if ( isDefined( buildable ) || stub.persistent != 3 )
			{
				if (craft)
				{
					stub maps/mp/zombies/_zm_buildables::buildablestub_finish_build( player );
					stub maps/mp/zombies/_zm_buildables::buildablestub_remove();
					stub.model notsolid();
					stub.model show();
				}

				i = 0;
				foreach ( piece in stub.buildablezone.pieces )
				{
					piece maps/mp/zombies/_zm_buildables::piece_unspawn();
					if ( !craft && i > 0 )
					{
						stub.buildablezone maps/mp/zombies/_zm_buildables::buildable_set_piece_built( piece );
					}
					i++;
				}
				return;
			}
		}
	}
}

removebuildable( buildable, after_built )
{
	if (!isDefined(after_built))
	{
		after_built = 0;
	}

	if (after_built)
	{
		foreach (stub in level._unitriggers.trigger_stubs)
		{
			if(IsDefined(stub.equipname) && stub.equipname == buildable)
			{
				stub.model hide();
				maps/mp/zombies/_zm_unitrigger::unregister_unitrigger( stub );
				return;
			}
		}
	}
	else
	{
		foreach (stub in level.buildable_stubs)
		{
			if ( !isDefined( buildable ) || stub.equipname == buildable )
			{
				if ( isDefined( buildable ) || stub.persistent != 3 )
				{
					stub maps/mp/zombies/_zm_buildables::buildablestub_remove();
					foreach (piece in stub.buildablezone.pieces)
					{
						piece maps/mp/zombies/_zm_buildables::piece_unspawn();
					}
					maps/mp/zombies/_zm_unitrigger::unregister_unitrigger( stub );
					return;
				}
			}
		}
	}
}

get_equipname() //credit to Jbleezy for this function
{
	if ( self.equipname == "turbine" )
	{
		return "Turbine";
	}
	else if ( self.equipname == "electric_trap" )
	{
		return "Electric Trap";
	}
	else if ( self.equipname == "riotshield_zm" )
	{
		return "Zombie Shield";
	}
}

get_player_perk_purchase_limit()
{
	if ( isDefined( self.player_perk_purchase_limit ) )
	{
		return self.player_perk_purchase_limit;
	}
	return level.perk_purchase_limit;
}

increment_player_perk_purchase_limit()
{
	perks = getPerks();
	if ( !isDefined( self.player_perk_purchase_limit ) )
	{
		self.player_perk_purchase_limit = level.perk_purchase_limit;
	}
	if ( self.player_perk_purchase_limit < perks.size )
	{
		self.player_perk_purchase_limit++;
	}
}

gscRestart()
{
	level waittill( "end_game" );
	setDvar( "customMapsMapRestarted", 1 );
	wait 10;
	map_restart( false );
}

setPlayersToSpectator()
{
	level.no_end_game_check = 1;
	wait 3;
	players = get_players();
	i = 0;
	while ( i < players.size )
	{
		if ( i == 0 )
		{
			i++;
		}
		players[ i ] setToSpectator();
		i++;
	}
	wait 5;
	level.no_end_game_check = 0;
	spawnAllPlayers();
}

setToSpectator()
{
    self.sessionstate = "spectator"; 
    if (isDefined(self.is_playing))
    {
        self.is_playing = false;
    }
}

spawnAllPlayers()
{
	players = get_players();
	i = 0;
	while ( i < players.size )
	{
		if ( players[ i ].sessionstate == "spectator" && isDefined( players[ i ].spectator_respawn ) )
		{
			players[ i ] [[ level.spawnplayer ]]();
			if ( level.script != "zm_tomb" || level.script != "zm_prison" || !is_classic() )
			{
				thread maps\mp\zombies\_zm::refresh_player_navcard_hud();
			}
		}
		i++;
	}
	level.no_end_game_check = 0;
}

emptyLobbyRestart()
{
	while ( 1 )
	{
		players = get_players();
		if (players.size > 0 )
		{
			while ( 1 )
			{
				players = get_players();
				if ( players.size < 1  )
				{
					map_restart( false );
				}
				wait 60;
			}
		}
		wait 1;
	}
}


prison_auto_refuel_plane()
{
	level endon ( "end_game" );
	for ( ;; )
	{
		flag_wait( "spawn_fuel_tanks" );
		wait 0.05;
		buildcraftable( "refuelable_plane" );
	}
}

build_plane_later()
{
	level endon ( "end_game" );
	level endon ( "plane_built" );
	
	level.planeBuiltOnRound = getDvarIntDefault( "planeBuiltOnRound", 10 );
	level.zombie_vars[ "planeBuiltOnRound" ] = level.planeBuiltOnRound;
	
	for ( ;; )
	{
		level waittill ( "start_of_round" );
		if ( level.round_number >= level.planeBuiltOnRound )
		{
			buildcraftable( "plane" );
			level notify ( "plane_built" );
		}
		wait 0.5;
	}
}

setupWunderfizz()
{
	level.wunderfizzCost = getDvarIntDefault("wunderfizzCost", 1500);
	if(level.script == "zm_tomb")
    {
    	level._effect[ "wunderfizz_loop" ] = loadfx( "maps/zombie_tomb/fx_tomb_dieselmagic_on" );
    	//thread wunderfizz((2468,4459,-316), (0,180,0), "p6_zm_vending_diesel_magic");
    }
    if ( isDefined ( level.customMap ) && level.customMap == "house" )
	{
		thread wunderfizz((4782,5998,-64),(0,111,0), "zombie_vending_jugg");
    }
    else if ( isDefined ( level.customMap ) && level.customMap == "rooftop" )
	{
		thread wunderfizz((3215.64,9568.38,1528),(0,90,0), "p6_zm_al_vending_jugg_on");
    }
}

getPerks()
{
	perks = [];
	//Order is Rainbow
	if(isDefined(level.zombiemode_using_juggernaut_perk) && level.zombiemode_using_juggernaut_perk)
	{
		perks[perks.size] = "specialty_armorvest";
	}
	if(isDefined(level._custom_perks[ "specialty_nomotionsensor"] ))
	{
		perks[perks.size] = "specialty_nomotionsensor";
	}
	if ( isDefined( level.zombiemode_using_doubletap_perk ) && level.zombiemode_using_doubletap_perk )
	{
		perks[perks.size] = "specialty_rof";
	}
	if ( isDefined( level.zombiemode_using_marathon_perk ) && level.zombiemode_using_marathon_perk )
	{
		perks[perks.size] = "specialty_longersprint";
	}
	if ( isDefined( level.zombiemode_using_sleightofhand_perk ) && level.zombiemode_using_sleightofhand_perk )
	{
		perks[perks.size] = "specialty_fastreload";
	}
	if(isDefined(level.zombiemode_using_additionalprimaryweapon_perk) && level.zombiemode_using_additionalprimaryweapon_perk)
	{
		perks[perks.size] = "specialty_additionalprimaryweapon";
	}
	if ( isDefined( level.zombiemode_using_revive_perk ) && level.zombiemode_using_revive_perk )
	{
		perks[perks.size] = "specialty_quickrevive";
	}
	if ( isDefined( level.zombiemode_using_chugabud_perk ) && level.zombiemode_using_chugabud_perk )
	{
		perks[perks.size] = "specialty_finalstand";
	}
	if ( isDefined( level._custom_perks[ "specialty_grenadepulldeath" ] ))
	{
		perks[perks.size] = "specialty_grenadepulldeath";
	}
	if ( isDefined( level._custom_perks[ "specialty_flakjacket" ]) && level.script != "zm_buried" )
	{
		perks[perks.size] = "specialty_flakjacket";
	}
	if ( isDefined( level.zombiemode_using_deadshot_perk ) && level.zombiemode_using_deadshot_perk )
	{
		perks[perks.size] = "specialty_deadshot";
	}
	if ( isDefined( level.zombiemode_using_tombstone_perk ) && level.zombiemode_using_tombstone_perk )
	{
		perks[perks.size] = "specialty_scavenger";
	}
	return perks;
}

getPerkName(perk)
{
	if(perk == "specialty_armorvest")
		return "Juggernog";
	if(perk == "specialty_rof")
		return "Double Tap";
	if(perk == "specialty_longersprint")
		return "Stamin-Up";
	if(perk == "specialty_fastreload")
		return "Speed Cola";
	if(perk == "specialty_additionalprimaryweapon")
		return "Mule Kick";
	if(perk == "specialty_quickrevive")
		return "Quick Revive";
	if(perk == "specialty_finalstand")
		return "Who's Who";
	if(perk == "specialty_grenadepulldeath")
		return "Electric Cherry";
	if(perk == "specialty_flakjacket")
		return "PHD Flopper";
	if(perk == "specialty_deadshot")
		return "Deadshot Daiquiri";
	if(perk == "specialty_scavenger")
		return "Tombstone";
	if(perk == "specialty_nomotionsensor")
		return "Vulture Aid";
}

getPerkModel(perk)
{
	if(perk == "specialty_armorvest")
	{
		if( level.script == "zm_prison" )
			return "p6_zm_al_vending_jugg_on";
		else
			return "zombie_vending_jugg";
	}
	if(perk == "specialty_nomotionsensor")
		return "p6_zm_vending_vultureaid";
	if(perk == "specialty_rof")
	{
		if(level.script == "zm_prison")
			return "p6_zm_al_vending_doubletap2_on";
		else
			return "zombie_vending_doubletap2";
	}
	if(perk == "specialty_longersprint")
		return "zombie_vending_marathon";
	if(perk == "specialty_fastreload")
	{
		if( level.script == "zm_prison" )
			return "p6_zm_al_vending_sleight_on";
		else
			return "zombie_vending_sleight";
	}
	if(perk == "specialty_quickrevive")
		if(level.script == "zm_prison")
			return "p6_zm_vending_electric_cherry_on";
		else
			return "zombie_vending_revive";
	if(perk == "specialty_scavenger")
		return "zombie_vending_tombstone";
	if(perk == "specialty_finalstand")
		return "p6_zm_vending_chugabud";
	if(perk == "specialty_grenadepulldeath")
		return "p6_zm_vending_electric_cherry_on";
	if(perk == "specialty_additionalprimaryweapon")
		if(level.script == "zm_prison")
			return "p6_zm_al_vending_three_gun_on";
		else
			return "zombie_vending_three_gun";
	if(perk == "specialty_deadshot")
	{
		if(level.script == "zm_prison")
			return "p6_zm_al_vending_ads_on";
		else
			return "zombie_vending_ads";
	}
	if(perk == "specialty_flakjacket")
	{
		if(level.script == "zm_prison")
			return "p6_zm_al_vending_nuke_on";
		else
			return "zombie_vending_ads";
	}
}
getPerkBottleModel(perk)
{
	if(perk == "specialty_armorvest")
		return "t6_wpn_zmb_perk_bottle_jugg_world";
	if(perk == "specialty_rof")
		return "t6_wpn_zmb_perk_bottle_doubletap_world";
	if(perk == "specialty_longersprint")
		return "t6_wpn_zmb_perk_bottle_marathon_world";
	if(perk == "specialty_nomotionsensor")
		return "t6_wpn_zmb_perk_bottle_vultureaid_world";
	if(perk == "specialty_fastreload")
		return "t6_wpn_zmb_perk_bottle_sleight_world";
	if(perk == "specialty_flakjacket")
		return "t6_wpn_zmb_perk_bottle_nuke_world";
	if(perk == "specialty_quickrevive")
		return "t6_wpn_zmb_perk_bottle_revive_world";
	if(perk == "specialty_scavenger")
		return "t6_wpn_zmb_perk_bottle_tombstone_world";
	if(perk == "specialty_finalstand")
		return "t6_wpn_zmb_perk_bottle_chugabud_world";
	if(perk == "specialty_grenadepulldeath")
		return "t6_wpn_zmb_perk_bottle_cherry_world";
	if(perk == "specialty_additionalprimaryweapon")
		return "t6_wpn_zmb_perk_bottle_mule_kick_world";
	if(perk == "specialty_deadshot")
		return "t6_wpn_zmb_perk_bottle_deadshot_world";
}

wunderfizz(origin, angles, model)
{
	collision = spawn("script_model", origin);
    collision setModel("collision_geo_cylinder_32x128_standard");
    collision rotateTo(angles, .1);
	wunderfizzMachine = spawn("script_model", origin);
	wunderfizzMachine setModel(model);
	wunderfizzMachine rotateTo(angles, .1);
	wunderfizzBottle = spawn("script_model", origin);
	wunderfizzBottle setModel("tag_origin");
	wunderfizzBottle.angles = angles;
	wunderfizzBottle.origin += vectorScale( ( 0, 0, 1 ), 55 );
	wunderfizzMachine.bottle = wunderfizzBottle;
	perks = getPerks();
	cost = level.wunderfizzCost;
	trig = spawn("trigger_radius", origin, 1, 50, 50);
	trig SetCursorHint("HINT_NOICON");
	trig SetHintString("Hold ^3&&1^7 to buy Perk-a-Cola [Cost: " + cost + "]");
	if(level.script == "zm_tomb")
		wunderfizzMachine thread wunderfizzSounds();
	for(;;)
	{
		trig waittill("trigger", player);
		if(player UseButtonPressed() && player.score >= cost && player.isDrinkingPerk == 0)
		{
			if(player.num_perks < level.perk_purchase_limit)
			{
				if(player.num_perks < perks.size)
				{
					player playsound("zmb_cha_ching");
					player.score -= cost;
					trig setHintString(" ");
					rtime = 3;
					wunderfx = SpawnFX(level._effect["wunderfizz_loop"], wunderfizzMachine.origin,AnglesToForward(angles),AnglesToUp(angles));
					TriggerFX(wunderfx);
					level notify("wunderSpinStart");
					wunderfizzMachine thread perk_bottle_motion();
					wait .1;
					while(rtime>0)
					{
						for(;;)
						{
							perkForRandom = perks[randomInt(perks.size)];
							if(!(player hasPerk(perkForRandom)))
							{
								if(level.script == "zm_tomb")
								{
									wunderfizzMachine.bottle setModel(getPerkBottleModel(perkForRandom));
									break;
								}
								else
								{
									wunderfizzMachine setModel(getPerkModel(perkForRandom));
									break;
								}
							}
						}
						if(level.script == "zm_tomb")
						{
							TriggerFX(wunderfx);
							wait .2;
							rtime -= .2;
						}
						else
						{
							wait .1;
							rtime -= .1;
						}
					}
					wunderfizzMachine notify( "done_cycling" );
					perklist = array_randomize(perks);
					for(j=0;j<perklist.size;j++)
					{
						if(!(player hasPerk(perklist[j])))
						{
							perkName = getPerkName(perklist[j]);
							if(level.script == "zm_tomb")
							{
								wunderfizzMachine.bottle setModel(getPerkBottleModel(perklist[j]));

							}
							else
							{
								if(level.script == "zm_prison")
								{
									wunderfizzMachine setModel(getPerkModel(perklist[j]));
									fx = SpawnFX(level._effect["electriccherry"], origin, AnglesToForward(angles),AnglesToUp(angles));
								}
								else
								{
									wunderfizzMachine setModel(getPerkModel(perklist[j]) + "_on");
									fx = SpawnFX(level._effect["tombstone_light"], origin, AnglesToForward(angles),AnglesToUp(angles));
								}
								TriggerFX(fx);
							}
							trig SetHintString("Hold ^3&&1^7 for " + perkName);
							time = 7;
							while(time > 0)
							{
								if(player UseButtonPressed() && distance(player.origin, trig.origin) < 65)
								{
									player thread givePerk(perklist[j]);
									break;
								}
								TriggerFX(wunderfx);
								wait .2;
								time -= .2;
							}
							wunderfizzMachine setModel(model);
							wunderfizzMachine.bottle setModel("tag_origin");
							trig SetHintString(" ");
							level notify("wunderSpinStop");
							fx Delete();
							break;
						}
					}
					wunderfx Delete();
					wait 2;
					trig SetHintString("Hold ^3&&1^7 to buy Perk-a-Cola [Cost: " + cost + "]");
				}
				else
				{
					trig SetHintString("You Have All " + perks.size + " Perks");
					wait 2;
					trig SetHintString("Hold ^3&&1^7 to buy Perk-a-Cola [Cost: " + cost + "]");
				}
			}
			else{
				trig SetHintString("You Can Only Hold " + level.perk_purchase_limit + " Perks");
				wait 2;
				trig SetHintString("Hold ^3&&1^7 to buy Perk-a-Cola [Cost: " + cost + "]");
			}
		}
		wait .1;
	}
}
perk_bottle_motion()
{
	putouttime = 3;
	putbacktime = 10;
	v_float = anglesToForward( self.angles - ( 0, 90, 0 ) ) * 10;
	self.bottle.origin = self.origin + ( 0, 0, 53 );
	self.bottle.angles = self.angles;
	self.bottle.origin -= v_float;
	self.bottle moveto( self.bottle.origin + v_float, putouttime, putouttime * 0.5 );
	self.bottle.angles += ( 0, 0, 10 );
	self.bottle rotateyaw( 720, putouttime, putouttime * 0.5 );
	self waittill( "done_cycling" );
	self.bottle.angles = self.angles;
	self.bottle moveto( self.bottle.origin - v_float, putbacktime, putbacktime * 0.5 );
	self.bottle rotateyaw( 90, putbacktime, putbacktime * 0.5 );
}

wunderfizzSounds()
{
	while(1)
	{
		level waittill("wunderSpinStart");
		sound_ent = spawn("script_origin", self.origin);
		sound_ent StopSounds();
		sound_ent PlaySound( "zmb_rand_perk_start");
		sound_ent PlayLoopSound("zmb_rand_perk_loop", 0.5);
		level waittill("wunderSpinStop");
		sound_ent StopLoopSound(1);
		sound_ent PlaySound("zmb_rand_perk_stop");
		sound_ent Delete();

	}
}

givePerk(perk)
{
	if(!(self hasPerk(perk) || (self maps/mp/zombies/_zm_perks::has_perk_paused(perk))))
	{
		self.isDrinkingPerk = 1;
		gun = self maps/mp/zombies/_zm_perks::perk_give_bottle_begin(perk);
        evt = self waittill_any_return("fake_death", "death", "player_downed", "weapon_change_complete");
        if (evt == "weapon_change_complete")
        self thread maps/mp/zombies/_zm_perks::wait_give_perk(perk, 1);
       	self maps/mp/zombies/_zm_perks::perk_give_bottle_end(gun, perk);
       	self.isDrinkingPerk = 0;
    	if (self maps/mp/zombies/_zm_laststand::player_is_in_laststand() || isDefined(self.intermission) && self.intermission)
        	return;
    	self notify("burp");
	}
}

turn_on_power_origins()
{
	level waittill( "connected", player );
	maps/mp/zombies/_zm_game_module::turn_power_on_and_open_doors();
	wait 1;
	flag_set( "power_on" );
	level setclientfield( "zombie_power_on", 1 );
	if ( isDefined ( level.customMap ) && level.customMap != "trenches" )
	{
		level notify( "sleight_on" );
		wait_network_frame();
	}
	level notify( "sleight_on" );
	wait_network_frame();
	level notify( "doubletap_on" );
	wait_network_frame();
	if ( isDefined ( level.customMap ) && level.customMap != "excavation" )
	{
		level notify( "juggernog_on" );
		wait_network_frame();
		level notify( "marathon_on" );
		wait_network_frame();
	}
	level notify( "electric_cherry_on" );
	wait_network_frame();
	level notify( "deadshot_on" );
	wait_network_frame();
	level notify( "divetonuke_on" );
	wait_network_frame();
	level notify( "additionalprimaryweapon_on" );
	wait_network_frame();
	level notify( "Pack_A_Punch_on" );
	wait_network_frame();
	t_pap = getent( "specialty_weapupgrade", "script_noteworthy" );
	t_pap trigger_on();
	flag_set( "power_on" );
	level setclientfield( "zone_capture_hud_all_generators_captured", 1 );
	if ( !flag( "generator_lost_to_recapture_zombies" ) )
	{
		level notify( "all_zones_captured_none_lost" );
	}
}

createText(font, fontscale, align, relative, x, y, sort, text)
{
	textElem = CreateFontString( font, fontscale );
	textElem setPoint( align, relative, x, y );
	textElem.sort = sort;
	textElem.hideWhenInMenu = true;

	textElem.type = "text";
	addTextTableEntry(textElem, getStringId(text));
	textElem setSafeText(self, text);

	return textElem;
}


initOverFlowFix()
{
	self.stringTable = [];
	self.stringTableEntryCount = 0;
	self.textTable = [];
	self.textTableEntryCount = 0;

	if(isDefined(level.anchorText) == false)
	{
		level.anchorText = createServerFontString("default",1.5);
		level.anchorText setText("anchor");
		level.anchorText.alpha = 0;

	level.stringCount = 0;
	}
}

clearStrings()
{
	level.anchorText clearAllTextAfterHudElem();
	level.stringCount = 0;

	foreach(player in level.players)
	{
		player purgeTextTable();
		player purgeStringTable();
		player recreateText();
		player.resetPerkHUD = 1;
	}
}

setSafeText(player, text)
{
	stringId = player getStringId(text);

	if(stringId == -1)
	{
		player addStringTableEntry(text);
		stringId = player getStringId(text);
	}
	else
	{
		player editTextTableEntry(self.textTableIndex, stringId);
	}


	if(level.stringCount > 150)
	clearStrings();

	self setText(text);
}

recreateText()
{
	foreach(entry in self.textTable)
		entry.element setSafeText(self, lookUpStringById(entry.stringId));
}

addStringTableEntry(string)
{
	entry = spawnStruct();
	entry.id = self.stringTableEntryCount;
	entry.string = string;

	self.stringTable[self.stringTable.size] = entry;
	self.stringTableEntryCount++;
	level.stringCount++;
}

lookUpStringById(id)
{
	string = "";

	foreach(entry in self.stringTable)
	{
		if(entry.id == id)
		{
			string = entry.string;
			break;
		}
	}

	return string;
}

getStringId(string)
{
	id = -1;

	foreach(entry in self.stringTable)
	{
		if(entry.string == string)
		{
			id = entry.id;
			break;
		}
	}

	return id;
}

getStringTableEntry(id)
{
	stringTableEntry = -1;

	foreach(entry in self.stringTable)
	{
		if(entry.id == id)
		{
			stringTableEntry = entry;
			break;
		}
	}
	return stringTableEntry;
}

purgeStringTable()
{
	stringTable = [];
	foreach(entry in self.stringTable)
	{
		stringTable[stringTable.size] = getStringTableEntry(entry.stringId);
	}

	self.stringTable = stringTable;
}

purgeTextTable()
{
	textTable = [];

	foreach(entry in self.textTable)
	{
		if(entry.id != -1)
			textTable[textTable.size] = entry;
	}

	self.textTable = textTable;
}

addTextTableEntry(element, stringId)
{
	entry = spawnStruct();
	entry.id = self.textTableEntryCount;
	entry.element = element;
	entry.stringId = stringId;

	element.textTableIndex = entry.id;

	self.textTable[self.textTable.size] = entry;
	self.textTableEntryCount++;
}

editTextTableEntry(id, stringId)
{
	foreach(entry in self.textTable)
	{
		if(entry.id == id)
		{
			entry.stringId = stringId;
			break;
		}
	}
}

deleteTextTableEntry(id)
{
	foreach(entry in self.textTable)
	{
		if(entry.id == id)
		{
			entry.id = -1;
			entry.stringId = -1;
		}
	}
}

clear(player)
{
	if(self.type == "text")
		player deleteTextTableEntry(self.textTableIndex);

	self destroy();
}

insta_kill_rounds_tracker()
{
	level.postInstaKillRounds = 0;
	while ( 1 )
	{
		level waittill( "start_of_round" );
		level.speed_change_round = undefined;
		if ( level.round_number >= 31 )
		{
			health = calculate_insta_kill_rounds();
			level.postInstaKillRounds++;
		}
		if ( !isDefined( health ) )
		{
			if ( level.zombie_health > 5500000 )
			{
				health = 5500000;
			}
		}
		if ( isDefined( health ) )
		{
			level.zombie_health = health;
		}
		if ( is_true( level.roundIsInstaKill ) )
		{
			players = get_players();
			for ( i = 0; i < players.size; i++ )
			{
				players[ i ] iprintln( "All zombies are insta kill this round" );
			}
		}
	}
}

calculate_insta_kill_rounds()
{
	level.roundIsInstaKill = 0;
	if ( level.round_number >= 163 )
	{
		return undefined;
	}
	health = level.zombie_vars[ "zombie_health_start" ];
	for ( i = 2; i <= ( level.postInstaKillRounds + 163 ); i++ )
	{
		if ( i >= 10 )
		{
			health += int( health * level.zombie_vars[ "zombie_health_increase_multiplier" ] );
		}
		else
		{
			health = int( health + level.zombie_vars[ "zombie_health_increase" ] );
		}
	}
	if ( health < 0 )
	{
		level.roundIsInstaKill = 1;
		return 20;
	}
	return undefined;
}

actor_damage_override( inflictor, attacker, damage, flags, meansofdeath, weapon, vpoint, vdir, shitloc, psoffsettime, boneindex ) //checked changed to match cerberus output //checked against bo3 _zm.gsc partially changed to match
{
	if ( !isDefined( self ) || !isDefined( attacker ) )
	{
		return damage;
	}
	if ( weapon == "tazer_knuckles_zm" || weapon == "jetgun_zm" )
	{
		self.knuckles_extinguish_flames = 1;
	}
	else if ( weapon != "none" )
	{
		self.knuckles_extinguish_flames = undefined;
	}
	if ( isDefined( attacker.animname ) && attacker.animname == "quad_zombie" )
	{
		if ( isDefined( self.animname ) && self.animname == "quad_zombie" )
		{
			return 0;
		}
	}
	if ( !isplayer( attacker ) && isDefined( self.non_attacker_func ) )
	{
		if ( isDefined( self.non_attack_func_takes_attacker ) && self.non_attack_func_takes_attacker )
		{
			return self [[ self.non_attacker_func ]]( damage, weapon, attacker );
		}
		else
		{
			return self [[ self.non_attacker_func ]]( damage, weapon );
		}
	}
	if ( !isplayer( attacker ) && !isplayer( self ) )
	{
		return damage;
	}
	if ( !isDefined( damage ) || !isDefined( meansofdeath ) )
	{
		return damage;
	}
	if ( meansofdeath == "" )
	{
		return damage;
	}
	old_damage = damage;
	final_damage = damage;
	if ( isDefined( self.actor_damage_func ) )
	{
		final_damage = [[ self.actor_damage_func ]]( inflictor, attacker, damage, flags, meansofdeath, weapon, vpoint, vdir, shitloc, psoffsettime, boneindex );
	}
	if ( attacker.classname == "script_vehicle" && isDefined( attacker.owner ) )
	{
		attacker = attacker.owner;
	}
	if ( isDefined( self.in_water ) && self.in_water )
	{
		if ( int( final_damage ) >= self.health )
		{
			self.water_damage = 1;
		}
	}
	attacker thread maps/mp/gametypes_zm/_weapons::checkhit( weapon );
	if ( attacker maps/mp/zombies/_zm_pers_upgrades_functions::pers_mulit_kill_headshot_active() && is_headshot( weapon, shitloc, meansofdeath ) )
	{
		final_damage *= 2;
	}
	if ( is_true( level.headshots_only ) && isDefined( attacker ) && isplayer( attacker ) )
	{
		//changed to match bo3 _zm.gsc behavior
		if ( meansofdeath == "MOD_MELEE" && shitloc == "head" || meansofdeath == "MOD_MELEE" && shitloc == "helmet" )
		{
			return int( final_damage );
		}
		if ( is_explosive_damage( meansofdeath ) )
		{
			return int( final_damage );
		}
		else if ( !is_headshot( weapon, shitloc, meansofdeath ) )
		{
			return 0;
		}
	}
	if ( self.animname != "brutus_zombie" )
	{
		if ( weapon == "minigun_alcatraz_zm" )
		{
			final_damage = ( self.health * 0.24 ) + 666;
		}
		else if ( weapon == "minigun_alcatraz_upgraded_zm" )
		{
			final_damage = ( self.health * 0.29 ) + 666;
		}
		if ( is_true( level.zombiemode_using_deadshot_perk ) && isDefined( attacker ) && isPlayer( attacker ) && attacker hasPerk( "specialty_deadshot" ) && is_headshot( weapon, shitloc, meansofdeath ) )
		{
			final_damage *= 2;
		}
	}
	else if ( self.animname == "brutus_zombie" )
	{
		final_damage /= 3;
	}
	return int( final_damage );
}

actor_damage_override_wrapper( inflictor, attacker, damage, flags, meansofdeath, weapon, vpoint, vdir, shitloc, psoffsettime, boneindex ) //checked does not match cerberus output did not change
{
	damage_override = self actor_damage_override( inflictor, attacker, damage, flags, meansofdeath, weapon, vpoint, vdir, shitloc, psoffsettime, boneindex );
	if ( ( self.health - damage_override ) > 0 || !is_true( self.dont_die_on_me ) )
	{
		self finishactordamage( inflictor, attacker, damage_override, flags, meansofdeath, weapon, vpoint, vdir, shitloc, psoffsettime, boneindex );
	}
	else 
	{
		self [[ level.callbackactorkilled ]]( inflictor, attacker, damage, meansofdeath, weapon, vdir, shitloc, psoffsettime );
		self finishactordamage( inflictor, attacker, damage_override, flags, meansofdeath, weapon, vpoint, vdir, shitloc, psoffsettime, boneindex );
	}
}

getMapString(map) //custom function
{
	if(map == "tunnel")
		return "Tunnel";
	if(map == "diner")
		return "Diner";
	if(map == "power")
		return "Power Station";
	if(map == "house")
		return "Cabin";
	if(map == "cornfield")
		return "Cornfield";
	if(map == "docks")
		return "Docks";
	if(map == "cellblock")
		return "Cellblock";
	if(map == "rooftop")
		return "Rooftop/Bridge";
	if(map == "trenches")
		return "Trenches";
	if(map == "excavation")
		return "No Man's Land";
	if(map == "tank")
		return "Tank/Church";
	if(map == "crazyplace")
		return "Crazy Place";
	if(map == "vanilla")
		return "Vanilla";
}

override_map()
{
	wait 3;
	if ( level.script == "zm_transit" )
	{
		if ( isDefined ( level.customMap ) && level.customMap != "tunnel" && level.customMap != "diner" && level.customMap != "power" && level.customMap != "cornfield" && level.customMap != "house" && level.customMap != "vanilla" )
		{
			setDvar( "customMap", "house" );
			setDvar( "customMapRotation", "house power cornfield diner tunnel" );
			setDvar( "customMapRotationActive", 1 );
			map_restart( false );
		}
	}
	if ( level.script == "zm_prison" )
	{
		if ( isDefined ( level.customMap ) && level.customMap != "docks" && level.customMap != "cellblock" && level.customMap != "rooftop" && level.customMap != "vanilla" )
		{
			setDvar( "customMap", "docks" );
			setDvar( "customMapRotation", "docks cellblock rooftop" );
			setDvar( "customMapRotationActive", 1 );
			map_restart( false );
		}
	}
	else if ( level.script == "zm_tomb" )
	{
		if ( isDefined ( level.customMap ) && level.customMap != "trenches" && level.customMap != "excavation" && level.customMap != "tank" && level.customMap != "crazyplace" && level.customMap != "vanilla" )
		{
			setDvar( "customMap", "crazyplace" );
			setDvar( "customMapRotation", "trenches excavation tank crazyplace" );
			setDvar( "customMapRotationActive", 1 );
			map_restart( false );
		}
	}
	return;
}

map_rotation() //custom function
{
	level waittill( "end_game");
	wait 2;
	level.randomizeMapRotation = getDvarIntDefault( "randomizeMapRotation", 0 );
	level.customMapRotationActive = getDvarIntDefault( "customMapRotationActive", 0 );
	level.customMapRotation = getDvar( "customMapRotation" );
	level.mapList = strTok( level.customMapRotation, " " );
	if ( !level.customMapRotationActive )
	{
		return;
	}
	if ( !isDefined( level.customMapRotation ) || level.customMapRotation == "" )
	{
		if ( level.script == "zm_transit" )
		{
			level.customMapRotation = "cornfield diner house power tunnel";
		}
		else if ( level.script == "zm_prison" )
		{
			level.customMapRotation = "docks cellblock rooftop";
		}
	}
	if ( level.randomizeMapRotation && level.mapList.size > 3 )
	{
		level thread random_map_rotation();
		return;
	}
	if( isDefined( level.mapList[ 1 ] ) && level.customMap == level.mapList[ 0 ] )
	{
		setDvar( "customMap", level.mapList[ 1 ] );
	}
	else if( isDefined( level.mapList[ 2 ] ) && level.customMap == level.mapList[ 1 ] )
	{
		setDvar( "customMap", level.mapList[ 2 ] );
	}
	else if( isDefined( level.mapList[ 3 ] ) && level.customMap == level.mapList[ 2 ] )
	{
		setDvar( "customMap", level.mapList[ 3 ] );
	}
	else if( isDefined( level.mapList[ 4 ] ) && level.customMap == level.mapList[ 3 ] )
	{
		setDvar( "customMap", level.mapList[ 4 ] );
	}
	else
	{
		setDvar( "customMap", level.mapList[ 0 ] );
	}
	return;
}

random_map_rotation() //custom function
{
	level.nextMap = RandomInt( level.mapList.size );
	level.lastMap = getDvar( "lastMap" );
	if( level.customMap == level.mapList[ level.nextMap ] || level.mapList[ level.nextMap ] == level.lastMap )
	{
		return random_map_rotation();
	}
	else
	{
		setDvar( "lastMap", level.customMap );
		setDvar( "customMap", level.mapList[ level.nextMap ] );
		return;
	}
}

init_spawnpoints_for_custom_survival_maps() //custom function
{
	level.mapRestarted = getDvarIntDefault( "customMapsMapRestarted", 0 );
	level.customMap = getDvar( "customMap" ); //valid inputs "tunnel", "diner", "power", "house", "cornfield", "docks", "cellblock", "rooftop"
	level.serverName = getDvar( "serverName" );
	if ( !isDefined( level.serverName ) || level.serverName == "" )
	{
		level.OGName = getDvar( "sv_hostname" );
		setDvar( "serverName", level.OGName );
		level.serverName = getDvar( "serverName" );
	}
	map = level.customMap;
	setDvar( "sv_hostname", "" + level.serverName +" ^6| ^7Current Map: ^6" + getMapString(map) );
	if ( level.script == "zm_transit" )
	{
		//TUNNEL
		level.tunnelSpawnpoints = [];
		level.tunnelSpawnpoints[ 0 ] = spawnstruct();
		level.tunnelSpawnpoints[ 0 ].origin = ( -11196, -837, 192 );
		level.tunnelSpawnpoints[ 0 ].angles = ( 0, -94, 0 );
		level.tunnelSpawnpoints[ 0 ].radius = 32;
		level.tunnelSpawnpoints[ 0 ].script_noteworthy = "initial_spawn";
		level.tunnelSpawnpoints[ 0 ].script_int = 2048;
		
		level.tunnelSpawnpoints[ 1 ] = spawnstruct();
		level.tunnelSpawnpoints[ 1 ].origin = ( -11386, -863, 192 );
		level.tunnelSpawnpoints[ 1 ].angles = ( 0, -44, 0 );
		level.tunnelSpawnpoints[ 1 ].radius = 32;
		level.tunnelSpawnpoints[ 1 ].script_noteworthy = "initial_spawn";
		level.tunnelSpawnpoints[ 1 ].script_int = 2048;
		
		level.tunnelSpawnpoints[ 2 ] = spawnstruct();
		level.tunnelSpawnpoints[ 2 ].origin = ( -11405, -1000, 192 );
		level.tunnelSpawnpoints[ 2 ].angles = ( 0, -32, 0 );
		level.tunnelSpawnpoints[ 2 ].radius = 32;
		level.tunnelSpawnpoints[ 2 ].script_noteworthy = "initial_spawn";
		level.tunnelSpawnpoints[ 2 ].script_int = 2048;
		
		level.tunnelSpawnpoints[ 3 ] = spawnstruct();
		level.tunnelSpawnpoints[ 3 ].origin = ( -11498, -1151, 192 );
		level.tunnelSpawnpoints[ 3 ].angles = ( 0, 4, 0 );
		level.tunnelSpawnpoints[ 3 ].radius = 32;
		level.tunnelSpawnpoints[ 3 ].script_noteworthy = "initial_spawn";
		level.tunnelSpawnpoints[ 3 ].script_int = 2048;
		
		level.tunnelSpawnpoints[ 4 ] = spawnstruct();
		level.tunnelSpawnpoints[ 4 ].origin = ( -11398, -1326, 191 );
		level.tunnelSpawnpoints[ 4 ].angles = ( 0, 50, 0 );
		level.tunnelSpawnpoints[ 4 ].radius = 32;
		level.tunnelSpawnpoints[ 4 ].script_noteworthy = "initial_spawn";
		level.tunnelSpawnpoints[ 4 ].script_int = 2048;
		
		level.tunnelSpawnpoints[ 5 ] = spawnstruct();
		level.tunnelSpawnpoints[ 5 ].origin = ( -11222, -1345, 192 );
		level.tunnelSpawnpoints[ 5 ].angles = ( 0, 89, 0 );
		level.tunnelSpawnpoints[ 5 ].radius = 32;
		level.tunnelSpawnpoints[ 5 ].script_noteworthy = "initial_spawn";
		level.tunnelSpawnpoints[ 5 ].script_int = 2048;
		
		level.tunnelSpawnpoints[ 6 ] = spawnstruct();
		level.tunnelSpawnpoints[ 6 ].origin = ( -10934, -1380, 192 );
		level.tunnelSpawnpoints[ 6 ].angles = ( 0, 157, 0 );
		level.tunnelSpawnpoints[ 6 ].radius = 32;
		level.tunnelSpawnpoints[ 6 ].script_noteworthy = "initial_spawn";
		level.tunnelSpawnpoints[ 6 ].script_int = 2048;
		
		level.tunnelSpawnpoints[ 7 ] = spawnstruct();
		level.tunnelSpawnpoints[ 7 ].origin = ( -10999, -1072, 192 );
		level.tunnelSpawnpoints[ 7 ].angles = ( 0, -144, 0 );
		level.tunnelSpawnpoints[ 7 ].radius = 32;
		level.tunnelSpawnpoints[ 7 ].script_noteworthy = "initial_spawn";
		level.tunnelSpawnpoints[ 7 ].script_int = 2048;
		
		//DINER
		level.dinerSpawnpoints = [];									 
		level.dinerSpawnpoints[ 0 ] = spawnstruct();
		level.dinerSpawnpoints[ 0 ].origin = ( -3991, -7317, -63 );
		level.dinerSpawnpoints[ 0 ].angles = ( 0, 161, 0 );
		level.dinerSpawnpoints[ 0 ].radius = 32;
		level.dinerSpawnpoints[ 0 ].script_noteworthy = "initial_spawn";
		level.dinerSpawnpoints[ 0 ].script_int = 2048;
		
		level.dinerSpawnpoints[ 1 ] = spawnstruct();
		level.dinerSpawnpoints[ 1 ].origin = ( -4231, -7395, -60 );
		level.dinerSpawnpoints[ 1 ].angles = ( 0, 120, 0 );
		level.dinerSpawnpoints[ 1 ].radius = 32;
		level.dinerSpawnpoints[ 1 ].script_noteworthy = "initial_spawn";
		level.dinerSpawnpoints[ 1 ].script_int = 2048;
		
		level.dinerSpawnpoints[ 2 ] = spawnstruct();
		level.dinerSpawnpoints[ 2 ].origin = ( -4127, -6757, -54 );
		level.dinerSpawnpoints[ 2 ].angles = ( 0, 217, 0 );
		level.dinerSpawnpoints[ 2 ].radius = 32;
		level.dinerSpawnpoints[ 2 ].script_noteworthy = "initial_spawn";
		level.dinerSpawnpoints[ 2 ].script_int = 2048;
		
		level.dinerSpawnpoints[ 3 ] = spawnstruct();
		level.dinerSpawnpoints[ 3 ].origin = ( -4465, -7346, -58 );
		level.dinerSpawnpoints[ 3 ].angles = ( 0, 173, 0 );
		level.dinerSpawnpoints[ 3 ].radius = 32;
		level.dinerSpawnpoints[ 3 ].script_noteworthy = "initial_spawn";
		level.dinerSpawnpoints[ 3 ].script_int = 2048;
		
		level.dinerSpawnpoints[ 4 ] = spawnstruct();
		level.dinerSpawnpoints[ 4 ].origin = ( -5770, -6600, -55 );
		level.dinerSpawnpoints[ 4 ].angles = ( 0, -106, 0 );
		level.dinerSpawnpoints[ 4 ].radius = 32;
		level.dinerSpawnpoints[ 4 ].script_noteworthy = "initial_spawn";
		level.dinerSpawnpoints[ 4 ].script_int = 2048;
		
		level.dinerSpawnpoints[ 5 ] = spawnstruct();
		level.dinerSpawnpoints[ 5 ].origin = ( -6135, -6671, -56 );
		level.dinerSpawnpoints[ 5 ].angles = ( 0, -46, 0 );
		level.dinerSpawnpoints[ 5 ].radius = 32;
		level.dinerSpawnpoints[ 5 ].script_noteworthy = "initial_spawn";
		level.dinerSpawnpoints[ 5 ].script_int = 2048;
		
		level.dinerSpawnpoints[ 6 ] = spawnstruct();
		level.dinerSpawnpoints[ 6 ].origin = ( -6182, -7120, -60 );
		level.dinerSpawnpoints[ 6 ].angles = ( 0, 51, 0 );
		level.dinerSpawnpoints[ 6 ].radius = 32;
		level.dinerSpawnpoints[ 6 ].script_noteworthy = "initial_spawn";
		level.dinerSpawnpoints[ 6 ].script_int = 2048;
		
		level.dinerSpawnpoints[ 7 ] = spawnstruct();
		level.dinerSpawnpoints[ 7 ].origin = ( -5882, -7174, -61 );
		level.dinerSpawnpoints[ 7 ].angles = ( 0, 99, 0 );
		level.dinerSpawnpoints[ 7 ].radius = 32;
		level.dinerSpawnpoints[ 7 ].script_noteworthy = "initial_spawn";
		level.dinerSpawnpoints[ 7 ].script_int = 2048;
		
		//CORNFIELD
		level.cornfieldSpawnpoints = [];
		level.cornfieldSpawnpoints[ 0 ] = spawnstruct();
		level.cornfieldSpawnpoints[ 0 ].origin = ( 7521, -545, -198 );
		level.cornfieldSpawnpoints[ 0 ].angles = ( 0, 40, 0 );
		level.cornfieldSpawnpoints[ 0 ].radius = 32;
		level.cornfieldSpawnpoints[ 0 ].script_noteworthy = "initial_spawn";
		level.cornfieldSpawnpoints[ 0 ].script_int = 2048;
		
		level.cornfieldSpawnpoints[ 1 ] = spawnstruct();
		level.cornfieldSpawnpoints[ 1 ].origin = ( 7751, -522, -202 );
		level.cornfieldSpawnpoints[ 1 ].angles = ( 0, 145, 0 );
		level.cornfieldSpawnpoints[ 1 ].radius = 32;
		level.cornfieldSpawnpoints[ 1 ].script_noteworthy = "initial_spawn";
		level.cornfieldSpawnpoints[ 1 ].script_int = 2048;
		
		level.cornfieldSpawnpoints[ 2 ] = spawnstruct();
		level.cornfieldSpawnpoints[ 2 ].origin = ( 7691, -395, -201 );
		level.cornfieldSpawnpoints[ 2 ].angles = ( 0, -131, 0 );
		level.cornfieldSpawnpoints[ 2 ].radius = 32;
		level.cornfieldSpawnpoints[ 2 ].script_noteworthy = "initial_spawn";
		level.cornfieldSpawnpoints[ 2 ].script_int = 2048;
		
		level.cornfieldSpawnpoints[ 3 ] = spawnstruct();
		level.cornfieldSpawnpoints[ 3 ].origin = ( 7536, -432, -199 );
		level.cornfieldSpawnpoints[ 3 ].angles = ( 0, -24, 0 );
		level.cornfieldSpawnpoints[ 3 ].radius = 32;
		level.cornfieldSpawnpoints[ 3 ].script_noteworthy = "initial_spawn";
		level.cornfieldSpawnpoints[ 3 ].script_int = 2048;
		
		level.cornfieldSpawnpoints[ 4 ] = spawnstruct();
		level.cornfieldSpawnpoints[ 4 ].origin = ( 13745, -336, -188 );
		level.cornfieldSpawnpoints[ 4 ].angles = ( 0, -178, 0 );
		level.cornfieldSpawnpoints[ 4 ].radius = 32;
		level.cornfieldSpawnpoints[ 4 ].script_noteworthy = "initial_spawn";
		level.cornfieldSpawnpoints[ 4 ].script_int = 2048;
		
		level.cornfieldSpawnpoints[ 5 ] = spawnstruct();
		level.cornfieldSpawnpoints[ 5 ].origin = ( 13758, -681, -188 );
		level.cornfieldSpawnpoints[ 5 ].angles = ( 0, -179, 0 );
		level.cornfieldSpawnpoints[ 5 ].radius = 32;
		level.cornfieldSpawnpoints[ 5 ].script_noteworthy = "initial_spawn";
		level.cornfieldSpawnpoints[ 5 ].script_int = 2048;
		
		level.cornfieldSpawnpoints[ 6 ] = spawnstruct();
		level.cornfieldSpawnpoints[ 6 ].origin = ( 13816, -1088, -189 );
		level.cornfieldSpawnpoints[ 6 ].angles = ( 0, -177, 0 );
		level.cornfieldSpawnpoints[ 6 ].radius = 32;
		level.cornfieldSpawnpoints[ 6 ].script_noteworthy = "initial_spawn";
		level.cornfieldSpawnpoints[ 6 ].script_int = 2048;
		
		level.cornfieldSpawnpoints[ 7 ] = spawnstruct();
		level.cornfieldSpawnpoints[ 7 ].origin = ( 13752, -1444, -182 );
		level.cornfieldSpawnpoints[ 7 ].angles = ( 0, -177, 0 ); 
		level.cornfieldSpawnpoints[ 7 ].radius = 32;
		level.cornfieldSpawnpoints[ 7 ].script_noteworthy = "initial_spawn";
		level.cornfieldSpawnpoints[ 7 ].script_int = 2048;
		
		//POWER STATION
		level.powerStationSpawnpoints = [];
		level.powerStationSpawnpoints[ 0 ] = spawnstruct();
		level.powerStationSpawnpoints[ 0 ].origin = ( 11288, 7988, -550 );
		level.powerStationSpawnpoints[ 0 ].angles = ( 0, -137, 0 );
		level.powerStationSpawnpoints[ 0 ].radius = 32;
		level.powerStationSpawnpoints[ 0 ].script_noteworthy = "initial_spawn";
		level.powerStationSpawnpoints[ 0 ].script_int = 2048;
		
		level.powerStationSpawnpoints[ 1 ] = spawnstruct();
		level.powerStationSpawnpoints[ 1 ].origin = ( 11284, 7760, -549 );
		level.powerStationSpawnpoints[ 1 ].angles = ( 0, 177, 0 );
		level.powerStationSpawnpoints[ 1 ].radius = 32;
		level.powerStationSpawnpoints[ 1 ].script_noteworthy = "initial_spawn";
		level.powerStationSpawnpoints[ 1 ].script_int = 2048;
		
		level.powerStationSpawnpoints[ 2 ] = spawnstruct();
		level.powerStationSpawnpoints[ 2 ].origin = ( 10784, 7623, -584 );
		level.powerStationSpawnpoints[ 2 ].angles = ( 0, -10, 0 );
		level.powerStationSpawnpoints[ 2 ].radius = 32;
		level.powerStationSpawnpoints[ 2 ].script_noteworthy = "initial_spawn";
		level.powerStationSpawnpoints[ 2 ].script_int = 2048;
		
		level.powerStationSpawnpoints[ 3 ] = spawnstruct();
		level.powerStationSpawnpoints[ 3 ].origin = ( 10866, 7473, -580 );
		level.powerStationSpawnpoints[ 3 ].angles = ( 0, 21, 0 );
		level.powerStationSpawnpoints[ 3 ].radius = 32;
		level.powerStationSpawnpoints[ 3 ].script_noteworthy = "initial_spawn";
		level.powerStationSpawnpoints[ 3 ].script_int = 2048;
		
		level.powerStationSpawnpoints[ 4 ] = spawnstruct();
		level.powerStationSpawnpoints[ 4 ].origin = ( 10261, 8146, -580 );
		level.powerStationSpawnpoints[ 4 ].angles = ( 0, -31, 0 );
		level.powerStationSpawnpoints[ 4 ].radius = 32;
		level.powerStationSpawnpoints[ 4 ].script_noteworthy = "initial_spawn";
		level.powerStationSpawnpoints[ 4 ].script_int = 2048;
		
		level.powerStationSpawnpoints[ 5 ] = spawnstruct();
		level.powerStationSpawnpoints[ 5 ].origin = ( 10595, 8055, -541 );
		level.powerStationSpawnpoints[ 5 ].angles = ( 0, -43, 0 );
		level.powerStationSpawnpoints[ 5 ].radius = 32;
		level.powerStationSpawnpoints[ 5 ].script_noteworthy = "initial_spawn";
		level.powerStationSpawnpoints[ 5 ].script_int = 2048;
		
		level.powerStationSpawnpoints[ 6 ] = spawnstruct();
		level.powerStationSpawnpoints[ 6 ].origin = ( 10477, 7679, -567 );
		level.powerStationSpawnpoints[ 6 ].angles = ( 0, -9, 0 );
		level.powerStationSpawnpoints[ 6 ].radius = 32;
		level.powerStationSpawnpoints[ 6 ].script_noteworthy = "initial_spawn";
		level.powerStationSpawnpoints[ 6 ].script_int = 2048;
		
		level.powerStationSpawnpoints[ 7 ] = spawnstruct();
		level.powerStationSpawnpoints[ 7 ].origin = ( 10165, 7879, -570 );
		level.powerStationSpawnpoints[ 7 ].angles = ( 0, -15, 0 );
		level.powerStationSpawnpoints[ 7 ].radius = 32;
		level.powerStationSpawnpoints[ 7 ].script_noteworthy = "initial_spawn";
		level.powerStationSpawnpoints[ 7 ].script_int = 2048;
		
		level.houseSpawnpoints = [];
		level.houseSpawnpoints[ 0 ] = spawnstruct();
		level.houseSpawnpoints[ 0 ].origin = ( 5071, 7022, -20 );
		level.houseSpawnpoints[ 0 ].angles = ( 0, 315, 0 );
		level.houseSpawnpoints[ 0 ].radius = 32;
		level.houseSpawnpoints[ 0 ].script_noteworthy = "initial_spawn";
		level.houseSpawnpoints[ 0 ].script_int = 2048;
		
		level.houseSpawnpoints[ 1 ] = spawnstruct();
		level.houseSpawnpoints[ 1 ].origin = ( 5358, 7034, -20 );
		level.houseSpawnpoints[ 1 ].angles = ( 0, 246, 0 );
		level.houseSpawnpoints[ 1 ].radius = 32;
		level.houseSpawnpoints[ 1 ].script_noteworthy = "initial_spawn";
		level.houseSpawnpoints[ 1 ].script_int = 2048;
		
		level.houseSpawnpoints[ 2 ] = spawnstruct();
		level.houseSpawnpoints[ 2 ].origin = ( 5078, 6733, -20 );
		level.houseSpawnpoints[ 2 ].angles = ( 0, 56, 0 );
		level.houseSpawnpoints[ 2 ].radius = 32;
		level.houseSpawnpoints[ 2 ].script_noteworthy = "initial_spawn";
		level.houseSpawnpoints[ 2 ].script_int = 2048;
		
		level.houseSpawnpoints[ 3 ] = spawnstruct();
		level.houseSpawnpoints[ 3 ].origin = ( 5334, 6723, -20 );
		level.houseSpawnpoints[ 3 ].angles = ( 0, 123, 0 );
		level.houseSpawnpoints[ 3 ].radius = 32;
		level.houseSpawnpoints[ 3 ].script_noteworthy = "initial_spawn";
		level.houseSpawnpoints[ 3 ].script_int = 2048;
		
		level.houseSpawnpoints[ 4 ] = spawnstruct();
		level.houseSpawnpoints[ 4 ].origin = ( 5057, 6583, -10 );
		level.houseSpawnpoints[ 4 ].angles = ( 0, 0, 0 );
		level.houseSpawnpoints[ 4 ].radius = 32;
		level.houseSpawnpoints[ 4 ].script_noteworthy = "initial_spawn";
		level.houseSpawnpoints[ 4 ].script_int = 2048;
		
		level.houseSpawnpoints[ 5 ] = spawnstruct();
		level.houseSpawnpoints[ 5 ].origin = ( 5305, 6591, -20 );
		level.houseSpawnpoints[ 5 ].angles = ( 0, 180, 0 );
		level.houseSpawnpoints[ 5 ].radius = 32;
		level.houseSpawnpoints[ 5 ].script_noteworthy = "initial_spawn";
		level.houseSpawnpoints[ 5 ].script_int = 2048;
		
		level.houseSpawnpoints[ 6 ] = spawnstruct();
		level.houseSpawnpoints[ 6 ].origin = ( 5350, 6882, -20 );
		level.houseSpawnpoints[ 6 ].angles = ( 0, 180, 0 );
		level.houseSpawnpoints[ 6 ].radius = 32;
		level.houseSpawnpoints[ 6 ].script_noteworthy = "initial_spawn";
		level.houseSpawnpoints[ 6 ].script_int = 2048;
		
		level.houseSpawnpoints[ 7 ] = spawnstruct();
		level.houseSpawnpoints[ 7 ].origin = ( 5102, 6851, -20 );
		level.houseSpawnpoints[ 7 ].angles = ( 0, 0, 0 );
		level.houseSpawnpoints[ 7 ].radius = 32;
		level.houseSpawnpoints[ 7 ].script_noteworthy = "initial_spawn";
		level.houseSpawnpoints[ 7 ].script_int = 2048;
	}
	if ( level.script == "zm_prison" )
	{
		level.docksSpawnpoints = [];
		level.docksSpawnpoints[ 0 ] = spawnstruct();
		level.docksSpawnpoints[ 0 ].origin = ( -335, 5512, -71 );
		level.docksSpawnpoints[ 0 ].angles = ( 0, -169, 0 );
		level.docksSpawnpoints[ 0 ].radius = 32;
		level.docksSpawnpoints[ 0 ].script_noteworthy = "initial_spawn";
		level.docksSpawnpoints[ 0 ].script_int = 2048;
		
		level.docksSpawnpoints[ 1 ] = spawnstruct();
		level.docksSpawnpoints[ 1 ].origin = ( -589, 5452, -71 );
		level.docksSpawnpoints[ 1 ].angles = ( 0, -78, 0 );
		level.docksSpawnpoints[ 1 ].radius = 32;
		level.docksSpawnpoints[ 1 ].script_noteworthy = "initial_spawn";
		level.docksSpawnpoints[ 1 ].script_int = 2048;
		
		level.docksSpawnpoints[ 2 ] = spawnstruct();
		level.docksSpawnpoints[ 2 ].origin = ( -1094, 5426, -71 );
		level.docksSpawnpoints[ 2 ].angles = ( 0, 170, 0 );
		level.docksSpawnpoints[ 2 ].radius = 32;
		level.docksSpawnpoints[ 2 ].script_noteworthy = "initial_spawn";
		level.docksSpawnpoints[ 2 ].script_int = 2048;
		
		level.docksSpawnpoints[ 3 ] = spawnstruct();
		level.docksSpawnpoints[ 3 ].origin = ( -1200, 5882, -71 );
		level.docksSpawnpoints[ 3 ].angles = ( 0, -107, 0 );
		level.docksSpawnpoints[ 3 ].radius = 32;
		level.docksSpawnpoints[ 3 ].script_noteworthy = "initial_spawn";
		level.docksSpawnpoints[ 3 ].script_int = 2048;
		
		level.docksSpawnpoints[ 4 ] = spawnstruct();
		level.docksSpawnpoints[ 4 ].origin = ( 669, 6785, 209 );
		level.docksSpawnpoints[ 4 ].angles = ( 0, -143, 0 );
		level.docksSpawnpoints[ 4 ].radius = 32;
		level.docksSpawnpoints[ 4 ].script_noteworthy = "initial_spawn";
		level.docksSpawnpoints[ 4 ].script_int = 2048;
		
		level.docksSpawnpoints[ 5 ] = spawnstruct();
		level.docksSpawnpoints[ 5 ].origin = ( 476, 6774, 196 );
		level.docksSpawnpoints[ 5 ].angles = ( 0, -90, 0 );
		level.docksSpawnpoints[ 5 ].radius = 32;
		level.docksSpawnpoints[ 5 ].script_noteworthy = "initial_spawn";
		level.docksSpawnpoints[ 5 ].script_int = 2048;
		
		level.docksSpawnpoints[ 6 ] = spawnstruct();
		level.docksSpawnpoints[ 6 ].origin = ( 699, 6562, 208 );
		level.docksSpawnpoints[ 6 ].angles = ( 0, 159, 0 );
		level.docksSpawnpoints[ 6 ].radius = 32;
		level.docksSpawnpoints[ 6 ].script_noteworthy = "initial_spawn";
		level.docksSpawnpoints[ 6 ].script_int = 2048;
		
		level.docksSpawnpoints[ 7 ] = spawnstruct();
		level.docksSpawnpoints[ 7 ].origin = ( 344, 6472, 264 );
		level.docksSpawnpoints[ 7 ].angles = ( 0, 26, 0 );
		level.docksSpawnpoints[ 7 ].radius = 32;
		level.docksSpawnpoints[ 7 ].script_noteworthy = "initial_spawn";
		level.docksSpawnpoints[ 7 ].script_int = 2048;
		
		level.cellblockSpawnpoints = [];
		level.cellblockSpawnpoints[ 0 ] = spawnstruct();
		level.cellblockSpawnpoints[ 0 ].origin = ( 954, 10521, 1338 );
		level.cellblockSpawnpoints[ 0 ].angles = ( 0, 12, 0 );
		level.cellblockSpawnpoints[ 0 ].radius = 32;
		level.cellblockSpawnpoints[ 0 ].script_noteworthy = "initial_spawn";
		level.cellblockSpawnpoints[ 0 ].script_int = 2048;
		
		level.cellblockSpawnpoints[ 1 ] = spawnstruct();
		level.cellblockSpawnpoints[ 1 ].origin = ( 977, 10649, 1338 );
		level.cellblockSpawnpoints[ 1 ].angles = ( 0, 45, 0 );
		level.cellblockSpawnpoints[ 1 ].radius = 32;
		level.cellblockSpawnpoints[ 1 ].script_noteworthy = "initial_spawn";
		level.cellblockSpawnpoints[ 1 ].script_int = 2048;
		
		level.cellblockSpawnpoints[ 2 ] = spawnstruct();
		level.cellblockSpawnpoints[ 2 ].origin = ( 1118, 10498, 1338 );
		level.cellblockSpawnpoints[ 2 ].angles = ( 0, 90, 0 );
		level.cellblockSpawnpoints[ 2 ].radius = 32;
		level.cellblockSpawnpoints[ 2 ].script_noteworthy = "initial_spawn";
		level.cellblockSpawnpoints[ 2 ].script_int = 2048;
		
		level.cellblockSpawnpoints[ 3 ] = spawnstruct();
		level.cellblockSpawnpoints[ 3 ].origin = ( 1435, 10591, 1338 );
		level.cellblockSpawnpoints[ 3 ].angles = ( 0, 90, 0 );
		level.cellblockSpawnpoints[ 3 ].radius = 32;
		level.cellblockSpawnpoints[ 3 ].script_noteworthy = "initial_spawn";
		level.cellblockSpawnpoints[ 3 ].script_int = 2048;
		
		level.cellblockSpawnpoints[ 4 ] = spawnstruct();
		level.cellblockSpawnpoints[ 4 ].origin = ( 1917, 10376, 1338 );
		level.cellblockSpawnpoints[ 4 ].angles = ( 0, 69, 0 );
		level.cellblockSpawnpoints[ 4 ].radius = 32;
		level.cellblockSpawnpoints[ 4 ].script_noteworthy = "initial_spawn";
		level.cellblockSpawnpoints[ 4 ].script_int = 2048;
		
		level.cellblockSpawnpoints[ 5 ] = spawnstruct();
		level.cellblockSpawnpoints[ 5 ].origin = ( 2025, 10362, 1338 );
		level.cellblockSpawnpoints[ 5 ].angles = ( 0, 121, 0 );
		level.cellblockSpawnpoints[ 5 ].radius = 32;
		level.cellblockSpawnpoints[ 5 ].script_noteworthy = "initial_spawn";
		level.cellblockSpawnpoints[ 5 ].script_int = 2048;
		
		level.cellblockSpawnpoints[ 6 ] = spawnstruct();
		level.cellblockSpawnpoints[ 6 ].origin = ( 2090, 10426, 1338 );
		level.cellblockSpawnpoints[ 6 ].angles = ( 0, 121, 0 );
		level.cellblockSpawnpoints[ 6 ].radius = 32;
		level.cellblockSpawnpoints[ 6 ].script_noteworthy = "initial_spawn";
		level.cellblockSpawnpoints[ 6 ].script_int = 2048;
		
		level.cellblockSpawnpoints[ 7 ] = spawnstruct();
		level.cellblockSpawnpoints[ 7 ].origin = ( 1758, 10562, 1338 );
		level.cellblockSpawnpoints[ 7 ].angles = ( 0, 180, 0 );
		level.cellblockSpawnpoints[ 7 ].radius = 32;
		level.cellblockSpawnpoints[ 7 ].script_noteworthy = "initial_spawn";
		level.cellblockSpawnpoints[ 7 ].script_int = 2048;
		
		level.rooftopSpawnpoints = [];
		level.rooftopSpawnpoints[ 0 ] = spawnstruct();
		level.rooftopSpawnpoints[ 0 ].origin = ( 2708, 9596, 1714 );
		level.rooftopSpawnpoints[ 0 ].angles = ( 0, 328, 0 );
		level.rooftopSpawnpoints[ 0 ].radius = 32;
		level.rooftopSpawnpoints[ 0 ].script_noteworthy = "initial_spawn";
		level.rooftopSpawnpoints[ 0 ].script_int = 2048;
		
		level.rooftopSpawnpoints[ 1 ] = spawnstruct();
		level.rooftopSpawnpoints[ 1 ].origin = ( 2875, 9596, 1706 );
		level.rooftopSpawnpoints[ 1 ].angles = ( 0, 275, 0 );
		level.rooftopSpawnpoints[ 1 ].radius = 32;
		level.rooftopSpawnpoints[ 1 ].script_noteworthy = "initial_spawn";
		level.rooftopSpawnpoints[ 1 ].script_int = 2048;
		
		level.rooftopSpawnpoints[ 2 ] = spawnstruct();
		level.rooftopSpawnpoints[ 2 ].origin = ( 3125.5, 9461.5, 1706 );
		level.rooftopSpawnpoints[ 2 ].angles = ( 0, 70, 0 );
		level.rooftopSpawnpoints[ 2 ].radius = 32;
		level.rooftopSpawnpoints[ 2 ].script_noteworthy = "initial_spawn";
		level.rooftopSpawnpoints[ 2 ].script_int = 2048;
		
		level.rooftopSpawnpoints[ 3 ] = spawnstruct();
		level.rooftopSpawnpoints[ 3 ].origin = ( 3408, 9512.5, 1706 );
		level.rooftopSpawnpoints[ 3 ].angles = ( 0, 133, 0 );
		level.rooftopSpawnpoints[ 3 ].radius = 32;
		level.rooftopSpawnpoints[ 3 ].script_noteworthy = "initial_spawn";
		level.rooftopSpawnpoints[ 3 ].script_int = 2048;
		
		level.rooftopSpawnpoints[ 4 ] = spawnstruct();
		level.rooftopSpawnpoints[ 4 ].origin = ( 3421, 9803.5, 1706 );
		level.rooftopSpawnpoints[ 4 ].angles = ( 0, 229, 0 );
		level.rooftopSpawnpoints[ 4 ].radius = 32;
		level.rooftopSpawnpoints[ 4 ].script_noteworthy = "initial_spawn";
		level.rooftopSpawnpoints[ 4 ].script_int = 2048;
		
		level.rooftopSpawnpoints[ 5 ] = spawnstruct();
		level.rooftopSpawnpoints[ 5 ].origin = ( 3168, 9807, 1706 );
		level.rooftopSpawnpoints[ 5 ].angles = ( 0, 295, 0 );
		level.rooftopSpawnpoints[ 5 ].radius = 32;
		level.rooftopSpawnpoints[ 5 ].script_noteworthy = "initial_spawn";
		level.rooftopSpawnpoints[ 5 ].script_int = 2048;
		
		level.rooftopSpawnpoints[ 6 ] = spawnstruct();
		level.rooftopSpawnpoints[ 6 ].origin = ( 2900, 9731.5, 1706 );
		level.rooftopSpawnpoints[ 6 ].angles = ( 0, 68, 0 );
		level.rooftopSpawnpoints[ 6 ].radius = 32;
		level.rooftopSpawnpoints[ 6 ].script_noteworthy = "initial_spawn";
		level.rooftopSpawnpoints[ 6 ].script_int = 2048;
		
		level.rooftopSpawnpoints[ 7 ] = spawnstruct();
		level.rooftopSpawnpoints[ 7 ].origin = ( 2589, 9731.5, 1706 );
		level.rooftopSpawnpoints[ 7 ].angles = ( 0, 36, 0 );
		level.rooftopSpawnpoints[ 7 ].radius = 32;
		level.rooftopSpawnpoints[ 7 ].script_noteworthy = "initial_spawn";
		level.rooftopSpawnpoints[ 7 ].script_int = 2048;
	}
	if( level.script == "zm_tomb" )
	{
		level.trenchesSpawnpoints = [];
		level.trenchesSpawnpoints[ 0 ] = spawnstruct();
		level.trenchesSpawnpoints[ 0 ].origin = ( -1431, 3732, -314 );
		level.trenchesSpawnpoints[ 0 ].angles = ( 0, 333, 0 );
		level.trenchesSpawnpoints[ 0 ].radius = 32;
		level.trenchesSpawnpoints[ 0 ].script_noteworthy = "initial_spawn";
		level.trenchesSpawnpoints[ 0 ].script_int = 2048;
		
		level.trenchesSpawnpoints[ 1 ] = spawnstruct();
		level.trenchesSpawnpoints[ 1 ].origin = ( -509, 3697, -295 );
		level.trenchesSpawnpoints[ 1 ].angles = ( 0, 326, 0 );
		level.trenchesSpawnpoints[ 1 ].radius = 32;
		level.trenchesSpawnpoints[ 1 ].script_noteworthy = "initial_spawn";
		level.trenchesSpawnpoints[ 1 ].script_int = 2048;
		
		level.trenchesSpawnpoints[ 2 ] = spawnstruct();
		level.trenchesSpawnpoints[ 2 ].origin = ( 738, 3485, -293 );
		level.trenchesSpawnpoints[ 2 ].angles = ( 0, 127, 0 );
		level.trenchesSpawnpoints[ 2 ].radius = 32;
		level.trenchesSpawnpoints[ 2 ].script_noteworthy = "initial_spawn";
		level.trenchesSpawnpoints[ 2 ].script_int = 2048;
		
		level.trenchesSpawnpoints[ 3 ] = spawnstruct();
		level.trenchesSpawnpoints[ 3 ].origin = ( 1523, 3955, -322 );
		level.trenchesSpawnpoints[ 3 ].angles = ( 0, 91, 0 );
		level.trenchesSpawnpoints[ 3 ].radius = 32;
		level.trenchesSpawnpoints[ 3 ].script_noteworthy = "initial_spawn";
		level.trenchesSpawnpoints[ 3 ].script_int = 2048;
		
		level.trenchesSpawnpoints[ 4 ] = spawnstruct();
		level.trenchesSpawnpoints[ 4 ].origin = ( 1902, 4024, -361 );
		level.trenchesSpawnpoints[ 4 ].angles = ( 0, 227, 0 );
		level.trenchesSpawnpoints[ 4 ].radius = 32;
		level.trenchesSpawnpoints[ 4 ].script_noteworthy = "initial_spawn";
		level.trenchesSpawnpoints[ 4 ].script_int = 2048;
		
		level.trenchesSpawnpoints[ 5 ] = spawnstruct();
		level.trenchesSpawnpoints[ 5 ].origin = ( 280, 2147, -125 );
		level.trenchesSpawnpoints[ 5 ].angles = ( 0, 42, 0 );
		level.trenchesSpawnpoints[ 5 ].radius = 32;
		level.trenchesSpawnpoints[ 5 ].script_noteworthy = "initial_spawn";
		level.trenchesSpawnpoints[ 5 ].script_int = 2048;
		
		level.trenchesSpawnpoints[ 6 ] = spawnstruct();
		level.trenchesSpawnpoints[ 6 ].origin = ( -78, 2631, -263 );
		level.trenchesSpawnpoints[ 6 ].angles = ( 0, 4, 0 );
		level.trenchesSpawnpoints[ 6 ].radius = 32;
		level.trenchesSpawnpoints[ 6 ].script_noteworthy = "initial_spawn";
		level.trenchesSpawnpoints[ 6 ].script_int = 2048;
		
		level.trenchesSpawnpoints[ 7 ] = spawnstruct();
		level.trenchesSpawnpoints[ 7 ].origin = ( 2094, 2869, -281 );
		level.trenchesSpawnpoints[ 7 ].angles = ( 0, 178, 0 );
		level.trenchesSpawnpoints[ 7 ].radius = 32;
		level.trenchesSpawnpoints[ 7 ].script_noteworthy = "initial_spawn";
		level.trenchesSpawnpoints[ 7 ].script_int = 2048;

		level.excavationSpawnpoints = [];
		level.excavationSpawnpoints[ 0 ] = spawnstruct();
		level.excavationSpawnpoints[ 0 ].origin = ( 1392, 802, 104 );
		level.excavationSpawnpoints[ 0 ].angles = ( 0, 226, 0 );
		level.excavationSpawnpoints[ 0 ].radius = 32;
		level.excavationSpawnpoints[ 0 ].script_noteworthy = "initial_spawn";
		level.excavationSpawnpoints[ 0 ].script_int = 2048;
		
		level.excavationSpawnpoints[ 1 ] = spawnstruct();
		level.excavationSpawnpoints[ 1 ].origin = ( 480, 800, 83 );
		level.excavationSpawnpoints[ 1 ].angles = ( 0, 329, 0 );
		level.excavationSpawnpoints[ 1 ].radius = 32;
		level.excavationSpawnpoints[ 1 ].script_noteworthy = "initial_spawn";
		level.excavationSpawnpoints[ 1 ].script_int = 2048;
		
		level.excavationSpawnpoints[ 2 ] = spawnstruct();
		level.excavationSpawnpoints[ 2 ].origin = ( -778, 936, 133 );
		level.excavationSpawnpoints[ 2 ].angles = ( 0, 320, 0 );
		level.excavationSpawnpoints[ 2 ].radius = 32;
		level.excavationSpawnpoints[ 2 ].script_noteworthy = "initial_spawn";
		level.excavationSpawnpoints[ 2 ].script_int = 2048;
		
		level.excavationSpawnpoints[ 3 ] = spawnstruct();
		level.excavationSpawnpoints[ 3 ].origin = ( -1914, 512, 94 );
		level.excavationSpawnpoints[ 3 ].angles = ( 0, 11, 0 );
		level.excavationSpawnpoints[ 3 ].radius = 32;
		level.excavationSpawnpoints[ 3 ].script_noteworthy = "initial_spawn";
		level.excavationSpawnpoints[ 3 ].script_int = 2048;
		
		level.excavationSpawnpoints[ 4 ] = spawnstruct();
		level.excavationSpawnpoints[ 4 ].origin = ( -1763, -319, 114 );
		level.excavationSpawnpoints[ 4 ].angles = ( 0, 24, 0 );
		level.excavationSpawnpoints[ 4 ].radius = 32;
		level.excavationSpawnpoints[ 4 ].script_noteworthy = "initial_spawn";
		level.excavationSpawnpoints[ 4 ].script_int = 2048;
		
		level.excavationSpawnpoints[ 5 ] = spawnstruct();
		level.excavationSpawnpoints[ 5 ].origin = ( -907, -382, 100 );
		level.excavationSpawnpoints[ 5 ].angles = ( 0, 33, 0 );
		level.excavationSpawnpoints[ 5 ].radius = 32;
		level.excavationSpawnpoints[ 5 ].script_noteworthy = "initial_spawn";
		level.excavationSpawnpoints[ 5 ].script_int = 2048;
		
		level.excavationSpawnpoints[ 6 ] = spawnstruct();
		level.excavationSpawnpoints[ 6 ].origin = ( 742, -945, 66 );
		level.excavationSpawnpoints[ 6 ].angles = ( 0, 131, 0 );
		level.excavationSpawnpoints[ 6 ].radius = 32;
		level.excavationSpawnpoints[ 6 ].script_noteworthy = "initial_spawn";
		level.excavationSpawnpoints[ 6 ].script_int = 2048;
		
		level.excavationSpawnpoints[ 7 ] = spawnstruct();
		level.excavationSpawnpoints[ 7 ].origin = ( 1286, -266, 99 );
		level.excavationSpawnpoints[ 7 ].angles = ( 0, 147, 0 );
		level.excavationSpawnpoints[ 7 ].radius = 32;
		level.excavationSpawnpoints[ 7 ].script_noteworthy = "initial_spawn";
		level.excavationSpawnpoints[ 7 ].script_int = 2048;

		level.tankSpawnpoints = [];
		level.tankSpawnpoints[ 0 ] = spawnstruct();
		level.tankSpawnpoints[ 0 ].origin = ( 308, -2021, 247 );
		level.tankSpawnpoints[ 0 ].angles = ( 0, 129, 0 );
		level.tankSpawnpoints[ 0 ].radius = 32;
		level.tankSpawnpoints[ 0 ].script_noteworthy = "initial_spawn";
		level.tankSpawnpoints[ 0 ].script_int = 2048;
		
		level.tankSpawnpoints[ 1 ] = spawnstruct();
		level.tankSpawnpoints[ 1 ].origin = ( 1285, -2074, 168 );
		level.tankSpawnpoints[ 1 ].angles = ( 0, 198, 0 );
		level.tankSpawnpoints[ 1 ].radius = 32;
		level.tankSpawnpoints[ 1 ].script_noteworthy = "initial_spawn";
		level.tankSpawnpoints[ 1 ].script_int = 2048;
		
		level.tankSpawnpoints[ 2 ] = spawnstruct();
		level.tankSpawnpoints[ 2 ].origin = ( 1042, -2753, 51 );
		level.tankSpawnpoints[ 2 ].angles = ( 0, 142, 0 );
		level.tankSpawnpoints[ 2 ].radius = 32;
		level.tankSpawnpoints[ 2 ].script_noteworthy = "initial_spawn";
		level.tankSpawnpoints[ 2 ].script_int = 2048;
		
		level.tankSpawnpoints[ 3 ] = spawnstruct();
		level.tankSpawnpoints[ 3 ].origin = ( 250, -2928, 62 );
		level.tankSpawnpoints[ 3 ].angles = ( 0, 81, 0 );
		level.tankSpawnpoints[ 3 ].radius = 32;
		level.tankSpawnpoints[ 3 ].script_noteworthy = "initial_spawn";
		level.tankSpawnpoints[ 3 ].script_int = 2048;
		
		level.tankSpawnpoints[ 4 ] = spawnstruct();
		level.tankSpawnpoints[ 4 ].origin = ( 213, -2448, 52 );
		level.tankSpawnpoints[ 4 ].angles = ( 0, 259, 0 );
		level.tankSpawnpoints[ 4 ].radius = 32;
		level.tankSpawnpoints[ 4 ].script_noteworthy = "initial_spawn";
		level.tankSpawnpoints[ 4 ].script_int = 2048;
		
		level.tankSpawnpoints[ 5 ] = spawnstruct();
		level.tankSpawnpoints[ 5 ].origin = ( -319, -2363, 112 );
		level.tankSpawnpoints[ 5 ].angles = ( 0, 328, 0 );
		level.tankSpawnpoints[ 5 ].radius = 32;
		level.tankSpawnpoints[ 5 ].script_noteworthy = "initial_spawn";
		level.tankSpawnpoints[ 5 ].script_int = 2048;
		
		level.tankSpawnpoints[ 6 ] = spawnstruct();
		level.tankSpawnpoints[ 6 ].origin = ( 743, -2282, 51 );
		level.tankSpawnpoints[ 6 ].angles = ( 0, 350, 0 );
		level.tankSpawnpoints[ 6 ].radius = 32;
		level.tankSpawnpoints[ 6 ].script_noteworthy = "initial_spawn";
		level.tankSpawnpoints[ 6 ].script_int = 2048;
		
		level.tankSpawnpoints[ 7 ] = spawnstruct();
		level.tankSpawnpoints[ 7 ].origin = ( 633, -2023, 235 );
		level.tankSpawnpoints[ 7 ].angles = ( 0, 143, 0 );
		level.tankSpawnpoints[ 7 ].radius = 32;
		level.tankSpawnpoints[ 7 ].script_noteworthy = "initial_spawn";
		level.tankSpawnpoints[ 7 ].script_int = 2048;

		level.crazyplaceSpawnpoints = [];
		level.crazyplaceSpawnpoints[ 0 ] = spawnstruct();
		level.crazyplaceSpawnpoints[ 0 ].origin = ( 11164, -6942, -351 );
		level.crazyplaceSpawnpoints[ 0 ].angles = ( 0, 223, 0 );
		level.crazyplaceSpawnpoints[ 0 ].radius = 32;
		level.crazyplaceSpawnpoints[ 0 ].script_noteworthy = "initial_spawn";
		level.crazyplaceSpawnpoints[ 0 ].script_int = 2048;
		
		level.crazyplaceSpawnpoints[ 1 ] = spawnstruct();
		level.crazyplaceSpawnpoints[ 1 ].origin = ( 11301, -7129, -351 );
		level.crazyplaceSpawnpoints[ 1 ].angles = ( 0, 206, 0 );
		level.crazyplaceSpawnpoints[ 1 ].radius = 32;
		level.crazyplaceSpawnpoints[ 1 ].script_noteworthy = "initial_spawn";
		level.crazyplaceSpawnpoints[ 1 ].script_int = 2048;
		
		level.crazyplaceSpawnpoints[ 2 ] = spawnstruct();
		level.crazyplaceSpawnpoints[ 2 ].origin = ( 9531, -7056, -351 );
		level.crazyplaceSpawnpoints[ 2 ].angles = ( 0, 282, 0 );
		level.crazyplaceSpawnpoints[ 2 ].radius = 32;
		level.crazyplaceSpawnpoints[ 2 ].script_noteworthy = "initial_spawn";
		level.crazyplaceSpawnpoints[ 2 ].script_int = 2048;
		
		level.crazyplaceSpawnpoints[ 3 ] = spawnstruct();
		level.crazyplaceSpawnpoints[ 3 ].origin = ( 9683, -7028, -345 );
		level.crazyplaceSpawnpoints[ 3 ].angles = ( 0, 255, 0 );
		level.crazyplaceSpawnpoints[ 3 ].radius = 32;
		level.crazyplaceSpawnpoints[ 3 ].script_noteworthy = "initial_spawn";
		level.crazyplaceSpawnpoints[ 3 ].script_int = 2048;
		
		level.crazyplaceSpawnpoints[ 4 ] = spawnstruct();
		level.crazyplaceSpawnpoints[ 4 ].origin = ( 9469, -8501, -403 );
		level.crazyplaceSpawnpoints[ 4 ].angles = ( 0, 349, 0 );
		level.crazyplaceSpawnpoints[ 4 ].radius = 32;
		level.crazyplaceSpawnpoints[ 4 ].script_noteworthy = "initial_spawn";
		level.crazyplaceSpawnpoints[ 4 ].script_int = 2048;
		
		level.crazyplaceSpawnpoints[ 5 ] = spawnstruct();
		level.crazyplaceSpawnpoints[ 5 ].origin = ( 9480, -8635, -397 );
		level.crazyplaceSpawnpoints[ 5 ].angles = ( 0, 9, 0 );
		level.crazyplaceSpawnpoints[ 5 ].radius = 32;
		level.crazyplaceSpawnpoints[ 5 ].script_noteworthy = "initial_spawn";
		level.crazyplaceSpawnpoints[ 5 ].script_int = 2048;
		
		level.crazyplaceSpawnpoints[ 6 ] = spawnstruct();
		level.crazyplaceSpawnpoints[ 6 ].origin = ( 11198, -8728, -413 );
		level.crazyplaceSpawnpoints[ 6 ].angles = ( 0, 152, 0 );
		level.crazyplaceSpawnpoints[ 6 ].radius = 32;
		level.crazyplaceSpawnpoints[ 6 ].script_noteworthy = "initial_spawn";
		level.crazyplaceSpawnpoints[ 6 ].script_int = 2048;
		
		level.crazyplaceSpawnpoints[ 7 ] = spawnstruct();
		level.crazyplaceSpawnpoints[ 7 ].origin = ( 11318, -8613, -412 );
		level.crazyplaceSpawnpoints[ 7 ].angles = ( 0, 150, 0 );
		level.crazyplaceSpawnpoints[ 7 ].radius = 32;
		level.crazyplaceSpawnpoints[ 7 ].script_noteworthy = "initial_spawn";
		level.crazyplaceSpawnpoints[ 7 ].script_int = 2048;
	}
}

init_barriers_for_custom_maps() //custom function
{
	if(level.script == "zm_transit" && isDefined(level.customMap) && level.customMap != "vanilla")
	{
		//DINER CLIPS
		dinerclip1 = spawn("script_model", (-3952,-6957,-67));
		dinerclip1 setModel("collision_player_wall_256x256x10");
		dinerclip1 rotateTo((0,82,0), .1);

		dinerclip2 = spawn("script_model", (-4173,-6679,-60));
		dinerclip2 setModel("collision_player_wall_512x512x10");
		dinerclip2 rotateTo((0,0,0), .1);

		dinerclip3 = spawn("script_model", (-5073,-6732,-59));
		dinerclip3 setModel("collision_player_wall_512x512x10");
		dinerclip3 rotateTo((0,328,0), .1);

		dinerclip4 = spawn("script_model", (-6104,-6490,-38));
		dinerclip4 setModel("collision_player_wall_512x512x10");
		dinerclip4 rotateTo((0,2,0), .1);

		dinerclip5 = spawn("script_model", (-5850,-6486,-38));
		dinerclip5 setModel("collision_player_wall_256x256x10");
		dinerclip5 rotateTo((0,0,0), .1);

		dinerclip6 = spawn("script_model", (-5624,-6406,-40));
		dinerclip6 setModel("collision_player_wall_256x256x10");
		dinerclip6 rotateTo((0,226,0), .1);

		dinerclip7 = spawn("script_model", (-6348,-6886,-55));
		dinerclip7 setModel("collision_player_wall_512x512x10");
		dinerclip7 rotateTo((0,98,0), .1);

		//TUNNEL BARRIERS
		tunnelbarrier1 = spawn("script_model", (-11250,-520,255));
		tunnelbarrier1 setModel("veh_t6_civ_movingtrk_cab_dead");
		tunnelbarrier1 rotateTo((0,172,0),.1);
		tunnelclip1 = spawn("script_model", (-11250,-580,255));
		tunnelclip1 setModel("collision_player_wall_256x256x10");
		tunnelclip1 rotateTo((0,180,0), .1);
		tunnelclip2 = spawn("script_model", (-11506,-580,255));
		tunnelclip2 setModel("collision_player_wall_256x256x10");
		tunnelclip2 rotateTo((0,180,0), .1);

		tunnelbarrier4 = spawn("script_model", (-10770,-3240,255));
		tunnelbarrier4 setModel("veh_t6_civ_movingtrk_cab_dead");
		tunnelbarrier4 rotateTo((0,214,0),.1);
		tunnelclip3 = spawn("script_model", (-10840,-3190,255));
		tunnelclip3 setModel("collision_player_wall_256x256x10");
		tunnelclip3 rotateTo((0,214,0), .1);

		    //tunnelclip3 DisconnectPaths();

		//HOUSE BARRIERS
		housebarrier1 = spawn("script_model", (5568,6336,-70));
		housebarrier1 setModel("collision_player_wall_512x512x10");
		housebarrier1 rotateTo((0,266,0),.1);
		housebarrier1 ConnectPaths();

		housebarrier2 = spawn("script_model", (5074,7089,-24));
		housebarrier2 setModel("collision_player_wall_128x128x10");
		housebarrier2 rotateTo((0,0,0),.1);
		housebarrier2 ConnectPaths();

		housebarrier3 = spawn("script_model", (4985,5862,-64));
		housebarrier3 setModel("collision_player_wall_512x512x10");
		housebarrier3 rotateTo((0,159,0),.1);
		housebarrier3 ConnectPaths();

		housebarrier4 = spawn("script_model", (5207,5782,-64));
		housebarrier4 setModel("collision_player_wall_512x512x10");
		housebarrier4 rotateTo((0,159,0),.1);
		housebarrier4 ConnectPaths();

		housebarrier5 = spawn("script_model", (4819,6475,-64));
		housebarrier5 setModel("collision_player_wall_512x512x10");
		housebarrier5 rotateTo((0,258,0),.1);
		housebarrier5 ConnectPaths();

		housebarrier6 = spawn("script_model", (4767,6200,-64));
		housebarrier6 setModel("collision_player_wall_512x512x10");
		housebarrier6 rotateTo((0,258,0),.1);
		housebarrier6 ConnectPaths();

		housebarrier7 = spawn("script_model", (5459,5683,-64));
		housebarrier7 setModel("collision_player_wall_512x512x10");
		housebarrier7 rotateTo((0,159,0),.1);
		housebarrier7 ConnectPaths();
		
		housebush1 = spawn("script_model", (5548.5, 6358, -72));
		housebush1 setModel("t5_foliage_bush05");
		housebush1 rotateTo((0,271,0),.1);
		
		housebush2 = spawn("script_model", (5543.79, 6269.37, -64.75));
		housebush2 setModel("t5_foliage_bush05");
		housebush2 rotateTo((0,-45,0),.1);
		
		housebush3 = spawn("script_model", (5553.23, 6446, -76));
		housebush3 setModel("t5_foliage_bush05");
		housebush3 rotateTo((0,90,0),.1);
		
		housebush4 = spawn("script_model", (5534, 6190.8, -64));
		housebush4 setModel("t5_foliage_bush05");
		housebush4 rotateTo((0,180,0),.1);
		
		housebush5 = spawn("script_model", (5565.1, 5661, -64));
		housebush5 setModel("t5_foliage_bush05");
		housebush5 rotateTo((0,-45,0),.1);
		
		housebush6 = spawn("script_model", (5380.4, 5738, -64));
		housebush6 setModel("t5_foliage_bush05");
		housebush6 rotateTo((0,80,0),.1);
		
		housebush7 = spawn("script_model", (5467, 5702, -64));
		housebush7 setModel("t5_foliage_bush05");
		housebush7 rotateTo((0,40,0),.1);
		
		housebush8 = spawn("script_model", (5323.1, 5761.7, -64));
		housebush8 setModel("t5_foliage_bush05");
		housebush8 rotateTo((0,120,0),.1);
		
		housebush9 = spawn("script_model", (5261, 5787.5, -64));
		housebush9 setModel("t5_foliage_bush05");
		housebush9 rotateTo((0,150,0),.1);
		
		housebush10 = spawn("script_model", (5199, 5813.5, -64));
		housebush10 setModel("t5_foliage_bush05");
		housebush10 rotateTo((0,230,0),.1);
		
		housebush11 = spawn("script_model", (5137, 5839.5, -64)); //-62, +26
		housebush11 setModel("t5_foliage_bush05");
		housebush11 rotateTo((0,0,0),.1);
		
		housebush12 = spawn("script_model", (5075, 5865.5, -64));
		housebush12 setModel("t5_foliage_bush05");
		housebush12 rotateTo((0,70,0),.1);
		
		housebush13 = spawn("script_model", (5013, 5891.5, -64));
		housebush13 setModel("t5_foliage_bush05");
		housebush13 rotateTo((0,170,0),.1);
		
		housebush14 = spawn("script_model", (4951, 5917.5, -64));
		housebush14 setModel("t5_foliage_bush05");
		housebush14 rotateTo((0,0,0),.1);
		
		housebush15 = spawn("script_model", (4889, 5943.5, -64));
		housebush15 setModel("t5_foliage_bush05");
		housebush15 rotateTo((0,245,0),.1);
		
		housebush16 = spawn("script_model", (4810, 5926.5, -64));
		housebush16 setModel("t5_foliage_bush05");
		housebush16 rotateTo((0,53,0),.1);
		
		housebush17 = spawn("script_model", (4762, 6069, -64));
		housebush17 setModel("t5_foliage_bush05");
		housebush17 rotateTo((0,100,0),.1);
		
		housebush18 = spawn("script_model", (4777, 6149, -64)); //+15, +80
		housebush18 setModel("t5_foliage_bush05");
		housebush18 rotateTo((0,200,0),.1);
		
		housebush19 = spawn("script_model", (4792, 6229, -64));
		housebush19 setModel("t5_foliage_bush05");
		housebush19 rotateTo((0,100,0),.1);
		
		housebush20 = spawn("script_model", (4807, 6309, -64));
		housebush20 setModel("t5_foliage_bush05");
		housebush20 rotateTo((0,200,0),.1);
		
		housebush21 = spawn("script_model", (4822, 6389, -64));
		housebush21 setModel("t5_foliage_bush05");
		housebush21 rotateTo((0,100,0),.1);
		
		housebush22 = spawn("script_model", (4837, 6469, -64));
		housebush22 setModel("t5_foliage_bush05");
		housebush22 rotateTo((0,200,0),.1);
		
		housebush23 = spawn("script_model", (4852, 6549, -64));
		housebush23 setModel("t5_foliage_bush05");
		housebush23 rotateTo((0,100,0),.1);
		
		housebush24 = spawn("script_model", (4867, 6629, -64));
		housebush24 setModel("t5_foliage_bush05");
		housebush24 rotateTo((0,200,0),.1);
		
		housebush25 = spawn("script_model", (5557.4, 6524.5, -80));
		housebush25 setModel("t5_foliage_bush05");
		housebush25 rotateTo((0,200,0),.1);
		
		housebush26 = spawn("script_model", (5078.68, 7172.37, -64));
		housebush26 setModel("t5_foliage_bush05");
		housebush26 rotateTo((0,234,0),.1);
		
		housebush27 = spawn("script_model", (5017, 7130.22, -64));
		housebush27 setModel("t5_foliage_bush05");
		housebush27 rotateTo((0,45,0),.1);
		
		housebush28 = spawn("script_model", (5154.25, 7133.65, -64));
		housebush28 setModel("t5_foliage_bush05");
		housebush28 rotateTo((0,130,0),.1);
		
		housebush29 = spawn("script_model", (5105.25, 7166.65, -64));
		housebush29 setModel("t5_foliage_bush05");
		housebush29 rotateTo((0,292,0),.1);

		//POWER STATION BARRIERS
		powerbarrier1 = spawn("script_model", (9965,8133,-556));
		powerbarrier1 setModel("veh_t6_civ_60s_coupe_dead");
		powerbarrier1 rotateTo((15,5,0),.1);
		powerclip1 = spawn("script_model", (9955,8105,-575));
		powerclip1 setModel("collision_player_wall_256x256x10");
		powerclip1 rotateTo((0,0,0),.1);

		powerbarrier2 = spawn("script_model", (10056,8350,-584));
		powerbarrier2 setModel("veh_t6_civ_bus_zombie");
		powerbarrier2 rotateTo((0,340,0),.1);
		powerbarrier2 NotSolid();
		powerclip2 = spawn("script_model", (10267,8194,-556));
		powerclip2 setModel("collision_player_wall_256x256x10");
		powerclip2 rotateTo((0,340,0),.1);
		powerclip3 = spawn("script_model", (10409,8220,-181));
		powerclip3 setModel("collision_player_wall_512x512x10");
		powerclip3 rotateTo((0,250,0),.1);
		powerclip4 = spawn("script_model", (10409,8220,-556));
		powerclip4 setModel("collision_player_wall_128x128x10");
		powerclip4 rotateTo((0,250,0),.1);

		powerbarrier3 = spawn("script_model", (10281,7257,-575));
		powerbarrier3 setModel("veh_t6_civ_microbus_dead");
		powerbarrier3 rotateTo((0,13,0),.1);
		powerclip4 = spawn("script_model", (10268,7294,-569));
		powerclip4 setModel("collision_player_wall_256x256x10");
		powerclip4 rotateTo((0,13,0),.1);

		powerbarrier4 = spawn("script_model", (10100,7238,-575));
		powerbarrier4 setModel("veh_t6_civ_60s_coupe_dead");
		powerbarrier4 rotateTo((0,52,0),.1);
		powerclip5 = spawn("script_model", (10170,7292,-505));
		powerclip5 setModel("collision_player_wall_128x128x10");
		powerclip5 rotateTo((0,140,0),.1);
		powerclip6 = spawn("script_model", (10030,7216,-569));
		powerclip6 setModel("collision_player_wall_256x256x10");
		powerclip6 rotateTo((0,49,0),.1);

		powerclip7 = spawn("script_model", (10563,8630,-344));
		powerclip7 setModel("collision_player_wall_256x256x10");
		powerclip7 rotateTo((0,270,0),.1);

		//CORNFIELD BARRIERS
		cornfieldbarrier1 = spawn("script_model", (10190,135,-159));
		cornfieldbarrier1 setModel("veh_t6_civ_movingtrk_cab_dead");
		cornfieldbarrier1 rotateTo((0,172,0),.1);
		cornfieldclip1 = spawn("script_model", (10100,100,-159));
		cornfieldclip1 setModel("collision_player_wall_512x512x10");
		cornfieldclip1 rotateTo((0,172,0),.1);

		cornfieldbarrier2 = spawn("script_model", (10100,-1800,-217));
		cornfieldbarrier2 setModel("veh_t6_civ_bus_zombie");
		cornfieldbarrier2 rotateTo((0,126,0),.1);
		cornfieldbarrier2 NotSolid();
		cornfieldclip1 = spawn("script_model", (10045,-1607,-181));
		cornfieldclip1 setModel("collision_player_wall_512x512x10");
		cornfieldclip1 rotateTo((0,126,0),.1);
	}
}
onspawnplayer( predictedspawn ) //modified function
{
	if ( !isDefined( predictedspawn ) )
	{
		predictedspawn = 0;
	}
	pixbeginevent( "ZSURVIVAL:onSpawnPlayer" );
	self.usingobj = undefined;
	self.is_zombie = 0;
	if ( isDefined( level.custom_spawnplayer ) && isDefined( self.player_initialized ) && self.player_initialized )
	{
		self [[ level.custom_spawnplayer ]]();
		return;
	}
	if ( flag( "begin_spawning" ) )
	{
		spawnpoint = maps/mp/zombies/_zm::check_for_valid_spawn_near_team( self, 1 );
	}
	if ( !isDefined( spawnpoint ) )
	{
		match_string = "";
		location = level.scr_zm_map_start_location;
		if ( ( location == "default" || location == "" ) && isDefined( level.default_start_location ) )
		{
			location = level.default_start_location;
		}
		match_string = level.scr_zm_ui_gametype + "_" + location;
		spawnpoints = [];
		if ( isDefined( level.customMap ) && level.customMap == "tunnel" )
		{
			for ( i = 0; i < level.tunnelSpawnpoints.size; i++ )
			{
				spawnpoints[ spawnpoints.size ] = level.tunnelSpawnpoints[ i ];
			}
		}
		else if ( isDefined( level.customMap ) && level.customMap == "diner" )
		{
			for ( i = 0; i < level.dinerSpawnpoints.size; i++ )
			{
				spawnpoints[ spawnpoints.size ] = level.dinerSpawnpoints[ i ];
			}
		}
		else if ( isDefined( level.customMap ) && level.customMap == "cornfield" )
		{
			for ( i = 0; i < level.cornfieldSpawnpoints.size; i++ )
			{
				spawnpoints[ spawnpoints.size ] = level.cornfieldSpawnpoints[ i ];
			}
		}
		else if ( isDefined( level.customMap ) && level.customMap == "power" )
		{
			for ( i = 0; i < level.powerStationSpawnpoints.size; i++ )
			{
				spawnpoints[ spawnpoints.size ] = level.powerStationSpawnpoints[ i ];
			}
		}
		else if ( isDefined( level.customMap ) && level.customMap == "house" )
		{
			for ( i = 0; i < level.houseSpawnpoints.size; i++ )
			{
				spawnpoints[ spawnpoints.size ] = level.houseSpawnpoints[ i ];
			}
		}
		else if ( isDefined( level.customMap ) && level.customMap == "docks" )
		{
			for ( i = 0; i < level.docksSpawnpoints.size; i++ )
			{
				spawnpoints[ spawnpoints.size ] = level.docksSpawnpoints[ i ];
			}
		}
		else if ( isDefined( level.customMap ) && level.customMap == "cellblock" )
		{
			for ( i = 0; i < level.cellblockSpawnpoints.size; i++ )
			{
				spawnpoints[ spawnpoints.size ] = level.cellblockSpawnpoints[ i ];
			}
		}
		else if ( isDefined( level.customMap ) && level.customMap == "rooftop" )
		{
			for ( i = 0; i < level.rooftopSpawnpoints.size; i++ )
			{
				spawnpoints[ spawnpoints.size ] = level.rooftopSpawnpoints[ i ];
			}
		}
		else if ( isDefined( level.customMap ) && level.customMap == "trenches" )
		{
			for ( i = 0; i < level.trenchesSpawnpoints.size; i++ )
			{
				spawnpoints[ spawnpoints.size ] = level.trenchesSpawnpoints[ i ];
			}
		}
		else if ( isDefined( level.customMap ) && level.customMap == "excavation" )
		{
			for ( i = 0; i < level.excavationSpawnpoints.size; i++ )
			{
				spawnpoints[ spawnpoints.size ] = level.excavationSpawnpoints[ i ];
			}
		}
		else if ( isDefined( level.customMap ) && level.customMap == "tank" )
		{
			for ( i = 0; i < level.tankSpawnpoints.size; i++ )
			{
				spawnpoints[ spawnpoints.size ] = level.tankSpawnpoints[ i ];
			}
		}
		else if ( isDefined( level.customMap ) && level.customMap == "crazyplace" )
		{
			for ( i = 0; i < level.crazyplaceSpawnpoints.size; i++ )
			{
				spawnpoints[ spawnpoints.size ] = level.crazyplaceSpawnpoints[ i ];
			}
		}
		else
		{
			spawnpoints = getstructarray( "initial_spawn_points", "targetname" );
		}
		spawnpoint = getfreespawnpoint( spawnpoints, self );
	}
	self spawn( spawnpoint.origin, spawnpoint.angles, "zsurvival" );
	self.entity_num = self getentitynumber();
	self thread maps/mp/zombies/_zm::onplayerspawned();
	self thread maps/mp/zombies/_zm::player_revive_monitor();
	self freezecontrols( 1 );
	self.spectator_respawn = spawnpoint;
	self.score = self maps/mp/gametypes_zm/_globallogic_score::getpersstat( "score" );
	self.pers[ "participation" ] = 0;
	
	self.score_total = self.score;
	self.old_score = self.score;
	self.player_initialized = 0;
	self.zombification_time = 0;
	self.enabletext = 1;
	self thread maps/mp/zombies/_zm_blockers::rebuild_barrier_reward_reset();
	if ( isDefined( level.host_ended_game ) && !level.host_ended_game )
	{
		self freeze_player_controls( 0 );
		self enableweapons();
	}
	if ( isDefined( level.game_mode_spawn_player_logic ) )
	{
		spawn_in_spectate = [[ level.game_mode_spawn_player_logic ]]();
		if ( spawn_in_spectate )
		{
			self delay_thread( 0.05, maps/mp/zombies/_zm::spawnspectator );
		}
	}
	pixendevent();
}
getfreespawnpoint( spawnpoints, player ) //checked changed to match cerberus output
{
	if ( !isDefined( spawnpoints ) )
	{
		return undefined;
	}
	if ( !isDefined( game[ "spawns_randomized" ] ) )
	{
		game[ "spawns_randomized" ] = 1;
		spawnpoints = array_randomize( spawnpoints );
		random_chance = randomint( 100 );
		if ( random_chance > 50 )
		{
			set_game_var( "side_selection", 1 );
		}
		else
		{
			set_game_var( "side_selection", 2 );
		}
	}
	side_selection = get_game_var( "side_selection" );
	if ( get_game_var( "switchedsides" ) )
	{
		if ( side_selection == 2 )
		{
			side_selection = 1;
		}
		else
		{
			if ( side_selection == 1 )
			{
				side_selection = 2;
			}
		}
	}
	if ( isdefined( player ) && isdefined( player.team ) )
	{
		i = 0;
		while ( isdefined( spawnpoints ) && i < spawnpoints.size )
		{
			if ( side_selection == 1 )
			{
				if ( player.team != "allies" && isdefined( spawnpoints[ i ].script_int ) && spawnpoints[ i ].script_int == 1 )
				{
					arrayremovevalue( spawnpoints, spawnpoints[ i ] );
					i = 0;
				}
				else if ( player.team == "allies" && isdefined( spawnpoints[ i ].script_int) && spawnpoints[ i ].script_int == 2 )
				{
					arrayremovevalue( spawnpoints, spawnpoints[ i ] );
					i = 0;
				}
				else
				{
					i++;
				}
			}
			else //changed to be like beta dump
			{
				if ( player.team == "allies" && isdefined( spawnpoints[ i ].script_int ) && spawnpoints[ i ].script_int == 1 )
				{
					arrayremovevalue(spawnpoints, spawnpoints[i]);
					i = 0;
				}
				else if ( player.team != "allies" && isdefined( spawnpoints[ i ].script_int ) && spawnpoints[ i ].script_int == 2 )
				{
					arrayremovevalue( spawnpoints, spawnpoints[ i ] );
					i = 0;
				}
				else
				{
					i++;
				}
			}
		}
	}
	if ( !isdefined( player.playernum ) )
	{
		if ( player.team == "allies" )
		{
			player.playernum = get_game_var( "_team1_num" );
			set_game_var( "_team1_num", player.playernum + 1 );
		}
		else
		{
			player.playernum = get_game_var( "_team2_num" );
			set_game_var( "_team2_num", player.playernum + 1 );
		}
	}
	for ( j = 0; j < spawnpoints.size; j++ )
	{
		if ( !isdefined( spawnpoints[ j ].en_num ) ) 
		{
			for ( m = 0; m < spawnpoints.size; m++ )
			{
				spawnpoints[m].en_num = m;
			}
		}
		else if ( spawnpoints[ j ].en_num == player.playernum )
		{
			return spawnpoints[ j ];
		}
	}
	return spawnpoints[ 0 ];
}

get_player_spawns_for_gametype() //modified function
{
	match_string = "";
	location = level.scr_zm_map_start_location;
	if ( ( location == "default" || location == "" ) && isDefined( level.default_start_location ) )
	{
		location = level.default_start_location;
	}
	match_string = level.scr_zm_ui_gametype + "_" + location;
	player_spawns = [];
	structs = getstructarray("player_respawn_point", "targetname");
	i = 0;
	while ( i < structs.size )
	{
		if ( isdefined( structs[ i ].script_string ) )
		{
			tokens = strtok( structs[ i ].script_string, " " );
			foreach ( token in tokens )
			{
				if ( token == match_string )
				{
					player_spawns[ player_spawns.size ] = structs[ i ];
				}
			}
			i++;
			continue;
		}
		player_spawns[ player_spawns.size ] = structs[ i ];
		i++;
	}
	custom_spawns = [];
	if ( isDefined( level.customMap ) && level.customMap == "tunnel" )
	{
		for(i=0;i<level.tunnelSpawnpoints.size;i++)
		{
			custom_spawns[custom_spawns.size] = level.tunnelSpawnpoints[i];
		}
		return custom_spawns;
	}
	else if( isDefined( level.customMap ) && level.customMap == "diner")
	{
		for(i=0;i<level.dinerSpawnpoints.size;i++)
		{
			custom_spawns[custom_spawns.size] = level.dinerSpawnpoints[i];
		}
		return custom_spawns;
	}
	else if( isDefined( level.customMap ) && level.customMap == "cornfield")
	{
		for(i=0;i<level.cornfieldSpawnpoints.size;i++)
		{
			custom_spawns[custom_spawns.size] = level.cornfieldSpawnpoints[i];
		}
		return custom_spawns;
	}
	else if( isDefined( level.customMap ) && level.customMap == "power")
	{
		for(i=0;i<level.powerStationSpawnpoints.size;i++)
		{
			custom_spawns[custom_spawns.size] = level.powerStationSpawnpoints[i];
		}
		return custom_spawns;
	}
	else if( isDefined( level.customMap ) && level.customMap == "house")
	{
		for(i=0;i<level.houseSpawnpoints.size;i++)
		{
			custom_spawns[custom_spawns.size] = level.houseSpawnpoints[i];
		}
		return custom_spawns;
	}
	else if( isDefined( level.customMap ) && level.customMap == "docks")
	{
		for(i=0;i<level.docksSpawnpoints.size;i++)
		{
			custom_spawns[custom_spawns.size] = level.docksSpawnpoints[i];
		}
		return custom_spawns;
	}
	else if( isDefined( level.customMap ) && level.customMap == "cellblock")
	{
		for(i=0;i<level.cellblockSpawnpoints.size;i++)
		{
			custom_spawns[custom_spawns.size] = level.cellblockSpawnpoints[i];
		}
		return custom_spawns;
	}
	else if( isDefined( level.customMap ) && level.customMap == "rooftop")
	{
		for(i=0;i<level.rooftopSpawnpoints.size;i++)
		{
			custom_spawns[custom_spawns.size] = level.rooftopSpawnpoints[i];
		}
		return custom_spawns;
	}
	return player_spawns;
}

create_spawner_list( zkeys ) //modified function
{
	level.zombie_spawn_locations = [];
	level.inert_locations = [];
	level.enemy_dog_locations = [];
	level.zombie_screecher_locations = [];
	level.zombie_avogadro_locations = [];
	level.quad_locations = [];
	level.zombie_leaper_locations = [];
	level.zombie_astro_locations = [];
	level.zombie_brutus_locations = [];
	level.zombie_mechz_locations = [];
	level.zombie_napalm_locations = [];
	for ( z = 0; z < zkeys.size; z++ )
	{
		zone = level.zones[ zkeys[ z ] ];
		if ( zone.is_enabled && zone.is_active && zone.is_spawning_allowed )
		{
			for ( i = 0; i < zone.spawn_locations.size; i++ )
			{
				if(level.script == "zm_transit")
				{
					if ( zone.spawn_locations[ i ].origin == ( 8394, -2545, -205.16 ) )
					{
						zone.spawn_locations[ i ].is_enabled = 0;
					}
					else if ( zone.spawn_locations[ i ].origin == ( 10015, 6931, -571.7 ) )
					{
						zone.spawn_locations[ i ].origin = (10249.4, 7691.71, -569.875);
					}
					else if ( zone.spawn_locations[ i ].origin == ( 9339, 6411, -566.9 ) )
					{
						zone.spawn_locations[ i ].origin = (9993.29, 7486.83, -582.875);
					}
					else if ( zone.spawn_locations[ i ].origin == ( 9914, 8408, -576 ) )
					{
						zone.spawn_locations[ i ].origin = (9993.29, 7550, -582.875);
					}
					else if ( zone.spawn_locations[ i ].origin == ( 9429, 5281, -539.6 ) )
					{
						zone.spawn_locations[ i ].is_enabled = 0;
					}
					else if ( zone.spawn_locations[ i ].origin == ( 10015, 6931, -571.7 ) )
					{
						zone.spawn_locations[ i ].is_enabled = 0;
					}
					else if ( zone.spawn_locations[ i ].origin == ( 13019.1, 7382.5, -754 ) )
					{
						zone.spawn_locations[ i ].is_enabled = 0;
					}
					else if ( zone.spawn_locations[ i ].origin == ( -3825, -6576, -52.7 ) )
					{
						zone.spawn_locations[ i ].origin = (-4061.03, -6754.44, -58.0897);
					}
					else if ( zone.spawn_locations[ i ].origin == ( -3450, -6559, -51.9 ) )
					{
						zone.spawn_locations[ i ].origin = (-4060.93, -6968.64, -65.3446);
					}
					else if ( zone.spawn_locations[ i ].origin == ( -4165, -6098, -64 ) )
					{
						zone.spawn_locations[ i ].origin = (-4239.78, -6902.81, -57.0494);
					}
					else if ( zone.spawn_locations[ i ].origin == ( -5058, -5902, -73.4 ) )
					{
						zone.spawn_locations[ i ].origin = (-4846.77, -6906.38, 54.8145);
					}
					else if ( zone.spawn_locations[ i ].origin == ( -6462, -7159, -64 ) )
					{
						zone.spawn_locations[ i ].origin = (-6201.18, -7107.83, -59.7182);
					}
					else if ( zone.spawn_locations[ i ].origin == ( -5130, -6512, -35.4 ) )
					{
						zone.spawn_locations[ i ].origin = (-5396.36, -6801.88, -60.0821);
					}
					else if ( zone.spawn_locations[ i ].origin == ( -6531, -6613, -54.4 ) )
					{
						zone.spawn_locations[ i ].origin = (-6116.62, -6586.81, -50.8905);
					}
					else if ( zone.spawn_locations[ i ].origin == ( -5373, -6231, -51.9 ) )
					{
						zone.spawn_locations[ i ].origin = (-4827.92, -7137.19, -62.9082);
					}
					else if ( zone.spawn_locations[ i ].origin == ( -5752, -6230, -53.4 ) )
					{
						zone.spawn_locations[ i ].origin = (-5572.47, -6426, -39.1894);
					}
					else if ( zone.spawn_locations[ i ].origin == ( -5540, -6508, -42 ) )
					{
						zone.spawn_locations[ i ].origin = (-5789.51, -6935.81, -57.875);
					}
					else if ( zone.spawn_locations[ i ].origin == ( -11093 , 393 , 192 ) )
					{
						zone.spawn_locations[ i ].origin = (-11431.3, -644.496, 192.125);
					}
					else if ( zone.spawn_locations[ i ].origin == ( -10944 , -3846 , 221.14 ) )
					{
						zone.spawn_locations[ i ].origin = (-11351.7, -1988.58, 184.125);
					}
					else if ( zone.spawn_locations[ i ].origin == ( -11251 , -4397 , 200.02 ) )
					{
						zone.spawn_locations[ i ].origin = (-11431.3, -644.496, 192.125);
					}
					else if ( zone.spawn_locations[ i ].origin == ( -11334 , -5280 , 212.7 ) )
					{
						zone.spawn_locations[ i ].origin = (-11600.6, -1918.41, 192.125);
						zone.spawn_locations[ i ].script_noteworthy = "riser_location";
					}
					else if (zone.spawn_locations[ i ].origin == (-10836, 1195, 209.7) )
					{
						zone.spawn_locations[ i ].origin = (-11241.2, -1118.76, 184.125);
					}
				}
				else if (level.script == "zm_prison")
				{
					if( zone.spawn_locations[ i ].origin == ( -1880.2, 5419.9, -55 ) )
					{
						zone.spawn_locations[ i ].is_enabled = 0;
					}
					else if( zone.spawn_locations[ i ].origin == ( -1852.2, 5307.9, -55 ) )
					{
						zone.spawn_locations[ i ].is_enabled = 0;
					}
				}
				if(zone.spawn_locations[ i ].is_enabled)
				{
					level.zombie_spawn_locations[level.zombie_spawn_locations.size] = zone.spawn_locations[i];
				}
			}
			for(x = 0; x < zone.inert_locations.size; x++)
			{
				if(zone.inert_locations[x].is_enabled)
				{
					level.inert_locations[level.inert_locations.size] = zone.inert_locations[x];
				}
			}
			for(x = 0; x < zone.dog_locations.size; x++)
			{
				if(zone.dog_locations[x].is_enabled)
				{
					level.enemy_dog_locations[level.enemy_dog_locations.size] = zone.dog_locations[x];
				}
			}
			for(x = 0; x < zone.screecher_locations.size; x++)
			{
				if(zone.screecher_locations[x].is_enabled)
				{
					level.zombie_screecher_locations[level.zombie_screecher_locations.size] = zone.screecher_locations[x];
				}
			}
			/*
			for(x = 0; x < zone.avogadro_locations.size; x++)
			{
				if(zone.avogadro_locations[x].is_enabled)
				{
					level.zombie_avogadro_locations[level.zombie_avogadro_locations.size] = zone.avogadro_locations[x];
				}
			}
			*/
			for(x = 0; x < zone.quad_locations.size; x++)
			{
				if(zone.quad_locations[x].is_enabled)
				{
					level.quad_locations[level.quad_locations.size] = zone.quad_locations[x];
				}
			}
			for(x = 0; x < zone.leaper_locations.size; x++)
			{
				if(zone.leaper_locations[x].is_enabled)
				{
					level.zombie_leaper_locations[level.zombie_leaper_locations.size] = zone.leaper_locations[x];
				}
			}
			for(x = 0; x < zone.astro_locations.size; x++)
			{
				if(zone.astro_locations[x].is_enabled)
				{
					level.zombie_astro_locations[level.zombie_astro_locations.size] = zone.astro_locations[x];
				}
			}
			for(x = 0; x < zone.napalm_locations.size; x++)
			{
				if(zone.napalm_locations[x].is_enabled)
				{
					level.zombie_napalm_locations[level.zombie_napalm_locations.size] = zone.napalm_locations[x];
				}
			}
			for(x = 0; x < zone.brutus_locations.size; x++)
			{
				if(zone.brutus_locations[x].is_enabled)
				{
					level.zombie_brutus_locations[level.zombie_brutus_locations.size] = zone.brutus_locations[x];
				}
			}
			for(x = 0; x < zone.mechz_locations.size; x++)
			{
				if(zone.mechz_locations[x].is_enabled)
				{
					level.zombie_mechz_locations[level.zombie_mechz_locations.size] = zone.mechz_locations[x];
				}
			}
		}
	}
}
manage_zones( initial_zone ) //checked changed to match cerberus output
{

	maps/mp/zombies/_zm_zonemgr::deactivate_initial_barrier_goals();
	zone_choke = 0;
	spawn_points = maps/mp/gametypes_zm/_zm_gametype::get_player_spawns_for_gametype();
	for ( i = 0; i < spawn_points.size; i++ )
	{
		spawn_points[ i ].locked = 1;
	}
	if ( isDefined( level.zone_manager_init_func ) )
	{
		[[ level.zone_manager_init_func ]]();
	}
	if ( isDefined( level.customMap ) && level.customMap == "rooftop" )
	{
		initial_zone = [];
		initial_zone[ 0 ] = "zone_roof";
		initial_zone[ 1 ] = "zone_roof_infirmary";
		initial_zone[ 2 ] = "zone_infirmary";
	}
	else if ( isDefined( level.customMap ) && level.customMap == "docks" )
	{
		initial_zone = [];
		initial_zone[ 0 ] = "zone_dock";
		initial_zone[ 1 ] = "zone_dock_puzzle";
		initial_zone[ 2 ] = "zone_dock_gondola";	
	}
	else if ( isDefined( level.customMap ) && level.customMap == "trenches" )
	{
		initial_zone = [];
		initial_zone[ 0 ] = "zone_bunker_4a";
		initial_zone[ 1 ] = "zone_bunker_4b";
		initial_zone[ 2 ] = "zone_bunker_4c";
		initial_zone[ 3 ] = "zone_bunker_4d";
		initial_zone[ 4 ] = "zone_bunker_4e";
		initial_zone[ 5 ] = "zone_bunker_tank_c";
		initial_zone[ 6 ] = "zone_bunker_tank_c1";
		initial_zone[ 7 ] = "zone_bunker_tank_d";
		initial_zone[ 8 ] = "zone_bunker_tank_d1";
		initial_zone[ 9 ] = "zone_bunker_1a";
		initial_zone[ 10 ] = "zone_bunker_1";
		initial_zone[ 11 ] = "zone_fire_stairs";
		initial_zone[ 12 ] = "zone_bunker_3a";
		initial_zone[ 13 ] = "zone_bunker_3b";
		initial_zone[ 14 ] = "zone_bunker_2a";
		initial_zone[ 15 ] = "zone_bunker_2";
	}
	else if ( isDefined( level.customMap ) && level.customMap == "excavation" )
	{
		initial_zone = [];
		initial_zone[ 0 ] = "zone_nml_2a";
		initial_zone[ 1 ] = "zone_nml_2";
		initial_zone[ 2 ] = "zone_bunker_tank_e";
		initial_zone[ 3 ] = "zone_bunker_tank_e1";
		initial_zone[ 4 ] = "zone_bunker_tank_e2";
		initial_zone[ 5 ] = "zone_bunker_tank_f";
		initial_zone[ 6 ] = "zone_nml_1";
		initial_zone[ 7 ] = "zone_nml_4";
		initial_zone[ 8 ] = "zone_nml_0";
		initial_zone[ 9 ] = "zone_nml_5";
		initial_zone[ 10 ] = "zone_nml_celllar";
		initial_zone[ 11 ] = "zone_bolt_stairs";
		initial_zone[ 12 ] = "zone_nml_3";
		initial_zone[ 13 ] = "zone_nml_2b";
		initial_zone[ 14 ] = "zone_nml_6";
		initial_zone[ 15 ] = "zone_nml_8";
		initial_zone[ 16 ] = "zone_nml_10a";
		initial_zone[ 17 ] = "zone_nml_10";
		initial_zone[ 18 ] = "zone_nml_7";
		initial_zone[ 19 ] = "zone_bunker_tank_a";
		initial_zone[ 20 ] = "zone_bunker_tank_a1";
		initial_zone[ 21 ] = "zone_bunker_tank_a2";
		initial_zone[ 22 ] = "zone_bunker_tank_b";
		initial_zone[ 23 ] = "zone_nml_9";
		initial_zone[ 24 ] = "zone_air_stairs";
		initial_zone[ 25 ] = "zone_nml_11";
		initial_zone[ 26 ] = "zone_nml_12";
		initial_zone[ 27 ] = "zone_nml_16";
		initial_zone[ 28 ] = "zone_nml_17";
		initial_zone[ 29 ] = "zone_nml_18";
		initial_zone[ 30 ] = "zone_nml_19";
		initial_zone[ 31 ] = "ug_bottom_zone";
		initial_zone[ 32 ] = "zone_nml_13";
		initial_zone[ 33 ] = "zone_nml_14";
		initial_zone[ 34 ] = "zone_nml_15";
	}
	else if ( isDefined( level.customMap ) && level.customMap == "tank" )
	{
		initial_zone = [];
		initial_zone[ 0 ] = "zone_village_0";
		initial_zone[ 1 ] = "zone_village_5";
		initial_zone[ 2 ] = "zone_village_5a";
		initial_zone[ 3 ] = "zone_village_5b";
		initial_zone[ 4 ] = "zone_village_1";
		initial_zone[ 5 ] = "zone_village_4b";
		initial_zone[ 6 ] = "zone_village_4a";
		initial_zone[ 7 ] = "zone_village_4";
	}
	else if ( isDefined( level.customMap ) && level.customMap == "crazyplace" )
	{
		initial_zone = [];
		initial_zone[ 0 ] = "zone_chamber_0";
		initial_zone[ 1 ] = "zone_chamber_1";
		initial_zone[ 2 ] = "zone_chamber_2";
		initial_zone[ 3 ] = "zone_chamber_3";
		initial_zone[ 4 ] = "zone_chamber_4";
		initial_zone[ 5 ] = "zone_chamber_5";
		initial_zone[ 6 ] = "zone_chamber_6";
		initial_zone[ 7 ] = "zone_chamber_7";
		initial_zone[ 8 ] = "zone_chamber_8";
	}
	if ( isarray( initial_zone ) )
	{
		for ( i = 0; i < initial_zone.size; i++ )
		{
			maps/mp/zombies/_zm_zonemgr::zone_init( initial_zone[ i ] );
			maps/mp/zombies/_zm_zonemgr::enable_zone( initial_zone[ i ] );
		}
	}
	else
	{
		maps/mp/zombies/_zm_zonemgr::zone_init( initial_zone );
		maps/mp/zombies/_zm_zonemgr::enable_zone( initial_zone );
	}
	maps/mp/zombies/_zm_zonemgr::setup_zone_flag_waits();
	zkeys = getarraykeys( level.zones );
	level.zone_keys = zkeys;
	level.newzones = [];
	for ( z = 0; z < zkeys.size; z++ )
	{
		level.newzones[ zkeys[ z ] ] = spawnstruct();
	}
	oldzone = undefined;
	flag_set( "zones_initialized" );
	flag_wait( "begin_spawning" );
	while ( getDvarInt( "noclip" ) == 0 || getDvarInt( "notarget" ) != 0 )
	{	
		for( z = 0; z < zkeys.size; z++ )
		{
			level.newzones[ zkeys[ z ] ].is_active = 0;
			level.newzones[ zkeys[ z ] ].is_occupied = 0;
		}
		a_zone_is_active = 0;
		a_zone_is_spawning_allowed = 0;
		level.zone_scanning_active = 1;
		z = 0;
		while ( z < zkeys.size )
		{
			zone = level.zones[ zkeys[ z ] ];
			newzone = level.newzones[ zkeys[ z ] ];
			if( !zone.is_enabled )
			{
				z++;
				continue;
			}
			if ( isdefined(level.zone_occupied_func ) )
			{
				newzone.is_occupied = [[ level.zone_occupied_func ]]( zkeys[ z ] );
			}
			else
			{
				newzone.is_occupied = maps/mp/zombies/_zm_zonemgr::player_in_zone( zkeys[ z ] );
			}
			if ( newzone.is_occupied )
			{
				newzone.is_active = 1;
				a_zone_is_active = 1;
				if ( zone.is_spawning_allowed )
				{
					a_zone_is_spawning_allowed = 1;
				}
				if ( !isdefined(oldzone) || oldzone != newzone )
				{
					level notify( "newzoneActive", zkeys[ z ] );
					oldzone = newzone;
				}
				azkeys = getarraykeys( zone.adjacent_zones );
				for ( az = 0; az < zone.adjacent_zones.size; az++ )
				{
					if ( zone.adjacent_zones[ azkeys[ az ] ].is_connected && level.zones[ azkeys[ az ] ].is_enabled )
					{
						level.newzones[ azkeys[ az ] ].is_active = 1;
						if ( level.zones[ azkeys[ az ] ].is_spawning_allowed )
						{
							a_zone_is_spawning_allowed = 1;
						}
					}
				}
			}
			zone_choke++;
			if ( zone_choke >= 3 )
			{
				zone_choke = 0;
				wait 0.05;
			}
			z++;
		}
		level.zone_scanning_active = 0;
		for ( z = 0; z < zkeys.size; z++ )
		{
			level.zones[ zkeys[ z ] ].is_active = level.newzones[ zkeys[ z ] ].is_active;
			level.zones[ zkeys[ z ] ].is_occupied = level.newzones[ zkeys[ z ] ].is_occupied;
		}
		if ( !a_zone_is_active || !a_zone_is_spawning_allowed )
		{
			if ( isarray( initial_zone ) )
			{
				level.zones[ initial_zone[ 0 ] ].is_active = 1;
				level.zones[ initial_zone[ 0 ] ].is_occupied = 1;
				level.zones[ initial_zone[ 0 ] ].is_spawning_allowed = 1;
			}
			else
			{
				level.zones[ initial_zone ].is_active = 1;
				level.zones[ initial_zone ].is_occupied = 1;
				level.zones[ initial_zone ].is_spawning_allowed = 1;
			}
		}
		[[ level.create_spawner_list_func ]]( zkeys );
		level.active_zone_names = maps/mp/zombies/_zm_zonemgr::get_active_zone_names();
		wait 1;
	}
}