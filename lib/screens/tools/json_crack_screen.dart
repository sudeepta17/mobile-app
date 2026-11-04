import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../state/auth_state.dart';
import '../../widgets/app_drawer.dart';

class JsonCrackScreen extends StatefulWidget {
  final AuthState? authState;

  const JsonCrackScreen({super.key, this.authState});

  @override
  State<JsonCrackScreen> createState() => _JsonCrackScreenState();
}

class _JsonCrackScreenState extends State<JsonCrackScreen> with SingleTickerProviderStateMixin {
  GlobalKey<ScaffoldState>? _scaffoldKey;
  GlobalKey<ScaffoldState> get _effectiveScaffoldKey => _scaffoldKey ??= GlobalKey<ScaffoldState>();
  late TabController _tabController;
  final TextEditingController _jsonController = TextEditingController();

  dynamic _parsedJson;
  String? _parseError;

  final String _defaultJson = '''{
  "project": "Essane Global Platform",
  "version": "2.4.1",
  "status": "production",
  "active_users": 1420,
  "config": {
    "dark_mode": true,
    "api_timeout_ms": 5000,
    "features": [
      "realtime_chat",
      "whiteboard",
      "blockers_engine",
      "payroll_pipeline"
    ]
  },
  "modules": [
    {
      "id": 1,
      "name": "Employee Workspace",
      "healthy": true
    },
    {
      "id": 2,
      "name": "Admin Control Room",
      "healthy": true
    }
  ]
}''';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _jsonController.text = _defaultJson;
    _parseAndValidate();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _jsonController.dispose();
    super.dispose();
  }

  void _parseAndValidate() {
    try {
      final decoded = jsonDecode(_jsonController.text);
      setState(() {
        _parsedJson = decoded;
        _parseError = null;
      });
    } catch (e) {
      setState(() {
        _parsedJson = null;
        _parseError = e.toString();
      });
    }
  }

  void _formatJson() {
    HapticFeedback.selectionClick();
    try {
      final decoded = jsonDecode(_jsonController.text);
      const encoder = JsonEncoder.withIndent('  ');
      final pretty = encoder.convert(decoded);
      setState(() {
        _jsonController.text = pretty;
        _parsedJson = decoded;
        _parseError = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('JSON formatted cleanly')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cannot format invalid JSON: ${e.toString()}')),
      );
    }
  }

  void _copyJson() {
    HapticFeedback.selectionClick();
    Clipboard.setData(ClipboardData(text: _jsonController.text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('JSON copied to clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final cardBg = isDark ? AppColors.darkCard : AppColors.lightCard;
    final borderCol = isDark ? AppColors.darkLine : AppColors.lightLine;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final accent = isDark ? AppColors.accentDark : AppColors.accentLight;

    return Scaffold(
      key: _effectiveScaffoldKey,
      backgroundColor: bg,
      drawer: widget.authState != null
          ? AppDrawer(
              currentItem: SidebarItemKey.essaneJsonCrack,
              authState: widget.authState!,
            )
          : null,
      appBar: AppBar(
        leading: widget.authState != null
            ? IconButton(
                icon: const Icon(CupertinoIcons.bars),
                onPressed: () => _effectiveScaffoldKey.currentState?.openDrawer(),
              )
            : null,
        title: Text(
          'Essane JSON Crack',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: textPrimary,
            fontFamily: 'Poppins',
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.wand_stars),
            tooltip: 'Format / Beautify',
            onPressed: _formatJson,
          ),
          IconButton(
            icon: const Icon(CupertinoIcons.doc_on_clipboard),
            tooltip: 'Copy',
            onPressed: _copyJson,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: accent,
          unselectedLabelColor: Colors.grey,
          indicatorColor: accent,
          tabs: const [
            Tab(icon: Icon(CupertinoIcons.chevron_left_slash_chevron_right), text: 'JSON Editor'),
            Tab(icon: Icon(CupertinoIcons.graph_square), text: 'Tree Visualizer'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: JSON Editor
          Column(
            children: [
              if (_parseError != null)
                Container(
                  width: double.infinity,
                  color: Colors.red.withValues(alpha: 0.12),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      const Icon(CupertinoIcons.exclamationmark_triangle_fill, color: Colors.red, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _parseError!,
                          style: const TextStyle(fontSize: 11, color: Colors.red, fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF131518) : const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: borderCol),
                    ),
                    padding: const EdgeInsets.all(14),
                    child: TextField(
                      controller: _jsonController,
                      maxLines: null,
                      expands: true,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 13,
                        color: Color(0xFFF8FAFC),
                        height: 1.4,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Paste or type JSON here...',
                        hintStyle: TextStyle(color: Colors.white30),
                      ),
                      onChanged: (val) => _parseAndValidate(),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Tab 2: Tree Visualizer
          _parsedJson == null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(CupertinoIcons.exclamationmark_triangle, size: 48, color: Colors.amber),
                      const SizedBox(height: 12),
                      const Text(
                        'Invalid JSON',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Fix syntax errors in the editor tab to view graph.',
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderCol),
                      ),
                      child: _buildJsonNode(keyName: 'ROOT', value: _parsedJson),
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildJsonNode({required String keyName, required dynamic value}) {
    if (value is Map) {
      return ExpansionTile(
        initiallyExpanded: true,
        tilePadding: EdgeInsets.zero,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFE8590C).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                keyName,
                style: const TextStyle(
                  color: Color(0xFFE8590C),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  fontFamily: 'monospace',
                ),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '{${value.length} keys}',
              style: const TextStyle(color: Colors.grey, fontSize: 11),
            ),
          ],
        ),
        children: value.entries.map((e) {
          return Padding(
            padding: const EdgeInsets.only(left: 16),
            child: _buildJsonNode(keyName: e.key.toString(), value: e.value),
          );
        }).toList(),
      );
    } else if (value is List) {
      return ExpansionTile(
        initiallyExpanded: true,
        tilePadding: EdgeInsets.zero,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                keyName,
                style: const TextStyle(
                  color: Color(0xFF3B82F6),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  fontFamily: 'monospace',
                ),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '[${value.length} items]',
              style: const TextStyle(color: Colors.grey, fontSize: 11),
            ),
          ],
        ),
        children: value.asMap().entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(left: 16),
            child: _buildJsonNode(keyName: '[${entry.key}]', value: entry.value),
          );
        }).toList(),
      );
    } else {
      Color valColor = Colors.green;
      if (value is num) valColor = Colors.blue;
      if (value is bool) valColor = Colors.purple;
      if (value == null) valColor = Colors.grey;

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$keyName: ',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                fontFamily: 'monospace',
              ),
            ),
            Expanded(
              child: Text(
                value == null ? 'null' : (value is String ? '"$value"' : value.toString()),
                style: TextStyle(
                  color: valColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}

