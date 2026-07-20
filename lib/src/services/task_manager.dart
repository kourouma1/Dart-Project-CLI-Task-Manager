import 'dart:io';

import 'package:projet1/src/exceptions/task_exception.dart';
import 'package:projet1/src/models/task.dart';
import 'package:projet1/src/repositories/task_repository.dart';

enum TaskSort { none, priority, deadline }

class TaskManager {
  TaskManager({required File storageFile})
      : _repository = TaskRepository<Task>(storageFile: storageFile);

  final TaskRepository<Task> _repository;

  Task addTask(String title, TaskPriority priority, {DateTime? deadline, bool isUrgent = false, String contact = 'n/a'}) {
    if (title.trim().isEmpty) {
      throw InvalidTaskDataException('Task title cannot be empty.');
    }

    final task = isUrgent
        ? UrgentTask(
            id: _nextId(),
            title: title.trim(),
            priority: priority,
            deadline: deadline,
            contact: contact,
          )
        : BasicTask(
            id: _nextId(),
            title: title.trim(),
            priority: priority,
            deadline: deadline,
          );

    _repository.add(task);
    return task;
  }

  List<Task> listTasks({TaskSort sortBy = TaskSort.none}) {
    final tasks = _repository.getAll();
    switch (sortBy) {
      case TaskSort.priority:
        final sorted = List<Task>.from(tasks);
        const priorityOrder = {
          TaskPriority.high: 0,
          TaskPriority.medium: 1,
          TaskPriority.low: 2,
        };
        sorted.sort(
          (a, b) => priorityOrder[a.priority]!.compareTo(priorityOrder[b.priority]!),
        );
        return sorted;
      case TaskSort.deadline:
        final sorted = List<Task>.from(tasks);
        sorted.sort((a, b) {
          if (a.deadline == null && b.deadline == null) return 0;
          if (a.deadline == null) return 1;
          if (b.deadline == null) return -1;
          return a.deadline!.compareTo(b.deadline!);
        });
        return sorted;
      case TaskSort.none:
        return tasks;
    }
  }

  Task? getTask(String id) => _repository.getById(id);

  void markTaskAsDone(String id) {
    final task = _repository.getById(id);
    if (task == null) {
      throw TaskNotFoundException(id);
    }

    if (task is UrgentTask) {
      _repository.update(
        UrgentTask(
          id: task.id,
          title: task.title,
          priority: task.priority,
          deadline: task.deadline,
          isDone: true,
          contact: task.contact,
        ),
      );
      return;
    }

    _repository.update(
      BasicTask(
        id: task.id,
        title: task.title,
        priority: task.priority,
        deadline: task.deadline,
        isDone: true,
      ),
    );
  }

  void deleteTask(String id) {
    _repository.delete(id);
  }

  String _nextId() {
    final tasks = _repository.getAll();
    var maxIndex = 0;
    for (final task in tasks) {
      final index = int.tryParse(task.id.split('-').last) ?? 0;
      if (index > maxIndex) {
        maxIndex = index;
      }
    }
    return 'task-${maxIndex + 1}';
  }
}
