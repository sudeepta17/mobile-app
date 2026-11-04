import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../state/auth_state.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/app_header_back_button.dart';

enum WhiteboardTool { pen, eraser, line, rectangle }

class WhiteboardStroke {
  final List<Offset> points;
  final Color color;
  final double strokeWidth;
  final WhiteboardTool tool;

  WhiteboardStroke({
    required this.points,
    required this.color,
    required this.strokeWidth,
    required this.tool,
  });
}

class WhiteboardScreen extends StatefulWidget {
  final AuthState? authState;

  const WhiteboardScreen({super.key, this.authState});

  @override
  State<WhiteboardScreen> createState() => _WhiteboardScreenState();
}

class _WhiteboardScreenState extends State<WhiteboardScreen> {
  GlobalKey<ScaffoldState>? _scaffoldKey;
  GlobalKey<ScaffoldState> get _effectiveScaffoldKey => _scaffoldKey ??= GlobalKey<ScaffoldState>();

  final List<WhiteboardStroke> _strokes = [];
  final List<WhiteboardStroke> _undoneStrokes = [];
  List<Offset> _currentPoints = [];

  WhiteboardTool _selectedTool = WhiteboardTool.pen;
  Color _selectedColor = const Color(0xFFE8590C);
  double _strokeWidth = 4.0;

  final List<Color> _colors = const [
    Color(0xFFE8590C), // Essane Orange
    Color(0xFF0F172A), // Dark Slate
    Color(0xFF3B82F6), // Blue
    Color(0xFF10B981), // Green
    Color(0xFFEF4444), // Red
    Color(0xFF8B5CF6), // Purple
  ];

  void _undo() {
    if (_strokes.isNotEmpty) {
      HapticFeedback.selectionClick();
      setState(() {
        _undoneStrokes.add(_strokes.removeLast());
      });
    }
  }

  void _redo() {
    if (_undoneStrokes.isNotEmpty) {
      HapticFeedback.selectionClick();
      setState(() {
        _strokes.add(_undoneStrokes.removeLast());
      });
    }
  }

  void _clearCanvas() {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Whiteboard?'),
        content: const Text('Are you sure you want to erase all drawings from the canvas?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              setState(() {
                _strokes.clear();
                _undoneStrokes.clear();
              });
              Navigator.of(ctx).pop();
            },
            child: const Text('Clear All', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final canvasBg = isDark ? const Color(0xFF181A1D) : Colors.white;
    final borderCol = isDark ? AppColors.darkLine : AppColors.lightLine;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    return Scaffold(
      key: _effectiveScaffoldKey,
      backgroundColor: bg,
      drawer: widget.authState != null
          ? AppDrawer(
              currentItem: SidebarItemKey.essanecalidraw,
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
          'Essanecalidraw',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: textPrimary,
            fontFamily: 'Poppins',
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.arrow_counterclockwise),
            onPressed: _strokes.isNotEmpty ? _undo : null,
          ),
          IconButton(
            icon: const Icon(CupertinoIcons.arrow_clockwise),
            onPressed: _undoneStrokes.isNotEmpty ? _redo : null,
          ),
          IconButton(
            icon: const Icon(CupertinoIcons.trash),
            onPressed: _clearCanvas,
          ),
          const Padding(
            padding: EdgeInsets.only(right: 12),
            child: AppHeaderBackButton(),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Toolbar (Tools, Colors, Stroke Width)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF202327) : const Color(0xFFF1F5F9),
                border: Border(bottom: BorderSide(color: borderCol)),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    // Tool buttons
                    _ToolButton(
                      icon: CupertinoIcons.pencil,
                      label: 'Pen',
                      isSelected: _selectedTool == WhiteboardTool.pen,
                      onTap: () => setState(() => _selectedTool = WhiteboardTool.pen),
                    ),
                    const SizedBox(width: 6),
                    _ToolButton(
                      icon: CupertinoIcons.sparkles,
                      label: 'Eraser',
                      isSelected: _selectedTool == WhiteboardTool.eraser,
                      onTap: () => setState(() => _selectedTool = WhiteboardTool.eraser),
                    ),
                    const SizedBox(width: 6),
                    _ToolButton(
                      icon: CupertinoIcons.slash_circle,
                      label: 'Line',
                      isSelected: _selectedTool == WhiteboardTool.line,
                      onTap: () => setState(() => _selectedTool = WhiteboardTool.line),
                    ),
                    const SizedBox(width: 6),
                    _ToolButton(
                      icon: CupertinoIcons.square,
                      label: 'Rect',
                      isSelected: _selectedTool == WhiteboardTool.rectangle,
                      onTap: () => setState(() => _selectedTool = WhiteboardTool.rectangle),
                    ),
                    const SizedBox(width: 14),

                    // Color Palette
                    if (_selectedTool != WhiteboardTool.eraser) ...[
                      ..._colors.map((c) {
                        final isSel = _selectedColor == c;
                        return GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _selectedColor = c);
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: c,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSel ? Colors.white : Colors.transparent,
                                width: 2.5,
                              ),
                              boxShadow: isSel
                                  ? [BoxShadow(color: c.withValues(alpha: 0.6), blurRadius: 6)]
                                  : null,
                            ),
                          ),
                        );
                      }),
                      const SizedBox(width: 14),
                    ],

                    // Stroke width choices
                    ...[2.0, 4.0, 8.0, 14.0].map((w) {
                      final isSel = _strokeWidth == w;
                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _strokeWidth = w);
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isSel ? const Color(0xFFE8590C) : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${w.toInt()}px',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isSel ? Colors.white : textPrimary,
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),

            // Canvas Workspace
            Expanded(
              child: Container(
                color: canvasBg,
                child: GestureDetector(
                  onPanStart: (details) {
                    setState(() {
                      _currentPoints = [details.localPosition];
                    });
                  },
                  onPanUpdate: (details) {
                    setState(() {
                      _currentPoints.add(details.localPosition);
                    });
                  },
                  onPanEnd: (details) {
                    setState(() {
                      _strokes.add(
                        WhiteboardStroke(
                          points: List.from(_currentPoints),
                          color: _selectedTool == WhiteboardTool.eraser ? canvasBg : _selectedColor,
                          strokeWidth: _selectedTool == WhiteboardTool.eraser ? 24.0 : _strokeWidth,
                          tool: _selectedTool,
                        ),
                      );
                      _currentPoints = [];
                      _undoneStrokes.clear();
                    });
                  },
                  child: CustomPaint(
                    painter: _WhiteboardPainter(
                      strokes: _strokes,
                      currentPoints: _currentPoints,
                      currentColor: _selectedTool == WhiteboardTool.eraser ? canvasBg : _selectedColor,
                      currentWidth: _selectedTool == WhiteboardTool.eraser ? 24.0 : _strokeWidth,
                      currentTool: _selectedTool,
                    ),
                    size: Size.infinite,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ToolButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8590C) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: isSelected ? Colors.white : Colors.grey),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WhiteboardPainter extends CustomPainter {
  final List<WhiteboardStroke> strokes;
  final List<Offset> currentPoints;
  final Color currentColor;
  final double currentWidth;
  final WhiteboardTool currentTool;

  _WhiteboardPainter({
    required this.strokes,
    required this.currentPoints,
    required this.currentColor,
    required this.currentWidth,
    required this.currentTool,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final s in strokes) {
      _paintStroke(canvas, s.points, s.color, s.strokeWidth, s.tool);
    }
    if (currentPoints.isNotEmpty) {
      _paintStroke(canvas, currentPoints, currentColor, currentWidth, currentTool);
    }
  }

  void _paintStroke(Canvas canvas, List<Offset> points, Color color, double width, WhiteboardTool tool) {
    if (points.isEmpty) return;
    final paint = Paint()
      ..color = color
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = (tool == WhiteboardTool.rectangle) ? PaintingStyle.stroke : PaintingStyle.stroke;

    if (tool == WhiteboardTool.line && points.length >= 2) {
      canvas.drawLine(points.first, points.last, paint);
    } else if (tool == WhiteboardTool.rectangle && points.length >= 2) {
      final rect = Rect.fromPoints(points.first, points.last);
      canvas.drawRect(rect, paint);
    } else {
      final path = Path();
      path.moveTo(points[0].dx, points[0].dy);
      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _WhiteboardPainter oldDelegate) => true;
}

