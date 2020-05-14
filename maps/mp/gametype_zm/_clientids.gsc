#include maps/mp/zombies/_zm_utility;
#include maps/common_scripts/utility;
#include maps/mp/_utility;

init()
{
	screecher_spawner_remover();
}

screecher_spawner_remover()
{
	objects = getentarray();
	for ( i = 0; i < objects.size; i++ )
	{
		if ( isDefined( objects[ i ].script_noteworthy ) && objects[ i ].script_noteworthy == "screecher_location" || isDefined( objects[ i ].script_noteworthy ) && objects[ i ].script_noteworthy == "riser_location screecher_location" )
		{
			logline1 = "The object: " + objects[ i ].script_noteworthy + " is deleted" + "\n";
			logprint( logline1 );
			objects[ i ] delete();
		}
		/*
		else if ( isDefined( objects[ i ].targetname ) )
		{
			if ( objects[ i ].targetname == "screecher_volume" )
			{
				logline2 = "The object: " + objects[ i ].targetname + " is deleted" + "\n";
				logprint( logline2 );
				objects[ i ] delete();
			}
		}
		*/
	}
}
