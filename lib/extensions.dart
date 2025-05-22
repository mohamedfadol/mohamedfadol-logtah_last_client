// extensions.dart
extension IterableExtensions<E> on Iterable<E> {
  Iterable<T> mapIndexed<T>(T Function(int index, E element) transform) sync* {
    int index = 0;
    for (final element in this) {
      yield transform(index, element);
      index++;
    }
  }
}
