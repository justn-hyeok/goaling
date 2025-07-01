class Goal {
  final String id;
  final String title;
  final String description;
  final DateTime deadline;
  final List<SubTask> subTasks;
  final String category;
  final int priority;
  final double progress;
  final List<String> evidencePhotoPaths;
  final List<String> documentPaths;

  Goal({
    required this.id,
    required this.title,
    required this.description,
    required this.deadline,
    this.subTasks = const [],
    required this.category,
    required this.priority,
    this.progress = 0.0,
    this.evidencePhotoPaths = const [],
    this.documentPaths = const [],
  });

  Goal copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? deadline,
    List<SubTask>? subTasks,
    String? category,
    int? priority,
    double? progress,
    List<String>? evidencePhotoPaths,
    List<String>? documentPaths,
  }) {
    return Goal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      deadline: deadline ?? this.deadline,
      subTasks: subTasks ?? this.subTasks,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      progress: progress ?? this.progress,
      evidencePhotoPaths: evidencePhotoPaths ?? this.evidencePhotoPaths,
      documentPaths: documentPaths ?? this.documentPaths,
    );
  }
}

class SubTask {
  final String id;
  final String title;
  final bool isCompleted;

  SubTask({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });

  SubTask copyWith({
    String? id,
    String? title,
    bool? isCompleted,
  }) {
    return SubTask(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
