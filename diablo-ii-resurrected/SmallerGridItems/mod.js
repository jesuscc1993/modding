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
      let w = Math.ceil(row.invwidth * scale);
      let h = Math.ceil(row.invheight * scale);
      let maxSockets = w * h;

      if (config.keepSockets && maxSockets < row.gemsockets) {
        w = Math.ceil(row.gemsockets / 3);
        h = row.gemsockets < 4 ? row.gemsockets : Math.ceil(row.gemsockets / 2);
      } else {
        row.gemsockets =
          row.gemsockets > maxSockets ? maxSockets : row.gemsockets;
      }

      row.invwidth = w;
      row.invheight = h;
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
