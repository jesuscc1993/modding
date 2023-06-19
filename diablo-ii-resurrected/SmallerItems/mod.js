const processFile = (filename) => {
  const contents = D2RMM.readTsv(filename);
  contents.rows.forEach((row) => {
    const w = Math.ceil(row.invwidth * config.scale);
    const h = Math.ceil(row.invheight * config.scale);
    const maxSockets = w * h;

    row.invwidth = w;
    row.invheight = h;
    row.gemsockets = row.gemsockets > maxSockets ? maxSockets : row.gemsockets;
  });
  D2RMM.writeTsv(filename, contents);
};

if (config.armor) processFile('global\\excel\\armor.txt');
if (config.weapons) processFile('global\\excel\\weapons.txt');
if (config.misc) processFile('global\\excel\\misc.txt');
