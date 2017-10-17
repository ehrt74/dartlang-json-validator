import 'package:json_validator/src/source_dependency.dart';


class TargetTemplate {
  static final String WILDCARD = "#";
  static final String VAL = "VAL";

  final List<String> path;

  String toString()=>"$path";

  String valueTemplate;

  TargetTemplate(this.path, this.valueTemplate);

  TargetError getTarget(Source source) {
    var retPath = new List<String>();
    for (String p in path) {
      if (p.startsWith(WILDCARD)) {
        int n;
        try {
          n = int.parse(p.substring(WILDCARD.length));
        } catch (e) {
          return new TargetError(null, "could not parse $p as wildcard");
        }
        if (n >= source.dictionary.length) {
          return new TargetError(null,
              "${this}: dictionary too small for target template: ${source}");
        }
        retPath.add(source.dictionary[n]);
        continue;
      }
      if (p == VAL) {
        if (source.value == null) {
          return new TargetError(
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
        return new TargetError(null, "${this}: value not set in source ${source}");
      }
      value = source.value;
    } else if(valueTemplate.startsWith(WILDCARD)) {
      int n;
      try {
        n = int.parse(valueTemplate.substring(WILDCARD.length));
      } catch (e) {
        return new TargetError(null, "could not parse $valueTemplate as wildcard");
      }
      if (n >= source.dictionary.length) {
        return new TargetError(null,
            "${this}: dictionary too small for target template: ${source}");
      }
      value = source.dictionary[n];
    } else {
      value = valueTemplate;
    }

    return new TargetError(new Target(retPath, value), null);
  }

  List<TargetError> getTargets(List<Source> sources)=>sources.map((s)=>this.getTarget(s)).toList();
}

class TargetError {
  final Target target;
  final String error;

  TargetError(this.target, this.error);
}

class Target {

  String toString()=>"["+path.join("/")+"]:$value";

  final List<String> path;
  final String value;

  Target(this.path, this.value);
}

