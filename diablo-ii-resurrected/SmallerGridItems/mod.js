const scale = 0.4;

const GroupName = {
  Armor: 'armor',
  Misc: 'misc',
  Weapon: 'weapon',
};

const shouldScaleItem = (item, groupName) => {
  return (
    item.invwidth * item.invheight > 2 ||
    (groupName === GroupName.Armor && item.belt)
  );
};

const processTable = (filename, groupName) => {
  const contents = D2RMM.readTsv(filename);
  contents.rows.forEach((row) => {
    if (shouldScaleItem(row, groupName)) {
      const w = Math.ceil(row.invwidth * scale);
      const h = Math.ceil(row.invheight * scale);
      const maxSockets = w * h;

      row.invwidth = w;
      row.invheight = h;
      row.gemsockets =
        row.gemsockets > maxSockets ? maxSockets : row.gemsockets;
    }
  });
  D2RMM.writeTsv(filename, contents);
};

const processSprites = (groupName) => {
  D2RMM.copyFile(
    `hd\\global\\ui\\items\\${groupName}`,
    `hd\\global\\ui\\items\\${groupName}`,
    true
  );
};

const processGroup = (filePath, groupName) => {
  processTable(filePath, groupName);
  processSprites(groupName);
};

if (config.armor) {
  processGroup('global\\excel\\armor.txt', GroupName.Armor);
}
if (config.weapons) {
  processGroup('global\\excel\\weapons.txt', GroupName.Weapon);
}
if (config.misc) {
  processGroup('global\\excel\\misc.txt', GroupName.Misc);
}
