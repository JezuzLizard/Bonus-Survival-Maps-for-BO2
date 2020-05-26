#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;
#include maps/mp/zombies/_zm_buildables;
#include maps/mp/zombies/_zm_game_module;
#include maps/mp/zombies/_zm_ai_basic;
#include maps/mp/gametypes_zm/_weapons;
#include maps/mp/zombies/_zm_afterlife;

init()
{
	thread gscRestart();
	thread setPlayersToSpectator();
	level.player_out_of_playable_area_monitor = 0;
	setDvar( "scr_screecher_ignore_player", 1 );
	thread init_custom_map();
	if ( level.customMap == "house" )
	{
		thread wunderfizz((4782,5998,-64),(0,111,0), "zombie_vending_jugg");
    }
}

init_custom_map()
{
	level thread onplayerconnected();
	disable_pers_upgrades();
	thread init_buildables();
}

onplayerconnected()
{
	for ( ;; )
	{
		level waittill( "connected", player );
		player thread addPerkSlot();
		player thread onplayerspawned();
		player thread [[ level.givecustomcharacters ]]();
		if(level.script == "zm_prison")
		{
			player thread afterlife_doors_close();
		}
	}
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
			self IPrintLnBold("You can now hold: " + self.player_perk_purchase_limit + " perks!");
			completedCount++;
		}
		if((perks.size - level.perk_purchase_limit) <= completedCount)
			break;
		wait .1;
	}
}

onplayerspawned()
{
	for ( ;; )
	{
		self waittill( "spawned_player" );
		self thread disable_player_pers_upgrades();
		level notify ( "check_count" );
	}
}

disable_pers_upgrades() //credit to Jbleezy for this function
{
	level waittill("initial_disable_player_pers_upgrades");

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
	level notify("initial_disable_player_pers_upgrades");
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
	else if ( isDefined( level.customMap ) && level.customMap == "docks" )
	{
		thread auto_upgrade_tower();
		thread disable_gondola();
		thread disable_door();
		thread disable_afterlife_boxes();
		thread modified_hellhound();
		wait 2;
		level notify( "cable_puzzle_gate_afterlife" );
		flag_set( "power_on" );
		level setclientfield( "zombie_power_on", 1 );
		buildcraftable( "quest_key1" );
		buildcraftable( "alcatraz_shield_zm" );
		buildcraftable( "plane" );
		changecraftableoption( 0 );
		wait 1;
		level notify( "sleight_on" );
		wait_network_frame();
		level notify( "doubletap_on" );
		wait_network_frame();
		level notify( "juggernog_on" );
		wait_network_frame();
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

getPerks()
{
	perks = [];
	//Order is Rainbow
	if(isDefined(level.zombiemode_using_juggernaut_perk) && level.zombiemode_using_juggernaut_perk)
	{
		perks[perks.size] = "specialty_armorvest";
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
	if ( isDefined( level._custom_perks[ "specialty_grenadepulldeath" ].perk_machine_set_kvps ))
	{
		perks[perks.size] = "specialty_grenadepulldeath";
	}
	if ( isDefined( level._custom_perks[ "specialty_flakjacket" ].perk_machine_set_kvps ))
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
		return "zombie_vending_jugg";
	if(perk == "specialty_rof")
		return "zombie_vending_doubletap2";
	if(perk == "specialty_longersprint")
		return "zombie_vending_marathon";
	if(perk == "specialty_fastreload")
		return "zombie_vending_sleight";
	if(perk == "specialty_quickrevive")
		return "zombie_vending_revive";
	if(perk == "specialty_scavenger")
		return "zombie_vending_tombstone";
}

wunderfizz(origin, angles, model)
{
	collision = spawn("script_model", origin);
    collision setModel("collision_geo_cylinder_32x128_standard");
    collision rotateTo(angles, .1);
	wunderfizzMachine = spawn("script_model", origin);
	wunderfizzMachine setModel(model);
	wunderfizzMachine rotateTo(angles, .1);
	perks = getPerks();
	cost = 1500;
	trig = spawn("trigger_radius", origin, 1, 50, 50);
	trig SetCursorHint("HINT_NOICON");
	trig SetHintString("Hold ^3&&1^7 to buy Perk-a-Cola [Cost: " + cost + "]");
	level waittill("connected", player);
	for(;;)
	{
		trig waittill("trigger", player);
		if(player UseButtonPressed() && player.score >= cost && player.isDrinkingPerk == 0)
		{
			if(player.num_perks < (player get_player_perk_purchase_limit()))
			{
				if(player.num_perks < perks.size)
				{
					player playsound("zmb_cha_ching");
					player.score -= cost;
					trig setHintString("Randomizing");
					rtime = 3;
					while(rtime>0)
					{
						if(level.script == "zm_transit")
						{
							for(;;)
							{
								perkForRandom = perks[randomInt(perks.size)];
								if(!(player hasPerk(perkForRandom)))
								{
									wunderfizzMachine setModel(getPerkModel(perkForRandom));
									break;
								}
							}
						}
						wait .1;
						rtime -= .1;
					}
					perklist = array_randomize(perks);
					for(j=0;j<perklist.size;j++)
					{
						if(!(player hasPerk(perklist[j])))
						{
							perkName = getPerkName(perklist[j]);
							if(level.script == "zm_transit")
								perkModel = getPerkModel(perklist[j]);
							wunderfizzMachine setModel(perkModel + "_on");
							fx = SpawnFX(level._effect["tombstone_light"], origin, AnglesToForward(angles),AnglesToUp(angles));
							TriggerFX(fx);
							trig SetHintString("Hold ^3&&1^7 for " + perkName);
							time = 7;
							while(time > 0)
							{
								if(player UseButtonPressed() && distance(player.origin, trig.origin) < 50)
								{
									player thread givePerk(perklist[j]);
									wunderfizzMachine setModel(model);
									trig SetHintString(" ");
									fx Delete();
									break;
								}
								wait .1;
								time -= .1;
							}
							wunderfizzMachine setModel(model);
							trig SetHintString(" ");
							fx Delete();
							break;
						}
					}
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
				trig SetHintString("You Can Only Hold " + (player get_player_perk_purchase_limit()) + " Perks");
				wait 2;
				trig SetHintString("Hold ^3&&1^7 to buy Perk-a-Cola [Cost: " + cost + "]");
			}
		}
		wait .1;
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

gscRestart()
{
	level waittill( "end_game" );
	setDvar( "customMapsMapRestarted", 1 );
	wait 12; //20 is ideal
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

disable_gondola()
{
	wait 3;
	level notify( "gondola_powered_on_roof" );
	t_call_triggers = getentarray( "gondola_call_trigger", "targetname" );
	call_triggers = getFirstArrayKey( t_call_triggers );
	while ( isDefined( call_triggers ) )
	{
		trigger = t_call_triggers[ call_triggers ];
		trigger.origin = ( 0, 0, 0 );
		return;
	}
}

disable_door()
{
	zm_doors = getentarray( "zombie_door", "targetname" );
	i = 0;
	while ( i < zm_doors.size )
	{
		if ( zm_doors[ i ].origin == ( 101, 8124, 311 ) )
		{
			zm_doors[ i ].origin = ( 0, 0, 0 );
		}
		i++;
	}
}

disable_afterlife_boxes()
{
	a_afterlife_triggers = getstructarray( "afterlife_trigger", "targetname" );
	_a87 = a_afterlife_triggers;
	_k87 = getFirstArrayKey( _a87 );
	while ( isDefined( _k87 ) )
	{
		struct = _a87[ _k87 ];
		if ( struct.origin == ( -1390.02, 5371.56, -24 ) || struct.origin == ( 339.684, 6529.53, 312 ) )
		{
			struct.unitrigger_stub.origin = ( 0, 0, 0 );
		}
		_k87 = getNextArrayKey( _a87, _k87 );
	}
}

modified_hellhound()
{
	tomahawk_effect = getstruct( "tomahawk_pickup_pos", "targetname" );
	tomahawk_effect.origin = ( 981.75, 5818.75, 314.125 );
	
	tomahawk_trigger = getstruct( "tomahawk_trigger_pos", "targetname" );
	tomahawk_trigger.origin = ( 981.75, 5818.75, 314.125 );
	
	level.zombies_required = 0;
	
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
		if ( level.zombies_required == 35 )
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
			level thread maps/mp/zombies/_zm_audio::sndmusicstingerevent( "quest_generic" );
			return;
		}
		else
		{
			wait 0.25;
		}
	}
}

auto_upgrade_tower()
{
	for(;;)
	{
		level waittill( "trap_activated" );
		wait 2;
		level notify( "tower_trap_upgraded" );
	}
}
