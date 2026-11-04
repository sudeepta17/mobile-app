import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../state/auth_state.dart';
import '../../widgets/app_drawer.dart';

class CertificateRecord {
  final int id;
  final String title;
  final String recipientName;
  final String designation;
  final DateTime startDate;
  final DateTime endDate;
  final String performanceNote;
  final String certificateNumber;

  const CertificateRecord({
    required this.id,
    required this.title,
    required this.recipientName,
    required this.designation,
    required this.startDate,
    required this.endDate,
    required this.performanceNote,
    required this.certificateNumber,
  });
}

class EmployeeCertificatesScreen extends StatefulWidget {
  final AuthState? authState;

  const EmployeeCertificatesScreen({super.key, this.authState});

  @override
  State<EmployeeCertificatesScreen> createState() => _EmployeeCertificatesScreenState();
}

class _EmployeeCertificatesScreenState extends State<EmployeeCertificatesScreen> {
  GlobalKey<ScaffoldState>? _scaffoldKey;
  GlobalKey<ScaffoldState> get _effectiveScaffoldKey => _scaffoldKey ??= GlobalKey<ScaffoldState>();
  String _searchQuery = '';
  List<CertificateRecord> _certificates = [];

  @override
  void initState() {
    super.initState();
    final name = widget.authState?.currentUser?.name ?? 'Sarah Jenkins';
    _certificates = [
      CertificateRecord(
        id: 1,
        title: 'Internship & Professional Training Certificate',
        recipientName: name,
        designation: 'Associate Full-Stack Developer',
        startDate: DateTime(2025, 6, 1),
        endDate: DateTime(2025, 12, 1),
        performanceNote:
            'Exemplary performance, outstanding dedication, and significant technical contributions to our cloud microservices platform.',
        certificateNumber: 'ESS-CERT-2025-0891',
      ),
      CertificateRecord(
        id: 2,
        title: 'Engineering Excellence & Core Innovation Award',
        recipientName: name,
        designation: 'Software Development Engineer',
        startDate: DateTime(2026, 1, 1),
        endDate: DateTime(2026, 6, 30),
        performanceNote:
            'Commended for architecture optimization of payment gateway latency reduction by 42%.',
        certificateNumber: 'ESS-AWD-2026-0142',
      ),
    ];
  }

  void _viewCertificateModal(CertificateRecord cert) {
    HapticFeedback.selectionClick();
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: const Color(0xFFFFFBF5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Gold Border Framing
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFD4AF37), width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Header Emblem
                      const Icon(CupertinoIcons.rosette, size: 48, color: Color(0xFFD4AF37)),
                      const SizedBox(height: 8),
                      const Text(
                        'ESSANE GLOBAL',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 3,
                          color: Color(0xFF1E293B),
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'CERTIFICATE OF ACCOMPLISHMENT',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.5,
                          color: Color(0xFFB45309),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text('This is to certify that', style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey)),
                      const SizedBox(height: 6),
                      Text(
                        cert.recipientName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E293B),
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        cert.designation,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFFE8590C)),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'has successfully completed the tenure for ${cert.title} from ${DateFormat("MMMM yyyy").format(cert.startDate)} to ${DateFormat("MMMM yyyy").format(cert.endDate)} with ${cert.performanceNote}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 11, color: Color(0xFF475569), height: 1.4),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(DateFormat('dd MMMM yyyy').format(cert.endDate), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                              const Text('Date Issued', style: TextStyle(fontSize: 9, color: Colors.grey)),
                            ],
                          ),
                          Column(
                            children: const [
                              Text(
                                'A. Essane',
                                style: TextStyle(
                                  fontFamily: 'Caveat',
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              Text('Authorized Signatory', style: TextStyle(fontSize: 9, color: Colors.grey)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('Close'),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE8590C),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(CupertinoIcons.arrow_down_to_line, color: Colors.white, size: 16),
                      label: const Text('Download PDF', style: TextStyle(color: Colors.white)),
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Certificate downloaded: ${cert.certificateNumber}.pdf')),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final cardBg = isDark ? AppColors.darkCard : AppColors.lightCard;
    final borderCol = isDark ? AppColors.darkLine : AppColors.lightLine;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textMuted = isDark ? AppColors.darkMuted : AppColors.lightMuted;
    final accent = isDark ? AppColors.accentDark : AppColors.accentLight;

    final query = _searchQuery;
    final filtered = _certificates.where((c) {
      if (query.isEmpty) return true;
      final q = query.toLowerCase();
      return c.title.toLowerCase().contains(q) || c.performanceNote.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      key: _effectiveScaffoldKey,
      backgroundColor: bg,
      drawer: widget.authState != null
          ? AppDrawer(
              currentItem: SidebarItemKey.myCertificates,
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
          'My Certificates',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: textPrimary,
            fontFamily: 'Poppins',
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: CupertinoSearchTextField(
                placeholder: 'Search certificates by title or achievement...',
                onChanged: (val) => setState(() => _searchQuery = val),
              ),
            ),
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(CupertinoIcons.rosette, size: 48, color: textMuted),
                          const SizedBox(height: 12),
                          Text('No certificates found', style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      itemCount: filtered.length,
                      itemBuilder: (ctx, idx) {
                        final cert = filtered[idx];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: borderCol),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 46,
                                    height: 46,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    alignment: Alignment.center,
                                    child: const Icon(CupertinoIcons.rosette, color: Color(0xFFD4AF37), size: 26),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          cert.title,
                                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: textPrimary, fontFamily: 'Poppins'),
                                        ),
                                        Text(
                                          cert.certificateNumber,
                                          style: const TextStyle(fontSize: 11, color: Color(0xFFE8590C), fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Icon(CupertinoIcons.calendar, size: 14, color: textMuted),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${DateFormat('MMM yyyy').format(cert.startDate)} – ${DateFormat('MMM yyyy').format(cert.endDate)}',
                                    style: TextStyle(fontSize: 12, color: textMuted),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                cert.performanceNote,
                                style: TextStyle(fontSize: 12, color: textPrimary, height: 1.4),
                              ),
                              const SizedBox(height: 14),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: accent,
                                      side: BorderSide(color: accent),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                    icon: const Icon(CupertinoIcons.eye, size: 16),
                                    label: const Text('View & Download'),
                                    onPressed: () => _viewCertificateModal(cert),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

