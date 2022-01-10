#include maps/mp/zombies/_zm_utility;
#include common_scripts/utility;
#include maps/mp/_utility;
#include maps/mp/zombies/_zm_pers_upgrades;

main()
{
	replacefunc(maps/mp/zombies/_zm_pers_upgrades::pers_upgrade_init, ::pers_upgrade_init);
	replacefunc(maps/mp/zombies/_zm_pers_upgrades::is_pers_system_active, ::is_pers_system_active);
}

pers_upgrade_init() //checked matches cerberus output
{
}

is_pers_system_active()
{
	return 0;
}