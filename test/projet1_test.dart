import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:projet1/projet1.dart';
import 'package:test/test.dart';

void main() {
  late Directory tempDir;
  late File storageFile;
  late TaskManager manager;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('task_manager_test_');
    storageFile = File(p.join(tempDir.path, 'tasks.json'));
    manager = TaskManager(storageFile: storageFile);
  });

  tearDown(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  test('adds a basic task and lists it', () {
    final task = manager.addTask('Write docs', TaskPriority.high);

    expect(task.title, 'Write docs');
    expect(manager.listTasks().length, 1);
    expect(manager.listTasks().first.priority, TaskPriority.high);
  });

  test('marks a task as done', () {
    final task = manager.addTask('Ship feature', TaskPriority.medium);

    manager.markTaskAsDone(task.id);

    final updated = manager.getTask(task.id);
    expect(updated!.isDone, isTrue);
  });

  test('deletes a task', () {
    final task = manager.addTask('Delete old task', TaskPriority.low);

    manager.deleteTask(task.id);

    expect(manager.listTasks(), isEmpty);
  });

  test('persists tasks to disk and reloads them', () {
    manager.addTask('Persist me', TaskPriority.low);

    final reloaded = TaskManager(storageFile: storageFile);

    expect(reloaded.listTasks(), hasLength(1));
    expect(reloaded.listTasks().first.title, 'Persist me');
  });

  test('throws for invalid priority values', () {
    expect(
      () => Task.parsePriority('urgent'),
      throwsA(isA<InvalidTaskDataException>()),
    );
  });
}
