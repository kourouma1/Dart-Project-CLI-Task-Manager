import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:projet1/projet1.dart';
import 'package:test/test.dart';

void main() {
  late Directory tempDir;
  late File storageFile;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('task_repository_test_');
    storageFile = File(p.join(tempDir.path, 'tasks.json'));
  });

  tearDown(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  test('TaskRepository<T> implements the Repository<T> interface', () {
    final repository = TaskRepository<Task>(storageFile: storageFile);

    expect(repository, isA<Repository<Task>>());
  });

  test('add/getAll/getById/update/delete work as expected', () {
    final repository = TaskRepository<Task>(storageFile: storageFile);
    final task = BasicTask(id: 'task-1', title: 'Write docs', priority: TaskPriority.low);

    repository.add(task);

    expect(repository.getAll(), hasLength(1));
    expect(repository.getById('task-1')?.title, 'Write docs');

    repository.update(task.copyWith(title: 'Write better docs'));
    expect(repository.getById('task-1')?.title, 'Write better docs');

    repository.delete('task-1');
    expect(repository.getAll(), isEmpty);
  });

  test('adding a task with a duplicate id throws', () {
    final repository = TaskRepository<Task>(storageFile: storageFile);
    final task = BasicTask(id: 'task-1', title: 'First', priority: TaskPriority.low);
    repository.add(task);

    expect(
      () => repository.add(BasicTask(id: 'task-1', title: 'Duplicate', priority: TaskPriority.low)),
      throwsA(isA<TaskException>()),
    );
  });

  test('updating a missing task throws TaskNotFoundException', () {
    final repository = TaskRepository<Task>(storageFile: storageFile);

    expect(
      () => repository.update(BasicTask(id: 'missing', title: 'Nope', priority: TaskPriority.low)),
      throwsA(isA<TaskNotFoundException>()),
    );
  });

  test('deleting a missing task throws TaskNotFoundException', () {
    final repository = TaskRepository<Task>(storageFile: storageFile);

    expect(
      () => repository.delete('missing'),
      throwsA(isA<TaskNotFoundException>()),
    );
  });

  test('persists tasks to disk and reloads them into a fresh repository', () {
    final repository = TaskRepository<Task>(storageFile: storageFile);
    repository.add(BasicTask(id: 'task-1', title: 'Persist me', priority: TaskPriority.medium));

    final reloaded = TaskRepository<Task>(storageFile: storageFile);

    expect(reloaded.getAll(), hasLength(1));
    expect(reloaded.getAll().first.title, 'Persist me');
  });

  test('starting from a missing file yields an empty repository', () {
    final repository = TaskRepository<Task>(storageFile: storageFile);

    expect(repository.getAll(), isEmpty);
  });

  test('loading a corrupted JSON file throws StorageException', () {
    storageFile.createSync(recursive: true);
    storageFile.writeAsStringSync('{not valid json');

    expect(
      () => TaskRepository<Task>(storageFile: storageFile),
      throwsA(isA<StorageException>()),
    );
  });
}
