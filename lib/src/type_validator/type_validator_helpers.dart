import 'package:json_validator/src/type_validator/type_validator_base.dart';
import 'package:json_validator/src/type_validator/object_builder.dart';


/// a convenience instance of DateTimeValidator
DateTimeValidator DATETIME = new DateTimeValidator();

///DateTimeValidator tries to convert a dynamic into an int and then
///return the time represented by this int in millisecondsSinceEpoch
class DateTimeValidator extends ValueValidator<DateTime> {
  DateTime validate(dynamic d) {
    clearInfos();
    if (d is! int) {
      errors.add("not an int");
      return null;
    }
    return new DateTime.fromMillisecondsSinceEpoch(d);
  }
}

///a convenience instance of DurationValidator
DurationValidator DURATION = new DurationValidator();
///DurationValidator tries to convert a dynamic into an int and then
///return the duration represented by this int in milliseconds
class DurationValidator extends ValueValidator<Duration> {
  Duration validate(dynamic d) {
    clearInfos();
    if (d is! int) {
      errors.add("not an int");
      return null;
    }
    return new Duration(milliseconds: d);
  }
}

///StringFromSelectionValidator tries to convert a dynamic into one of a
///supplied list of possible string values
class StringFromSelectionValidator extends ValueValidator<String> {

  ///the list of all valid values for the validator
  final List<String> vals;

  String validate(dynamic d) {
    clearInfos();
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

  ///vals supplies the StringFromSelectionValidator with a list of all possible
  ///values
  StringFromSelectionValidator(this.vals);
}


class ObjectValidator<T> extends ValueValidator<T> {

  ///If requireAllFields is true, validate will return null if any value
  ///in the map is missing
  final bool requireAllFields;

  ///A map of keys to wrapped validators which describes the map structure
//  final Map<String, MapField> fields;

  final MapValidator _mv;

  final ObjectBuilder<T> objectBuilder;

  ///validate tries to parse its argument using the structure of the fields
  ///property. If allFieldsMustValidate is true and a field does not validate,
  ///null is returned. If all fields fail validation, null is returned
  T validate(dynamic d) {
    clearInfos();
//    errors.clear();
    _mv.errors.clear();
    var m = _mv.validate(d);
    errors.addAll(_mv.errors);
    comments.addAll(_mv.comments);
    if (m==null) {
      return null;
    }
    var ret = objectBuilder.build(m);
    errors.addAll(objectBuilder.errors);
    return ret;
  }

  ObjectValidator(Map<String, MapField> fields, this.objectBuilder, {this.requireAllFields:false}):_mv=new MapValidator(fields, requireAllFields:requireAllFields);
}
