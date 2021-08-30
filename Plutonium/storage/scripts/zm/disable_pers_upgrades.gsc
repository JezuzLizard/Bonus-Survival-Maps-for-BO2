#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;
#include maps/mp/zombies/_zm_pers_upgrades;

main()
{
	replacefunc(maps/mp/zombies/_zm_pers_upgrades::pers_upgrade_init, ::pers_upgrade_init);
}

pers_upgrade_init() //checked matches cerberus output
{
}