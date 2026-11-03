import 'dart:convert';
import 'package:flutter/services.dart';
import '../../models/blocker_model.dart';
import '../../models/project_model.dart';
import '../interfaces/blocker_service_interface.dart';

class MockBlockerService implements IBlockerService {
  List<BlockerModel>? _blockers;

  Future<void> _ensureLoaded() async {
    if (_blockers != null) return;
    try {
      final jsonStr = await rootBundle.loadString('assets/mock_data/blockers.json');
      final list = jsonDecode(jsonStr) as List<dynamic>;
      _blockers = list.map((e) => BlockerModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      _blockers = [];
    }
  }

  @override
  Future<List<BlockerModel>> getBlockers() async {
    await _ensureLoaded();
    return List.unmodifiable(_blockers!);
  }

  @override
  Future<BlockerModel> reportBlocker({
    required String title,
    required String description,
    required int projectId,
    required Priority priority,
  }) async {
    await _ensureLoaded();
    final newBlocker = BlockerModel(
      id: (_blockers!.isEmpty ? 1 : _blockers!.map((b) => b.id).reduce((a, b) => a > b ? a : b) + 1),
      title: title,
      description: description,
      projectId: projectId,
      projectTitle: projectId == 101 ? 'Essane Global Portal & Mobile Redesign' : 'Internal Project',
      status: 'pending',
      priority: priority,
      createdBy: 'Sarah Jenkins',
      createdAt: DateTime.now().toIso8601String(),
      repliesCount: 0,
      latestReply: null,
    );
    _blockers!.insert(0, newBlocker);
    return newBlocker;
  }

  @override
  Future<void> resolveBlocker(int blockerId, String resolutionNote) async {
    await _ensureLoaded();
    final idx = _blockers!.indexWhere((b) => b.id == blockerId);
    if (idx != -1) {
      final old = _blockers![idx];
      _blockers![idx] = BlockerModel(
        id: old.id,
        title: old.title,
        description: old.description,
        projectId: old.projectId,
        projectTitle: old.projectTitle,
        status: 'resolved',
        priority: old.priority,
        createdBy: old.createdBy,
        createdAt: old.createdAt,
        repliesCount: old.repliesCount + 1,
        latestReply: resolutionNote,
      );
    }
  }
}

