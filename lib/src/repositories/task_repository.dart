import 'dart:convert';
import 'dart:io';

import 'package:projet1/src/exceptions/task_exception.dart';
import 'package:projet1/src/models/task.dart';
import 'package:projet1/src/repositories/repository.dart';

class TaskRepository<T extends Task> implements Repository<T> {
  TaskRepository({required File storageFile}) : _storageFile = storageFile {
    _loadFromFile();
  }

  final File _storageFile;
  final List<T> _tasks = <T>[];

  @override
  void add(T item) {
    if (_tasks.any((task) => task.id == item.id)) {
      throw TaskException('Task with id "${item.id}" already exists.');
    }
    _tasks.add(item);
    _persist();
  }

  @override
  List<T> getAll() => List<T>.unmodifiable(_tasks);

  @override
  T? getById(String id) {
    for (final task in _tasks) {
      if (task.id == id) {
        return task;
      }
    }
    return null;
  }

  @override
  void update(T item) {
    final index = _tasks.indexWhere((task) => task.id == item.id);
    if (index < 0) {
      throw TaskNotFoundException(item.id);
    }
    _tasks[index] = item;
    _persist();
  }

  @override
  void delete(String id) {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index < 0) {
      throw TaskNotFoundException(id);
    }
    _tasks.removeAt(index);
    _persist();
  }

  void _persist() {
    try {
      final parent = _storageFile.parent;
      if (!parent.existsSync()) {
        parent.createSync(recursive: true);
      }
      final payload = {
        'tasks': _tasks.map((task) => task.toJson()).toList(),
      };
      _storageFile.writeAsStringSync(jsonEncode(payload));
    } on FileSystemException catch (error) {
      throw StorageException('Unable to persist tasks: ${error.message}');
    }
  }

  void _loadFromFile() {
    if (!_storageFile.existsSync()) {
      return;
    }

    try {
      final content = _storageFile.readAsStringSync();
      if (content.trim().isEmpty) {
        return;
      }
      final decoded = jsonDecode(content) as Map<String, dynamic>;
      final items = decoded['tasks'] as List<dynamic>? ?? <dynamic>[];
      _tasks
        ..clear()
        ..addAll(items.map((item) {
          final taskJson = item as Map<String, dynamic>;
          return Task.fromJson(taskJson) as T;
        }));
    } on FormatException catch (error) {
      throw StorageException('Storage file is corrupted: ${error.message}');
    } on FileSystemException catch (error) {
      throw StorageException('Unable to read storage: ${error.message}');
    }
  }
}
