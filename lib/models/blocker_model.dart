import 'project_model.dart';

class BlockerModel {
  final int id;
  final String title;
  final String description;
  final int projectId;
  final String projectTitle;
  final String status; // pending, in_review, resolved
  final Priority priority;
  final String createdBy;
  final String createdAt;
  final int repliesCount;
  final String? latestReply;

  const BlockerModel({
    required this.id,
    required this.title,
    required this.description,
    required this.projectId,
    required this.projectTitle,
    required this.status,
    required this.priority,
    required this.createdBy,
    required this.createdAt,
    required this.repliesCount,
    this.latestReply,
  });

  factory BlockerModel.fromJson(Map<String, dynamic> json) {
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

    return BlockerModel(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      projectId: (json['project_id'] as num?)?.toInt() ?? 0,
      projectTitle: json['project_title'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      priority: parsePriority(json['priority'] as String?),
      createdBy: json['created_by'] as String? ?? '',
      createdAt: json['created_at'] as String? ?? '',
      repliesCount: (json['replies_count'] as num?)?.toInt() ?? 0,
      latestReply: json['latest_reply'] as String?,
    );
  }
}

