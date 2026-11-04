import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../state/auth_state.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/app_header_back_button.dart';

class ChecklistEntry {
  String text;
  bool isChecked;

  ChecklistEntry({required this.text, this.isChecked = false});
}

class NoteItem {
  final int id;
  String title;
  String content;
  bool isPinned;
  Color color;
  bool isChecklist;
  List<ChecklistEntry> checklistItems;

  NoteItem({
    required this.id,
    required this.title,
    required this.content,
    this.isPinned = false,
    required this.color,
    this.isChecklist = false,
    this.checklistItems = const [],
  });
}

class NotesScreen extends StatefulWidget {
  final AuthState? authState;

  const NotesScreen({super.key, this.authState});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  GlobalKey<ScaffoldState>? _scaffoldKey;
  GlobalKey<ScaffoldState> get _effectiveScaffoldKey => _scaffoldKey ??= GlobalKey<ScaffoldState>();
  String _searchQuery = '';
  List<NoteItem> _notes = [];

  final List<Color> _noteColors = const [
    Color(0xFFFEF3C7), // Warm Amber
    Color(0xFFFFEDD5), // Peach
    Color(0xFFDCFCE7), // Mint
    Color(0xFFE0E7FF), // Lavender
    Color(0xFFFCE7F3), // Rose
    Color(0xFFCFFAFE), // Ice Cyan
  ];

  @override
  void initState() {
    super.initState();
    _notes = [
      NoteItem(
        id: 1,
        title: 'Sprint 42 Planning Highlights',
        content:
            'Focus on latency reduction, Apple Pay sandbox verification, and finishing the mobile dashboard dark mode redesign.',
        isPinned: true,
        color: const Color(0xFFFFEDD5),
      ),
      NoteItem(
        id: 2,
        title: 'Release Checklist v2.4',
        content: '',
        isPinned: true,
        color: const Color(0xFFDCFCE7),
        isChecklist: true,
        checklistItems: [
          ChecklistEntry(text: 'Update version bump to 2.4.1', isChecked: true),
          ChecklistEntry(text: 'Run Flutter analyze and widget tests', isChecked: true),
          ChecklistEntry(text: 'Build Ad-Hoc iOS IPA distribution', isChecked: false),
          ChecklistEntry(text: 'Verify Razorpay webhook callback on staging', isChecked: false),
        ],
      ),
      NoteItem(
        id: 3,
        title: 'Architecture Ideas: Micro-frontends',
        content:
            'Consider migrating the admin reporting widgets into standalone dynamic plugins to decrease initial bundle size.',
        isPinned: false,
        color: const Color(0xFFE0E7FF),
      ),
      NoteItem(
        id: 4,
        title: 'Team Onboarding Resources',
        content: 'Share link to GitHub wiki, Swagger backend docs, and Slack #dev-general channel.',
        isPinned: false,
        color: const Color(0xFFFEF3C7),
      ),
    ];
  }

  void _showAddNoteModal() {
    HapticFeedback.mediumImpact();
    final titleCtrl = TextEditingController();
    final contentCtrl = TextEditingController();
    bool isPinned = false;
    bool isChecklist = false;
    Color selectedColor = _noteColors[0];
    final List<ChecklistEntry> items = [];
    final itemCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        final sheetBg = isDark ? const Color(0xFF1E2024) : Colors.white;
        final textPri = isDark ? Colors.white : const Color(0xFF1E293B);

        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: sheetBg,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isChecklist ? 'New Checklist' : 'New Note',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: textPri,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  isPinned ? CupertinoIcons.pin_fill : CupertinoIcons.pin,
                                  color: isPinned ? const Color(0xFFE8590C) : Colors.grey,
                                ),
                                onPressed: () => setModalState(() => isPinned = !isPinned),
                              ),
                              IconButton(
                                icon: const Icon(CupertinoIcons.xmark_circle_fill, color: Colors.grey),
                                onPressed: () => Navigator.of(ctx).pop(),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Mode switch (Text Note vs Checklist)
                      Row(
                        children: [
                          ChoiceChip(
                            label: const Text('Text Note'),
                            selected: !isChecklist,
                            selectedColor: const Color(0xFFE8590C),
                            labelStyle: TextStyle(
                              color: !isChecklist ? Colors.white : textPri,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                            onSelected: (val) {
                              if (val) setModalState(() => isChecklist = false);
                            },
                          ),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: const Text('Checklist'),
                            selected: isChecklist,
                            selectedColor: const Color(0xFFE8590C),
                            labelStyle: TextStyle(
                              color: isChecklist ? Colors.white : textPri,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                            onSelected: (val) {
                              if (val) setModalState(() => isChecklist = true);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      TextField(
                        controller: titleCtrl,
                        decoration: InputDecoration(
                          hintText: 'Title',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 12),

                      if (!isChecklist) ...[
                        TextField(
                          controller: contentCtrl,
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText: 'Take a note...',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ] else ...[
                        // Checklist items
                        ...items.map((it) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Checkbox(
                                  value: it.isChecked,
                                  activeColor: const Color(0xFFE8590C),
                                  onChanged: (val) => setModalState(() => it.isChecked = val ?? false),
                                ),
                                Expanded(child: Text(it.text, style: TextStyle(color: textPri))),
                              ],
                            ),
                          );
                        }),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: itemCtrl,
                                decoration: const InputDecoration(
                                  hintText: '+ Add list item',
                                  border: UnderlineInputBorder(),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(CupertinoIcons.plus_circle_fill, color: Color(0xFFE8590C)),
                              onPressed: () {
                                if (itemCtrl.text.trim().isNotEmpty) {
                                  setModalState(() {
                                    items.add(ChecklistEntry(text: itemCtrl.text.trim()));
                                    itemCtrl.clear();
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 16),

                      // Color selector
                      Row(
                        children: _noteColors.map((c) {
                          final isSel = selectedColor == c;
                          return GestureDetector(
                            onTap: () => setModalState(() => selectedColor = c),
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: c,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSel ? const Color(0xFFE8590C) : Colors.black12,
                                  width: isSel ? 3 : 1,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE8590C),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            if (titleCtrl.text.trim().isEmpty && contentCtrl.text.trim().isEmpty && items.isEmpty) {
                              return;
                            }
                            setState(() {
                              _notes.insert(
                                0,
                                NoteItem(
                                  id: DateTime.now().millisecondsSinceEpoch,
                                  title: titleCtrl.text.trim().isEmpty ? 'Untitled Note' : titleCtrl.text.trim(),
                                  content: contentCtrl.text.trim(),
                                  isPinned: isPinned,
                                  color: selectedColor,
                                  isChecklist: isChecklist,
                                  checklistItems: List.from(items),
                                ),
                              );
                            });
                            Navigator.of(ctx).pop();
                          },
                          child: const Text('Save Note', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textMuted = isDark ? AppColors.darkMuted : AppColors.lightMuted;
    final accent = isDark ? AppColors.accentDark : AppColors.accentLight;

    final query = _searchQuery;
    final filtered = _notes.where((n) {
      if (query.isEmpty) return true;
      final q = query.toLowerCase();
      final inTitle = n.title.toLowerCase().contains(q);
      final inContent = n.content.toLowerCase().contains(q);
      final inChecklist = n.checklistItems.any((it) => it.text.toLowerCase().contains(q));
      return inTitle || inContent || inChecklist;
    }).toList();

    final pinnedNotes = filtered.where((n) => n.isPinned).toList();
    final otherNotes = filtered.where((n) => !n.isPinned).toList();

    return Scaffold(
      key: _effectiveScaffoldKey,
      backgroundColor: bg,
      drawer: widget.authState != null
          ? AppDrawer(
              currentItem: SidebarItemKey.essaneKeep,
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
          'Essane Keep',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: textPrimary,
            fontFamily: 'Poppins',
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: AppHeaderBackButton(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: accent,
        onPressed: _showAddNoteModal,
        child: const Icon(CupertinoIcons.plus, color: Colors.white),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          children: [
            CupertinoSearchTextField(
              placeholder: 'Search notes & checklists...',
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
            const SizedBox(height: 16),

            if (pinnedNotes.isNotEmpty) ...[
              Text(
                'PINNED',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: textMuted,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 8),
              ...pinnedNotes.map((note) => _NoteCard(
                    note: note,
                    onTogglePin: () => setState(() => note.isPinned = !note.isPinned),
                    onDelete: () => setState(() => _notes.remove(note)),
                    onItemToggled: () => setState(() {}),
                  )),
              const SizedBox(height: 16),
            ],

            if (otherNotes.isNotEmpty) ...[
              if (pinnedNotes.isNotEmpty) ...[
                Text(
                  'OTHERS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: textMuted,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 8),
              ],
              ...otherNotes.map((note) => _NoteCard(
                    note: note,
                    onTogglePin: () => setState(() => note.isPinned = !note.isPinned),
                    onDelete: () => setState(() => _notes.remove(note)),
                    onItemToggled: () => setState(() {}),
                  )),
            ],

            if (filtered.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 60),
                  child: Column(
                    children: [
                      Icon(CupertinoIcons.doc_plaintext, size: 48, color: textMuted),
                      const SizedBox(height: 12),
                      Text('No notes found', style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  final NoteItem note;
  final VoidCallback onTogglePin;
  final VoidCallback onDelete;
  final VoidCallback onItemToggled;

  const _NoteCard({
    required this.note,
    required this.onTogglePin,
    required this.onDelete,
    required this.onItemToggled,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: note.color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  note.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
              GestureDetector(
                onTap: onTogglePin,
                child: Icon(
                  note.isPinned ? CupertinoIcons.pin_fill : CupertinoIcons.pin,
                  size: 18,
                  color: note.isPinned ? const Color(0xFFE8590C) : Colors.black45,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onDelete,
                child: const Icon(CupertinoIcons.trash, size: 16, color: Colors.black45),
              ),
            ],
          ),
          if (note.content.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              note.content,
              style: const TextStyle(fontSize: 13, color: Color(0xFF334155), height: 1.4),
            ),
          ],
          if (note.isChecklist && note.checklistItems.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...note.checklistItems.map((item) {
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  item.isChecked = !item.isChecked;
                  onItemToggled();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      Icon(
                        item.isChecked ? CupertinoIcons.check_mark_circled_solid : CupertinoIcons.circle,
                        size: 16,
                        color: item.isChecked ? const Color(0xFFE8590C) : Colors.black54,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item.text,
                          style: TextStyle(
                            fontSize: 13,
                            color: item.isChecked ? Colors.black38 : const Color(0xFF1E293B),
                            decoration: item.isChecked ? TextDecoration.lineThrough : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}

