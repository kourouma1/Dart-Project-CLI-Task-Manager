// End-to-end smoke test exercising the public API as a whole.
// Focused unit tests per layer live under test/models, test/repositories
// and test/services.
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:projet1/projet1.dart';
import 'package:test/test.dart';

void main() {
  test('add, list, complete and delete a task through the public API', () {
    final tempDir = Directory.systemTemp.createTempSync('projet1_e2e_test_');
    final storageFile = File(p.join(tempDir.path, 'tasks.json'));
    addTearDown(() {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    final manager = TaskManager(storageFile: storageFile);

    final task = manager.addTask(
      'Prepare release notes',
      TaskPriority.medium,
      deadline: DateTime(2026, 12, 1),
    );
    expect(manager.listTasks(), hasLength(1));

    manager.markTaskAsDone(task.id);
    expect(manager.getTask(task.id)!.isDone, isTrue);

    manager.deleteTask(task.id);
    expect(manager.listTasks(), isEmpty);

    expect(storageFile.existsSync(), isTrue);
  });
}
