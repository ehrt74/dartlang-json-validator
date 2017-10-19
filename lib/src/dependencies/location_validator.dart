import 'package:json_validator/src/dependencies/location_list.dart';
import 'package:json_validator/src/dependencies/location.dart';


LocationValidator LOCATIONVALIDATOR = new LocationValidator._intern();

class LocationValidator {

  LocationValidator._intern();

  LocationList validateLocationsWithMap(List<Location> locations, dynamic map) {
    var targets = new List<Location>();
    var errors = new List<String>();

    locations.forEach((Location t) {
      String err = _checkTarget(t, map);
      if (err==null)
        targets.add(t);
      else
        errors.add(err);
    });
    return new LocationList(targets, errors);
  }

  String _checkTarget(Location t, dynamic map) {
    var p = t.path;
    while(p.isNotEmpty) {
      if (map is! Map)
        return "{target: ${t} error: not found}";

      if (!(map as Map).containsKey(p.first))
        return "{target: ${t}, error: key ${p.first} not found}";

      map = map[p.first];
      p = p.skip(1);
    }
    if (t.value!=null) {
      if (map is Map)
        return "{target: ${t}, error: expecting leaf}";
      if (map!=t.value)
        return "{target: ${t}, error: wrong value in map}";
    }
    return null;
  }
}