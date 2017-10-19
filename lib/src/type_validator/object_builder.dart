///ObjectBuilder contains a factory to turn a validated Map<String, *> into
///an object
abstract class ObjectBuilder<T> {
  final List<String> errors = [];

  T build(Map<String, dynamic> m);
}