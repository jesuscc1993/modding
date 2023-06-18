const treasureclassexFilename = 'global\\excel\\treasureclassex.txt';
const treasureclassex = D2RMM.readTsv(treasureclassexFilename);

const tiers = 5;
const replacement = 'gld';

treasureclassex.rows.forEach((row) => {
  for (let col = 1; col <= 10; col++) {
    const item = `Item${col}`;
    const itemDrop = row[item];

    for (let tier = 1; tier <= tiers; tier++) {
      if (config[`disablehp${tier}`] && itemDrop === `hp${tier}`) {
        row[item] = replacement;
      }
      if (config[`disablemp${tier}`] && itemDrop === `^mp${tier}$`) {
        row[item] = replacement;
      }
    }

    if (config.disablervs && itemDrop === 'rvs') {
      row[item] = replacement;
    }
    if (config.disablervl && itemDrop == 'rvl') {
      row[item] = replacement;
    }
  }
});

D2RMM.writeTsv(treasureclassexFilename, treasureclassex);
