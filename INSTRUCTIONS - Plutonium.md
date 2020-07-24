# How to install

If you do not include all these files you will be missing core components of the mod you have been warned.

Create any folders if they do not exist! 

**Compile _clientids.gsc as _clientids.gsc and place it in maps/mp/gametypes_zm**
Disables perma perks, spawns in the wunderfizz, builds certain buildables, and adds restart fix.

**Compile _zm_gametype.gsc as _zm_gametype.gsc and place it in maps/mp/gametypes_zm**
Sets spawnpoints and respawn points. Also sets the map, and contains the map rotation system.

**Compiler _zm_audio_announcer.gsc as _zm_audio_announcer.gsc and place it maps/mp/zombies**
Fixes the audio announcer not playing his voicelines when powerups are grabbed.

**Compile _zm_perks.gsc as _zm_perks.gsc and place it in maps/mp/zombies**
Spawns in perk machines for all maps.

**Compile _zm_weapons.gsc as _zm_weapons.gsc and place it in maps/mp/zombies**
Moves wallbuys to desired locations.

**Compile _zm_magicbox.gsc as _zm_magicbox.gsc and place it in maps/mp/zombies**
Moves mystery boxes depending on the location.

**Compile _zm_zonemgr.gsc as _zm_zonemgr.gsc and place it maps/mp/zombies**
Removes certain zombie spawns and moves certain zombies spawns.

**Compile _zm_powerups.gsc as _zm_powerups.gsc and place it maps/mp/zombies**
Allows powerups to move to the stump on house.

**Compile zm_transit_classic.gsc as zm_transit_classic.gsc and place it in maps/mp**
Responsible for disabling the bus, and avogadro.

# How to launch

Set the map to tranzit and include these special dvars in your dedicated_zm.cfg:
```
set customMapRotation "diner power cornfield tunnel house" // rearrange the order of these or remove locations to change the rotation
set randomizeMapRotation 0 //set this to 1 to enable randomized map rotation
set customMapRotationActive 0 //set this to 1 to enable map rotation
set customMap "tunnel" //the initial map or constant map if map rotation is off
set perkSlotIncreaseKills 0 // Set Amount of Kills each player must earn to increase their perk slots (0 turns off this option)
```

# How to modify

Just like any script thats open source you can mod these scripts to your hearts content.
Whats unique about this mod is the sheer number of core game scripts that it modifies.
Modifying these is no different than modifying any other script, however modifying these scripts allow you to modify core game mechanics if you so choose.
Each script's functions that have been modified by us for the mod are indicated as such so you can tell what functions are custom to the mod and which oens are modified by the mod.
Simply search "custom function" for custom functions and "modified function" for modified functions.
If are in need of more recompileable scripts for your mod feel free to check this github project here: https://github.com/JezuzLizard/Recompilable-gscs-for-BO2-zombies-and-multiplayer

