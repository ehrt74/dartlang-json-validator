import 'package:json_validator/src/dependencies/location.dart';
import 'package:json_validator/src/dependencies/location_template.dart';
import 'package:json_validator/src/dependencies/location_validator.dart';
import 'package:json_validator/src/dependencies/source.dart';
import 'package:json_validator/src/dependencies/source_list.dart';

class LocationList {
  final List<Location> locations;
  final List<String> errors;

  String toString()=>
      "{locations:${locations}, \nerrors:${errors.join("\n")}}";

  LocationList(this.locations, this.errors);

  LocationList.fromSourceListAndTemplate(SourceList sourceList, LocationTemplate locationTemplate):locations=new List<Location>(), errors=new List<String>() {
    for(Source source in sourceList.sources) {
      _parseSource(source, locationTemplate);
    }
  }

  LocationList validateWithMap(dynamic map) => LOCATIONVALIDATOR.validateLocationsWithMap(this.locations, map);

  void _parseSource(Source source, LocationTemplate locationTemplate) {
    var retPath = new List<String>();
    for (String p in locationTemplate.path) {
      if (p.startsWith(locationTemplate.wildcardString)) {
        int n;
        try {
          n = int.parse(p.substring(locationTemplate.wildcardString.length));
        } catch (e) {
          errors.add("could not parse $p as wildcard");
          return;
        }
        if (n >= source.dictionary.length) {
          errors.add("${locationTemplate}: dictionary too small: ${source}");
          return;
        }
        retPath.add(source.dictionary[n]);
        continue;
      }
      if (p == locationTemplate.valueString) {
        if (source.value == null) {
          errors.add("${locationTemplate}: value not set in source: ${source}");
          return;
        }
        retPath.add(source.value);
        continue;
      }
      retPath.add(p);
      continue;
    }
    String value;
    if (locationTemplate.valueTemplate==null) {
    } else if (locationTemplate.valueTemplate==locationTemplate.valueString) {
      if (source.value==null) {
        errors.add("${this}: value not set in source: ${source}");
        return;
      }
      value = source.value;
    } else if(locationTemplate.valueTemplate.startsWith(locationTemplate.wildcardString)) {
      int n;
      try {
        n = int.parse(locationTemplate.valueTemplate.substring(locationTemplate.wildcardString.length));
      } catch (e) {
        errors.add("${this}: could not parse ${locationTemplate.valueTemplate} as wildcard");
        return;
      }
      if (n >= source.dictionary.length) {
        errors.add("${this}: dictionary too small: ${source}");
        return;
      }
      value = source.dictionary[n];
    } else {
      value = locationTemplate.valueTemplate;
    }
    locations.add(new Location(retPath, value));
  }
}
