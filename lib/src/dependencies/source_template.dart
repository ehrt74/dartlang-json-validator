/// SourceTemplate is a method of specifying a path through a map. The path is
/// stored as a list of string in the path variable. The path may contain a
/// special strings, the wildcardString. This represents any key of
/// the map at this point. During instantiation in the SourceMapParser, multiple
/// Source objects will be generated at points where the SourceTemplate.path
/// contains a wildcard, and the value of the key in the map is stored in the
/// Source.dictionary list
class SourceTemplate {

  String toString()=>"/${path.join("/")}/${getValue}";

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
}
