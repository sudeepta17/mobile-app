import '../../models/blocker_model.dart';
import '../../models/project_model.dart';

abstract class IBlockerService {
  Future<List<BlockerModel>> getBlockers();
  Future<BlockerModel> reportBlocker({
    required String title,
    required String description,
    required int projectId,
    required Priority priority,
  });
  Future<void> resolveBlocker(int blockerId, String resolutionNote);
}

