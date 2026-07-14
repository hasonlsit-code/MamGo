import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mamgo/core/constants/app_theme.dart';
import 'package:mamgo/data/datasources/meal_analysis_service.dart';
import 'package:mamgo/data/datasources/meal_log_service.dart';
import 'package:mamgo/data/models/meal_analysis.dart';
import 'package:mamgo/data/models/meal_log_entry.dart';
import 'package:mamgo/presentation/pages/meal_diary_screen.dart';
import 'package:mamgo/presentation/widgets/animated_mascot.dart';

/// Màn "Gợi ý": chụp ảnh bữa ăn để AI ước tính calo và dinh dưỡng.
class MealAnalysisScreen extends StatefulWidget {
  const MealAnalysisScreen({super.key});

  @override
  State<MealAnalysisScreen> createState() => _MealAnalysisScreenState();
}

class _MealAnalysisScreenState extends State<MealAnalysisScreen> {
  final _picker = ImagePicker();
  Uint8List? _imageBytes;
  String _imageMimeType = 'image/jpeg';
  MealAnalysis? _analysis;
  bool _loading = false;
  DateTime? _analyzedAt;
  String? _debugDetail;
  bool _showDebug = false;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final file = await _picker.pickImage(
        source: source,
        maxWidth: 1280,
        imageQuality: 80,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _imageMimeType = _resolveMimeType(file);
        _analysis = null;
      });
    } catch (e) {
      _showMessage('Không mở được ${source == ImageSource.camera ? "camera" : "thư viện"} 😓');
    }
  }

  String _resolveMimeType(XFile file) {
    if (file.mimeType != null && file.mimeType!.isNotEmpty) {
      return file.mimeType!;
    }
    final ext = file.path.toLowerCase().split('.').last;
    switch (ext) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'heic':
        return 'image/heic';
      default:
        return 'image/jpeg';
    }
  }

  Future<void> _analyze() async {
    final bytes = _imageBytes;
    if (bytes == null) return;
    setState(() {
      _loading = true;
      _showDebug = false;
    });
    final (result, error, debugDetail) =
        await MealAnalysisService.analyze(bytes, mimeType: _imageMimeType);
    if (!mounted) return;
    setState(() {
      _loading = false;
      _analysis = result;
      _analyzedAt = DateTime.now();
      _debugDetail = debugDetail;
    });
    if (error != null) _showMessage(error);
  }

  Future<void> _saveMeal() async {
    final a = _analysis;
    if (a == null) return;
    await MealLogService.add(MealLogEntry(
      time: DateTime.now(),
      totalKcal: a.totalKcal,
      items: a.items.map((i) => i.name).toList(),
    ));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('✅ Đã lưu bữa ăn ${a.totalKcal} kcal!'),
      action: SnackBarAction(
        label: 'Xem nhật ký',
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const MealDiaryScreen()),
        ),
      ),
    ));
  }

  void _showMessage(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  /// Bảng xem luồng output/lỗi thô từ AI — giúp tự chẩn đoán sự cố
  /// (vd: hết quota, model nào đang dùng...) mà không cần xem log console.
  Widget _buildDebugPanel() {
    final detail = _debugDetail;
    if (detail == null) return const SizedBox.shrink();
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF4F5F7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFDDE1E8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => setState(() => _showDebug = !_showDebug),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  const Icon(Icons.bug_report_outlined,
                      size: 16, color: AppTheme.textMedium),
                  const SizedBox(width: 6),
                  const Expanded(
                    child: Text(
                      'Xem phản hồi AI (debug)',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textMedium),
                    ),
                  ),
                  Icon(
                    _showDebug
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                    size: 18,
                    color: AppTheme.textMedium,
                  ),
                ],
              ),
            ),
          ),
          if (_showDebug)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFDDE1E8)),
                    ),
                    child: SelectableText(
                      detail,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.textMedium,
                        fontFamily: 'monospace',
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: detail));
                        _showMessage('Đã sao chép chi tiết');
                      },
                      icon: const Icon(Icons.copy_rounded, size: 14),
                      label: const Text('Sao chép', style: TextStyle(fontSize: 12)),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              _buildBotBubble(),
              const SizedBox(height: 16),
              _buildPhotoArea(),
              const SizedBox(height: 16),
              if (_imageBytes != null) _buildAnalyzeButton(),
              if (_debugDetail != null) ...[
                const SizedBox(height: 12),
                _buildDebugPanel(),
              ],
              if (_analysis != null) ...[
                const SizedBox(height: 20),
                _buildTotalCard(_analysis!),
                const SizedBox(height: 14),
                _buildMacros(_analysis!),
                const SizedBox(height: 14),
                _buildAiComment(_analysis!),
                if (_analysis!.suggestions.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  _buildSuggestions(_analysis!),
                ],
                const SizedBox(height: 18),
                OutlinedButton.icon(
                  onPressed: _saveMeal,
                  icon: const Icon(Icons.bookmark_border_rounded,
                      color: AppTheme.primary, size: 20),
                  label: const Text(
                    'Lưu bữa ăn',
                    style: TextStyle(
                        color: AppTheme.primary,
                        fontSize: 15,
                        fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.primary, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const SizedBox(width: 44),
        Expanded(
          child: Column(
            children: [
              RichText(
                text: const TextSpan(
                  style:
                      TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                  children: [
                    TextSpan(
                        text: 'Phân tích ',
                        style: TextStyle(color: AppTheme.primary)),
                    TextSpan(
                        text: 'bữa ăn',
                        style: TextStyle(color: AppTheme.orange)),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Chụp ảnh món ăn để AI ước tính calo và dinh dưỡng',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textMedium, fontSize: 13),
              ),
            ],
          ),
        ),
        _buildDiaryButton(),
      ],
    );
  }

  Widget _buildDiaryButton() {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const MealDiaryScreen()),
      ),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.menu_book_rounded,
            color: AppTheme.primary, size: 20),
      ),
    );
  }

  Widget _buildBotBubble() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AnimatedMascot(size: 52),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(
              color: Color(0xFFEAF3FE),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(18),
                bottomLeft: Radius.circular(18),
                bottomRight: Radius.circular(18),
              ),
            ),
            child: const Text(
              'Hãy chụp bữa ăn của bạn để mình đánh giá xem đủ dinh dưỡng không nhé! 📸',
              style: TextStyle(
                  color: AppTheme.textDark, fontSize: 13.5, height: 1.45),
            ),
          ),
        ),
      ],
    );
  }

  // ── Khu vực ảnh: placeholder hoặc ảnh đã chụp ──────────────────────────────
  Widget _buildPhotoArea() {
    if (_imageBytes == null) {
      return Container(
        height: 230,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFD3E2F5), width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppTheme.chipBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.restaurant_rounded,
                  color: AppTheme.primary, size: 32),
            ),
            const SizedBox(height: 12),
            const Text(
              'Đặt món ăn vào khung hình',
              style: TextStyle(
                  color: AppTheme.textMedium,
                  fontSize: 13,
                  fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _photoButton(
                  icon: Icons.photo_camera_rounded,
                  label: 'Chụp ảnh',
                  primary: true,
                  onTap: () => _pickImage(ImageSource.camera),
                ),
                const SizedBox(width: 12),
                _photoButton(
                  icon: Icons.photo_library_outlined,
                  label: 'Thư viện',
                  primary: false,
                  onTap: () => _pickImage(ImageSource.gallery),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        children: [
          Image.memory(
            _imageBytes!,
            width: double.infinity,
            height: 260,
            fit: BoxFit.cover,
          ),
          Positioned(
            bottom: 10,
            right: 10,
            child: Row(
              children: [
                _overlayButton(
                  icon: Icons.photo_camera_rounded,
                  label: 'Chụp lại',
                  onTap: () => _pickImage(ImageSource.camera),
                ),
                const SizedBox(width: 8),
                _overlayButton(
                  icon: Icons.photo_library_outlined,
                  label: 'Thư viện',
                  onTap: () => _pickImage(ImageSource.gallery),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _photoButton({
    required IconData icon,
    required String label,
    required bool primary,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
        decoration: BoxDecoration(
          color: primary ? AppTheme.primary : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: primary
              ? null
              : Border.all(color: const Color(0xFFD3E2F5), width: 1.5),
          boxShadow: primary
              ? [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Icon(icon,
                color: primary ? Colors.white : AppTheme.primary, size: 18),
            const SizedBox(width: 7),
            Text(
              label,
              style: TextStyle(
                color: primary ? Colors.white : AppTheme.primary,
                fontSize: 13.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _overlayButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 15),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyzeButton() {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: AppTheme.brandGradient),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: _loading ? null : _analyze,
        icon: _loading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2.5, color: Colors.white),
              )
            : const Icon(Icons.auto_awesome_rounded,
                color: Colors.white, size: 20),
        label: Text(
          _loading ? 'AI đang phân tích...' : 'Nhận nhận xét AI',
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }

  // ── Kết quả: tổng kcal + danh sách món ─────────────────────────────────────
  Widget _buildTotalCard(MealAnalysis a) {
    final hh = _analyzedAt?.hour.toString().padLeft(2, '0') ?? '';
    final mm = _analyzedAt?.minute.toString().padLeft(2, '0') ?? '';
    final confidenceColor = a.confidence == 'cao'
        ? AppTheme.success
        : a.confidence == 'thấp'
            ? Colors.redAccent
            : AppTheme.orange;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2EAF4)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0E0),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.local_fire_department_rounded,
                    color: AppTheme.orange, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tổng ước tính',
                      style: TextStyle(
                          color: AppTheme.textMedium, fontSize: 12),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${a.totalKcal}',
                          style: const TextStyle(
                            color: AppTheme.textDark,
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Padding(
                          padding: EdgeInsets.only(bottom: 4),
                          child: Text(
                            'kcal',
                            style: TextStyle(
                                color: AppTheme.orange,
                                fontSize: 15,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: confidenceColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle_rounded,
                            color: confidenceColor, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          'Độ tin cậy ${a.confidence}',
                          style: TextStyle(
                            color: confidenceColor,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_analyzedAt != null) ...[
                    const SizedBox(height: 5),
                    Text(
                      'Cập nhật: hôm nay, $hh:$mm',
                      style: const TextStyle(
                          color: AppTheme.textMedium, fontSize: 11),
                    ),
                  ],
                ],
              ),
            ],
          ),
          if (a.items.isNotEmpty) ...[
            const Divider(height: 26, color: Color(0xFFEFF3F9)),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Các món được nhận diện',
                style: TextStyle(
                  color: AppTheme.textDark,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            ...a.items.map((i) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: AppTheme.chipBg,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.restaurant_rounded,
                            color: AppTheme.primary, size: 16),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                                fontSize: 13.5, color: AppTheme.textDark),
                            children: [
                              TextSpan(
                                text: i.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600),
                              ),
                              if (i.note.isNotEmpty)
                                TextSpan(
                                  text: ' (${i.note})',
                                  style: const TextStyle(
                                      color: AppTheme.textMedium,
                                      fontSize: 12),
                                ),
                            ],
                          ),
                        ),
                      ),
                      Text(
                        '${i.kcal} kcal',
                        style: const TextStyle(
                          color: AppTheme.textDark,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }

  // ── Macro dinh dưỡng ───────────────────────────────────────────────────────
  Widget _buildMacros(MealAnalysis a) {
    final totalMacro = a.proteinG + a.carbG + a.fatG;
    double pct(int g) => totalMacro <= 0 ? 0 : g / totalMacro;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2EAF4)),
      ),
      child: Row(
        children: [
          Expanded(
              child: _macroColumn(
                  'Protein', a.proteinG, pct(a.proteinG), AppTheme.primary)),
          const SizedBox(width: 14),
          Expanded(
              child: _macroColumn(
                  'Carb', a.carbG, pct(a.carbG), AppTheme.orange)),
          const SizedBox(width: 14),
          Expanded(
              child:
                  _macroColumn('Fat', a.fatG, pct(a.fatG), AppTheme.success)),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Chất xơ',
                  style: TextStyle(
                      color: AppTheme.textDark,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppTheme.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${a.fiberG} g',
                  style: const TextStyle(
                    color: AppTheme.success,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _macroColumn(String label, int grams, double pct, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: AppTheme.textDark,
                fontSize: 13,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('$grams',
                style: const TextStyle(
                    color: AppTheme.textDark,
                    fontSize: 17,
                    fontWeight: FontWeight.w900)),
            const SizedBox(width: 2),
            const Padding(
              padding: EdgeInsets.only(bottom: 2),
              child: Text('g',
                  style: TextStyle(
                      color: AppTheme.textMedium, fontSize: 11)),
            ),
            const Spacer(),
            Text('${(pct * 100).round()}%',
                style: const TextStyle(
                    color: AppTheme.textMedium, fontSize: 11)),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 5,
            backgroundColor: const Color(0xFFEFF3F9),
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }

  Widget _buildAiComment(MealAnalysis a) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF3FE),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AnimatedMascot(size: 50),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: const TextSpan(
                    style: TextStyle(
                        fontSize: 14.5, fontWeight: FontWeight.bold),
                    children: [
                      TextSpan(
                          text: 'Nhận xét từ ',
                          style: TextStyle(color: AppTheme.textDark)),
                      TextSpan(
                          text: 'AI Mam',
                          style: TextStyle(color: AppTheme.primary)),
                      TextSpan(
                          text: 'Go',
                          style: TextStyle(color: AppTheme.orange)),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  a.comment,
                  style: const TextStyle(
                      color: AppTheme.textDark,
                      fontSize: 13,
                      height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestions(MealAnalysis a) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.eco_rounded, color: AppTheme.success, size: 18),
            SizedBox(width: 6),
            Text(
              'Gợi ý bổ sung',
              style: TextStyle(
                color: AppTheme.textDark,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: a.suggestions.take(3).map((s) {
            final positive = s.deltaKcal >= 0;
            return Expanded(
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2EAF4)),
                ),
                child: Column(
                  children: [
                    Text(
                      s.label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppTheme.textDark,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${positive ? '+' : ''}${s.deltaKcal} kcal',
                      style: TextStyle(
                        color:
                            positive ? AppTheme.orange : AppTheme.success,
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
