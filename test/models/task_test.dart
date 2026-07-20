import 'package:projet1/projet1.dart';
import 'package:test/test.dart';

void main() {
  group('Task.parsePriority', () {
    test('parses a valid, case-insensitive priority', () {
      expect(Task.parsePriority('HIGH'), TaskPriority.high);
      expect(Task.parsePriority('medium'), TaskPriority.medium);
    });

    test('throws InvalidTaskDataException for an unknown priority', () {
      expect(
        () => Task.parsePriority('urgent'),
        throwsA(isA<InvalidTaskDataException>()),
      );
    });
  });

  group('BasicTask', () {
    test('extends Task and exposes the "basic" type tag', () {
      final task = BasicTask(id: 'task-1', title: 'Write docs', priority: TaskPriority.low);

      expect(task, isA<Task>());
      expect(task.typeTag, 'basic');
      expect(task.isDone, isFalse);
    });

    test('round-trips through JSON', () {
      final task = BasicTask(
        id: 'task-1',
        title: 'Write docs',
        priority: TaskPriority.high,
        deadline: DateTime(2026, 1, 1),
      );

      final restored = Task.fromJson(task.toJson());

      expect(restored, isA<BasicTask>());
      expect(restored.id, task.id);
      expect(restored.title, task.title);
      expect(restored.priority, task.priority);
      expect(restored.deadline, task.deadline);
    });

    test('copyWith only changes the given fields', () {
      final task = BasicTask(id: 'task-1', title: 'Write docs', priority: TaskPriority.low);

      final done = task.copyWith(isDone: true);

      expect(done.isDone, isTrue);
      expect(done.id, task.id);
      expect(done.title, task.title);
      expect(done.priority, task.priority);
    });

    test('fromJson throws InvalidTaskDataException when id or title is missing', () {
      expect(
        () => BasicTask.fromJson({'title': 'No id'}),
        throwsA(isA<InvalidTaskDataException>()),
      );
    });
  });

  group('UrgentTask', () {
    test('extends BasicTask (which extends Task) and carries a contact', () {
      final task = UrgentTask(
        id: 'task-2',
        title: 'Escalate outage',
        priority: TaskPriority.high,
        contact: 'oncall@example.com',
      );

      expect(task, isA<BasicTask>());
      expect(task, isA<Task>());
      expect(task.typeTag, 'urgent');
      expect(task.contact, 'oncall@example.com');
    });

    test('round-trips through JSON, preserving the contact', () {
      final task = UrgentTask(
        id: 'task-2',
        title: 'Escalate outage',
        priority: TaskPriority.high,
        contact: 'oncall@example.com',
      );

      final restored = Task.fromJson(task.toJson());

      expect(restored, isA<UrgentTask>());
      expect((restored as UrgentTask).contact, 'oncall@example.com');
    });

    test('copyWith can update the contact independently of other fields', () {
      final task = UrgentTask(
        id: 'task-2',
        title: 'Escalate outage',
        priority: TaskPriority.high,
        contact: 'oncall@example.com',
      );

      final reassigned = task.copyWith(contact: 'backup@example.com') as UrgentTask;

      expect(reassigned.contact, 'backup@example.com');
      expect(reassigned.title, task.title);
    });
  });

  group('Task.fromJson dispatch', () {
    test('builds a BasicTask when "type" is absent or "basic"', () {
      final task = Task.fromJson({
        'id': 'task-1',
        'title': 'Untyped',
        'priority': 'low',
      });

      expect(task, isA<BasicTask>());
    });

    test('builds an UrgentTask when "type" is "urgent"', () {
      final task = Task.fromJson({
        'id': 'task-2',
        'title': 'Typed urgent',
        'priority': 'high',
        'type': 'urgent',
        'contact': 'me@example.com',
      });

      expect(task, isA<UrgentTask>());
    });
  });
}
