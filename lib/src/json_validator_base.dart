// Copyright (c) 2017, edouard. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

/// A ValueValidator can be used to check that a value is of the required type T.
/// Calling the validate method will return either an object of type T or null.
class ValueValidator<T> {

  /// validate is called with the object to be tested. When overloading it should
  /// return either a valid object of type T or null
  T validate(dynamic d) {
    errors.clear();
    if (d is! T) {
      errors.add("not a $T");
      return null;
    }
    return d;
  }

  /// errors contains a list of all errors found while validating. for collections
  /// the error path is included
  final List<String> errors = new List<String>();
}

/// INT can be used to test that a dynamic value is an int
final ValueValidator<int> INT = new ValueValidator<int>();

//class IntValidator extends ValueValidator<int> {}

/// BOOL can be used to test that a dynamic value is a bool
final ValueValidator<bool> BOOL = new ValueValidator<bool>();

/// DOUBLE can be used to test that a dynamic value is a double
final ValueValidator<double> DOUBLE = new ValueValidator<double>();

/// STRING can be used to test that a dynamic value is a String
final ValueValidator<String> STRING = new ValueValidator<String>();


/// A MapField wraps a ValueValidator with additional configuration.
/// an optional defaultValue paramater will be returned if validate is called
/// on invalid data
class MapField<T> {
  /// A MapValidator will return null if mustValidate is set to true and
  /// the MapField returns null when validating
  final bool mustValidate;

  /// validator will be used to validate the data stored at the field location
  final ValueValidator<T> validator;

  /// defaultValue will be returned if validation fails
  final T defaultValue;

  ///A MapField wraps a ValueValidator. defaultValue will be returned if
  ///validation fails
  MapField(this.validator, {T defaultValue:null, bool mustValidate:false}):defaultValue=defaultValue, mustValidate=mustValidate;
}

///ListValidator can be used to validate a list of objects of the same type
class ListValidator<T> extends ValueValidator<List> {
  ///validator is used to validate each list entry
  final ValueValidator validator;

  ///validate will create a list of validated entries. if there are no valid
  ///entries, null will be returned
  List<T> validate(dynamic d) {
    if (d is! List) {
      errors.add("not a List");
      return null;
    }
    var ret = new List<T>();
    for (int i=0; i<d.length; i++) {
      var d2 = d[i];
      if (d2 is! T) {
        errors.add("${i}/not a $T");
        continue;
      }
      T v = validator.validate(d2);
      errors.addAll(validator.errors.map((String s)=>"${i}/$s"));
      if (v==null) {
        errors.add("${i} failed validation");
        continue;
      }
      ret.add(v);
    }
    if (ret.isEmpty) {
      return null;
    }
    return ret;
  }

  //validator is used to validate each object in the list
  ListValidator(this.validator);
}

///MapValidator can be used to validate a map with known key names
class MapValidator extends ValueValidator<Map> {

  ///If allFieldsMustValidate is true, validate will return null if any value
  ///in the map fails validation
  final bool allFieldsMustValidate;

  ///A map of keys to wrapped validators which describes the map structure
  final Map<String, MapField> fields;

  ///validate tries to parse its argument using the structure of the fields
  ///property. If allFieldsMustValidate is true and a field does not validate,
  ///null is returned. If all fields fail validation, null is returned
  Map<String, dynamic> validate(dynamic d) {
    errors.clear();
    if (d is! Map) {
      errors.add("not a Map");
      return null;
    }
    var ret = new Map<String, dynamic>();
    for(String key in fields.keys) {
      MapField f = fields[key];
      if (!d.containsKey(key)) {
        if (f.mustValidate || allFieldsMustValidate) {
          errors.add("${key}/missing");
          errors.add("discarding");
          return null;
        }
        if (f.defaultValue!=null) {
          errors.add("${key}/added with value ${f.defaultValue}");
          ret[key] = f.defaultValue;
        }
        continue;
      }
      var v = f.validator.validate(d[key]);
      errors.addAll(f.validator.errors.map((String e)=>"${key}/${e}"));
      if (v==null) {
        if(f.mustValidate || allFieldsMustValidate) {
          errors.add("${key}/invalid");
          errors.add("discarding");
          return null;
        }
        if (f.defaultValue!=null) {
          errors.add("${key}/replaced with value ${f.defaultValue}");
          ret[key]=f.defaultValue;
        }
        continue;
      }
      ret[key] = v;

    }
    if (ret.isEmpty)
      return null;
    return ret;
  }

  ///MapValidator constructor takes a map of key name to MapField.
  ///If allFieldsMustValidate is set to true, mapValidator.validate(data)
  ///will return null if any field fails validation
  MapValidator(this.fields, [this.allFieldsMustValidate=false]);
}

///MapUnknownKeysValidator is used to validate a map of key to objects. The same
///ValueValidator is used to validate each value
class MapUnknownKeysValidator<T> extends ValueValidator<Map> {

  ///ValueValidator used to validate each value in the map supplied as argument
  ///to the validate instance method
  final ValueValidator<T> validator;

  ///validate returns a map of keys to valid instances of T. If validation of a
  ///value fails, this key is omitted in the returned map. If no values can be
  ///validated, null is returned
  Map<String, T> validate(dynamic d) {
    if (d is! Map) {
      errors.add("not a map");
      return null;
    }
    var ret = new Map<String, T>();
    for (String key in d.keys) {
      var d2 = d[key];
      var v = validator.validate(d2);
      errors.addAll(validator.errors.map((String e)=>"${key}/${e}"));
      if (v==null) {
        errors.add("${key} failed validation");
        continue;
      }
      ret[key]=v;
    }
    if (ret.isEmpty)
      return null;
    return ret;
  }

  /// the validator used to validate each value in the map passed to the
  /// validate instance method
  MapUnknownKeysValidator(this.validator);
}
