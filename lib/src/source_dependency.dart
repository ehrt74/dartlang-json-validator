class _SourceList {
  final List<SourceMapParser> _sources;
  final List<String> _errors;
  final List<String> _comments;
  _SourceList(this._sources, this._errors, this._comments);

  void _merge(_SourceList other) {
    this._sources.addAll(other._sources);
    this._errors.addAll(other._errors);
    this._comments.addAll(other._comments);
  }

  SourceList _toSourceList() => new SourceList(
        _sources.map((smp)=>new Source(smp._traversed, smp.dictionary, smp.value)).toList(growable:false),
        this._errors, this._comments);
}

/// Source is an instantiation of a SourceTemplate in a map. The path traversed,
/// the dictionary generated during instantiation, and the value of the leaf of
/// the map (if SourceTemplate.getValue is true) are stored
class Source {

  /// path of a route through the map which fulfills the source template
  final List<String> path;

  /// contains the values of the wildcards in the source template path
  final List<String> dictionary;

  /// contains the value of the end leaf node, if SourceTemplate.getValue was true
  final dynamic value;

  String toString()=>"{path: ${this.path.join("/")}, value:$value, dictionary:$dictionary}";

  Source(this.path, this.dictionary, this.value);
}

/// SourceList bundles the list of valid sources found with errors and comments
/// generated during instantiation of the SourceTemplate
class SourceList {
  final List<Source> sources;
  final List<String> errors;
  final List<String> comments;

  String toString() {
    return "{sources: ${sources}, \nerrors:${errors}, \ncomments:${comments}}";
  }

  SourceList(this.sources, this.errors, this.comments);
}

/// SourceTemplate is a method of specifying a path through a map. The path is
/// stored as a list of string in the path variable. The path may contain a
/// special strings, the wildcardString. This represents any key of
/// the map at this point. During instantiation in the SourceMapParser, multiple
/// Source objects will be generated at points where the SourceTemplate.path
/// contains a wildcard, and the value of the key in the map is stored in the
/// Source.dictionary list
class SourceTemplate {

  /// the path to be used for instantiation of Source objects. This should have
  /// a form like ["root", "child1", "child2", wildcardString, "child4"]
  final List<String> path;

  /// if the SourceMapParser should fetch the value stored in the leaf at the end
  /// of the path in the map
  final bool getValue;

  /// allows you to specify a wildcardString. This is useful if the map to be
  /// traversed uses "*" as a key
  final String wildcardString;

  SourceTemplate(this.path, this.getValue, {this.wildcardString="*"});


  SourceList getSourceList(dynamic map)=>new SourceMapParser(map, this).process();
}

class SourceMapParser {
  final String _wildcardString;

  List<String> _traversed = new List<String>();
  List<String> _remaining;

  List<String> dictionary = new List<String>();

  dynamic _map;

  bool _getValue;
  dynamic value;

  String toString() => "{path:${_traversed.join("/")} ... ${_remaining.join("/")}, value: $value, dictionary: ${dictionary}}";


  _SourceList _advance() {
    this._traversed..add(_remaining.first);
    _map = _map[_remaining.first];
    _remaining = _remaining.skip(1).toList();
    return new _SourceList([this], [], []);
  }

  _SourceList _branch(Iterable<String> vals) {
    List<SourceMapParser> ret = new List<SourceMapParser>();
    for (String key in vals) {
      ret.add(new SourceMapParser._intern(_cloneAndAdd(_traversed, key), _remaining.skip(1).toList(), _map[key], _cloneAndAdd(dictionary, key), this._getValue, this.value, this._wildcardString));
    }
    return new _SourceList(ret, [], []);
  }

  List<String> errors = new List<String>();
  List<String> comments = new List<String>();

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

        value = _map;
      }
      return new _SourceList([this], [], []);
    }
    var tmp = _step();
    var ret = new _SourceList([], tmp._errors, tmp._comments);

    for ( SourceMapParser s in tmp._sources) {
      ret._merge(s._process());
    }
    return ret;
  }

  SourceList process() {
    var slel = _process();
    return slel._toSourceList();
  }

  SourceMapParser._intern(this._traversed, this._remaining, this._map, this.dictionary, this._getValue, this.value, this._wildcardString);

  factory SourceMapParser(dynamic map, SourceTemplate st) {
    return new SourceMapParser._intern([], st.path, map, [], st.getValue, null, st.wildcardString);
  }
}

List<String> _cloneList(List<String> l)=>l.map((String s)=>s).toList();
List<String> _cloneAndAdd(List<String> l, String str)=>_cloneList(l)..add(str);