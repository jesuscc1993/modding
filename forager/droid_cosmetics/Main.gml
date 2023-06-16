#define Main
var _idleDroidBody = sprite_add("sprites/sprDroidBodyIdle.png", 6, false, false, 18, 25);
var _walkDroidBody = sprite_add("sprites/sprDroidBodyWalk.png", 6, false, false, 18, 25);
CosmeticCreate(undefined, "Droid Body", CosmeticType.Body, _idleDroidBody, _walkDroidBody, undefined, true);

var _idleDroidHead = sprite_add("sprites/sprDroidHeadIdle.png", 6, false, false, 18, 25);
var _walkDroidHead = sprite_add("sprites/sprDroidHeadWalk.png", 6, false, false, 18, 25);
CosmeticCreate(undefined, "Droid", CosmeticType.Head, _idleDroidHead, _walkDroidHead, undefined, true);

var _idleDroidCyclops = sprite_add("sprites/sprDroidCyclopsIdle.png", 6, false, false, 18, 25);
var _walkDroidCyclops = sprite_add("sprites/sprDroidCyclopsWalk.png", 6, false, false, 18, 25);
CosmeticCreate(undefined, "Droid Cyclops", CosmeticType.Head, _idleDroidCyclops, _walkDroidCyclops, undefined, true);

var _idleDroidGoggles = sprite_add("sprites/sprDroidGogglesIdle.png", 6, false, false, 18, 25);
var _walkDroidGoggles = sprite_add("sprites/sprDroidGogglesWalk.png", 6, false, false, 18, 25);
CosmeticCreate(undefined, "Droid Goggles", CosmeticType.Head, _idleDroidGoggles, _walkDroidGoggles, undefined, true);

var _idleDroidPaint = sprite_add("sprites/sprDroidPaintIdle.png", 6, false, false, 18, 25);
var _walkDroidPaint = sprite_add("sprites/sprDroidPaintWalk.png", 6, false, false, 18, 25);
CosmeticCreate(undefined, "Droid Paint", CosmeticType.Head, _idleDroidPaint, _walkDroidPaint, undefined, true);