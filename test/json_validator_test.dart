// Copyright (c) 2017, edouard. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:json_validator/json_validator.dart';
import 'package:json_validator/src/target_checker.dart';
import 'package:json_validator/src/source_dependency.dart';
import 'package:json_validator/src/target_dependency.dart';
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

  group('Dependency Source Test', () {
    test('simple value', () {
      dynamic map = "foo";
      var st = new SourceTemplate([], true);
      SourceList results = st.getSourceList(map);
      print(results);
      expect(results.sources.length == 1, isTrue);
    });
    test('source expects simple value', () {
      dynamic map = {"foo": "bar"};
      var results = (new SourceTemplate([], true)).getSourceList(map);
      print(results);
      expect(results.sources.length == 0, isTrue);
    });
    test('value at simple path', () {
      dynamic map = {"x": "foo"};
      var results = (new SourceTemplate(["x"], true)).getSourceList(map);
      print(results);
      expect(results.sources.length == 1, isTrue);
    });
    test('simple wildcard', () {
      dynamic map = {"x1": "y1", "x2": "y2"};
      var results = (new SourceTemplate(["*"], true)).getSourceList(map);
      print(results);
      expect(results.sources.length == 2, isTrue);
    });
    test('value at complex path', () {
      dynamic map = {"x1": {"x2": "foo"}, "y1": "bar"};
      var results = (new SourceTemplate(['x1', 'x2'], true)).getSourceList(map);
      print(results);
      expect(results.sources.length == 1, isTrue);
    });
    test('map too short', () {
      dynamic map = {"foo": "bar"};
      var results = (new SourceTemplate(["foo", "bar"], false)).getSourceList(map);
      print(results);
      expect(results.sources.length == 0, isTrue);
    });

    test('simple wildcard', () {
      dynamic map = {"x": "foo", "y": "bar"};
      var results = (new SourceTemplate(['*'], true)).getSourceList(map);
      print(results);
      expect(results.sources.length == 2, isTrue);
    });

    test('complicated structure', () {
      dynamic map = {
        "customers": {
          "x": {
            "name": "bob",
            "address": {
              "town": "Paris"
            },
            "orders": {
              "order00": {
                "productNumber": "product123"
              }
            }
          },
          "y": {
            "name": "sue",
            "address": {
              "town": "Tokyo"
            },
            "orders": {
              "order10": {
                "productNumber": "product234"
              },
              "order11": {
                "productNumber": "product123"
              }
            }
          },
          "z": {
            "name": "jane",
            "address": {
              "town": "Addis-Abeba"
            },
            "orders": {
              "order20": {
                "incorrectKey": "product345"
              }
            }
          }
        }
      };
      var st = new SourceTemplate(['customers', '*', 'orders', '*', 'productNumber'], true);
      var results = st.getSourceList(map);

      print(results);
      expect(results.sources.length == 3, isTrue);
    });
  });
  group('TargetTemplate', () {
    test('simple template', () {
      var map = {"foo": "bar"};
      var sourceList = (new SourceTemplate(["foo"], true)).getSourceList(map);

      expect(sourceList.errors.isEmpty, isTrue);

      var tt = new TargetTemplate(["foo"], "bar");

      var tl = tt.getTargetList(sourceList);
      print(tl);

      expect(tl.targets[0].path.length == 1, isTrue);
    });

    test('simple wildcard', () {
      var map = {"x1": "y1", "x2": "y2"};
      var sourceList = (new SourceTemplate(["*"], true)).getSourceList(map);
      expect(sourceList.errors.isEmpty, isTrue);

      var tt = new TargetTemplate(["#0"], null);

      var tl = tt.getTargetList(sourceList);
      print(tl);
      expect(tl.targets.length == 2, isTrue);
    });
    test('val wildcard', () {
      var map = {"x1": "y1", "x2": "y2"};
      var st = new SourceTemplate(["#"], true, wildcardString: "#");
      var sourceList = st.getSourceList(map);
      expect(sourceList.errors.isEmpty, isTrue);

      var tt = new TargetTemplate(["foo"], "#0");

      var tl = tt.getTargetList(sourceList);
      print(tl);

      expect(tl.targets.length == 2, isTrue);
    });
    test('complicated wildcard', () {
      var map = {"vals": {
        "val1": {"x11": "y11", "x12": "y12"},
        "val2": {"x21": "y21"}
      }};
      SourceTemplate st = new SourceTemplate(["vals", "*", "*"], true);
      var sourceList = st.getSourceList(map);
      expect(sourceList.errors.isEmpty, isTrue);

      var tt = new TargetTemplate(["root", "#1", "VAL", "foo"], "VAL");

      var tl = tt.getTargetList(sourceList);
      print(tl);

      expect(tl.targets.length == 3, isTrue);
    });
  });
  group('check targets', () {
    test('simple template', () {
      dynamic map = {"foo":"bar"};
      var st = new SourceTemplate(["foo"], false);
      var tt = new TargetTemplate(["foo"], null);

      var sourceList = st.getSourceList(map);
      var tl = tt.getTargetList(sourceList);

      var res = TARGETCHECKER.check(map, tl.targets);

      print(res.errors);
      print(res.targets);
      expect(res.errors.isEmpty, isTrue);
      expect(res.targets.length == 1, isTrue);
    });
    test('002', () {
      var map = {
        "persons": {
          "personid001": {
            "name": "sue",
            "orders": {
              "orderid001": {
                "products": {
                  "productid001": {
                    "price":5
                  }
                }
              }
            }
          },
          "personid002": {
            "name": "jane",
            "orders": {
              "orderid002": {
                "products": {
                  "productid002": {
                    "options": {
                      "optionKey001": "optionVal001"
                    }
                  },
                  "productid003": {
                    "price":4,
                    "options": {
                      "optionKey001":"optionVal001"
                    }
                  }
                }
              }
            }
          }
        },
        "products": {
          "productid001": {
            "available": true
          },
          "productid002": {
            "available": true,
            "options": {
              "optionKey001": {
                "optionVal001": "blue",
                "optionVal002": "red"
              }
            }
          }
        }
      };

      SourceTemplate st = new SourceTemplate(
          ["persons", "*", "orders", "*", "products", "*", "options", "*"],
          true);

      TargetTemplate tt = new TargetTemplate(["products", "#2", "options", "#3", "VAL"], null);

      SourceList sl = st.getSourceList(map);
      print("sourceList:\n$sl\n");
      TargetList tl = tt.getTargetList(sl);
      print("targetList:\n$tl\n");

      var res = TARGETCHECKER.check(map, tl.targets);
      print("errors verifying target paths:\n${res.errors}");

      print("paths found:\n$res");
      expect(res.errors.isNotEmpty, isTrue);
      expect(res.targets.length == 1, isTrue);
    });
  });
}
