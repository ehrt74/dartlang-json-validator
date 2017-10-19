# json_validator

A library for Dart developers. Its purpose is to validate json data structures. The data structure is modelled using Validator objects. Then the json data structure can be validated. Missing fields are identified and can optionally be replaced with a default value. Fields of the wrong type are identified and removed from the validated object.

## Usage

A simple usage example:

    import 'package:json_validator/type_validator.dart';

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
    }
    
Please see the test file for more usage examples.

# dependencies

A library to check cross-dependencies in json maps. Classes and methods in this library can verify that keys or values at one location in a map are also present at other locations. Consider a map containing a list of orders and and list of products. the orders contain productIds. These can be checked to see if they are present in the product list.

## Usage:

A simple usage example:

    import 'package:json_validator/dependencies.dart';
    
    var map = {
      "orders": {
        "order0001": {
          "products": {
            "product001": {
              "amount": 3,
              "options": {
                "option001":"option001val001"
              }
            }
          }
        }
      },
      "products": {
        "product001": {
          "options": {
            "option001": {
              "option001val001":"blue",
              "option001val002":"red"
            }
          }
        }
      }
    };
    
    main() {
      var sourceTemplate = new SourceTemplate(["orders", "*", "products", "*", "options", "*"], true);
      var locationTemplate = new LocationTemplate(["products", "#1", "options", "#2", "VAL"], null);
    
      var sourceList = new SourceList.fromMapAndSourceTemplate(map, sourceTemplate);
      var locationList = new LocationList.fromSourceListAndTemplate(sourceList, locationTemplate);
    
      var verifiedLocationList = locationList.validateWithMap(map);
      print(verifiedLocationList);
    } 

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/ehrt74/dartlang-json-validator/issues
