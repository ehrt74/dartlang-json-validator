import 'json_validator_base.dart';

class DateTimeValidator extends ValueValidator<DateTime> {
  DateTime validate(dynamic d) {
    if (d is! int) {
      errors.add("not an int");
      return null;
    }
    return new DateTime.fromMillisecondsSinceEpoch(d);
  }
}

class DurationValidator extends ValueValidator<Duration> {
  Duration validate(dynamic d) {
    if (d is! int) {
      errors.add("not an int");
      return null;
    }
    return new Duration(milliseconds: d);
  }
}

class StringFromSelectionValidator extends ValueValidator<String> {
  final List<String> vals;

  String validate(dynamic d) {
    if (d is! String) {
      errors.add("not a string");
      return null;
    }
    if (!vals.contains(d)) {
      errors.add("$d not in $vals");
      return null;
    }
    return d;
  }

  StringFromSelectionValidator(this.vals);
}