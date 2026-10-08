enum TaskStatus { todo, inProgress, done }

class TaskModel {
  final String id;
  final String title;
  final List<String> categories;
  final List<String> urls;
  final bool openVSCode;
  TaskStatus status;

  TaskModel({
    required this.id,
    required this.title,
    List<String>? categories,
    String? category,
    List<String>? urls,
    String? url,
    required this.openVSCode,
    this.status = TaskStatus.todo,
  })  : categories = categories ?? (category != null && category.isNotEmpty ? [category] : []),
        urls = urls ?? (url != null && url.isNotEmpty ? [url] : []);

  // Backward compatibility getters
  String get category => categories.isNotEmpty ? categories.first : 'General';
  String get url => urls.isNotEmpty ? urls.first : '';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'categories': categories,
      'category': category,
      'urls': urls,
      'url': url,
      'open_vscode': openVSCode,
      'status': status.name,
    };
  }
}
