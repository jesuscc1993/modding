const gambleFilename = 'global\\excel\\gamble.txt';
let gamble = D2RMM.readTxt(gambleFilename);
// gamble.rows = gamble.rows.concat([
//   { name: 'Small Charm', code: 'cm1' },
//   { name: 'Large Charm', code: 'cm2' },
//   { name: 'Grand Charm', code: 'cm3' },
// ]);
gamble = `${gamble}Small Charm	cm1
Large Charm	cm2
Grand Charm	cm3
`;
D2RMM.writeTxt(gambleFilename, gamble);
