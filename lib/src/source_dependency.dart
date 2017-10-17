class _SourceListErrorList {
  final List<Source> sources;
  final List<String> errors;
  _SourceListErrorList(this.sources, this.errors);

  void merge(_SourceListErrorList other) {
    this.sources.addAll(other.sources);
    this.errors.addAll(other.errors);
  }
}

class SourceTemplate {
  final List<String> path;
  final bool useValue;

  SourceTemplate(this.path, this.useValue);
}

class Source {
  static final WILDCARD = "*";

  List<String> traversed = new List<String>();
  List<String> remaining;

  List<String> dictionary = new List<String>();

  dynamic map;

  bool useValue;
  dynamic value;

  String toString() => "[${traversed.join("/")} ... ${remaining.join("/")}] value: $value, dictionary: [${dictionary.join(", ")}]";


  _SourceListErrorList _advance() {
    this.traversed..add(remaining.first);
    map = map[remaining.first];
    remaining = remaining.skip(1).toList();
    return new _SourceListErrorList([this], []);
  }

  _SourceListErrorList _branch(Iterable<String> vals) {
    List<Source> ret = new List<Source>();
    for (String key in vals) {
      ret.add(new Source._intern(cloneAndAdd(traversed, key), remaining.skip(1).toList(), map[key], cloneAndAdd(dictionary, key), this.useValue, this.value));
    }
    return new _SourceListErrorList(ret, []);
  }

  List<String> errors = new List<String>();
  List<String> comments = new List<String>();

  _SourceListErrorList _step() {
    if (map is List)
      return new _SourceListErrorList([], ["$this: Lists not supported"]);

    if(map is! Map)
      return new _SourceListErrorList([], ["$this: map is already at a leaf. cannot advance"]);

    if(remaining.first==WILDCARD)
      return _branch(map.keys);
    if(!(map as Map<String, dynamic>).keys.contains(remaining.first)) {
      return new _SourceListErrorList([], ["$this: ${remaining.first} not found in map"]);
    }
    return this._advance();
  }

  _SourceListErrorList _process() {
    if (remaining.isEmpty) {
      if (useValue) {
        if (map is List)
          return new _SourceListErrorList([], ["$this: Lists not supported"]);

        if (map is Map)
          return new _SourceListErrorList([], ["$this: searching for value. Map is however not at a leaf"]);

        value = map;
      }
      return new _SourceListErrorList([this], []);
    }
    var tmp = _step();
    var ret = new _SourceListErrorList([], tmp.errors);

    for ( Source s in tmp.sources) {
      ret.merge(s._process());
    }
    return ret;
  }

  List<Source> process() {
    var slel = _process();
    this.errors = slel.errors;
    return slel.sources;
  }

  Source._intern(this.traversed, this.remaining, this.map, this.dictionary, this.useValue, this.value);

  Source(this.map, this.remaining, this.useValue);

}

List<String> cloneList(List<String> l)=>l.map((String s)=>s).toList();
List<String> cloneAndAdd(List<String> l, String str)=>cloneList(l)..add(str);