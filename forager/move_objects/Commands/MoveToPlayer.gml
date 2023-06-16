#define RegisterMoveToPlayer
  CommandCreate("movetoplayer", false, ScriptWrap(MoveToPlayer), "object");

#define MoveToPlayer(_args)
  if (!AreArgsN(_args, 1)) return;
  var _name = _args[0];

  var _obj = GetObj(_name);

  if (_obj && InstanceExists(_obj, _name)) {
    with(GetNearestInstance(_obj)) {
      x = objPlayer.x;
      y = objPlayer.y;
      Trace("Moved nearest \"" + _name + "\" instance to x = " + string(x) + "; y = " + string(y));
    }
  }