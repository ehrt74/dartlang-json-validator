// Copyright (c) 2017, edouard. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

/// The type_validator library contains classes to validate the type of json
/// objects
///
/// To validate the type of a json object, first you construct a nested validator
/// object. then you call its validate method, passing the json object to be
/// validated as an argument.
///
/// The validator object will log an error if the object to be tested is not
/// of the required type.
///
/// A map validator is constructed with a Map of String -> MapField objects. A MapField
/// object contains meta-information about the field (if it is necessary or if
/// a supplied default value should be used if the field is missing.
library type_validator;

export 'package:json_validator/src/type_validator/type_validator_base.dart';
export 'package:json_validator/src/type_validator/type_validator_helpers.dart';
export 'package:json_validator/src/type_validator/object_builder.dart';

// TODO: Export any libraries intended for clients of this package.
