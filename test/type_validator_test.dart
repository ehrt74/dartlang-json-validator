// Copyright (c) 2017, edouard. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:json_validator/type_validator.dart';
import 'package:test/test.dart';

void main() {
  group('String field', () {
    test('001', () {
      var s = STRING.validate("foo");
      expect(s == "foo", isTrue);
      expect(STRING.errors.isEmpty, isTrue);
    });
    test('002', () {
      var s = STRING.validate(2);
      print(STRING.errors);
      expect(s == null, isTrue);
      expect(STRING.errors.isEmpty, isFalse);
    });
  });
  group('DateTime field', () {
    var now = new DateTime.now();

    test('001', () {
      var s = DATETIME.validate(now.millisecondsSinceEpoch);
      expect(s
          .difference(now)
          .inSeconds == 0, isTrue);
      expect(DATETIME.errors.isEmpty, isTrue);
    });
    test('002', () {
      var s = DATETIME.validate("foobar");
      expect(s == null, isTrue);
      print(DATETIME.errors);
      expect(DATETIME.errors.isEmpty, isFalse);
    });
  });
  group('List field', () {
    var lf = new ListValidator(STRING);

    test('001', () {
      var s = lf.validate(["foo", "bar"]);
      expect(s.length == 2, isTrue);
      expect(lf.errors.isEmpty, isTrue);
    });
    test('002', () {
      var s = lf.validate(["foo", true]);
      expect(s.length == 1, isTrue);
      print(lf.errors);
      expect(lf.errors.isEmpty, isFalse);
    });
  });
  group('Map field', () {
    var mf = new MapValidator({"name": new MapField(STRING),
      "age": new MapField(INT),
      "hasLongHair": new MapField(BOOL)});

    test('001', () {
      var s = mf.validate({"name": "Sarah", "age": 40, "hasLongHair": false});
      print(s);
      expect(s.length == 3, isTrue);
      expect(mf.errors.isEmpty, isTrue);
    });
    test('002', () {
      var s = mf.validate({"name": "Sarah", "age": "40", "hasLongHair": false});
      print(s);
      expect(s.length == 2, isTrue);
      expect(mf.errors.isEmpty, isFalse);
    });
    test('003', () {
      var s = mf.validate(["a", "list"]);
      print(s);
      expect(s == null, isTrue);
      expect(mf.errors.isEmpty, isFalse);
    });
    test('004', () {
      var s = mf.validate({"name": "Sarah", "age": "40", "hasLongHair": false});
      print(s);
      expect(s.length == 2, isTrue);
      expect(mf.errors.isEmpty, isFalse);
    });
  });
  group('Complicated object with unknown keys', () {
    var mf = new MapValidator({
      "name": new MapField(STRING),
      "age": new MapField(STRING),
      "hasLongHair": new MapField(BOOL),
      "cars": new MapField(new MapUnknownKeysValidator(
          new MapValidator({
            "mark": new MapField(STRING, mustValidate: true),
            "topSpeed": new MapField(INT, defaultValue: 100),
          }, requireAllFields: false))),
    });
    var o = {
      "name": "sarah",
      "age": 40,
      "hasLongHair": "true",
      "cars": {
        "myFirstCar": {"mark": "jaguar", "topSpeed": 140},
        "myCurrentCar": {"mark": "bmw"}
      }
    };
    test('001', () {
      var s = mf.validate(o);
      print(s);
      print("errors: ${mf.errors}");
      expect(s['name'] == "sarah", isTrue);
      expect(mf.comments.isEmpty, isFalse);
    });
  });
  group('Complicated object', () {
    var mf = new MapValidator({
      "name": new MapField(STRING),
      "age": new MapField(INT),
      "hasLongHair": new MapField(BOOL),
      "cars": new MapField(new ListValidator(new MapValidator({
        "mark": new MapField(STRING, mustValidate: true),
        "topSpeed": new MapField(INT, mustValidate: true),
      }))),
    });

    var o = {
      "name": "sarah",
      "age": 40,
      "hasLongHair": true,
      "cars": [{"mark": "jaguar", "topSpeed": 140}, {"mark": "bmw"}]
    };
    test('001', () {
      var s = mf.validate(o);
      print(s);
      print(mf.errors);
      print(mf.comments);
      expect(s["cars"].length == 2, isTrue);
    });
  });

}
