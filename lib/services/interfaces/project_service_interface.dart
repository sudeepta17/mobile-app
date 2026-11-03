import '../../models/project_model.dart';

abstract class IProjectService {
  Future<List<ProjectModel>> getProjects();
  Future<ProjectModel> getProjectById(int id);
  Future<List<ProjectTask>> getMyTasks();
  Future<ProjectTask> toggleTaskStatus(int taskId);
}

