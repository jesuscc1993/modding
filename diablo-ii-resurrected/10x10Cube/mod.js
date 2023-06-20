/* common */
const inventoryFilename = 'global\\excel\\inventory.txt';
const inventory = D2RMM.readTsv(inventoryFilename);
inventory.rows.forEach((row) => {
  if (
    row.class === 'Transmogrify Box Page 1' ||
    row.class === 'Transmogrify Box2'
  ) {
    row.gridX = 10;
    row.gridY = 10;
  }
});
D2RMM.writeTsv(inventoryFilename, inventory);

/* mouse */
const horadricCubeLayoutHDFilename =
  'global\\ui\\layouts\\horadriccubelayouthd.json';
const vendorPanelLayoutHD = D2RMM.readJson(horadricCubeLayoutHDFilename);
vendorPanelLayoutHD.children.forEach((child) => {
  if (child.name === 'grid') {
    child.fields.cellCount.x = 10;
    child.fields.cellCount.y = 10;
    child.fields.rect.x = 91;
    child.fields.rect.y = 303;
  }
  if (child.name === 'convert') {
    child.fields.rect.x = 523;
    child.fields.rect.y = 1313;
  }
  if (child.name === 'background') {
    child.fields.filename = 'PANEL\\Horadric_Cube\\HoradricCube_BG_Expanded';
  }
});
D2RMM.writeJson(horadricCubeLayoutHDFilename, vendorPanelLayoutHD);

/* keyboard */
const controllerHoradricCubeLayoutHDFilename =
  'global\\ui\\layouts\\controller\\horadriccubelayouthd.json';
const controllerHoradricCubeLayoutHD = D2RMM.readJson(
  controllerHoradricCubeLayoutHDFilename
);
controllerHoradricCubeLayoutHD.children.forEach((child) => {
  if (child.name === 'grid') {
    child.fields.rect.x = 160;
    child.fields.rect.y = 217;
  }
  if (child.name === 'convert') {
    child.fields.rect.x = 593;
    child.fields.rect.y = 1257;
  }
  if (child.name === 'background') {
    child.fields.filename =
      'Controller/Panel/HoradricCube/V2/HoradricCubeBG_Expanded';
  }
});
D2RMM.writeJson(
  controllerHoradricCubeLayoutHDFilename,
  controllerHoradricCubeLayoutHD
);

D2RMM.copyFile(
  'hd', // <mod folder>\hd
  'hd', // <diablo 2 folder>\mods\<modname>\<modname>.mpq\data\hd
  true // overwrite any conflicts
);
