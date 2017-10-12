# json_validator

A library for Dart developers. Its purpose is to validate json data structures. The data structure is modelled using JsonValueValidator objects. Then the json data structure can be validated. Missing fields are identified. Fields of the wrong type are identified and removed from the validated object.

## Usage

A simple usage example:

    import 'package:json_validator/json_validator.dart';

    main() {
      var personMap = {"name":"sarah", "age":40, "hasLongHair":false};
    
      var personValidator = new JsonMapValidator("aName", [new JsonIntValidator("age"),
      new JsonStringValidator("name"),
      new JsonBoolValidator("hasLongHair")
      ]);
    
      var validatedPersonMap = personValidator.parse(personMap);
      print(personValidator.errors);      
    }
    
Please see the test file for more usage examples.

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/ehrt74/dartlang-json-validator/issues
