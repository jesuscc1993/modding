const cubemainFilename = 'global\\excel\\cubemain.txt';
const cubemain = D2RMM.readTsv(cubemainFilename);

const gemTiers = ['Chipped', 'Flawed', 'Standard', 'Flawless', 'Perfect'];
const gemTypes = [
  { name: 'Amethyst', tiers: ['gcv', 'gfv', 'gsv', 'gzv', 'gpv'] },
  { name: 'Ruby', tiers: ['gcr', 'gfr', 'gsr', 'glr', 'gpr'] },
  { name: 'Sapphire', tiers: ['gcb', 'gfb', 'gsb', 'glb', 'gpb'] },
  { name: 'Topaz', tiers: ['gcy', 'gfy', 'gsy', 'gly', 'gpy'] },
  { name: 'Emerald', tiers: ['gcg', 'gfg', 'gsg', 'glg', 'gpg'] },
  { name: 'Diamond', tiers: ['gcw', 'gfw', 'gsw', 'glw', 'gpw'] },
  { name: 'Skull', tiers: ['skc', 'skf', 'sku', 'skl', 'skz'] },
];

const getItemName = (gemTier, gemType) => {
  return gemType.tiers[gemTier];
};

const pushUpgradeRecipe = (oldTier, newTier, gemType) => {
  cubemain.rows.push({
    description: `${config.gemUpgradeCount}x ${gemTiers[oldTier]} ${gemType.name} -> ${gemTiers[newTier]} ${gemType.name}`,
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
    description: `${gemTiers[oldTier]} ${gemType.name} -> ${config.gemDowngradeCount}x ${gemTiers[newTier]} ${gemType.name}`,
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
  if (config.gemUpgradeCount !== 3) {
    /* remove default recipes when upgrade count is not 3 */
    cubemain.rows = cubemain.rows.filter(
      (row) =>
        !row.description.match(
          /3 .* -> .* (Amethyst|Ruby|Sapphire|Topaz|Emerald|Diamond|Skull)/
        )
    );
  }

  for (let i = 0; i < gemTiers.length; i++) {
    if (config.enableDowngrade && i > 0) {
      /* add custom recipes */
      pushDowngradeRecipe(i, i - 1, gemType);
    }

    /* skip upgrade recipes if upgrade count is 3, as no change to the default is required */
    if (config.gemUpgradeCount !== 3 && i < gemTiers.length - 1) {
      /* add custom recipes */
      pushUpgradeRecipe(i, i + 1, gemType);
    }
  }
});

D2RMM.writeTsv(cubemainFilename, cubemain);
