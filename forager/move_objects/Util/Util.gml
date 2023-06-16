#define AreArgsN(_args, _count)
  if (array_length_1d(_args) != _count) {
    Trace("Invalid argument count!");
    return false;
  }

  return true;

#define GetObj(_name)
  var _obj = asset_get_index(_name);
  if (!_obj) Trace("Object not found!");
  return _obj;

#define InstanceExists(_obj, _name)
  if (instance_exists(_obj)) return true;

  Trace("No instances of \"" + _name + "\" found on screen");
  return false;

#define GetNearestInstance(_obj)
  return instance_nearest(objPlayer.x, objPlayer.y, _obj);