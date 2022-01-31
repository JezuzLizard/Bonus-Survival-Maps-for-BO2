# How to install

If you do not include all these files you will be missing core components of the mod you have been warned.

Create any folders if they do not exist! 

**Compile bsm_main.gsc as bsm_main.gsc and place it in %localappdata%/Plutonium/storage/t6/scripts/zm/**

**All other scripts follow the same process**

If using pre-compiled scripts,

**place scripts folder inside of the .zip file into %localappdata%/Plutonium/storage/t6/**

# How to launch

Set the map to tranzit and include these special dvars in your dedicated_zm.cfg:
```
set zeGamemode "survival"
set customMapRotation "diner power cornfield tunnel house town farm busdepot nuketown docks cellblock rooftop building1top maze trenches crazyplace" // rearrange the order of these or remove locations to change the rotation
set randomizeMapRotation 0 //set this to 1 to enable randomized map rotation
set customMapRotationActive 1 //set this to 1 to enable map rotation
set customMap "diner" //the initial map or constant map if map rotation is off
set disableBSMMagic 0 //set this to 1 to disable magic (Perks/Pack a Punch) Box enabled still
set useBossZombies 1 //set this to 1 to enable bosses (Brutus on Mob/Panzer on Origins) (on by default)
set perkSlotIncreaseKills 150 // Set Amount of Kills each player must earn to increase their perk slots (0 turns off this option)
```
Then set the sv_maprotation to the **FIRST MAP IN YOUR ROTATION.** This is important. Only the first map goes into sv_maprotation. The mod does the rest of the work.
If you set the wrong map in sv_maprotation, the mod will fix itself for you after the first game ends.

# How to modify

Just like any script thats open source you can mod these scripts to your hearts content.
Whats unique about this mod is the sheer number of core game scripts that it modifies.
Modifying these is no different than modifying any other script, however modifying these scripts allow you to modify core game mechanics if you so choose.
Each script's functions that have been modified by us for the mod are indicated as such so you can tell what functions are custom to the mod and which oens are modified by the mod.
Simply search "custom function" for custom functions and "modified function" for modified functions.
If are in need of more recompileable scripts for your mod feel free to check this github project here: https://github.com/JezuzLizard/Recompilable-gscs-for-BO2-zombies-and-multiplayer

