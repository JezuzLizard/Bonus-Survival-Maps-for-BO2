#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;
#include maps/mp/zombies/_zm_buildables;
#include maps/mp/zombies/_zm_game_module;
#include maps/mp/zombies/_zm_ai_basic;
#include maps/mp/gametypes_zm/_weapons;
#include maps/mp/zombies/_zm_perks;
#include maps/mp/gametypes_zm/_hud_util;

main()
{
	if(GetDvar("customMap") == "vanilla")
		return;
	replacefunc(maps/mp/zombies/_zm_perks::get_perk_array, ::get_perk_array);
}

init()
{
	//level.player_out_of_playable_area_monitor = 0;
	level.player_starting_points = 500;
	//level.perk_purchase_limit = 10;
	if(level.customMap == "vanilla")
		return;
	thread init_custom_map();
	if ( isDefined ( level.customMap ) && level.customMap != "vanilla" || getDvar("customMap") == "farm")
	{
		setDvar( "scr_screecher_ignore_player", 1 );
	}
	level.callbackactordamage = ::actor_damage_override_wrapper;
	thread logspam();
}

logspam()
{
	level endon("end_game");
	while(1)
	{
		logprint("Server Up " + level.round_number + "\n" );
		wait 1;
	}
}

meleeCoords()
{
	level endon("end_game");
	self endon("disconnnect");
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

get_perk_array( ignore_chugabud ) //checked matches cerberus output
{
	perk_array = [];
	if ( self hasperk( "specialty_armorvest" ) )
	{
		perk_array[ perk_array.size ] = "specialty_armorvest";
	}
	if ( self hasperk( "specialty_deadshot" ) )
	{
		perk_array[ perk_array.size ] = "specialty_deadshot";
	}
	if ( self hasperk( "specialty_fastreload" ) )
	{
		perk_array[ perk_array.size ] = "specialty_fastreload";
	}
	if ( self hasperk( "specialty_longersprint" ) )
	{
		perk_array[ perk_array.size ] = "specialty_longersprint";
	}
	if ( self hasperk( "specialty_quickrevive" ) )
	{
		perk_array[ perk_array.size ] = "specialty_quickrevive";
	}
	if ( self hasperk( "specialty_rof" ) )
	{
		perk_array[ perk_array.size ] = "specialty_rof";
	}
	if ( self hasperk( "specialty_additionalprimaryweapon" ) )
	{
		perk_array[ perk_array.size ] = "specialty_additionalprimaryweapon";
	}
	if ( !isDefined( ignore_chugabud ) || ignore_chugabud == 0 )
	{
		if ( self hasperk( "specialty_finalstand" ) )
		{
			perk_array[ perk_array.size ] = "specialty_finalstand";
		}
	}
	if ( level._custom_perks.size > 0 )
	{
		a_keys = getarraykeys( level._custom_perks );
		for ( i = 0; i < a_keys.size; i++ )
		{
			if ( self hasperk( a_keys[ i ] ) )
			{
				perk_array[ perk_array.size ] = a_keys[ i ];
			}
		}
	}
	return perk_array; 
}

init_custom_map()
{
	level thread onplayerconnected();
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
	level endon("end_game");
	for ( ;; )
	{
		level waittill( "connected", player );
		player thread addPerkSlot();
		player thread onplayerspawned();
		player thread perkHud();
		//player thread meleeCoords();
	}
}

perkHud()
{
	if(level.script != "zm_prison" && level.script != "zm_highrise")
		return;
	if(isdefined(level.customMap) && level.customMap == "vanilla")
		return;
	self endon("disconnect");
	level endon("end_game");
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
	self endon("disconnect");
	level endon("end_game");
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
		//bot = AddTestClient();
		if(isFirstSpawn)
		{
			self initOverFlowFix();

			isFirstSpawn = false;
		}
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
		if(is_true(level.customMap == "building1top"))
		{
			level.zombie_include_weapons[ "slipgun_zm" ] = 1;
			level.zombie_weapons[ "slipgun_zm" ].is_in_box = 1;
		}
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
	
	level.planeBuiltOnRound = getDvarIntDefault( "planeBuiltOnRound", 1 );
	level.zombie_vars[ "planeBuiltOnRound" ] = level.planeBuiltOnRound;
	
	for ( ;; )
	{
		level waittill ( "between_round_over" );
		if ( level.round_number >= level.planeBuiltOnRound )
		{
			buildcraftable( "plane" );
			break;
		}
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
	if ( isDefined( level.zombiemode_using_chugabud_perk ) && level.zombiemode_using_chugabud_perk && level.customMap != "building1top" && level.customMap != "redroom")
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
