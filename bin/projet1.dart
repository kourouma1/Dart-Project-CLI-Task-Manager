import 'dart:io';

import 'package:projet1/projet1.dart';

void main(List<String> arguments) {
  final storageFile = File('tasks.json');
  final manager = TaskManager(storageFile: storageFile);

  print('=== CLI Task Manager ===');
  print('Fichier de données : ${storageFile.absolute.path}');

  var running = true;
  while (running) {
    _printMenu();
    final choice = stdin.readLineSync()?.trim();

    try {
      switch (choice) {
        case '1':
          _addTask(manager);
          break;
        case '2':
          _listTasks(manager);
          break;
        case '3':
          _markTaskDone(manager);
          break;
        case '4':
          _deleteTask(manager);
          break;
        case '5':
          running = false;
          print('Au revoir !');
          break;
        default:
          print('Choix invalide, veuillez réessayer.\n');
      }
    } on TaskException catch (error) {
      print('Erreur : ${error.message}\n');
    }
  }
}

void _printMenu() {
  print('''
--------------------------------
1. Ajouter une tâche
2. Lister les tâches
3. Marquer une tâche comme terminée
4. Supprimer une tâche
5. Quitter
--------------------------------
Votre choix :''');
}

void _addTask(TaskManager manager) {
  stdout.write('Titre de la tâche : ');
  final title = stdin.readLineSync()?.trim() ?? '';

  stdout.write('Priorité (low/medium/high) : ');
  final priorityInput = stdin.readLineSync()?.trim() ?? '';
  final priority = Task.parsePriority(priorityInput);

  stdout.write('Date limite (AAAA-MM-JJ, laisser vide si aucune) : ');
  final deadlineInput = stdin.readLineSync()?.trim() ?? '';
  DateTime? deadline;
  if (deadlineInput.isNotEmpty) {
    try {
      deadline = DateTime.parse(deadlineInput);
    } on FormatException {
      throw InvalidTaskDataException('Date invalide : "$deadlineInput".');
    }
  }

  stdout.write('Tâche urgente ? (o/n) : ');
  final isUrgent = (stdin.readLineSync()?.trim().toLowerCase() ?? 'n') == 'o';

  var contact = 'n/a';
  if (isUrgent) {
    stdout.write('Contact à prévenir : ');
    contact = stdin.readLineSync()?.trim() ?? 'n/a';
  }

  final task = manager.addTask(
    title,
    priority,
    deadline: deadline,
    isUrgent: isUrgent,
    contact: contact,
  );

  print('Tâche créée avec succès : ${_formatTask(task)}\n');
}

void _listTasks(TaskManager manager) {
  stdout.write('Trier par (1=aucun, 2=priorité, 3=date limite) : ');
  final sortChoice = stdin.readLineSync()?.trim();
  final sortBy = switch (sortChoice) {
    '2' => TaskSort.priority,
    '3' => TaskSort.deadline,
    _ => TaskSort.none,
  };

  final tasks = manager.listTasks(sortBy: sortBy);
  if (tasks.isEmpty) {
    print('Aucune tâche enregistrée.\n');
    return;
  }

  print('');
  for (final task in tasks) {
    print(_formatTask(task));
  }
  print('');
}

void _markTaskDone(TaskManager manager) {
  stdout.write('Identifiant de la tâche à marquer comme terminée : ');
  final id = stdin.readLineSync()?.trim() ?? '';
  manager.markTaskAsDone(id);
  print('Tâche "$id" marquée comme terminée.\n');
}

void _deleteTask(TaskManager manager) {
  stdout.write('Identifiant de la tâche à supprimer : ');
  final id = stdin.readLineSync()?.trim() ?? '';
  manager.deleteTask(id);
  print('Tâche "$id" supprimée.\n');
}

String _formatTask(Task task) {
  final status = task.isDone ? '[x]' : '[ ]';
  final deadline = task.deadline == null
      ? 'sans échéance'
      : task.deadline!.toIso8601String().split('T').first;
  final urgentTag = task is UrgentTask ? ' (URGENT - contact: ${task.contact})' : '';
  return '$status ${task.id} | ${task.title} | priorité: ${task.priority.name} | échéance: $deadline$urgentTag';
}
