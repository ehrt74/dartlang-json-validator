// Copyright (c) 2017, edouard. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

/// The dependecies library is used to check a json object for cross-dependencies.
///
/// For example, consider a json object containing a map of orders and a map of
/// products. each order object contains a productId.
///
/// The dependency library can be used to check that the productId is present
/// in the product map.
///
/// This is done by constructing a SourceTemplate object, in this case the path
/// to the productId value in the order object. The json object is then passed
/// to get a SourceList object. A source object contains a dictionary of values
/// found at any wildcards in the SourceTemplate object.
///
/// Then a LocationTemplate object is constructed. This is a path to the required
/// location in the json map, with wildcards.
///
/// Then a LocationList object is constructed from the SourceList object and the
/// LocationTemplate. This will try to create a Location object for each Source
/// in the SourceList object
///
/// Finally, the LocationList object is verified for the json object.
library dependencies;

export 'package:json_validator/src/dependencies/source.dart';
export 'package:json_validator/src/dependencies/source_list.dart';
export 'package:json_validator/src/dependencies/source_template.dart';
export 'package:json_validator/src/dependencies/location_validator.dart';
export 'package:json_validator/src/dependencies/location.dart';
export 'package:json_validator/src/dependencies/location_list.dart';
export 'package:json_validator/src/dependencies/location_template.dart';