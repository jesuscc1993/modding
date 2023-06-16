#define RegisterSnapPos
  CommandCreate("snappos", false, ScriptWrap(SnapPos), "object");

#define SnapPos(_args)
  if (!AreArgsN(_args, 1)) return;
  var _name = _args[0];

  var _obj = GetObj(_name);

  if (_obj && InstanceExists(_obj, _name)) {
    with(GetNearestInstance(_obj)) {
      x = round(x / 16) * 16;
      y = round(y / 16) * 16;
      Trace("Moved nearest \"" + _name + "\" instance to x = " + string(x) + "; y = " + string(y));
    }
  }