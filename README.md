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
    models/task.dart               # abstract Task, BasicTask, UrgentTask
    repositories/repository.dart   # Repository<T> interface (generic)
    repositories/task_repository.dart # TaskRepository<T>, JSON persistence
    services/task_manager.dart     # business logic (add/list/done/delete)
    exceptions/task_exception.dart # TaskException hierarchy
  projet1.dart                     # public library barrel file
bin/
  projet1.dart                     # interactive CLI entry point
test/
  projet1_test.dart                # end-to-end smoke test (public API)
  models/task_test.dart            # unit tests for Task/BasicTask/UrgentTask
  repositories/task_repository_test.dart # unit tests for TaskRepository<T>
  services/task_manager_test.dart  # unit tests for TaskManager
  exceptions/task_exception_test.dart # unit tests for the exception hierarchy
.github/workflows/dart.yml         # CI: pub get, analyze, test on every push
```

### Architecture

The `lib/src` folder is split into layers, each with a single responsibility:

- **`models`** — plain data classes (`Task`, `BasicTask`, `UrgentTask`) with no I/O.
- **`repositories`** — persistence layer (`Repository<T>` interface, `TaskRepository<T>` JSON implementation).
- **`services`** — business logic (`TaskManager`), orchestrating repositories and models.
- **`exceptions`** — the `TaskException` hierarchy, shared across all layers.
- **`bin/projet1.dart`** — the presentation layer: an interactive CLI on top of `TaskManager`.

The test suite mirrors this layering, with one test file per layer (see above), plus a top-level end-to-end test.

## Requirements

- [Dart SDK](https://dart.dev/get-dart) `>= 3.12.2`

## Getting started

Clone the repo and fetch dependencies:

```bash
git clone <this-repo-url>
cd projet1
dart pub get
```

Run the app:

```bash
dart run bin/projet1.dart
```

A `tasks.json` file is created in the current directory (git-ignored) and used to persist your tasks between runs.

You will be shown a menu:

```text
1. Ajouter une tâche
2. Lister les tâches
3. Marquer une tâche comme terminée
4. Supprimer une tâche
5. Quitter
```

Follow the prompts to add a task (title, priority, optional deadline, optional urgent flag + contact), list tasks (optionally sorted by priority or deadline), mark a task done by its id (e.g. `task-1`), or delete a task by its id.

### Example session

```text
=== CLI Task Manager ===
Fichier de données : /home/user/projet1/tasks.json
--------------------------------
1. Ajouter une tâche
2. Lister les tâches
3. Marquer une tâche comme terminée
4. Supprimer une tâche
5. Quitter
--------------------------------
Votre choix : 1
Titre de la tâche : Appeler le client
Priorité (low/medium/high) : high
Date limite (AAAA-MM-JJ, laisser vide si aucune) :
Tâche urgente ? (o/n) : o
Contact à prévenir : Martin
Tâche créée avec succès : [ ] task-1 | Appeler le client | priorité: high | échéance: sans échéance (URGENT - contact: Martin)
```

## Running the tests

The project has 35+ unit tests written with the [`test`](https://pub.dev/packages/test) package, split across five files (one per architectural layer, see [Architecture](#architecture) above): model creation and JSON round-tripping, the `Repository<T>` contract (including corrupted-file handling via `StorageException`), business rules in `TaskManager` (id assignment after deletion, marking as done, error cases), sorting (by priority and by deadline), and the custom exception hierarchy.

```bash
dart test
```

Run static analysis (used in CI):

```bash
dart analyze
```

## Continuous integration

`.github/workflows/dart.yml` runs `dart pub get`, `dart analyze` and `dart test` on every push and pull request targeting `main`.

## Technical highlights

- **Abstract classes & inheritance**: `Task` is abstract. `BasicTask` extends `Task`, and `UrgentTask` extends `BasicTask` — a three-level chain (`Task -> BasicTask -> UrgentTask`) where `UrgentTask` adds a `contact` field and reuses `BasicTask`'s JSON encoding via `super.toJson()`.
- **Interface**: `Repository<T>` is declared as `abstract interface class Repository<T>` — in Dart 3, the `interface` modifier means it can only be *implemented*, not extended, from outside its library. `TaskRepository<T>` implements it.
- **Generics**: `Repository<T>` and `TaskRepository<T extends Task>`.
- **Custom exceptions**: `TaskException` and its subtypes `InvalidTaskDataException`, `TaskNotFoundException`, `StorageException`, each caught and reported distinctly by the CLI.
- **Persistence**: tasks are serialized to/from JSON and stored in `tasks.json`.
