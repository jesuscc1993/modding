#define Main
  CommandCreate("give_land", false, ScriptWrap(GiveLand));
  CommandCreate("give_obliterator", false, ScriptWrap(GiveObliterator));

#define GiveLand
  RemoveItem(Item.Landfill, 100)
  GainItem(Item.Landfill, 100)

#define GiveObliterator
  GainItem(Item.Obliterator, 1)