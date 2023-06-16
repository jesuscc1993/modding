#define RegisterSetPos
  CommandCreate("setpos", false, ScriptWrap(SetPos), "object", "x", "y");

#define SetPos(_args)
  if (!AreArgsN(_args, 3)) return;
  var _name = _args[0];
  var _x = _args[1];
  var _y = _args[2];

  var _obj = GetObj(_name);

  if (_obj && InstanceExists(_obj, _name)) {
    with(GetNearestInstance(_obj)) {
      x = _x;
      y = _y;
      Trace("Moved nearest \"" + _name + "\" instance to x = " + string(x) + "; y = " + string(y));
    }
  }