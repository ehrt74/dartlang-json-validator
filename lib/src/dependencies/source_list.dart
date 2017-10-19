import 'package:json_validator/src/dependencies/source.dart';
import 'package:json_validator/src/dependencies/source_template.dart';

/// SourceList bundles the list of valid sources found with errors and comments
/// generated during instantiation of the SourceTemplate
class SourceList {
  final List<Source> sources;
  final List<String> errors;
  final List<String> comments;

  String toString()=>"{sources: ${sources}, \nerrors:${errors}, \ncomments:${comments}}";

  SourceList(this.sources, this.errors, this.comments);

  /// SourceList.fromMapAndSourceTemplate sets sources to all possible instantiations
  /// of sourceTemplate in map.
  factory SourceList.fromMapAndSourceTemplate(dynamic map, SourceTemplate sourceTemplate) {
    return new _SourceMapParser(map, sourceTemplate)._process()._toSourceList();
  }
}


class _SourceMapParser {
  final String _wildcardString;

  List<String> _traversed = new List<String>();
  List<String> _remaining;

  List<String> _dictionary = new List<String>();

  dynamic _map;

  bool _getValue;
  dynamic _value;

  String toString() => "{path:${_traversed.join("/")}/ ... ${_remaining.join("/")}/${_value??""}, dictionary: ${_dictionary}}";


  _SourceList _advance() {
    this._traversed..add(_remaining.first);
    _map = _map[_remaining.first];
    _remaining = _remaining.skip(1).toList();
    return new _SourceList([this], [], []);
  }

  _SourceList _branch(Iterable<String> vals) {
    List<_SourceMapParser> ret = new List<_SourceMapParser>();
    for (String key in vals) {
      ret.add(new _SourceMapParser._intern(_cloneAndAdd(_traversed, key), _remaining.skip(1).toList(), _map[key], _cloneAndAdd(_dictionary, key), this._getValue, this._value, this._wildcardString));
    }
    return new _SourceList(ret, [], []);
  }

  List<String> _errors = new List<String>();
  List<String> _comments = new List<String>();

  _SourceList _step() {
    if (_map is List)
      return new _SourceList([], ["$this: Lists not supported"], []);

    if(_map is! Map)
      return new _SourceList([], ["$this: map is already at a leaf. cannot advance"], []);

    if(_remaining.first==_wildcardString)
      return _branch(_map.keys);
    if(!(_map as Map<String, dynamic>).keys.contains(_remaining.first)) {
      return new _SourceList([], [], ["{source: $this, comment: ${_remaining.first} not found in map}"]);
    }
    return this._advance();
  }

  _SourceList _process() {
    if (_remaining.isEmpty) {
      if (_getValue) {
        if (_map is List)
          return new _SourceList([], ["$this: Lists not supported"], []);

        if (_map is Map)
          return new _SourceList([], ["$this: searching for value. Map is however not at a leaf"], []);

        _value = _map;
      }
      return new _SourceList([this], [], []);
    }
    var tmp = _step();
    var ret = new _SourceList([], tmp._errors, tmp._comments);

    for ( _SourceMapParser s in tmp._sources) {
      ret._merge(s._process());
    }
    return ret;
  }

  _SourceMapParser._intern(this._traversed, this._remaining, this._map, this._dictionary, this._getValue, this._value, this._wildcardString);

  factory _SourceMapParser(dynamic map, SourceTemplate sourceTemplate) {
    return new _SourceMapParser._intern([], sourceTemplate.path, map, [], sourceTemplate.getValue, null, sourceTemplate.wildcardString);
  }
}

class _SourceList {
  final List<_SourceMapParser> _sources;
  final List<String> _errors;
  final List<String> _comments;
  _SourceList(this._sources, this._errors, this._comments);

  void _merge(_SourceList other) {
    this._sources.addAll(other._sources);
    this._errors.addAll(other._errors);
    this._comments.addAll(other._comments);
  }

  SourceList _toSourceList() => new SourceList(
      _sources.map((smp)=>new Source(smp._traversed, smp._dictionary, smp._value)).toList(growable:false),
      this._errors, this._comments);
}

List<String> _cloneList(List<String> l)=>l.map((String s)=>s).toList();
List<String> _cloneAndAdd(List<String> l, String str)=>_cloneList(l)..add(str);