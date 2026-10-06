enum TaskStatus { todo, inProgress, done }

class TaskModel {
  final String id;
  final String title;
  final String category;
  final String url;
  final bool openVSCode;
  TaskStatus status;

  TaskModel({
    required this.id,
    required this.title,
    required this.category,
    required this.url,
    required this.openVSCode,
    this.status = TaskStatus.todo,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'url': url,
      'open_vscode': openVSCode,
      'status': status.name,
    };
  }
}
