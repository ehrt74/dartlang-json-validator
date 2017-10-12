// Copyright (c) 2017, edouard. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:json_validator/json_validator.dart';

main() {
  var personMap = {"name":"sarah", "age":40, "hasLongHair":false};

  var personValidator = new JsonMapValidator("aName", [new JsonIntValidator("age"),
  new JsonStringValidator("name"),
  new JsonBoolValidator("hasLongHair")
  ]);

  var validatedPersonMap = personValidator.parse(personMap);
}
