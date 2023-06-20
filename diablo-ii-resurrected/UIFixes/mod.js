const processLayout = (filename, oldCoords, newCoords) => {
  const layout = D2RMM.readJson(filename);
  layout.children.forEach((child) => {
    if (child.name === 'grid') {
      const { rect } = child.fields;
      if (rect.x === oldCoords.x && rect.y === oldCoords.y) {
        child.fields.rect.x = newCoords.x;
        child.fields.rect.y = newCoords.y;
      }
    }
  });
  D2RMM.writeJson(filename, layout);
};

processLayout(
  'global\\ui\\layouts\\vendorpanellayouthd.json',
  { x: 91, y: 233 },
  { x: 88, y: 235 }
);

processLayout(
  'global\\ui\\layouts\\bankexpansionlayouthd.json',
  { x: 54, y: 177 },
  { x: 57, y: 177 }
);
