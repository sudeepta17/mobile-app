import 'dart:convert';
import 'package:flutter/services.dart';
import '../../models/project_model.dart';
import '../interfaces/project_service_interface.dart';

class MockProjectService implements IProjectService {
  List<ProjectModel>? _projects;

  Future<void> _ensureLoaded() async {
    if (_projects != null) return;
    try {
      final jsonStr = await rootBundle.loadString('assets/mock_data/projects.json');
      final list = jsonDecode(jsonStr) as List<dynamic>;
      _projects = list.map((e) => ProjectModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      _projects = [];
    }
  }

  @override
  Future<List<ProjectModel>> getProjects() async {
    await _ensureLoaded();
    return List.unmodifiable(_projects!);
  }

  @override
  Future<ProjectModel> getProjectById(int id) async {
    await _ensureLoaded();
    return _projects!.firstWhere((p) => p.id == id, orElse: () => _projects!.first);
  }

  @override
  Future<List<ProjectTask>> getMyTasks() async {
    await _ensureLoaded();
    final List<ProjectTask> allTasks = [];
    for (final p in _projects!) {
      allTasks.addAll(p.tasks);
    }
    return allTasks;
  }

  @override
  Future<ProjectTask> toggleTaskStatus(int taskId) async {
    await _ensureLoaded();
    for (int pIdx = 0; pIdx < _projects!.length; pIdx++) {
      final project = _projects![pIdx];
      final taskIdx = project.tasks.indexWhere((t) => t.id == taskId);
      if (taskIdx != -1) {
        final current = project.tasks[taskIdx];
        final nextStatus = current.status == TaskStatus.completed
            ? TaskStatus.todo
            : TaskStatus.completed;

        final updatedTask = ProjectTask(
          id: current.id,
          title: current.title,
          description: current.description,
          status: nextStatus,
          priority: current.priority,
          dueDate: current.dueDate,
          assignee: current.assignee,
        );

        final updatedTasksList = List<ProjectTask>.from(project.tasks);
        updatedTasksList[taskIdx] = updatedTask;

        final completedCount = updatedTasksList.where((t) => t.status == TaskStatus.completed).length;
        final newProgress = updatedTasksList.isEmpty
            ? 0
            : ((completedCount / updatedTasksList.length) * 100).round();

        _projects![pIdx] = ProjectModel(
          id: project.id,
          title: project.title,
          code: project.code,
          description: project.description,
          status: project.status,
          priority: project.priority,
          progress: newProgress,
          startDate: project.startDate,
          dueDate: project.dueDate,
          client: project.client,
          leadName: project.leadName,
          teamCount: project.teamCount,
          tasksTotal: updatedTasksList.length,
          tasksCompleted: completedCount,
          tags: project.tags,
          tasks: updatedTasksList,
        );

        return updatedTask;
      }
    }
    throw Exception('Task not found: $taskId');
  }
}

