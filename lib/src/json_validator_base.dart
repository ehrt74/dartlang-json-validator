// Copyright (c) 2017, edouard. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

// TODO: Put public facing types in this file.

/// JsonValueValidator is used to validate a json value according to the supplied options
abstract class JsonValueValidator<T> {
  /// the name of the key pointing to this field. This will appear in error messages.
  final String name;

  /// if an error should be recorded if this field is missing.
  final bool required;

  /// default value to be used if the field is invalid.
  final T defaultVal;

  /// a list of all errors encountered during validation of a json value
  final List<String> errors = new List<String>();

  String get _path {
    if(name!=null) {
      return "$name/";
    }
    return "";
  }


  T parse(dynamic d) {
    errors.clear();
    if (d is! T) {
      errors.add("${_path}not of class $T");
      return defaultVal;
    }
    return d as T;
  }

  JsonValueValidator(this.name, {bool required:true, T defaultVal:null}):this.required=required, this.defaultVal=defaultVal;
}

class JsonStringValidator extends JsonValueValidator<String> {
  JsonStringValidator(String name, {bool required:true, String defaultVal:null}):super(name, required:required, defaultVal:defaultVal);
}
class JsonBoolValidator extends JsonValueValidator<bool> {
  JsonBoolValidator(String name, {bool required:true, bool defaultVal:false}):super(name, required:required, defaultVal:defaultVal);
}
class JsonIntValidator extends JsonValueValidator<int> {
  JsonIntValidator(String name, {bool required:true, int defaultVal:0}):super(name, required:required, defaultVal:defaultVal);
}
class JsonDoubleValidator extends JsonValueValidator<double> {
  JsonDoubleValidator(String name, {bool required:true, double defaultVal:0.0}):super(name, required:required, defaultVal:defaultVal);
}

/// helper class for DateTime fields. Expects an int in millisecondsSinceEpoch
class JsonDateTimeValidator extends JsonValueValidator<DateTime> {
  static DateTime ZERO = new DateTime.fromMillisecondsSinceEpoch(0);

  DateTime parse(dynamic d) {
    errors.clear();
    if (d is! int) {
      errors.add("${_path}not an int");
      return defaultVal;
    }
    return new DateTime.fromMillisecondsSinceEpoch(d as int);
  }

  JsonDateTimeValidator(String name, {bool required=true, DateTime defaultVal=null}):super(name, required:required, defaultVal:defaultVal);
}

/// helper class for Duration fields. Expects an int in millisecondsSinceEpoch
class JsonDurationValidator extends JsonValueValidator<Duration> {
  static Duration ZERO = new Duration();

  Duration parse(dynamic d) {
    errors.clear();
    if (d is! int) {
      errors.add("${_path}not an int");
      return defaultVal;
    }
    return new Duration(milliseconds: d as int);
  }

  JsonDurationValidator(String name, {bool required=true, Duration defaultVal=null}):super(name, required:required, defaultVal:defaultVal);
}

/// For maps where the names of the keys are not known in advance
class JsonUnknownKeysMapValidator extends JsonValueValidator<Map> {

  /// the values of the map to be validated are validated against this JsonValueValidator
  JsonValueValidator field;

  Map<String, dynamic> parse(dynamic d) {
    errors.clear();
    if (d is! Map<String, dynamic>) {
      errors.add("${_path}not a Map<String, dynamic>");
      return defaultVal;
    }
    var m = d as Map<String, dynamic>;
    var vals = new Map<String, dynamic>();
    for (var key in m.keys) {
      var val = field.parse(m[key]);
      errors.addAll(field.errors.map((String s)=>"${_path}${key}$s"));
      if(val!=null)
        vals[key]=val;
    }
    return vals;
  }

  JsonUnknownKeysMapValidator(String name, this.field, {bool required:true, Map defaultVal:null}):super(name, required:required, defaultVal:defaultVal);
}

class JsonMapValidator extends JsonValueValidator<Map> {
  List<JsonValueValidator> fields;

  /// if set to true, if a field does not validate the whole map will be replaced by defaultVal
  bool mustAllValidate = false;



  Map<String, dynamic> parse(dynamic d) {
    errors.clear();
    if (d is! Map<String, dynamic>) {
      errors.add("${_path}not a Map<String, dynamic>");
      return defaultVal;
    }
    var m = d as Map<String, dynamic>;
    var vals = new Map<String, dynamic>();
    for (var field in fields) {
      if(!m.containsKey(field.name)) {
        if (field.required) {
          errors.add("${_path}${field.name}/required field missing");
          if (mustAllValidate) {
            errors.add("${_path}discarding");
            return defaultVal;
          }
        }
        continue;
      }
      dynamic val = field.parse(d[field.name]);
      errors.addAll(field.errors.map((String s)=>"${_path}$s"));
      if (val!=null) {
        vals[field.name] = val;
      } else if(mustAllValidate) {
        errors.add("${_path}discarding");
        return defaultVal;
      }
    }
    return vals;
  }
  JsonMapValidator(String name, this.fields, {bool mustAllValidate=false, bool required=true, Map<String, dynamic> defaultVal=null}):super(name, required:required, defaultVal:defaultVal) {
    this.mustAllValidate=mustAllValidate;
  }
}

class JsonListValidator extends JsonValueValidator<List> {
  JsonValueValidator field;

  /// if set to true, if one field in the json list does not validate, parse will return defaultVal
  bool mustAllValidate = false;

  List<dynamic> parse(dynamic d) {
    errors.clear();
    if (d is! List) {
      errors.add("$name is not a List");
      return defaultVal;
    }
    var l = d as List;
    var vals = new List();
    for (int i=0; i<l.length; i++) {
      var o = l[i];
      dynamic val = field.parse(o);
      errors.addAll(field.errors.map((String e)=>"$_path${i}/${e}"));
      if (field.errors.isNotEmpty && mustAllValidate) {
        errors.add("${_path}discarding");
        return defaultVal;
      }
      if (val!=null)
        vals.add(val);
    }
    return vals;
  }

  JsonListValidator(String name, this.field, {bool mustAllValidate:false, bool required=true, List defaultVal=null}):super(name, required:required, defaultVal:defaultVal) {
    this.mustAllValidate=mustAllValidate;
  }
}