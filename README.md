# CLI Task Manager

A command-line task management application written in pure Dart (no Flutter).

## Features

- Add a task with a title, a priority (`low` / `medium` / `high`) and an optional deadline
- Mark tasks as "urgent" (adds a contact to notify) via the `UrgentTask` subclass
- List all tasks, optionally sorted by priority or by deadline
- Mark a task as done
- Delete a task
- Data is persisted to a local `tasks.json` file, reloaded automatically on startup

## Project structure

```text
lib/
  src/
    models/task.dart              # abstract Task, BasicTask, UrgentTask
    repositories/repository.dart  # Repository<T> interface (generic)
    repositories/task_repository.dart # TaskRepository<T>, JSON persistence
    services/task_manager.dart    # business logic (add/list/done/delete)
    exceptions/task_exception.dart # TaskException hierarchy
  projet1.dart                    # public library barrel file
bin/
  projet1.dart                    # interactive CLI entry point
test/
  projet1_test.dart                # unit tests
```

## Requirements

- [Dart SDK](https://dart.dev/get-dart) `>= 3.12.2`

## Getting started

Install dependencies:

```bash
dart pub get
```

Run the app:

```bash
dart run bin/projet1.dart
```

A `tasks.json` file is created in the current directory and used to persist your tasks between runs.

You will be shown a menu:

```text
1. Ajouter une tâche
2. Lister les tâches
3. Marquer une tâche comme terminée
4. Supprimer une tâche
5. Quitter
```

Follow the prompts to add a task (title, priority, optional deadline, optional urgent flag + contact), list tasks (optionally sorted), mark a task done by its id (e.g. `task-1`), or delete a task by its id.

## Running the tests

The project has unit tests written with the [`test`](https://pub.dev/packages/test) package:

```bash
dart test
```

## Technical highlights

- **Abstract classes & inheritance**: `Task` is abstract; `BasicTask` extends it and `UrgentTask` extends `BasicTask`, adding a `contact` field.
- **Interface**: `Repository<T>` is an abstract class implemented by `TaskRepository<T>`.
- **Generics**: `Repository<T>` and `TaskRepository<T extends Task>`.
- **Custom exceptions**: `TaskException` and its subtypes `InvalidTaskDataException`, `TaskNotFoundException`, `StorageException`.
- **Persistence**: tasks are serialized to/from JSON and stored in `tasks.json`.
