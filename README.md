# json_validator

A library for Dart developers. Its purpose is to validate json data structures. The data structure is modelled using JsonValueValidator objects. Then the json data structure can be validated. Missing fields are identified. Fields of the wrong type are identified and removed from the validated object.

## Usage

A simple usage example:

    import 'package:json_validator/json_validator.dart';

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
    }
    
Please see the test file for more usage examples.

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/ehrt74/dartlang-json-validator/issues
