#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;
#include maps/mp/zombies/_zm_buildables;
#include maps/mp/zombies/_zm_game_module;
#include maps/mp/zombies/_zm_ai_basic;
#include maps/mp/gametypes_zm/_weapons;
#include maps/mp/zombies/_zm_perks;
#include maps/mp/gametypes_zm/_hud_util;

init()
{
	thread gscRestart();
	thread emptyLobbyRestart();
	thread setPlayersToSpectator();
	level.player_out_of_playable_area_monitor = 0;
	//level.player_starting_points = 500000;
	//level.perk_purchase_limit = 10;
	thread init_custom_map();
	thread setupWunderfizz();
	if ( isDefined ( level.customMap ) && level.customMap != "vanilla" || getDvar("customMap") == "farm")
	{
		setDvar( "scr_screecher_ignore_player", 1 );
	}
	level thread insta_kill_rounds_tracker();
	level.callbackactordamage = ::actor_damage_override_wrapper;
}

meleeCoords()
{
	level endon("end_game");
	for(;;)
	{
		if(self meleeButtonPressed())
		{
			self IPrintLn("hello there");
			me = self.origin;
			you = self GetPlayerAngles();
			self IPrintLn("Origin = "+ me);
			angles = (0, (self GetPlayerAngles())[1] + 90, 0);
			logprint(self.origin + ", " + angles + "\n");
			wait 1;
			self IPrintLn("Angles = "+ you);
			/*
			for(i=0;i<level.chests.size;i++)
			{
				self IPrintLn(level.chests[i].script_noteworthy);
				wait 0.5;
			}*/
		}
		wait .5;
	}
}

init_custom_map()
{
	level thread onplayerconnected();
	disable_pers_upgrades();
	flag_wait( "initial_blackscreen_passed" );
	thread init_buildables();
	if(level.script == "zm_highrise" && is_true(level.customMap != "vanilla") || level.script == "zm_buried" && is_true(level.customMap != "vanilla"))
		thread power_setup();
	wait 5;
	thread map_fixes();
}

power_setup()
{
	maps/mp/zombies/_zm_game_module::turn_power_on_and_open_doors();
	wait 1;
	flag_set( "power_on" );
	level setclientfield( "zombie_power_on", 1 );
}

onplayerconnected()
{
	for ( ;; )
	{
		level waittill( "connected", player );
		player thread addPerkSlot();
		player thread onplayerspawned();
		player thread perkHud();
		player thread meleeCoords();
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
	if(level.script != "zm_prison" && level.script != "zm_highrise")
		return;
	if(isdefined(level.customMap) && level.customMap == "vanilla")
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
	if ( isDefined( level.customMap ) && level.customMap == "tunnel" || isDefined( level.customMap ) && level.customMap == "diner" || isDefined( level.customMap ) && level.customMap == "power" || isDefined( level.customMap ) && level.customMap == "cornfield" || isDefined( level.customMap ) && level.customMap == "house")
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
	if ( level.script == "zm_highrise" && isDefined( level.customMap ) && level.customMap != "vanilla" )
	{
		removebuildable( "springpad_zm" );
		removebuildable( "slipgun_zm" );
		removebuildable( "keys_zm" );
		removebuildable( "ekeys_zm" );
		removebuildable( "sq_common" );
		level.zombie_include_weapons[ "slipgun_zm" ] = 1;
		level.zombie_weapons[ "slipgun_zm" ].is_in_box = 1;
	}
	if ( level.script == "zm_tomb" && isdefined( level.customMap ) && level.customMap != "vanilla" )
	{
		removebuildable("equip_dieseldrone_zm");
		removebuildable("elemental_staff_fire");
		removebuildable("elemental_staff_air");
		removebuildable("elemental_staff_lightning");
		removebuildable("elemental_staff_water");
		removebuildable("gramophone");
		buildcraftable("tomb_shield_zm");
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
	//map_restart( false );
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
		wait 2;
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

weapon_no_ammo(weapon)
{
	if(weapon == "one_inch_punch_zm")
	{
		return 1;
	}
	return 0;
}

setupWunderfizz()
{
	level.wunderfizzChecksPower = getDvarIntDefault( "wunderfizzChecksPower", 1 );
	level.wunderfizzCost = getDvarIntDefault("wunderfizzCost", 1500);
	wunderfizzUseRandomStart = getDvarIntDefault("wunderfizzUseRandomStart", 0 );
	level.wunderfizz_locations = 0;
	if(wunderfizzUseRandomStart)
		level.currentWunderfizzLocation = 0;
	else
		level.currentWunderfizzLocation = 1;
	if(isdefined ( level.customMap ) && level.customMap == "trenches")
    {
		level._effect[ "wunderfizz_loop" ] = loadfx( "maps/zombie_tomb/fx_tomb_dieselmagic_on" );
		wunderfizzSetup((775, 2545, -126.096), (0,315,0), "p6_zm_vending_diesel_magic");
    	wunderfizzSetup((-252.588, 3710, -295.875), (0,0,0), "p6_zm_vending_diesel_magic");
    	wunderfizzSetup((2975, 5361.24, -367.875), (0,270,0), "p6_zm_vending_diesel_magic");
		//DO NOT TOUCH BELOW IF YOU DON'T KNOW WHAT YOU'RE DOING
		if(wunderfizzUseRandomStart)
		{
			level waittill("connected", player);
			wait 1;
			level.currentWunderfizzLocation = chooseLocation(level.currentWunderfizzLocation);
			level notify("wunderfizzMove");
		}
    }
    else if(isdefined(level.customMap) && level.customMap == "crazyplace")
    {
    	wunderfizzSetup(( 10287.4,-7082.78,-463.75 ), (0,62,0), "p6_zm_vending_diesel_magic");
    }
    else if(isDefined ( level.customMap ) && level.customMap == "house")
    {
    	wunderfizzSetup((4782,5998,-64),(0,111,0), "zombie_vending_jugg");
    	//DO NOT TOUCH BELOW IF YOU DON'T KNOW WHAT YOU'RE DOING
    	if(wunderfizzUseRandomStart)
    	{
    		level waittill("connected", player);
    		wait 1;
			level.currentWunderfizzLocation = chooseLocation(level.currentWunderfizzLocation);
			level notify("wunderfizzMove");
    	}
    }
    else if(isDefined ( level.customMap ) && level.customMap == "rooftop")
    {
    	wunderfizzSetup((3215.64,9568.38,1528),(0,90,0), "p6_zm_al_vending_jugg_on");
    	//DO NOT TOUCH BELOW IF YOU DON'T KNOW WHAT YOU'RE DOING
    	if(wunderfizzUseRandomStart)
    	{
    		level waittill("connected", player);
    		wait 1;
			level.currentWunderfizzLocation = chooseLocation(level.currentWunderfizzLocation);
			level notify("wunderfizzMove");
    	}
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

wunderfizzSetup(origin, angles, model)
{
	level.wunderfizz_locations++;
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
	wunderfizzMachine.location = level.wunderfizz_locations;
	wunderfizzMachine.uses = 0;
	perks = getPerks();
	cost = level.wunderfizzCost;
	trig = spawn("trigger_radius", origin, 1, 50, 50);
	trig SetCursorHint("HINT_NOICON");
	wunderfizzMachine thread wunderfizz(origin, angles, model, cost, perks, trig, wunderfizzBottle);
}

wunderfizz(origin, angles, model, cost, perks, trig, wunderfizzBottle )
{
	if(is_true(level.disableBSMMagic))
	{
		trig SetHintString("Magic is disabled");
		return;
	}
	self thread playLocFX();
	if(level.wunderfizzChecksPower && level.script != "zm_prison" && level.script != "zm_nuked")
	{
		trig SetHintString("Power Must Be Activated First");
		flag_wait("power_on");
		trig SetHintString(" ");
	}
	else
	{
		trig SetHintString(" ");
	}
	for(;;)
	{
		if(level.currentWunderfizzLocation == self.location)
		{
			self ShowPart("j_ball");
			for(;;)
			{
				trig SetHintString("Hold ^3&&1^7 to buy Perk-a-Cola [Cost: " + cost + "]");
				trig waittill("trigger", player);
				if(player UseButtonPressed() && player.score >= cost && player.isDrinkingPerk == 0)
				{
					if(player.num_perks < player get_player_perk_purchase_limit())
					{
						if(player.num_perks < perks.size)
						{
							self thread wunderfizzSounds();
							player playsound("zmb_cha_ching");
							self.uses++;
							player.score -= cost;
							trig setHintString(" ");
							rtime = 3;
							wunderfx = SpawnFX(level._effect["wunderfizz_loop"], self.origin,AnglesToForward(angles),AnglesToUp(angles));
							TriggerFX(wunderfx);
							self thread perk_bottle_motion();
							wait .1;
							while(rtime>0)
							{
								for(;;)
								{
									perkForRandom = perks[randomInt(perks.size)];
									if(!(player hasPerk(perkForRandom) || (player maps/mp/zombies/_zm_perks::has_perk_paused(perkForRandom))))
									{
										if(level.script == "zm_tomb")
										{
											self.bottle setModel(getPerkBottleModel(perkForRandom));
											break;
										}
										else
										{
											self setModel(getPerkModel(perkForRandom));
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
							self notify( "done_cycling" );
							if((self.uses >= RandomIntRange(3,7)) && (level.wunderfizz_locations > 1))
							{
								if(level.script == "zm_tomb")
								{
									self.bottle setModel("t6_wpn_zmb_perk_bottle_bear_world");
									if(level.script != "zm_tomb")
										self setModel("zombie_teddybear");
									level notify("wunderSpinStop");
									wunderfx Delete();
									wait 7;
									self.bottle setModel("tag_origin");
									level.currentWunderfizzLocation = chooseLocation(level.currentWunderfizzLocation);
									level notify("wunderfizzMove");
									self setModel(model);
									self.uses = 0;
									break;
								}
								else{
									self setModel("zombie_teddybear");
									self.angles = angles + (0,-90,0);
									wunderfx Delete();
									player.score += cost;
									trig SetHintString("Wunderfizz is Moving");
									wait 7;
									level.currentWunderfizzLocation = chooseLocation(level.currentWunderfizzLocation);
									level notify("wunderfizzMove");
									self.angles = angles;
									self setModel(model);
									self.uses = 0;
									break;
								}
							}
							else{
								perklist = array_randomize(perks);
								for(j=0;j<perklist.size;j++)
								{
									if(!(player hasPerk(perklist[j]) || (self maps/mp/zombies/_zm_perks::has_perk_paused(perklist[j]))))
									{
										perkName = getPerkName(perklist[j]);
										if(level.script == "zm_tomb")
										{
											self.bottle setModel(getPerkBottleModel(perklist[j]));

										}
										else
										{
											if(level.script == "zm_prison")
											{
												self setModel(getPerkModel(perklist[j]));
												fx = SpawnFX(level._effect["electriccherry"], origin, AnglesToForward(angles),AnglesToUp(angles));
											}
											else
											{
												self setModel(getPerkModel(perklist[j]) + "_on");
												fx = SpawnFX(level._effect["tombstone_light"], origin, AnglesToForward(angles),AnglesToUp(angles));
											}
											TriggerFX(fx);
										}
										trig SetHintString("Hold ^3&&1^7 for " + perkName);
										time = 7;
										while(time > 0)
										{
											if(player UseButtonPressed() && distance(player.origin, trig.origin) < 65 && player can_buy_weapon())
											{
												player thread givePerk(perklist[j]);
												break;
											}
											TriggerFX(wunderfx);
											wait .2;
											time -= .2;
										}
										self setModel(model);
										self.bottle setModel("tag_origin");
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
						}
						else
						{
							trig SetHintString("You Have All " + perks.size + " Perks");
							wait 2;
							trig SetHintString("Hold ^3&&1^7 to buy Perk-a-Cola [Cost: " + cost + "]");
						}
					}
					else{
						trig SetHintString("You Can Only Hold ^3" + player get_player_perk_purchase_limit() + "^7 Perks");
						wait 2;
						trig SetHintString("Hold ^3&&1^7 to buy Perk-a-Cola [Cost: " + cost + "]");
					}
				}
				wait .1;
			}
		}
		else{
			trig SetHintString("Wunderfizz Orb is at Another Location");
			self HidePart("j_ball");
			level waittill("wunderfizzMove");
		}
		wait .1;
	}
}

can_buy_weapon() //checked matches cerberus output
{
	if ( isDefined( self.is_drinking ) && self.is_drinking > 0 )
	{
		return 0;
	}
	if ( self hacker_active() )
	{
		return 0;
	}
	if ( self IsSwitchingWeapons() )
	{
		return 0;
	}
	current_weapon = self getcurrentweapon();
	if ( is_placeable_mine( current_weapon ) || is_equipment_that_blocks_purchase( current_weapon ) )
	{
		return 0;
	}
	if ( self in_revive_trigger() )
	{
		return 0;
	}
	if ( current_weapon == "none" )
	{
		return 0;
	}
	return 1;
}

playLocFX()
{
	level waittill("connected", player);
	for(;;)
	{
		fx = SpawnFX(level._effect["lght_marker"], self.origin);
		if(self.location == level.currentWunderfizzLocation)
		{
			TriggerFX(fx);
		}
		level waittill("wunderfizzMove");
		fx Delete();
	}
}

chooseLocation(currLoc)
{
	for(;;)
	{
		loc = RandomIntRange(1, level.wunderfizz_locations + 1);
		if(currLoc != loc)
		{
			return loc;
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
	sound_ent = spawn("script_origin", self.origin);
	sound_ent StopSounds();
	sound_ent PlaySound( "zmb_rand_perk_start");
	sound_ent PlayLoopSound("zmb_rand_perk_loop", 0.5);
	level waittill("wunderSpinStop");
	sound_ent StopLoopSound(1);
	sound_ent PlaySound("zmb_rand_perk_stop");
	sound_ent Delete();
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

extra_perk_spawns() //custom function
{
	if(level.script == "zm_tomb")
	{
		level.trenchesPerkArray = array( "specialty_armorvest", "specialty_weapupgrade", "specialty_longersprint" );
	
		level.trenchesPerks[ "specialty_armorvest" ] = spawnstruct();
		level.trenchesPerks[ "specialty_armorvest" ].origin = ( -976.359, 2905.5, -112 );
		level.trenchesPerks[ "specialty_armorvest" ].angles = ( 0, 90, 0 );
		level.trenchesPerks[ "specialty_armorvest" ].model = "p6_zm_al_vending_nuke_on";
		level.trenchesPerks[ "specialty_armorvest" ].script_noteworthy = "specialty_armorvest";
		level.trenchesPerks[ "specialty_weapupgrade" ] = spawnstruct();
		level.trenchesPerks[ "specialty_weapupgrade" ].origin = (-6223.94, -6694.36, 152.125);
		level.trenchesPerks[ "specialty_weapupgrade" ].angles = ( 0, 180, 0 );
		level.trenchesPerks[ "specialty_weapupgrade" ].model = "p6_zm_tm_packapunch";
		level.trenchesPerks[ "specialty_weapupgrade" ].script_noteworthy = "specialty_weapupgrade";
		level.trenchesPerks[ "specialty_longersprint" ] = spawnstruct();
		level.trenchesPerks[ "specialty_longersprint" ].origin = (-250.068, 4296.36, -191.754);
		level.trenchesPerks[ "specialty_longersprint" ].angles = ( 0, 0, 0 );
		level.trenchesPerks[ "specialty_longersprint" ].model = "zombie_vending_marathon";
		level.trenchesPerks[ "specialty_longersprint" ].script_noteworthy = "specialty_longersprint";
		
		level.excavationPerkArray = array( "specialty_fastreload", "specialty_quickrevive", "specialty_additionalprimaryweapon" );
		
		level.excavationPerks[ "specialty_fastreload" ] = spawnstruct();
		level.excavationPerks[ "specialty_fastreload" ].origin = ( -104.359, -758.326, 224 );
		level.excavationPerks[ "specialty_fastreload" ].angles = ( 0, 87.718, 0 );
		level.excavationPerks[ "specialty_fastreload" ].model = "p6_zm_al_vending_nuke_on";
		level.excavationPerks[ "specialty_fastreload" ].script_noteworthy = "specialty_fastreload";
		level.excavationPerks[ "specialty_quickrevive" ] = spawnstruct();
		level.excavationPerks[ "specialty_quickrevive" ].origin = ( -395.641, 1078.5, 131.5 );
		level.excavationPerks[ "specialty_quickrevive" ].angles = ( 0, 314, 0 );
		level.excavationPerks[ "specialty_quickrevive" ].model = "p6_zm_al_vending_nuke_on";
		level.excavationPerks[ "specialty_quickrevive" ].script_noteworthy = "specialty_quickrevive";
		level.excavationPerks[ "specialty_additionalprimaryweapon" ] = spawnstruct();
		level.excavationPerks[ "specialty_additionalprimaryweapon" ].origin = ( -863.388, 2216.36, -119.95 );
		level.excavationPerks[ "specialty_additionalprimaryweapon" ].angles = ( 0, 0, 0 );
		level.excavationPerks[ "specialty_additionalprimaryweapon" ].model = "p6_anim_zm_buildable_pap_on";
		level.excavationPerks[ "specialty_additionalprimaryweapon" ].script_noteworthy = "specialty_additionalprimaryweapon";
		
		level.tankPerkArray = array( "specialty_longersprint", "specialty_fastreload", "specialty_additionalprimaryweapon", "specialty_armorvest", "specialty_quickrevive", "specialty_weapupgrade" );
		
		level.tankPerks[ "specialty_fastreload" ] = spawnstruct();
		level.tankPerks[ "specialty_fastreload" ].origin = ( 1081.96, -2531.19, 302.1 );
		level.tankPerks[ "specialty_fastreload" ].angles = ( 0, 286, 0 );
		level.tankPerks[ "specialty_fastreload" ].model = "zombie_vending_sleight";
		level.tankPerks[ "specialty_fastreload" ].script_noteworthy = "specialty_fastreload";
		level.tankPerks[ "specialty_additionalprimaryweapon" ] = spawnstruct();
		level.tankPerks[ "specialty_additionalprimaryweapon" ].origin = ( 132.545, -2446, 302.1 );
		level.tankPerks[ "specialty_additionalprimaryweapon" ].angles = ( 0, 55, 0 );
		level.tankPerks[ "specialty_additionalprimaryweapon" ].model = "p6_zm_al_vending_nuke_on";
		level.tankPerks[ "specialty_additionalprimaryweapon" ].script_noteworthy = "specialty_additionalprimaryweapon";
		level.tankPerks[ "specialty_quickrevive" ] = spawnstruct();
		level.tankPerks[ "specialty_quickrevive" ].origin = ( -48.11, -2140.42, 230 );
		level.tankPerks[ "specialty_quickrevive" ].angles = ( 0, 113.712, 0 );
		level.tankPerks[ "specialty_quickrevive" ].model = "p6_zm_al_vending_nuke_on";
		level.tankPerks[ "specialty_quickrevive" ].script_noteworthy = "specialty_quickrevive";
		level.tankPerks[ "specialty_armorvest" ] = spawnstruct();
		level.tankPerks[ "specialty_armorvest" ].origin = ( 1578.91, -2230.5, -34.5 );
		level.tankPerks[ "specialty_armorvest" ].angles = ( 0, 284, 0 );
		level.tankPerks[ "specialty_armorvest" ].model = "p6_zm_al_vending_nuke_on";
		level.tankPerks[ "specialty_armorvest" ].script_noteworthy = "specialty_armorvest";
		level.tankPerks[ "specialty_longersprint" ] = spawnstruct();
		level.tankPerks[ "specialty_longersprint" ].origin = ( 172.817, -2415.75, 50 );
		level.tankPerks[ "specialty_longersprint" ].angles = ( 0, 13, 0 );
		level.tankPerks[ "specialty_longersprint" ].model = "p6_zm_al_vending_nuke_on";
		level.tankPerks[ "specialty_longersprint" ].script_noteworthy = "specialty_longersprint";
		level.tankPerks[ "specialty_weapupgrade" ] = spawnstruct();
		level.tankPerks[ "specialty_weapupgrade" ].origin = ( 1427.41, -1577.64, -107.95 );
		level.tankPerks[ "specialty_weapupgrade" ].angles = ( 0, 356.609, 0 );
		level.tankPerks[ "specialty_weapupgrade" ].model = "p6_zm_tm_packapunch";
		level.tankPerks[ "specialty_weapupgrade" ].script_noteworthy = "specialty_weapupgrade";
		
		level.crazyplacePerkArray = array( "specialty_longersprint", "specialty_fastreload", "specialty_armorvest", "specialty_quickrevive", "specialty_weapupgrade" );
		
		level.crazyplacePerks[ "specialty_fastreload" ] = spawnstruct();
		level.crazyplacePerks[ "specialty_fastreload" ].origin = ( 9519.64, -7785.12, -463.25 );
		level.crazyplacePerks[ "specialty_fastreload" ].angles = ( 0, 54.5, 0 );
		level.crazyplacePerks[ "specialty_fastreload" ].model = "zombie_vending_sleight";
		level.crazyplacePerks[ "specialty_fastreload" ].script_noteworthy = "specialty_fastreload";
		level.crazyplacePerks[ "specialty_quickrevive" ] = spawnstruct();
		level.crazyplacePerks[ "specialty_quickrevive" ].origin = ( 10728, -7107, -443.75 );
		level.crazyplacePerks[ "specialty_quickrevive" ].angles = ( 0, 27, 0 );
		level.crazyplacePerks[ "specialty_quickrevive" ].model = "p6_zm_al_vending_nuke_on";
		level.crazyplacePerks[ "specialty_quickrevive" ].script_noteworthy = "specialty_quickrevive";
		level.crazyplacePerks[ "specialty_armorvest" ] = spawnstruct();
		level.crazyplacePerks[ "specialty_armorvest" ].origin = ( 9986, -8815.25, -451.75 );
		level.crazyplacePerks[ "specialty_armorvest" ].angles = ( 0, 194, 0 );
		level.crazyplacePerks[ "specialty_armorvest" ].model = "p6_zm_al_vending_nuke_on";
		level.crazyplacePerks[ "specialty_armorvest" ].script_noteworthy = "specialty_armorvest";
		level.crazyplacePerks[ "specialty_longersprint" ] = spawnstruct();
		level.crazyplacePerks[ "specialty_longersprint" ].origin = ( 10853.9, -8289.79, -447.75 );
		level.crazyplacePerks[ "specialty_longersprint" ].angles = ( 0, 178, 0 );
		level.crazyplacePerks[ "specialty_longersprint" ].model = "p6_zm_al_vending_nuke_on";
		level.crazyplacePerks[ "specialty_longersprint" ].script_noteworthy = "specialty_longersprint";
		level.crazyplacePerks[ "specialty_weapupgrade" ] = spawnstruct();
		level.crazyplacePerks[ "specialty_weapupgrade" ].origin = ( 10781.6, -7873.87, -463.875 );
		level.crazyplacePerks[ "specialty_weapupgrade" ].angles = ( 0, 274.026, 0 );
		level.crazyplacePerks[ "specialty_weapupgrade" ].model = "p6_zm_tm_packapunch";
		level.crazyplacePerks[ "specialty_weapupgrade" ].script_noteworthy = "specialty_weapupgrade";
	}
	else if(level.script == "zm_prison")
	{
		level.docksPerkArray = array( "specialty_deadshot", "specialty_rof", "specialty_fastreload", "specialty_grenadepulldeath", "specialty_weapupgrade", "specialty_longersprint", "specialty_additionalprimaryweapon", "specialty_flakjacket", "specialty_quickrevive" );
		
		level.docksPerks[ "specialty_deadshot" ] = spawnstruct();
		level.docksPerks[ "specialty_deadshot" ].origin = ( -1566, 5542.5, -64 );
		level.docksPerks[ "specialty_deadshot" ].angles = ( 0, 45, 0 );
		level.docksPerks[ "specialty_deadshot" ].model = "zombie_vending_ads_on";
		level.docksPerks[ "specialty_deadshot" ].script_noteworthy = "specialty_deadshot";
		level.docksPerks[ "specialty_fastreload" ] = spawnstruct();
		level.docksPerks[ "specialty_fastreload" ].origin = ( -1232.75, 5205.5, -71.875 );
		level.docksPerks[ "specialty_fastreload" ].angles = ( 0, 179, 0 );
		level.docksPerks[ "specialty_fastreload" ].model = "zombie_vending_sleight";
		level.docksPerks[ "specialty_fastreload" ].script_noteworthy = "specialty_fastreload";
		level.docksPerks[ "specialty_rof" ] = spawnstruct();
		level.docksPerks[ "specialty_rof" ].origin = ( -578, 6095, -36 );
		level.docksPerks[ "specialty_rof" ].angles = ( 0, 282, 0 );
		level.docksPerks[ "specialty_rof" ].model = "zombie_vending_doubletap2";
		level.docksPerks[ "specialty_rof" ].script_noteworthy = "specialty_rof";
		level.docksPerks[ "specialty_grenadepulldeath" ] = spawnstruct();
		level.docksPerks[ "specialty_grenadepulldeath" ].origin = ( 82, 8102, 276 );
		level.docksPerks[ "specialty_grenadepulldeath" ].angles = ( 0, 315, 0 );
		level.docksPerks[ "specialty_grenadepulldeath" ].model = "p6_zm_vending_electric_cherry_off";
		level.docksPerks[ "specialty_grenadepulldeath" ].script_noteworthy = "specialty_grenadepulldeath";
		level.docksPerks[ "specialty_longersprint" ] = spawnstruct();
		level.docksPerks[ "specialty_longersprint" ].origin = ( -652.5, 5326, -72 );
		level.docksPerks[ "specialty_longersprint" ].angles = ( 0, 145, 0 );
		level.docksPerks[ "specialty_longersprint" ].model = "p6_zm_al_vending_nuke_on";
		level.docksPerks[ "specialty_longersprint" ].script_noteworthy = "specialty_longersprint";
		level.docksPerks[ "specialty_additionalprimaryweapon" ] = spawnstruct();
		level.docksPerks[ "specialty_additionalprimaryweapon" ].origin = ( 386, 8297, 64 );
		level.docksPerks[ "specialty_additionalprimaryweapon" ].angles = ( 0, 0, 0 );
		level.docksPerks[ "specialty_additionalprimaryweapon" ].model = "p6_zm_al_vending_nuke_on";
		level.docksPerks[ "specialty_additionalprimaryweapon" ].script_noteworthy = "specialty_additionalprimaryweapon";
		level.docksPerks[ "specialty_quickrevive" ] = spawnstruct();
		level.docksPerks[ "specialty_quickrevive" ].origin = ( 208.5, 6373.25, 64 );
		level.docksPerks[ "specialty_quickrevive" ].angles = ( 0, 235, 0 );
		level.docksPerks[ "specialty_quickrevive" ].model = "p6_zm_al_vending_nuke_on";
		level.docksPerks[ "specialty_quickrevive" ].script_noteworthy = "specialty_quickrevive";
		level.docksPerks[ "specialty_flakjacket" ] = spawnstruct();
		level.docksPerks[ "specialty_flakjacket" ].origin = ( -643, 7057, 64 );
		level.docksPerks[ "specialty_flakjacket" ].angles = ( 0, 57, 0 );
		level.docksPerks[ "specialty_flakjacket" ].model = "p6_zm_al_vending_nuke_on";
		level.docksPerks[ "specialty_flakjacket" ].script_noteworthy = "specialty_flakjacket";
		level.docksPerks[ "specialty_weapupgrade" ] = spawnstruct();
		level.docksPerks[ "specialty_weapupgrade" ].origin = ( -1769, 5391, -72 );
		level.docksPerks[ "specialty_weapupgrade" ].angles = ( 0, 100, 0 );
		level.docksPerks[ "specialty_weapupgrade" ].model = "p6_zm_al_vending_pap_on";
		level.docksPerks[ "specialty_weapupgrade" ].script_noteworthy = "specialty_weapupgrade";
		
		level.cellblockPerkArray = array( "specialty_armorvest", "specialty_deadshot", "specialty_rof", "specialty_weapupgrade", "specialty_longersprint", "specialty_additionalprimaryweapon", "specialty_flakjacket", "specialty_quickrevive" );
		
		level.cellblockPerks[ "specialty_deadshot" ] = spawnstruct();
		level.cellblockPerks[ "specialty_deadshot" ].origin = ( 2827, 9263, 1335 );
		level.cellblockPerks[ "specialty_deadshot" ].angles = ( 0, 180, 0 );
		level.cellblockPerks[ "specialty_deadshot" ].model = "zombie_vending_ads_on";
		level.cellblockPerks[ "specialty_deadshot" ].script_noteworthy = "specialty_deadshot";
		level.cellblockPerks[ "specialty_armorvest" ] = spawnstruct();
		level.cellblockPerks[ "specialty_armorvest" ].origin = ( 1403.5, 9693.5, 1335 );
		level.cellblockPerks[ "specialty_armorvest" ].angles = ( 0, 90, 0 );
		level.cellblockPerks[ "specialty_armorvest" ].model = "zombie_vending_sleight";
		level.cellblockPerks[ "specialty_armorvest" ].script_noteworthy = "specialty_armorvest";
		level.cellblockPerks[ "specialty_rof" ] = spawnstruct();
		level.cellblockPerks[ "specialty_rof" ].origin = ( 878, 9956, 1335 );
		level.cellblockPerks[ "specialty_rof" ].angles = ( 0, 180, 0 );
		level.cellblockPerks[ "specialty_rof" ].model = "zombie_vending_doubletap2";
		level.cellblockPerks[ "specialty_rof" ].script_noteworthy = "specialty_rof";
		level.cellblockPerks[ "specialty_longersprint" ] = spawnstruct();
		level.cellblockPerks[ "specialty_longersprint" ].origin = ( -416.35, 9123.5, 1336 );
		level.cellblockPerks[ "specialty_longersprint" ].angles = ( 0, 90, 0 );
		level.cellblockPerks[ "specialty_longersprint" ].model = "p6_zm_al_vending_nuke_on";
		level.cellblockPerks[ "specialty_longersprint" ].script_noteworthy = "specialty_longersprint";
		level.cellblockPerks[ "specialty_additionalprimaryweapon" ] = spawnstruct();
		level.cellblockPerks[ "specialty_additionalprimaryweapon" ].origin = ( 1627.6, 9117.5, 1336 );
		level.cellblockPerks[ "specialty_additionalprimaryweapon" ].angles = ( 0, 90, 0 );
		level.cellblockPerks[ "specialty_additionalprimaryweapon" ].model = "p6_zm_al_vending_nuke_on";
		level.cellblockPerks[ "specialty_additionalprimaryweapon" ].script_noteworthy = "specialty_additionalprimaryweapon";
		level.cellblockPerks[ "specialty_quickrevive" ] = spawnstruct();
		level.cellblockPerks[ "specialty_quickrevive" ].origin = ( 1777.1, 10675.5, 1335 );
		level.cellblockPerks[ "specialty_quickrevive" ].angles = ( 0, -43, 0 );
		level.cellblockPerks[ "specialty_quickrevive" ].model = "p6_zm_al_vending_nuke_on";
		level.cellblockPerks[ "specialty_quickrevive" ].script_noteworthy = "specialty_quickrevive";
		level.cellblockPerks[ "specialty_flakjacket" ] = spawnstruct();
		level.cellblockPerks[ "specialty_flakjacket" ].origin = ( 1584, 9162, 1335 );
		level.cellblockPerks[ "specialty_flakjacket" ].angles = ( 0, 270, 0 );
		level.cellblockPerks[ "specialty_flakjacket" ].model = "p6_zm_al_vending_nuke_on";
		level.cellblockPerks[ "specialty_flakjacket" ].script_noteworthy = "specialty_flakjacket";
		level.cellblockPerks[ "specialty_weapupgrade" ] = spawnstruct();
		level.cellblockPerks[ "specialty_weapupgrade" ].origin = ( 891, 8349, 1544 );
		level.cellblockPerks[ "specialty_weapupgrade" ].angles = ( 0, 180, 0 );
		level.cellblockPerks[ "specialty_weapupgrade" ].model = "p6_zm_al_vending_pap_on";
		level.cellblockPerks[ "specialty_weapupgrade" ].script_noteworthy = "specialty_weapupgrade";
	}
	else if(level.script == "zm_transit")
	{
		level.cornfieldPerkArray = array( "specialty_armorvest", "specialty_rof", "specialty_fastreload", "specialty_longersprint",
								 "specialty_scavenger", "specialty_weapupgrade", "specialty_quickrevive" );
								 
		level.cornfieldPerks[ "specialty_armorvest" ] = spawnstruct();
		level.cornfieldPerks[ "specialty_armorvest" ].origin = ( 13936, -649, -189 );
		level.cornfieldPerks[ "specialty_armorvest" ].angles = ( 0, 179, 0 );
		level.cornfieldPerks[ "specialty_armorvest" ].model = "zombie_vending_jugg";
		level.cornfieldPerks[ "specialty_armorvest" ].script_noteworthy = "specialty_armorvest";
		level.cornfieldPerks[ "specialty_rof" ] = spawnstruct();
		level.cornfieldPerks[ "specialty_rof" ].origin = ( 12052, -1943, -160 );
		level.cornfieldPerks[ "specialty_rof" ].angles = ( 0, -137, 0 );
		level.cornfieldPerks[ "specialty_rof" ].model = "zombie_vending_doubletap2";
		level.cornfieldPerks[ "specialty_rof" ].script_noteworthy = "specialty_rof";
		level.cornfieldPerks[ "specialty_fastreload" ] = spawnstruct();
		level.cornfieldPerks[ "specialty_fastreload" ].origin = ( 13255, 74, -195 );
		level.cornfieldPerks[ "specialty_fastreload" ].angles = ( 0, -4, 0 );
		level.cornfieldPerks[ "specialty_fastreload" ].model = "zombie_vending_sleight";
		level.cornfieldPerks[ "specialty_fastreload" ].script_noteworthy = "specialty_fastreload";
		level.cornfieldPerks[ "specialty_longersprint" ] = spawnstruct();
		level.cornfieldPerks[ "specialty_longersprint" ].origin = ( 9944, -725, -211 );
		level.cornfieldPerks[ "specialty_longersprint" ].angles = ( 0, 133, 0 );
		level.cornfieldPerks[ "specialty_longersprint" ].model = "zombie_vending_marathon";
		level.cornfieldPerks[ "specialty_longersprint" ].script_noteworthy = "specialty_longersprint";
		level.cornfieldPerks[ "specialty_scavenger" ] = spawnstruct();
		level.cornfieldPerks[ "specialty_scavenger" ].origin = ( 13551, -1384, -188 );
		level.cornfieldPerks[ "specialty_scavenger" ].angles = ( 0, 90, 0 );
		level.cornfieldPerks[ "specialty_scavenger" ].model = "zombie_vending_tombstone";
		level.cornfieldPerks[ "specialty_scavenger" ].script_noteworthy = "specialty_scavenger";
		level.cornfieldPerks[ "specialty_weapupgrade" ] = spawnstruct();
		level.cornfieldPerks[ "specialty_weapupgrade" ].origin = ( 9960, -1288, -217 );
		level.cornfieldPerks[ "specialty_weapupgrade" ].angles = ( 0, 123, 0);
		level.cornfieldPerks[ "specialty_weapupgrade" ].model = "p6_anim_zm_buildable_pap_on";
		level.cornfieldPerks[ "specialty_weapupgrade" ].script_noteworthy = "specialty_weapupgrade";
		level.cornfieldPerks[ "specialty_quickrevive" ] = spawnstruct();
		level.cornfieldPerks[ "specialty_quickrevive" ].origin = ( 7831, -464, -203 );
		level.cornfieldPerks[ "specialty_quickrevive" ].angles = ( 0, -90, 0 );
		level.cornfieldPerks[ "specialty_quickrevive" ].model = "zombie_vending_quickrevive";
		level.cornfieldPerks[ "specialty_quickrevive" ].script_noteworthy = "specialty_quickrevive";
		
		level.dinerPerkArray = array( "specialty_armorvest", "specialty_rof", "specialty_longersprint",
								 	  "specialty_scavenger", "specialty_weapupgrade", "specialty_quickrevive" );
								 
		level.dinerPerks[ "specialty_armorvest" ] = spawnstruct();
		level.dinerPerks[ "specialty_armorvest" ].origin = ( -3634, -7464, -58 );
		level.dinerPerks[ "specialty_armorvest" ].angles = ( 0, 176, 0 );
		level.dinerPerks[ "specialty_armorvest" ].model = "zombie_vending_jugg";
		level.dinerPerks[ "specialty_armorvest" ].script_noteworthy = "specialty_armorvest";
		level.dinerPerks[ "specialty_rof" ] = spawnstruct();
		level.dinerPerks[ "specialty_rof" ].origin = ( -4170, -7610, -61 );
		level.dinerPerks[ "specialty_rof" ].angles = ( 0, -90, 0 );
		level.dinerPerks[ "specialty_rof" ].model = "zombie_vending_doubletap2";
		level.dinerPerks[ "specialty_rof" ].script_noteworthy = "specialty_rof";
		level.dinerPerks[ "specialty_longersprint" ] = spawnstruct();
		level.dinerPerks[ "specialty_longersprint" ].origin = ( -4576, -6704, -61 );
		level.dinerPerks[ "specialty_longersprint" ].angles = ( 0, 4, 0 );
		level.dinerPerks[ "specialty_longersprint" ].model = "zombie_vending_marathon";
		level.dinerPerks[ "specialty_longersprint" ].script_noteworthy = "specialty_longersprint";
		level.dinerPerks[ "specialty_scavenger" ] = spawnstruct();
		level.dinerPerks[ "specialty_scavenger" ].origin = ( -6496, -7691, 0 );
		level.dinerPerks[ "specialty_scavenger" ].angles = ( 0, 90, 0 );
		level.dinerPerks[ "specialty_scavenger" ].model = "zombie_vending_tombstone";
		level.dinerPerks[ "specialty_scavenger" ].script_noteworthy = "specialty_scavenger";
		level.dinerPerks[ "specialty_weapupgrade" ] = spawnstruct();
		level.dinerPerks[ "specialty_weapupgrade" ].origin = ( -6351, -7778, 227 );
		level.dinerPerks[ "specialty_weapupgrade" ].angles = ( 0, 175, 0 );
		level.dinerPerks[ "specialty_weapupgrade" ].model = "p6_anim_zm_buildable_pap_on";
		level.dinerPerks[ "specialty_weapupgrade" ].script_noteworthy = "specialty_weapupgrade";
		level.dinerPerks[ "specialty_quickrevive" ] = spawnstruct();
		level.dinerPerks[ "specialty_quickrevive" ].origin = ( -5424, -7920, -64 );
		level.dinerPerks[ "specialty_quickrevive" ].angles = ( 0, 137, 0 );
		level.dinerPerks[ "specialty_quickrevive" ].model = "zombie_vending_quickrevive";
		level.dinerPerks[ "specialty_quickrevive" ].script_noteworthy = "specialty_quickrevive";
		
		level.powerStationPerkArray = array( "specialty_armorvest", "specialty_rof", "specialty_fastreload",
								 			 "specialty_longersprint", "specialty_weapupgrade", "specialty_quickrevive" );
								 
		level.powerStationPerks[ "specialty_armorvest" ] = spawnstruct();
		level.powerStationPerks[ "specialty_armorvest" ].origin = ( 10746, 7282, -557 );
		level.powerStationPerks[ "specialty_armorvest" ].angles = ( 0, -132, 0 );
		level.powerStationPerks[ "specialty_armorvest" ].model = "zombie_vending_jugg";
		level.powerStationPerks[ "specialty_armorvest" ].script_noteworthy = "specialty_armorvest";
		level.powerStationPerks[ "specialty_rof" ] = spawnstruct();
		level.powerStationPerks[ "specialty_rof" ].origin = ( 11879, 7296, -755 );
		level.powerStationPerks[ "specialty_rof" ].angles = ( 0, -138, 0 );
		level.powerStationPerks[ "specialty_rof" ].model = "zombie_vending_doubletap2";
		level.powerStationPerks[ "specialty_rof" ].script_noteworthy = "specialty_rof";
		level.powerStationPerks[ "specialty_fastreload" ] = spawnstruct();
		level.powerStationPerks[ "specialty_fastreload" ].origin = ( 11568, 7723, -755 );
		level.powerStationPerks[ "specialty_fastreload" ].angles = ( 0, -1, 0 );
		level.powerStationPerks[ "specialty_fastreload" ].model = "zombie_vending_sleight";
		level.powerStationPerks[ "specialty_fastreload" ].script_noteworthy = "specialty_fastreload";
		level.powerStationPerks[ "specialty_longersprint" ] = spawnstruct();
		level.powerStationPerks[ "specialty_longersprint" ].origin = ( 10856, 7879, -576 );
		level.powerStationPerks[ "specialty_longersprint" ].angles = ( 0, -35, 0 );
		level.powerStationPerks[ "specialty_longersprint" ].model = "zombie_vending_marathon";
		level.powerStationPerks[ "specialty_longersprint" ].script_noteworthy = "specialty_longersprint";
		level.powerStationPerks[ "specialty_weapupgrade" ] = spawnstruct();
		level.powerStationPerks[ "specialty_weapupgrade" ].origin = ( 12625, 7434, -755 );
		level.powerStationPerks[ "specialty_weapupgrade" ].angles = ( 0, 162, 0 );
		level.powerStationPerks[ "specialty_weapupgrade" ].model = "p6_anim_zm_buildable_pap_on";
		level.powerStationPerks[ "specialty_weapupgrade" ].script_noteworthy = "specialty_weapupgrade";
		level.powerStationPerks[ "specialty_quickrevive" ] = spawnstruct();
		level.powerStationPerks[ "specialty_quickrevive" ].origin = ( 11156, 8120, -575 );
		level.powerStationPerks[ "specialty_quickrevive" ].angles = ( 0, -4, 0 );
		level.powerStationPerks[ "specialty_quickrevive" ].model = "zombie_vending_quickrevive";
		level.powerStationPerks[ "specialty_quickrevive" ].script_noteworthy = "specialty_quickrevive";
		
		level.tunnelPerkArray = array( "specialty_armorvest", "specialty_rof", "specialty_fastreload", "specialty_longersprint",
								 	   "specialty_scavenger", "specialty_weapupgrade", "specialty_quickrevive" );
								 
		level.tunnelPerks[ "specialty_armorvest" ] = spawnstruct();
		level.tunnelPerks[ "specialty_armorvest" ].origin = ( -11541, -2630, 194 );
		level.tunnelPerks[ "specialty_armorvest" ].angles = ( 0, -180, 0 );
		level.tunnelPerks[ "specialty_armorvest" ].model = "zombie_vending_jugg";
		level.tunnelPerks[ "specialty_armorvest" ].script_noteworthy = "specialty_armorvest";
		level.tunnelPerks[ "specialty_rof" ] = spawnstruct();
		level.tunnelPerks[ "specialty_rof" ].origin = ( -11170, -590, 196 );
		level.tunnelPerks[ "specialty_rof" ].angles = ( 0, -10, 0 );
		level.tunnelPerks[ "specialty_rof" ].model = "zombie_vending_doubletap2";
		level.tunnelPerks[ "specialty_rof" ].script_noteworthy = "specialty_rof";
		level.tunnelPerks[ "specialty_fastreload" ] = spawnstruct();
		level.tunnelPerks[ "specialty_fastreload" ].origin = ( -11373, -1674, 192 );
		level.tunnelPerks[ "specialty_fastreload" ].angles = ( 0, -89, 0 );
		level.tunnelPerks[ "specialty_fastreload" ].model = "zombie_vending_sleight";
		level.tunnelPerks[ "specialty_fastreload" ].script_noteworthy = "specialty_fastreload";
		level.tunnelPerks[ "specialty_longersprint" ] = spawnstruct();
		level.tunnelPerks[ "specialty_longersprint" ].origin = ( -11681, -734, 228 );
		level.tunnelPerks[ "specialty_longersprint" ].angles = ( 0, -19, 0 );
		level.tunnelPerks[ "specialty_longersprint" ].model = "zombie_vending_marathon";
		level.tunnelPerks[ "specialty_longersprint" ].script_noteworthy = "specialty_longersprint";
		level.tunnelPerks[ "specialty_scavenger" ] = spawnstruct();
		level.tunnelPerks[ "specialty_scavenger" ].origin = ( -10664, -757, 196 );
		level.tunnelPerks[ "specialty_scavenger" ].angles = ( 0, -98, 0 );
		level.tunnelPerks[ "specialty_scavenger" ].model = "zombie_vending_tombstone";
		level.tunnelPerks[ "specialty_scavenger" ].script_noteworthy = "specialty_scavenger";
		level.tunnelPerks[ "specialty_weapupgrade" ] = spawnstruct();
		level.tunnelPerks[ "specialty_weapupgrade" ].origin = ( -11301, -2096, 184 );
		level.tunnelPerks[ "specialty_weapupgrade" ].angles = ( 0, 115, 0 );
		level.tunnelPerks[ "specialty_weapupgrade" ].model = "p6_anim_zm_buildable_pap_on";
		level.tunnelPerks[ "specialty_weapupgrade" ].script_noteworthy = "specialty_weapupgrade";
		level.tunnelPerks[ "specialty_quickrevive" ] = spawnstruct();
		level.tunnelPerks[ "specialty_quickrevive" ].origin = ( -10780, -2565, 224 );
		level.tunnelPerks[ "specialty_quickrevive" ].angles = ( 0, 270, 0 );
		level.tunnelPerks[ "specialty_quickrevive" ].model = "zombie_vending_quickrevive";
		level.tunnelPerks[ "specialty_quickrevive" ].script_noteworthy = "specialty_quickrevive";
		
		level.housePerkArray = array( "specialty_weapupgrade" );

		level.housePerks["specialty_weapupgrade"] = spawnstruct();
		level.housePerks["specialty_weapupgrade"].origin = (5394,6869,-23);
		level.housePerks["specialty_weapupgrade"].angles = (0,90,0);
		level.housePerks["specialty_weapupgrade"].model = "tag_origin";
		level.housePerks["specialty_weapupgrade"].script_noteworthy = "specialty_weapupgrade";

		level.farmPerkArray = array( "specialty_weapupgrade" );

		level.farmPerks["specialty_weapupgrade"] = spawnstruct();
		level.farmPerks["specialty_weapupgrade"].origin = (7057, -5727, -49);
		level.farmPerks["specialty_weapupgrade"].angles = (0,90,0);
		level.farmPerks["specialty_weapupgrade"].model = "p6_anim_zm_buildable_pap_on";
		level.farmPerks["specialty_weapupgrade"].script_noteworthy = "specialty_weapupgrade";

		level.busPerkArray = array( "specialty_quickrevive", "specialty_weapupgrade", "specialty_armorvest", "specialty_rof", "specialty_fastreload" );

		level.busPerks[ "specialty_quickrevive" ] = spawnstruct();
		level.busPerks[ "specialty_quickrevive" ].origin = (-6706, 5016, -56);
		level.busPerks[ "specialty_quickrevive" ].angles = (0, 180, 0 );
		level.busPerks[ "specialty_quickrevive" ].model = "zombie_vending_quickrevive";
		level.busPerks[ "specialty_quickrevive" ].script_noteworthy = "specialty_quickrevive";
		level.busPerks["specialty_weapupgrade"] = spawnstruct();
		level.busPerks["specialty_weapupgrade"].origin = (-6834, 4553, -65);
		level.busPerks["specialty_weapupgrade"].angles = (0,230,0);
		level.busPerks["specialty_weapupgrade"].model = "p6_anim_zm_buildable_pap_on";
		level.busPerks["specialty_weapupgrade"].script_noteworthy = "specialty_weapupgrade";
		level.busPerks["specialty_armorvest"] = spawnstruct();
		level.busPerks["specialty_armorvest"].origin = (-6122, 4110, -52);
		level.busPerks["specialty_armorvest"].angles = (0,180,0);
		level.busPerks["specialty_armorvest"].model = "zombie_vending_jugg";
		level.busPerks["specialty_armorvest"].script_noteworthy = "specialty_armorvest";
		level.busPerks[ "specialty_rof" ] = spawnstruct();
		level.busPerks[ "specialty_rof" ].origin = (-6241, 5337, -56);
		level.busPerks[ "specialty_rof" ].angles = ( 0, 180, 0 );
		level.busPerks[ "specialty_rof" ].model = "zombie_vending_doubletap2";
		level.busPerks[ "specialty_rof" ].script_noteworthy = "specialty_rof";
		level.busPerks[ "specialty_fastreload" ] = spawnstruct();
		level.busPerks[ "specialty_fastreload" ].origin = (-7489, 4217, -64);
		level.busPerks[ "specialty_fastreload" ].angles = ( 0, 120, 0 );
		level.busPerks[ "specialty_fastreload" ].model = "zombie_vending_sleight";
		level.busPerks[ "specialty_fastreload" ].script_noteworthy = "specialty_fastreload";
	}
	else if(level.script == "zm_highrise")
	{
		level.building1topPerkArray = array( "specialty_quickrevive", "specialty_armorvest", "specialty_rof", "specialty_fastreload", "specialty_flakjacket", "specialty_additionalprimaryweapon", "specialty_weapupgrade" );

		level.building1topPerks[ "specialty_quickrevive" ] = spawnstruct();
		level.building1topPerks[ "specialty_quickrevive" ].origin = (1435, 1225, 3390);
		level.building1topPerks[ "specialty_quickrevive" ].angles = (-10, 180, 0 );
		level.building1topPerks[ "specialty_quickrevive" ].model = "zombie_vending_quickrevive";
		level.building1topPerks[ "specialty_quickrevive" ].script_noteworthy = "specialty_quickrevive";
		level.building1topPerks[ "specialty_armorvest" ] = spawnstruct();
		level.building1topPerks[ "specialty_armorvest" ].origin = (1444.47, 2713.98, 3048.52);
		level.building1topPerks[ "specialty_armorvest" ].angles = ( 0, 270, 0 );
		level.building1topPerks[ "specialty_armorvest" ].model = "zombie_vending_jugg";
		level.building1topPerks[ "specialty_armorvest" ].script_noteworthy = "specialty_armorvest";
		level.building1topPerks[ "specialty_rof" ] = spawnstruct();
		level.building1topPerks[ "specialty_rof" ].origin = (2286.36, 2122.6, 3040.13);
		level.building1topPerks[ "specialty_rof" ].angles = ( 0, 270, 0 );
		level.building1topPerks[ "specialty_rof" ].model = "zombie_vending_doubletap2";
		level.building1topPerks[ "specialty_rof" ].script_noteworthy = "specialty_rof";
		level.building1topPerks[ "specialty_fastreload" ] = spawnstruct();
		level.building1topPerks[ "specialty_fastreload" ].origin = (1916.92, 1139.1, 3216.13);
		level.building1topPerks[ "specialty_fastreload" ].angles = ( 0, 135, 0 );
		level.building1topPerks[ "specialty_fastreload" ].model = "zombie_vending_sleight";
		level.building1topPerks[ "specialty_fastreload" ].script_noteworthy = "specialty_fastreload";
		level.building1topPerks[ "specialty_flakjacket" ] = spawnstruct();
		level.building1topPerks[ "specialty_flakjacket" ].origin = (1421.23, 2102.13, 3219.31);
		level.building1topPerks[ "specialty_flakjacket" ].angles = ( 0, 45, 0 );
		level.building1topPerks[ "specialty_flakjacket" ].model = "zombie_vending_nuke_on_lo";
		level.building1topPerks[ "specialty_flakjacket" ].script_noteworthy = "specialty_flakjacket";
		level.building1topPerks[ "specialty_additionalprimaryweapon" ] = spawnstruct();
		level.building1topPerks[ "specialty_additionalprimaryweapon" ].origin = (1521.58, 2094.12, 3392.13);
		level.building1topPerks[ "specialty_additionalprimaryweapon" ].angles = ( 0, 90, 0 );
		level.building1topPerks[ "specialty_additionalprimaryweapon" ].model = "zombie_vending_three_gun";
		level.building1topPerks[ "specialty_additionalprimaryweapon" ].script_noteworthy = "specialty_additionalprimaryweapon";
		level.building1topPerks["specialty_weapupgrade"] = spawnstruct();
		level.building1topPerks["specialty_weapupgrade"].origin = (1195.34, 1281.47, 3392.13);
		level.building1topPerks["specialty_weapupgrade"].angles = (0, 90, 0);
		level.building1topPerks["specialty_weapupgrade"].model = "p6_anim_zm_buildable_pap_on";
		level.building1topPerks["specialty_weapupgrade"].script_noteworthy = "specialty_weapupgrade";
	}
	else if(level.script == "zm_buried")
	{
		level.mazePerkArray = array( "specialty_quickrevive", "specialty_armorvest", "specialty_rof", "specialty_fastreload", "specialty_additionalprimaryweapon", "specialty_longersprint", "specialty_weapupgrade" );

		pLA = [];
		pLA[0] = spawnstruct();
		pLA[0].origin = (4897.65, 724.522, 2.91781);
		pLA[0].angles = (0,0,0);
		pLA[1] = spawnstruct();
		pLA[1].origin = (6704.95, 944.359, 108.125);
		pLA[1].angles = (0,5,0);
		pLA[2] = spawnstruct();
		pLA[2].origin = (6994.16, 360.486, 108.125);
		pLA[2].angles = (0,236,0);
		pLA[3] = spawnstruct();
		pLA[3].origin = (5439, 870, 4.125);
		pLA[3].angles = (0,180,0);
		pLA[4] = spawnstruct();
		pLA[4].origin = (3434.58, 848.447, 57.4652);
		pLA[4].angles = (0,90,0);
		pLA[5] = spawnstruct();
		pLA[5].origin = (5211.65, 57.4669, 4.125);
		pLA[5].angles = (0,90,0);
		pLA[6] = spawnstruct();
		pLA[6].origin = (4115.64, -126.73, 4.125);
		pLA[6].angles = (0,90,0);
		pLA[7] = spawnstruct();
		pLA[7].origin = (4586.63, 1100.12, 4.125);
		pLA[7].angles = (0,270,0);
		pLA = array_randomize(pLA);
		level.mazePerks[ "specialty_armorvest" ] = spawnstruct();
		level.mazePerks[ "specialty_armorvest" ].origin = pLA[0].origin;
		level.mazePerks[ "specialty_armorvest" ].angles = pLA[0].angles;
		level.mazePerks[ "specialty_armorvest" ].model = "zombie_vending_jugg";
		level.mazePerks[ "specialty_armorvest" ].script_noteworthy = "specialty_armorvest";
		level.mazePerks[ "specialty_quickrevive" ] = spawnstruct();
		level.mazePerks[ "specialty_quickrevive" ].origin = pLA[1].origin;
		level.mazePerks[ "specialty_quickrevive" ].angles = pLA[1].angles;
		level.mazePerks[ "specialty_quickrevive" ].model = "zombie_vending_quickrevive";
		level.mazePerks[ "specialty_quickrevive" ].script_noteworthy = "specialty_quickrevive";
		level.mazePerks[ "specialty_rof" ] = spawnstruct();
		level.mazePerks[ "specialty_rof" ].origin = pLA[2].origin;
		level.mazePerks[ "specialty_rof" ].angles = pLA[2].angles;
		level.mazePerks[ "specialty_rof" ].model = "zombie_vending_doubletap2";
		level.mazePerks[ "specialty_rof" ].script_noteworthy = "specialty_rof";
		level.mazePerks[ "specialty_fastreload" ] = spawnstruct();
		level.mazePerks[ "specialty_fastreload" ].origin = pLA[3].origin;
		level.mazePerks[ "specialty_fastreload" ].angles = pLA[3].angles;
		level.mazePerks[ "specialty_fastreload" ].model = "zombie_vending_sleight";
		level.mazePerks[ "specialty_fastreload" ].script_noteworthy = "specialty_fastreload";
		level.mazePerks[ "specialty_additionalprimaryweapon" ] = spawnstruct();
		level.mazePerks[ "specialty_additionalprimaryweapon" ].origin = pLA[4].origin;
		level.mazePerks[ "specialty_additionalprimaryweapon" ].angles = pLA[4].angles;
		level.mazePerks[ "specialty_additionalprimaryweapon" ].model = "zombie_vending_three_gun";
		level.mazePerks[ "specialty_additionalprimaryweapon" ].script_noteworthy = "specialty_additionalprimaryweapon";
		level.mazePerks[ "specialty_longersprint" ] = spawnstruct();
		level.mazePerks[ "specialty_longersprint" ].origin = pLA[5].origin;
		level.mazePerks[ "specialty_longersprint" ].angles = pLA[5].angles;
		level.mazePerks[ "specialty_longersprint" ].model = "zombie_vending_marathon";
		level.mazePerks[ "specialty_longersprint" ].script_noteworthy = "specialty_longersprint";
		level.mazePerks[ "specialty_weapupgrade" ] = spawnstruct();
		level.mazePerks[ "specialty_weapupgrade" ].origin = pLA[6].origin;
		level.mazePerks[ "specialty_weapupgrade" ].angles = pLA[6].angles;
		level.mazePerks[ "specialty_weapupgrade" ].model = "p6_anim_zm_buildable_pap_on";
		level.mazePerks[ "specialty_weapupgrade" ].script_noteworthy = "specialty_weapupgrade";
	}
}