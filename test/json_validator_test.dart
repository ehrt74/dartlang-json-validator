// Copyright (c) 2017, edouard. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:json_validator/json_validator.dart';
import 'package:test/test.dart';

void main() {
  group('String field', () {
    JsonStringValidator jsf = new JsonStringValidator("aString", defaultVal:"missing");

    test('001', () {
      var s = jsf.parse("foo");
      expect(s=="foo", isTrue);
      expect(jsf.errors.isEmpty, isTrue);
    });
    test('002', () {
      var s = jsf.parse(2);
      print(jsf.errors);
      expect(s=="missing", isTrue);
      expect(jsf.errors.isEmpty, isFalse);
    });
  });
  group('DateTime field', () {
    var now = new DateTime.now();
    var oneHourAgo = now.subtract(new Duration(hours:1));
    var jdtf = new JsonDateTimeValidator("aDateTime", defaultVal:oneHourAgo);

    test('001', () {
      var s = jdtf.parse(now.millisecondsSinceEpoch);
      expect(s.difference(now).inSeconds==0, isTrue);
      expect(jdtf.errors.isEmpty, isTrue);
    });
    test('002', () {
      var s = jdtf.parse("foobar");
      expect(s==oneHourAgo, isTrue);
      print(jdtf.errors);
      expect(jdtf.errors.isEmpty, isFalse);
    });
  });
  group('List field', () {
    var jlf = new JsonListValidator("aList", new JsonStringValidator(null));

    test('001', () {
      var s = jlf.parse(["foo", "bar"]);
      expect(s.length==2, isTrue);
      expect(jlf.errors.isEmpty, isTrue);
    });
    test('002', () {
      var s = jlf.parse(["foo", true]);
      expect(s.length==1, isTrue);
      print(jlf.errors);
      expect(jlf.errors.isEmpty, isFalse);
    });
  });
  group('Map field', () {
    var jmf = new JsonMapValidator("aMap", [new JsonStringValidator("name"),
    new JsonIntValidator("age", defaultVal:null),
    new JsonBoolValidator("hasLongHair")
    ]);

    test('001', () {
      var s = jmf.parse({"name":"Sarah", "age":40, "hasLongHair":false});
      print(s);
      expect(s.length==3, isTrue);
      expect(jmf.errors.isEmpty, isTrue);
    });
    test('002', () {
      var s = jmf.parse({"name":"Sarah", "age":"40", "hasLongHair":false});
      print(s);
      expect(s.length==2, isTrue);
      expect(jmf.errors.isEmpty, isFalse);
    });
    test('003', () {
      var s = jmf.parse(["a", "list"]);
      print(s);
      expect(s==null, isTrue);
      expect(jmf.errors.isEmpty, isFalse);
    });
    test('004', () {
      var s = jmf.parse({"name":"Sarah", "age":"40", "hasLongHair":false});
      print(s);
      expect(s.length==2, isTrue);
      expect(jmf.errors.isEmpty, isFalse);
    });
  });
  group('Complicated object with unknown keys', ()
  {
    var jmf = new JsonMapValidator("aMap",
        [
          new JsonStringValidator("name"),
          new JsonIntValidator("age", defaultVal: null),
          new JsonBoolValidator("hasLongHair"),
          new JsonUnknownKeysMapValidator("cars", new JsonMapValidator("",
              [
                new JsonStringValidator("mark"),
                new JsonIntValidator("topSpeed", required:true)
              ], mustAllValidate: false))
        ]);
    var o = {"name":"sarah", "age":40, "hasLongHair":"true", "cars":{"myFirstCar":{"mark":"jaguar", "topSpeed":140}, "myCurrentCar":{"mark":"bmw" }}};
    test('001', () {
      var s = jmf.parse(o);
      print(s);
      print(jmf.errors);
      expect(s['name']=="sarah", isTrue);
    });
  });
  group('Complicated object', ()
  {
    var jmf = new JsonMapValidator("aMap",
        [
          new JsonStringValidator("name"),
          new JsonIntValidator("age", defaultVal: null),
          new JsonBoolValidator("hasLongHair"),
          new JsonListValidator("cars", new JsonMapValidator(null,
              [
                new JsonStringValidator("mark"),
                new JsonIntValidator("topSpeed", required:true)
              ], mustAllValidate: true), mustAllValidate: true)
        ], mustAllValidate:true);
    var o = {"name":"sarah", "age":40, "hasLongHair":true, "cars":[{"mark":"jaguar", "topSpeed":140}, {"mark":"bmw" }]};
    test('001', () {
      var s = jmf.parse(o);
      print(s);
      print(jmf.errors);
      expect(s==null, isTrue);
    });
  });
}
