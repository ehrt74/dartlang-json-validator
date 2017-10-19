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

  String toString()=>"{path: ${this.path.join("/")}/${value??""}, dictionary:$dictionary}";

  Source(this.path, this.dictionary, this.value);
}
