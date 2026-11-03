enum TaskStatus { todo, inProgress, review, completed }
enum Priority { low, medium, high, critical }

class ProjectTask {
  final int id;
  final String title;
  final String description;
  final TaskStatus status;
  final Priority priority;
  final String dueDate;
  final String assignee;

  const ProjectTask({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.dueDate,
    required this.assignee,
  });

  factory ProjectTask.fromJson(Map<String, dynamic> json) {
    TaskStatus parseStatus(String? val) {
      switch (val) {
        case 'in_progress':
          return TaskStatus.inProgress;
        case 'review':
          return TaskStatus.review;
        case 'completed':
          return TaskStatus.completed;
        case 'todo':
        default:
          return TaskStatus.todo;
      }
    }

    Priority parsePriority(String? val) {
      switch (val) {
        case 'critical':
          return Priority.critical;
        case 'high':
          return Priority.high;
        case 'medium':
          return Priority.medium;
        case 'low':
        default:
          return Priority.low;
      }
    }

    return ProjectTask(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      status: parseStatus(json['status'] as String?),
      priority: parsePriority(json['priority'] as String?),
      dueDate: json['due_date'] as String? ?? '',
      assignee: json['assignee'] as String? ?? 'Unassigned',
    );
  }
}

class ProjectModel {
  final int id;
  final String title;
  final String code;
  final String description;
  final String status;
  final Priority priority;
  final int progress;
  final String startDate;
  final String dueDate;
  final String client;
  final String leadName;
  final int teamCount;
  final int tasksTotal;
  final int tasksCompleted;
  final List<String> tags;
  final List<ProjectTask> tasks;

  const ProjectModel({
    required this.id,
    required this.title,
    required this.code,
    required this.description,
    required this.status,
    required this.priority,
    required this.progress,
    required this.startDate,
    required this.dueDate,
    required this.client,
    required this.leadName,
    required this.teamCount,
    required this.tasksTotal,
    required this.tasksCompleted,
    required this.tags,
    required this.tasks,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    Priority parsePriority(String? val) {
      switch (val) {
        case 'critical':
          return Priority.critical;
        case 'high':
          return Priority.high;
        case 'medium':
          return Priority.medium;
        default:
          return Priority.low;
      }
    }

    final rawTasks = json['tasks'] as List<dynamic>? ?? [];
    final rawTags = json['tags'] as List<dynamic>? ?? [];

    return ProjectModel(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      code: json['code'] as String? ?? '',
      description: json['description'] as String? ?? '',
      status: json['status'] as String? ?? 'in_progress',
      priority: parsePriority(json['priority'] as String?),
      progress: (json['progress'] as num?)?.toInt() ?? 0,
      startDate: json['start_date'] as String? ?? '',
      dueDate: json['due_date'] as String? ?? '',
      client: json['client'] as String? ?? '',
      leadName: json['lead_name'] as String? ?? '',
      teamCount: (json['team_count'] as num?)?.toInt() ?? 0,
      tasksTotal: (json['tasks_total'] as num?)?.toInt() ?? 0,
      tasksCompleted: (json['tasks_completed'] as num?)?.toInt() ?? 0,
      tags: rawTags.map((e) => e.toString()).toList(),
      tasks: rawTasks.map((e) => ProjectTask.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}

