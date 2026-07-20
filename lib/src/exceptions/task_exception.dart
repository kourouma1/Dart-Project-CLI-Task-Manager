class TaskException implements Exception {
  TaskException(this.message);

  final String message;

  @override
  String toString() => 'TaskException: $message';
}

class InvalidTaskDataException extends TaskException {
  InvalidTaskDataException(super.message);
}

class TaskNotFoundException extends TaskException {
  TaskNotFoundException(String id) : super('Task with id "$id" was not found.');
}

class StorageException extends TaskException {
  StorageException(super.message);
}
