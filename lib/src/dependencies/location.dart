class Location {
  final List<String> path;
  final String value;

  String toString()=>"{path: "+path.join("/")+"/${value??""}}";

  Location(this.path, this.value);
}
