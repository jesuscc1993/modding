#define Main
  global.droidOLx = 254
  global.droidOLy = 59
  global.stringDroids = ""

  CommandCreate("droidol", 0, ScriptWrap(UpdateDroidOL))

#define UpdateDroidOL(args)
  global.droidOLx = real(args[0])
  global.droidOLy = real(args[1])

#define OnSystemStep
  if (room = rmGame) {
    var activeDroids = instance_number(objDroid);
    global.stringDroids = string(activeDroids);
  }
    
#define OnDrawGUIEnd
  if (room = rmGame)
    if (global.stringDroids != "") {
      draw_set_valign(fa_middle);
      draw_set_halign(fa_left);
      var _scale = 2;
      var _x = global.droidOLx;
      var _y = global.droidOLy;
      draw_sprite_ext(
        sprDroid,
        0,
        _x,
        _y,
        _scale,
        _scale,
        0,
        -1,
        1
      );
      draw_text_transformed(
        _x+32,
        _y+12,
        global.stringDroids,
        1,
        1,
        0
      );
    }
    