// Copyright (c) 2017, edouard. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:json_validator/json_validator.dart';

class Car {
  final String mark;
  final int topSpeed;

  String toString()=>"$mark: $topSpeed";

  Car(this.mark, this.topSpeed);
}

class CarValidator extends ValueValidator<Car> {
  Car validate(dynamic d) {
    errors.clear();
    if (d is! Map<String, dynamic>) {
      errors.add("not a map");
      return null;
    }
    if (!d.containsKey("mark")) {
      errors.add("mark missing");
      return null;
    }
    if (d["mark"] is! String) {
      errors.add("mark/not a string");
      return null;
    }
    if (d.containsKey("topSpeed")&& d["topSpeed"] is int) {
      return new Car(d["mark"], d["topSpeed"]);
    }
    return new Car(d["mark"], 100);

  }
}

main() {
  var personMap = {"name":"sarah", "age":40, "hasLongHair":false};

  var personValidator = new MapValidator({
    "age":new MapField(new IntValidator()),
    "name":new MapField(new StringValidator()),
    "hasLongHair":new MapField(new BoolValidator(), false),
    "likesIceCream":new MapField(new BoolValidator(), true),
  });

  print(personValidator.validate(personMap));
  print(personValidator.errors);

  var carMap1 = {"mark":"bmw", "topSpeed":120};
  var carMap2 = {"mark":"ford", "topSpeed":"120"};
  var carMap3 = {"make":"fiat", "topSpeed":120};
  var carMap4 = {"mark":"peugeot"};

  var carValidator = new CarValidator();
  for (var carMap in [carMap1, carMap2, carMap3, carMap4]) {
    print(carValidator.validate(carMap));
    print(carValidator.errors);
  }
}
