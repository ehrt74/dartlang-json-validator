// Copyright (c) 2017, edouard. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:json_validator/json_validator.dart';
import 'package:json_validator/src/object_builder.dart';

class Car {
  final String mark;
  final int topSpeed;

  String toString()=>"$mark: $topSpeed";

  Car(this.mark, this.topSpeed);
}

class CarBuilder extends ObjectBuilder<Car> {
  Car build(Map<String, dynamic> m) {
    errors.clear();
    return new Car(m["mark"], m["topSpeed"]);
  }
}

var carValidator = new ObjectValidator<Car>(
    {
      "mark":new MapField(STRING, mustValidate: true, mustBePresent: true),
      "topSpeed":new MapField(INT, defaultValue:100, mustValidate: true, mustBePresent: false)},
    new CarBuilder(),
  requireAllFields: true
);


main() {
  var personMap = {"name":"sarah", "age":40, "hasLongHair":false};

  var personValidator = new MapValidator({
    "age":new MapField(INT),
    "name":new MapField(STRING),
    "hasLongHair":new MapField(BOOL, defaultValue:false),
    "likesIceCream":new MapField(BOOL, defaultValue:true),
  });

  print(personValidator.validate(personMap));
  print(personValidator.errors);

  var carMap1 = {"mark":"bmw", "topSpeed":120};
  var carMap2 = {"mark":"ford", "topSpeed":"120"};
  var carMap3 = {"make":"fiat", "topSpeed":120};
  var carMap4 = {"mark":"peugeot"};

  for (var carMap in [carMap1, carMap2, carMap3, carMap4]) {
    print("map: $carMap");
    print("car: ${carValidator.validate(carMap)}");
    print("errors: ${carValidator.errors}");
    print("comments: ${carValidator.comments}");
  }
}
