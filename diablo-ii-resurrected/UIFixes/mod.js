class ModConstants {
  static vendorPanelLayoutHd = { 
    file: `vendorpanellayouthd`,
    oldCoords: { x: 91, y: 233 },
    newCoords: { x: 88, y: 235 },
  };

  static bankExpansionLayoutHd = {
    file: `bankexpansionlayouthd`,
    oldCoords: { x: 54, y: 177 },
    newCoords: { x: 57, y: 177 },
  };
}

class UiFixesMod {
  build() {
    if (config.shouldFixVendorPanelLayoutHd) {
      this.processLayout(ModConstants.vendorPanelLayoutHd.file, ModConstants.vendorPanelLayoutHd.oldCoords, ModConstants.vendorPanelLayoutHd.newCoords);
    }

    if (config.shouldFixBankExpansionLayoutHd) {
      this.processLayout(ModConstants.bankExpansionLayoutHd.file, ModConstants.bankExpansionLayoutHd.oldCoords, ModConstants.bankExpansionLayoutHd.newCoords);
    }
  }

  processLayout(fileName, oldCoords, newCoords) {
    let path = `global\\ui\\layouts\\${fileName}.json`;
    let file = D2RMM.readJson(path);

    file.children.forEach((child) => {
      if (child.name === 'grid') {
        const { rect } = child.fields;
        if (rect.x === oldCoords.x && rect.y === oldCoords.y) {
          child.fields.rect.x = newCoords.x;
          child.fields.rect.y = newCoords.y;
        }
      }
    });

    D2RMM.writeJson(path, file);
  };
}

(new UiFixesMod()).build();
