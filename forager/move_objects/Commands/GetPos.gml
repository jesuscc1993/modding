#define RegisterGetPos
  CommandCreate("getpos", false, ScriptWrap(GetPos), "object");

#define GetPos(_args)
  if (!AreArgsN(_args, 1)) return;
  var _name = _args[0];

  var _obj = GetObj(_name);

  if (_obj && InstanceExists(_obj, _name)) {
    with(GetNearestInstance(_obj)) {
      Trace("Nearest \"" + _name + "\" instance found at x = " + string(x) + "; y = " + string(y));
    }
  }