const cubemainFilename = 'global\\excel\\cubemain.txt';
const cubemain = D2RMM.readTsv(cubemainFilename);

const gemTiers = [
  { name: 'Chipped', id: 'c' },
  { name: 'Flawed', id: 'f' },
  { name: 'Standard', id: 's' },
  { name: 'Flawless', id: 'z' },
];
const gemTypes = [
  { name: 'Amethyst', prefix: 'g', suffix: 'v' },
  { name: 'Ruby', prefix: 'g', suffix: 'r' },
  { name: 'Sapphire', prefix: 'g', suffix: 'b' },
  { name: 'Topaz', prefix: 'g', suffix: 'y' },
  { name: 'Emerald', prefix: 'g', suffix: 'g' },
  { name: 'Diamond', prefix: 'g', suffix: 'w' },
  { name: 'Skull', prefix: 's', suffix: 'k' },
];

const getItemName = (gemTier, gemType) => {
  return gemType.name === 'Skull'
    ? `${gemType.prefix}${gemType.suffix}${gemTier.id}`
    : `${gemType.prefix}${gemTier.id}${gemType.suffix}`;
};

const pushUpgradeRecipe = (oldTier, newTier, gemType) => {
  cubemain.rows.push({
    description: `${config.gemUpgradeCount}x ${oldTier.name} ${gemType.name} -> ${newTier.name} ${gemType.name}`,
    enabled: 1,
    version: 100,
    numinputs: config.gemUpgradeCount,
    'input 1': `"${getItemName(oldTier, gemType)},qty=${
      config.gemUpgradeCount
    }"`,
    output: getItemName(newTier, gemType),
    '*eol': 0,
  });
};

const pushDowngradeRecipe = (oldTier, newTier, gemType) => {
  const outputItemName = getItemName(newTier, gemType);

  cubemain.rows.push({
    description: `${oldTier.name} ${gemType.name} -> ${config.gemDowngradeCount}x ${newTier.name} ${gemType.name}`,
    enabled: 1,
    version: 100,
    numinputs: 1,
    'input 1': getItemName(oldTier, gemType),
    output: outputItemName,
    'output b': outputItemName,
    'output c': config.gemDowngradeCount > 2 ? outputItemName : undefined,
    '*eol': 0,
  });
};

gemTypes.forEach((gemType) => {
  for (let i = 0; i < gemTiers.length; i++) {
    if (i > 0) {
      /* add custom recipes */
      pushDowngradeRecipe(gemTiers[i], gemTiers[i - 1], gemType);
    }

    /* skip upgrade recipes if gem count is 3, as no change to the default is required */
    if (config.gemUpgradeCount !== 3 && i < gemTiers.length - 1) {
      /* remove default recipes */
      cubemain.rows = cubemain.rows.filter(
        (row) =>
          !row.description.match(
            /3 .* -> .* (Amethyst|Ruby|Sapphire|Topaz|Emerald|Diamond|Skull)/
          )
      );
      /* add custom recipes */
      pushUpgradeRecipe(gemTiers[i], gemTiers[i + 1], gemType);
    }
  }
});

D2RMM.writeTsv(cubemainFilename, cubemain);
