import 'package:json_validator/src/source_dependency.dart';


class Target {
  final List<String> path;
  final String value;

  String toString()=>"{path: "+path.join("/")+", value: $value}";

  Target(this.path, this.value);
}

class TargetList {
  final List<Target> targets;
  final List<String> errors;

  String toString()=>
      "{targets:${targets}, \nerrors:${errors.join("\n")}}";

  TargetList(this.targets, this.errors);
}

class TargetTemplate {
  static final String WILDCARD = "#";
  static final String VAL = "VAL";

  final List<String> path;

  String toString()=>"${path}, valueTemplate: $valueTemplate";

  String valueTemplate;

  TargetTemplate(this.path, this.valueTemplate);

  _TargetError _getTarget(Source source) {
    var retPath = new List<String>();
    for (String p in path) {
      if (p.startsWith(WILDCARD)) {
        int n;
        try {
          n = int.parse(p.substring(WILDCARD.length));
        } catch (e) {
          return new _TargetError(null, "could not parse $p as wildcard");
        }
        if (n >= source.dictionary.length) {
          return new _TargetError(null,
              "${this}: dictionary too small for target template: ${source}");
        }
        retPath.add(source.dictionary[n]);
        continue;
      }
      if (p == VAL) {
        if (source.value == null) {
          return new _TargetError(
              null, "${this}: value not set in source ${source}");
        }
        retPath.add(source.value);
        continue;
      }
      retPath.add(p);
      continue;
    }
    String value;
    if (valueTemplate==null) {
    } else if (valueTemplate==VAL) {
      if (source.value==null) {
        return new _TargetError(null, "${this}: value not set in source ${source}");
      }
      value = source.value;
    } else if(valueTemplate.startsWith(WILDCARD)) {
      int n;
      try {
        n = int.parse(valueTemplate.substring(WILDCARD.length));
      } catch (e) {
        return new _TargetError(null, "could not parse $valueTemplate as wildcard");
      }
      if (n >= source.dictionary.length) {
        return new _TargetError(null,
            "${this}: dictionary too small for target template: ${source}");
      }
      value = source.dictionary[n];
    } else {
      value = valueTemplate;
    }

    return new _TargetError(new Target(retPath, value), null);
  }

  TargetList getTargetList(SourceList sourceList) {
    var targets = new List<Target>();
    var errors = new List<String>();
    sourceList.sources.forEach((s) {
      var ta = this._getTarget(s);
      if (ta.target!=null) targets.add(ta.target);
      if (ta.error!=null) errors.add(ta.error);
    });
    return new TargetList(targets, errors);
  }
}

class _TargetError {
  final Target target;
  final String error;

  _TargetError(this.target, this.error);
}
