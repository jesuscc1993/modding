#define Main
  CommandCreate("despawn", true, ScriptWrap(Despawn), "object");
  CommandCreate("harvest_all", true, ScriptWrap(HarvestAll));
  CommandCreate("mine_all", true, ScriptWrap(MineAll));
  CommandCreate("loot_all", true, ScriptWrap(LootAll));
  CommandCreate("kill_animals", true, ScriptWrap(KillAnimals));

#define Despawn(_args)
  var _name = _args[0];
  var _obj = asset_get_index(_name);

  if (!_obj) {
    Trace("\"" + _name + "\" is not a valid object name");
    return;
  }

  if (instance_exists(_obj)) {
  	instance_destroy(_obj);
  	Trace("Despawned all \"" + _name + "\" instances on screen");
  } else {
    Trace("No instances of \"" + _name + "\" found on screen");
  }

#define HarvestAll
	instance_destroy(objBeet);
	instance_destroy(objBush);
	instance_destroy(objCactus);
	instance_destroy(objCinderbloom);
	instance_destroy(objCotton);
	instance_destroy(objFlower);
	instance_destroy(objHotPepper);
	instance_destroy(objLavender);
	instance_destroy(objNightshade);
	instance_destroy(objPumpkin);
	instance_destroy(objTree);
	instance_destroy(objVoidRose);
	instance_destroy(objWheat);
	Trace("Harvested visible plants");

#define MineAll
	instance_destroy(objCrystal);
	instance_destroy(objDesertRock);
	instance_destroy(objGrave);
	instance_destroy(objObsidianRock);
	instance_destroy(objRock);
	instance_destroy(objUraniumRock);
	instance_destroy(objVoidstoneRock);
	instance_destroy(objVolcanoRock);
	instance_destroy(objVolcanoRockBig);
	Trace("Mined all visible ores");

#define KillAnimals
  instance_destroy(objChicken);
  instance_destroy(objCow);
  instance_destroy(objSheep);
  Trace("Killed all visible animals");

#define LootAll
	HarvestAll();
	MineAll();