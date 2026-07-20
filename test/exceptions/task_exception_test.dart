import 'package:projet1/projet1.dart';
import 'package:test/test.dart';

void main() {
  group('TaskException hierarchy', () {
    test('TaskException.toString includes the message', () {
      final error = TaskException('something went wrong');

      expect(error.toString(), 'TaskException: something went wrong');
      expect(error, isA<Exception>());
    });

    test('InvalidTaskDataException is a TaskException', () {
      final error = InvalidTaskDataException('bad input');

      expect(error, isA<TaskException>());
      expect(error.message, 'bad input');
    });

    test('TaskNotFoundException carries the missing id in its message', () {
      final error = TaskNotFoundException('task-42');

      expect(error, isA<TaskException>());
      expect(error.message, contains('task-42'));
    });

    test('StorageException is a TaskException', () {
      final error = StorageException('disk is full');

      expect(error, isA<TaskException>());
      expect(error.message, 'disk is full');
    });
  });
}
