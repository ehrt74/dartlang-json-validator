// Copyright (c) 2017, edouard. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:json_validator/dependencies.dart';
import 'package:json_validator/src/dependencies/location_list.dart';
import 'package:test/test.dart';

void main() {

  group('Dependency Source Test', () {
    test('simple value', () {
      dynamic map = "foo";
      var sourceTemplate = new SourceTemplate([], true);
      var sourceList = new SourceList.fromMapAndSourceTemplate(map, sourceTemplate);
      print(sourceList);
      expect(sourceList.sources.length == 1, isTrue);
    });
    test('source expects simple value', () {
      dynamic map = {"foo": "bar"};
      var sourceTemplate = new SourceTemplate([], true);
      var sourceList = new SourceList.fromMapAndSourceTemplate(map, sourceTemplate);
      print(sourceList);
      expect(sourceList.sources.length == 0, isTrue);
    });
    test('value at simple path', () {
      dynamic map = {"x": "foo"};
      var sourceTemplate = new SourceTemplate(["x"], true);
      var sourceList = new SourceList.fromMapAndSourceTemplate(map, sourceTemplate);
      print(sourceList);
      expect(sourceList.sources.length == 1, isTrue);
    });
    test('simple wildcard', () {
      dynamic map = {"x1": "y1", "x2": "y2"};
      var sourceTemplate = new SourceTemplate(["*"], true);
      var sourceList = new SourceList.fromMapAndSourceTemplate(map, sourceTemplate);
      print(sourceList);
      expect(sourceList.sources.length == 2, isTrue);
    });
    test('value at complex path', () {
      dynamic map = {"x1": {"x2": "foo"}, "y1": "bar"};
      var sourceTemplate = new SourceTemplate(["x1", "x2"], true);
      var sourceList = new SourceList.fromMapAndSourceTemplate(map, sourceTemplate);
      print(sourceList);
      expect(sourceList.sources.length == 1, isTrue);
    });
    test('map too short', () {
      dynamic map = {"foo": "bar"};
      var sourceTemplate = new SourceTemplate(["foo", "bar"], true);
      var sourceList = new SourceList.fromMapAndSourceTemplate(map, sourceTemplate);
      print(sourceList);
      expect(sourceList.sources.length == 0, isTrue);
    });

    test('simple wildcard', () {
      dynamic map = {"x": "foo", "y": "bar"};
      var sourceTemplate = new SourceTemplate(["*"], true);
      var sourceList = new SourceList.fromMapAndSourceTemplate(map, sourceTemplate);
      print(sourceList);
      expect(sourceList.sources.length == 2, isTrue);
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
      var sourceTemplate = new SourceTemplate(['customers', '*', 'orders', '*', 'productNumber'], true);
      var sourceList = new SourceList.fromMapAndSourceTemplate(map, sourceTemplate);
      print(sourceList);
      expect(sourceList.sources.length == 3, isTrue);
    });
  });
  group('SourceTemplate', () {
    test('simple template', () {
      var map = {"foo": "bar"};
      var sourceTemplate = new SourceTemplate(["foo"], true);
      var sourceList = new SourceList.fromMapAndSourceTemplate(map, sourceTemplate);
      expect(sourceList.errors.isEmpty, isTrue);

      var locationTemplate = new LocationTemplate(["foo"], "bar");
      var locationList = new LocationList.fromSourceListAndTemplate(sourceList, locationTemplate);
      print(locationList);

      expect(locationList.locations[0].path.length == 1, isTrue);
    });

    test('simple wildcard', () {
      var map = {"x1": "y1", "x2": "y2"};
      var sourceTemplate = new SourceTemplate(["*"], true);
      var sourceList = new SourceList.fromMapAndSourceTemplate(map, sourceTemplate);
      expect(sourceList.errors.isEmpty, isTrue);

      var locationTemplate = new LocationTemplate(["#0"], null);
      var locationList = new LocationList.fromSourceListAndTemplate(sourceList, locationTemplate);
      print(locationList);
      expect(locationList.locations.length == 2, isTrue);
    });
    test('val wildcard', () {
      var map = {"x1": "y1", "x2": "y2"};
      var sourceTemplate = new SourceTemplate(["#"], true, wildcardString: "#");
      var sourceList = new SourceList.fromMapAndSourceTemplate(map, sourceTemplate);
      expect(sourceList.errors.isEmpty, isTrue);

      var locationTemplate = new LocationTemplate(["foo"], "#0");
      var locationList = new LocationList.fromSourceListAndTemplate(sourceList, locationTemplate);
      print(locationList);

      expect(locationList.locations.length == 2, isTrue);
    });
    test('complicated wildcard', () {
      var map = {"vals": {
        "val1": {"x11": "y11", "x12": "y12"},
        "val2": {"x21": "y21"}
      }};
      var sourceTemplate = new SourceTemplate(["vals", "*", "*"], true);
      var sourceList = new SourceList.fromMapAndSourceTemplate(map, sourceTemplate);
      expect(sourceList.errors.isEmpty, isTrue);

      var locationTemplate = new LocationTemplate(["root", "#1", "VAL", "foo"], "VAL");
      var locationList = new LocationList.fromSourceListAndTemplate(sourceList, locationTemplate);
      print(locationList);

      expect(locationList.locations.length == 3, isTrue);
    });
  });
  group('check targets', () {
    test('simple template', () {
      dynamic map = {"foo":"bar"};
      var sourceTemplate = new SourceTemplate(["foo"], false);
      var locationTemplate = new LocationTemplate(["foo"], null);
      var sourceList = new SourceList.fromMapAndSourceTemplate(map, sourceTemplate);
      var locationList = new LocationList.fromSourceListAndTemplate(sourceList, locationTemplate);

      var res = locationList.validateWithMap(map);

      print(res.errors);
      print(res.locations);
      expect(res.errors.isEmpty, isTrue);
      expect(res.locations.length == 1, isTrue);
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

      var sourceTemplate = new SourceTemplate(
          ["persons", "*", "orders", "*", "products", "*", "options", "*"],
          true);

      var locationTemplate = new LocationTemplate(["products", "#2", "options", "#3", "VAL"], null);
      print("locationTemplate:\n$locationTemplate\n");

      var sourceList = new SourceList.fromMapAndSourceTemplate(map, sourceTemplate);
      print("sourceList:\n$sourceList\n");

      var locationList = new LocationList.fromSourceListAndTemplate(sourceList, locationTemplate);
      print("locationList:\n$locationList\n");

      var res = locationList.validateWithMap(map);
      print("errors verifying target paths:\n${res.errors}");

      print("paths found:\n$res");
      expect(res.errors.isNotEmpty, isTrue);
      expect(res.locations.length == 1, isTrue);
    });
  });
}