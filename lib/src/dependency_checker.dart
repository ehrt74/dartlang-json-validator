import 'package:json_validator/src/source_dependency.dart';
import 'package:json_validator/src/target_dependency.dart';


DependencyChecker CHECKER = new DependencyChecker._intern();

class DependencyChecker {


  dynamic map;

  List<Target> targets = new List<Target>();

  List<String> errors = new List<String>();

  DependencyChecker._intern();

  List<Target> checkDependencies(dynamic map, SourceTemplate st, TargetTemplate tt) {
    targets.clear();
    errors.clear();
    var s = new Source(map, st.path, st.useValue);
    var sources = s.process();
    errors.addAll(s.errors);

    var tes = tt.getTargets(sources);
    tes.forEach((te) {
      if (te.error!=null) {
        errors.add(te.error);
      }
    });
    tes.map((te)=>te.target).forEach((Target t) {
      if(_checkTarget(t, map))
        targets.add(t);
    });
    return targets;
  }

  bool _checkTarget(Target t, dynamic m) {
    var p = t.path;
    while(p.isNotEmpty) {
      if (m is! Map) {
        errors.add("${t} not found");
        return false;
      }
      if (!(m as Map).containsKey(p.first)) {
        errors.add("${t}: key ${p.first} not found");
        return false;
      }
      m = m[p.first];
      p = p.skip(1);
    }
    if (t.value!=null) {
      if (m is Map) {
        errors.add("${t} expecting value.");
        return false;
      }
      if (m!=t.value) {
        errors.add("${t} wrong value in map");
        return false;
      }
      return true;
    }
    return true;
  }

}