#define RegisterMoveToCursor
  CommandCreate("movetocursor", false, ScriptWrap(MoveToCursor), "object");

#define MoveToCursor(_args)
  if (!AreArgsN(_args, 1)) return;
  var _name = _args[0];

  var _obj = GetObj(_name);

  if (_obj && InstanceExists(_obj, _name)) {
    with(GetNearestInstance(_obj)) {
      x = mouse_x;
      y = mouse_y;
      Trace("Moved nearest \"" + _name + "\" instance to x = " + string(x) + "; y = " + string(y));
    }
  }