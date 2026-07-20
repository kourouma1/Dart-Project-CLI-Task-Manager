/// A pure interface: classes outside this library can `implement` it but
/// cannot `extend` it, guaranteeing `TaskRepository` provides its own
/// implementation of every member rather than inheriting one.
abstract interface class Repository<T> {
  void add(T item);
  List<T> getAll();
  T? getById(String id);
  void update(T item);
  void delete(String id);
}
