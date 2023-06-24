const scale = 0.4;

const GroupName = {
  Armor: 'armor',
  Misc: 'misc',
  Weapon: 'weapon',
};

const shouldScaleItem = (item) => {
  return item.invwidth * item.invheight > 2 || item.type === 'belt';
};

const processTable = (filename) => {
  const contents = D2RMM.readTsv(filename);
  contents.rows.forEach((row) => {
    if (shouldScaleItem(row)) {
      const { gemsockets, invheight, invwidth } = row;
      let h = Math.ceil(invheight * scale);
      let w = Math.ceil(invwidth * scale);
      let maxSockets = w * h;

      if (config.keepSockets && maxSockets < gemsockets) {
        /* preserve aspect ratio for square items */
        if (h === 1 && w === 1 && gemsockets > 2 && gemsockets < 5) {
          h = 2;
          w = 2;
        } else {
          h = gemsockets < 4 ? gemsockets : Math.ceil(gemsockets / 2);
          w = Math.ceil(gemsockets / 3);
        }
      } else {
        row.gemsockets = gemsockets > maxSockets ? maxSockets : gemsockets;
      }

      row.invheight = h;
      row.invwidth = w;
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
  processTable(filePath);
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
