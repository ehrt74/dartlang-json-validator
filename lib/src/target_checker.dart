import 'package:json_validator/src/source_dependency.dart';
import 'package:json_validator/src/target_dependency.dart';


TargetChecker TARGETCHECKER = new TargetChecker._intern();

class TargetChecker {

  TargetChecker._intern();

  TargetList check(dynamic map, Iterable<Target> _targets) {
    var targets = new List<Target>();
    var errors = new List<String>();

    _targets.forEach((Target t) {
      String err = _checkTarget(t, map);
      if (err==null)
        targets.add(t);
      else
        errors.add(err);
    });
    return new TargetList(targets, errors);
  }

  String _checkTarget(Target t, dynamic map) {
    var p = t.path;
    while(p.isNotEmpty) {
      if (map is! Map)
        return "{target: ${t} error: not found}";

      if (!(map as Map).containsKey(p.first))
        return "{target: ${t}, error: key ${p.first} not found}";

      map = map[p.first];
      p = p.skip(1);
    }
    if (t.value!=null) {
      if (map is Map)
        return "{target: ${t}, error: expecting leaf}";
      if (map!=t.value)
        return "{target: ${t}, error: wrong value in map}";
    }
    return null;
  }
}