#define Main
  CommandCreate("dropinventory", false, ScriptWrap(DropInventory));

#define DropInventory
  for (var itemId = 0; itemId < Item.Count; itemId += 1) {
    if (itemId == Item.Droid || itemId == Item.Coin) continue;

    var amount = ItemCount(itemId, false);
    if (amount > 0) {
        RemoveItem(itemId, amount);
        DropItem(objPlayer.x, objPlayer.y, itemId, amount);
    }
  }