const scale = 0.4;

const GroupName = {
  Armor: 'armor',
  Misc: 'misc',
  Weapon: 'weapon',
};

const ArmorTypes = {
  belt: {
    folders: ['belt'],
    ids: ['belt'],
  },
  boot: {
    folders: ['boot'],
    ids: ['boot'],
  },
  glove: {
    folders: ['glove'],
    ids: ['glov'],
  },
  helmet: {
    folders: ['circlet', 'helmet', 'pelt'],
    ids: ['circ', 'helm', 'pelt', 'phlm'],
  },
  shield: {
    folders: ['shield', 'voodoo_head'],
    ids: ['ashd', 'head', 'shie'],
  },
  torso: {
    folders: ['armor'],
    ids: ['tors'],
  },
};

const WeaponTypes = {
  axe: {
    folders: ['axe'],
    ids: ['axe', 'taxe'],
  },
  bow: {
    folders: ['bow'],
    ids: ['abow', 'bow', 'xbow'],
  },
  club: {
    folders: ['club'],
    ids: ['club'],
  },
  katar: {
    folders: ['h2h'],
    ids: ['h2h', 'h2h2'],
  },
  hammer: {
    folders: ['hammer'],
    ids: ['hamm'],
  },
  javelin: {
    folders: ['javelin'],
    ids: ['ajav', 'jave'],
  },
  knife: {
    folders: ['knife'],
    ids: ['knif', 'tkni'],
  },
  mace: {
    folders: ['mace'],
    ids: ['mace'],
  },
  orb: {
    folders: ['orb'],
    ids: ['orb'],
  },
  polearm: {
    folders: ['polearm'],
    ids: ['pole'],
  },
  scepter: {
    folders: ['scepter'],
    ids: ['scep'],
  },
  spear: {
    folders: ['spear'],
    ids: ['aspe', 'spea'],
  },
  staff: {
    folders: ['staff'],
    ids: ['staf', 'wand'],
  },
  sword: {
    folders: ['sword'],
    ids: ['swor'],
  },
};

const shouldScaleItem = (item, types) => {
  return (
    (!types || types.includes(item.type)) &&
    (item.invwidth * item.invheight > 2 || item.type === 'belt')
  );
};

const processTable = (filename, types) => {
  const contents = D2RMM.readTsv(filename);
  contents.rows.forEach((row) => {
    if (shouldScaleItem(row, types)) {
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

const processSprites = (groupName, folders) => {
  if (folders) {
    folders.forEach((folder) => {
      D2RMM.copyFile(
        `hd\\global\\ui\\items\\${groupName}\\${folder}`,
        `hd\\global\\ui\\items\\${groupName}\\${folder}`,
        true
      );
    });
  } else {
    D2RMM.copyFile(
      `hd\\global\\ui\\items\\${groupName}`,
      `hd\\global\\ui\\items\\${groupName}`,
      true
    );
  }
};

const processGroup = (filePath, groupName, types, folders) => {
  processTable(filePath, types);
  processSprites(groupName, folders);
};

let enabledArmorTypes = [];
let enabledArmorFolders = [];
let enabledWeaponTypes = [];
let enabledWeaponFolders = [];

for (let k in config) {
  if (config[k] === true) {
    const armorType = ArmorTypes[k];
    if (armorType) {
      enabledArmorTypes = enabledArmorTypes.concat(armorType.ids);
      enabledArmorFolders = enabledArmorFolders.concat(armorType.folders);
    }
    const weaponType = WeaponTypes[k];
    if (weaponType) {
      enabledWeaponTypes = enabledWeaponTypes.concat(weaponType.ids);
      enabledWeaponFolders = enabledWeaponFolders.concat(weaponType.folders);
    }
  }
}

if (enabledArmorTypes.length) {
  processGroup(
    'global\\excel\\armor.txt',
    GroupName.Armor,
    enabledArmorTypes,
    enabledArmorFolders
  );
}

if (enabledWeaponTypes.length) {
  processGroup(
    'global\\excel\\weapons.txt',
    GroupName.Weapon,
    enabledWeaponTypes,
    enabledWeaponFolders
  );
}

if (config.misc) {
  processGroup('global\\excel\\misc.txt', GroupName.Misc);
}
