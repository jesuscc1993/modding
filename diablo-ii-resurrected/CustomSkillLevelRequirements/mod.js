const skillsFileName = 'global\\excel\\skills.txt';
const skills = D2RMM.readTsv(skillsFileName);

skills.rows.forEach((row) => {
  if (row.reqlevel !== '') {
    row.reqlevel = Math.ceil(row.reqlevel * config.levelRequirementMultiplier);
  }
});

D2RMM.writeTsv(skillsFileName, skills);
