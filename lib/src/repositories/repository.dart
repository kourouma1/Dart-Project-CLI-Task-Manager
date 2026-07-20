abstract class Repository<T> {
  void add(T item);
  List<T> getAll();
  T? getById(String id);
  void update(T item);
  void delete(String id);
}
