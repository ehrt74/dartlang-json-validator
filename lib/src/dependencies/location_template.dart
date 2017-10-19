class LocationTemplate {
  final String wildcardString;
  final String valueString;

  final List<String> path;

  String toString()=>"${path}, valueTemplate: $valueTemplate";

  String valueTemplate;

  LocationTemplate(this.path, this.valueTemplate, {this.wildcardString="#", this.valueString="VAL"});
}
