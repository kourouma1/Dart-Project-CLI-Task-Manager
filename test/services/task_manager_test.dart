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

  group('adding tasks', () {
    test('adds a basic task and lists it', () {
      final task = manager.addTask('Write docs', TaskPriority.high);

      expect(task, isA<BasicTask>());
      expect(task.title, 'Write docs');
      expect(manager.listTasks().length, 1);
      expect(manager.listTasks().first.priority, TaskPriority.high);
    });

    test('adds an urgent task carrying a contact', () {
      final task = manager.addTask(
        'Escalate outage',
        TaskPriority.high,
        isUrgent: true,
        contact: 'oncall@example.com',
      );

      expect(task, isA<UrgentTask>());
      expect((task as UrgentTask).contact, 'oncall@example.com');
    });

    test('rejects an empty title', () {
      expect(
        () => manager.addTask('   ', TaskPriority.low),
        throwsA(isA<InvalidTaskDataException>()),
      );
    });

    test('assigns increasing ids even after a deletion', () {
      final first = manager.addTask('First', TaskPriority.low);
      final second = manager.addTask('Second', TaskPriority.low);
      manager.deleteTask(second.id);

      final third = manager.addTask('Third', TaskPriority.low);

      expect(first.id, 'task-1');
      expect(second.id, 'task-2');
      expect(third.id, 'task-3');
    });
  });

  group('marking tasks as done', () {
    test('marks a task as done', () {
      final task = manager.addTask('Ship feature', TaskPriority.medium);

      manager.markTaskAsDone(task.id);

      final updated = manager.getTask(task.id);
      expect(updated!.isDone, isTrue);
    });

    test('throws TaskNotFoundException for an unknown id', () {
      expect(
        () => manager.markTaskAsDone('does-not-exist'),
        throwsA(isA<TaskNotFoundException>()),
      );
    });

    test('throws when marking an already-done task as done again', () {
      final task = manager.addTask('Ship feature', TaskPriority.medium);
      manager.markTaskAsDone(task.id);

      expect(
        () => manager.markTaskAsDone(task.id),
        throwsA(isA<InvalidTaskDataException>()),
      );
    });
  });

  group('deleting tasks', () {
    test('deletes a task', () {
      final task = manager.addTask('Delete old task', TaskPriority.low);

      manager.deleteTask(task.id);

      expect(manager.listTasks(), isEmpty);
    });

    test('throws TaskNotFoundException when deleting an unknown id', () {
      expect(
        () => manager.deleteTask('does-not-exist'),
        throwsA(isA<TaskNotFoundException>()),
      );
    });
  });

  group('listing and sorting', () {
    test('sorts tasks by priority (high, medium, low)', () {
      manager.addTask('Low task', TaskPriority.low);
      manager.addTask('High task', TaskPriority.high);
      manager.addTask('Medium task', TaskPriority.medium);

      final sorted = manager.listTasks(sortBy: TaskSort.priority);

      expect(sorted.map((t) => t.priority), [
        TaskPriority.high,
        TaskPriority.medium,
        TaskPriority.low,
      ]);
    });

    test('sorts tasks by deadline, pushing tasks without one to the end', () {
      manager.addTask('No deadline', TaskPriority.low);
      manager.addTask(
        'Later',
        TaskPriority.low,
        deadline: DateTime(2030, 1, 1),
      );
      manager.addTask(
        'Sooner',
        TaskPriority.low,
        deadline: DateTime(2026, 1, 1),
      );

      final sorted = manager.listTasks(sortBy: TaskSort.deadline);

      expect(sorted.map((t) => t.title), ['Sooner', 'Later', 'No deadline']);
    });
  });

  group('persistence', () {
    test('persists tasks to disk and reloads them', () {
      manager.addTask('Persist me', TaskPriority.low);

      final reloaded = TaskManager(storageFile: storageFile);

      expect(reloaded.listTasks(), hasLength(1));
      expect(reloaded.listTasks().first.title, 'Persist me');
    });

    test('round-trips an urgent task through JSON', () {
      manager.addTask(
        'Call back client',
        TaskPriority.high,
        isUrgent: true,
        contact: 'client@example.com',
      );

      final reloaded = TaskManager(storageFile: storageFile);
      final task = reloaded.listTasks().first;

      expect(task, isA<UrgentTask>());
      expect((task as UrgentTask).contact, 'client@example.com');
    });
  });
}
