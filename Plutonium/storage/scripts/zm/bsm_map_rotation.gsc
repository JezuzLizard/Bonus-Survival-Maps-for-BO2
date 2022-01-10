#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;

main()
{
	override_map();
}

init()
{
	thread map_rotation();
}

override_map()
{
	level.zeGamemode = ToLower( GetDvar( "zeGamemode"));
	mapname = ToLower( GetDvar( "mapname" ) );
	if(level.zeGamemode == "" || level.zeGamemode != "vanilla" && level.zeGamemode != "sharpshooter" && level.zeGamemode != "survival" )
		level.zeGamemode = "survival";
	if( GetDvar("customMap") == "" )
		SetDvar("customMap", "vanilla");
	if( (level.zeGamemode != "vanilla" && GetDvar("customMap") == "vanilla") || (level.zeGamemode == "vanilla" && GetDvar("customMap") != "vanilla")  )
	{
		SetDvar( "zeGamemode", "vanilla" );
		SetDvar( "customMap", "vanilla" );
		map_restart(false);
	}
	if ( isdefined(mapname) && mapname == "zm_transit" )
	{
		if ( GetDvar("customMap") != "tunnel" && GetDvar("customMap") != "diner" && GetDvar("customMap") != "power" && GetDvar("customMap") != "cornfield" && GetDvar("customMap") != "house" && GetDvar("customMap") != "vanilla" && GetDvar("customMap") != "town" && GetDvar("customMap") != "farm" && GetDvar("customMap") != "busdepot" )
		{
			SetDvar( "customMap", "house" );
		}
	}
	else if ( isdefined(mapname) && mapname == "zm_nuked" )
	{
		if ( GetDvar("customMap") != "nuketown" && GetDvar("customMap") != "vanilla")
		{
			SetDvar("customMap", "nuketown");
		}
	}
	else if ( isdefined(mapname) && mapname == "zm_highrise" )
	{
		if ( GetDvar("customMap") != "building1top" && GetDvar("customMap") != "redroom" && GetDvar("customMap") != "vanilla" )
		{
			SetDvar( "customMap", "building1top" );
		}
	}
	else if ( isdefined(mapname) && mapname == "zm_prison" )
	{
		if ( GetDvar("customMap") != "showers" && GetDvar("customMap") != "docks" && GetDvar("customMap") != "cellblock" && GetDvar("customMap") != "rooftop" && GetDvar("customMap") != "vanilla" )
		{
			SetDvar( "customMap", "docks" );
		}
	}
	else if ( isdefined(mapname) && mapname == "zm_buried" )
	{
		if ( GetDvar("customMap") != "maze" && GetDvar("customMap") != "vanilla")
		{
			SetDvar( "customMap", "maze" );
		}
	}
	else if ( isdefined(mapname) && mapname == "zm_tomb" )
	{
		if ( GetDvar("customMap") != "trenches" && GetDvar("customMap") != "crazyplace" && GetDvar("customMap") != "excavation" && GetDvar("customMap") != "vanilla" )
		{
			SetDvar( "customMap", "trenches" );
		}
	}
	map = ToLower(GetDvar("customMap"));
	if(map == "town" || map == "busdepot" || map == "farm" || map == "nuketown")
	{
		level.customMap = "vanilla";
	}
	else
	{
		level.customMap = map;
	}
	level.disableBSMMagic = getDvarIntDefault("disableBSMMagic", 0);
	if(level.zeGamemode == "sharpshooter")
	{
		level.disableBSMMagic = 1;
	}
	level notify("customMapSet");
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
		level.customMapRotation = "nuketown cellblock trenches busdepot building1top maze";
	}
	if ( level.randomizeMapRotation && level.mapList.size > 3 )
	{
		level thread random_map_rotation();
		return;
	}
	for(i=0;i<level.mapList.size;i++)
	{
		if(isdefined(level.mapList[i+1]) && getDvar("customMap") == level.mapList[i])
		{
			changeMap(level.mapList[i+1]);
			return;
		}
	}
	changeMap(level.mapList[0]);
}

changeMap(map)
{
	if(!isdefined(map))
		map = GetDvar("customMap");
	SetDvar("customMap", map);
	if(map == "tunnel" || map == "diner" || map == "power" || map == "cornfield" || map == "house")
		SetDvar("sv_maprotation","exec zm_classic_transit.cfg map zm_transit");
	else if(map == "town")
		SetDvar("sv_maprotation","exec zm_standard_town.cfg map zm_transit");
	else if(map == "farm")
		SetDvar("sv_maprotation","exec zm_standard_farm.cfg map zm_transit");
	else if(map == "busdepot")
		SetDvar("sv_maprotation","exec zm_standard_transit.cfg map zm_transit");
	else if(map == "nuketown")
		SetDvar("sv_maprotation","exec zm_standard_nuked.cfg map zm_nuked");
	else if(map == "showers" || map == "docks" || map == "cellblock" || map == "rooftop")
		SetDvar("sv_maprotation","exec zm_classic_prison.cfg map zm_prison");
	else if(map == "building1top" || map == "redroom")
		SetDvar("sv_maprotation", "exec zm_classic_rooftop.cfg map zm_highrise");
	else if(map == "maze")
		SetDvar("sv_maprotation", "exec zm_classic_processing.cfg map zm_buried");
	else if(map == "trenches" || map == "crazyplace")
		SetDvar("sv_maprotation", "exec zm_classic_tomb.cfg map zm_tomb");
}

random_map_rotation() //custom function
{
	level.nextMap = RandomInt( level.mapList.size );
	level.lastMap = getDvar( "lastMap" );
	if( getDvar("customMap") == level.mapList[ level.nextMap ] || level.mapList[ level.nextMap ] == level.lastMap )
	{
		return random_map_rotation();
	}
	else
	{
		setDvar( "lastMap", getDvar("customMap") );
		changeMap(level.mapList[ level.nextMap ]);
		return;
	}
}