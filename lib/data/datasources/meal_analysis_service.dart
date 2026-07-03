import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:mamgo/data/datasources/gemini_service.dart';
import 'package:mamgo/data/models/meal_analysis.dart';

/// Phân tích ảnh bữa ăn bằng Gemini Vision, trả về ước tính dinh dưỡng.
class MealAnalysisService {
  static const _apiKey = GeminiService.apiKey; // key đặt tại gemini_service.dart
  // Dùng chung model với chat (gemini_service.dart) để gộp chung 1 quota bucket.
  static const _modelName = GeminiService.modelName;

  static const _prompt = '''
Bạn là chuyên gia dinh dưỡng. Hãy phân tích ảnh bữa ăn này và trả về DUY NHẤT một JSON hợp lệ (không markdown, không giải thích thêm) theo đúng cấu trúc:
{
  "total_kcal": <tổng calo ước tính, số nguyên>,
  "confidence": "<cao | trung bình | thấp>",
  "items": [
    {"name": "<tên món tiếng Việt>", "note": "<mô tả ngắn thành phần, có thể rỗng>", "kcal": <số nguyên>}
  ],
  "protein_g": <gam đạm>,
  "carb_g": <gam tinh bột>,
  "fat_g": <gam chất béo>,
  "fiber_g": <gam chất xơ>,
  "comment": "<2-3 câu nhận xét thân thiện tiếng Việt về độ cân bằng dinh dưỡng của bữa ăn>",
  "suggestions": [
    {"label": "<gợi ý ngắn, vd: Thêm 1 hũ sữa chua>", "delta_kcal": <số nguyên, dương nếu thêm calo, âm nếu giảm>}
  ]
}
Tối đa 5 items và 3 suggestions. Nếu ảnh không phải đồ ăn, trả về: {"error": "not_food"}
''';

  /// Trả về (analysis, errorMessage, debugDetail).
  /// [debugDetail] chứa phản hồi thô/chi tiết lỗi kỹ thuật từ AI để hiển thị
  /// cho người dùng tự soi khi cần (vd: khi báo hết quota, lỗi parse...).
  /// [mimeType] nên khớp định dạng ảnh thật (image/jpeg, image/png...).
  static Future<(MealAnalysis?, String?, String?)> analyze(
    Uint8List imageBytes, {
    String mimeType = 'image/jpeg',
  }) async {
    if (_apiKey.isEmpty || _apiKey.startsWith('YOUR_')) {
      return (
        null,
        '🔑 Chưa cấu hình API key Gemini. Thêm key vào meal_analysis_service.dart nhé!',
        null,
      );
    }
    String rawText = '';
    try {
      final model = GenerativeModel(
        model: _modelName,
        apiKey: _apiKey,
        generationConfig: GenerationConfig(
          temperature: 0.2,
          maxOutputTokens: 3072,
          responseMimeType: 'application/json',
        ),
      );
      final response = await model.generateContent([
        Content.multi([
          TextPart(_prompt),
          DataPart(mimeType, imageBytes),
        ]),
      ]).timeout(const Duration(seconds: 45));

      rawText = response.text?.trim() ?? '';
      if (rawText.isEmpty) {
        return (
          null,
          'AI không trả về kết quả 😅 Thử lại với ảnh rõ hơn nhé!',
          'Model: $_modelName\nfinishReason: ${response.candidates.isNotEmpty ? response.candidates.first.finishReason : 'không rõ'}',
        );
      }
      // Bỏ code fence nếu có, và chỉ giữ phần từ { đầu tiên đến } cuối cùng
      // để loại bỏ mọi văn bản thừa mà model có thể chèn quanh JSON.
      var text = rawText
          .replaceFirst(RegExp(r'^```(json)?'), '')
          .replaceFirst(RegExp(r'```$'), '')
          .trim();
      final start = text.indexOf('{');
      final end = text.lastIndexOf('}');
      if (start == -1 || end == -1 || end < start) {
        debugPrint('[MămGo] Phản hồi AI không chứa JSON: $text');
        return (null, 'AI trả về dữ liệu lạ 😅 Thử chụp lại nhé!', rawText);
      }
      text = text.substring(start, end + 1);

      final json = jsonDecode(text) as Map<String, dynamic>;
      if (json['error'] == 'not_food') {
        return (
          null,
          'Hình như đây không phải ảnh đồ ăn 🤔 Chụp lại bữa ăn của bạn nhé!',
          null,
        );
      }
      return (MealAnalysis.fromJson(json), null, rawText);
    } on TimeoutException {
      return (
        null,
        'Phân tích quá lâu ⏱️ Kiểm tra mạng và thử lại nhé!',
        'Model: $_modelName\nTimeout sau 45s',
      );
    } on FormatException catch (e) {
      debugPrint('[MămGo] Lỗi parse JSON phân tích: $e');
      return (
        null,
        'AI trả về dữ liệu lạ 😅 Thử chụp lại nhé!',
        'Model: $_modelName\nLỗi parse: $e\n\nPhản hồi thô:\n$rawText',
      );
    } on GenerativeAIException catch (e) {
      debugPrint('[MămGo] GenerativeAIException: ${e.message}');
      final debug = 'Model: $_modelName\n${e.message}';
      if (e.message.contains('API_KEY') || e.message.contains('API key')) {
        return (null, '🔑 API key không hợp lệ. Kiểm tra lại key nhé!', debug);
      }
      if (e.message.contains('quota') ||
          e.message.contains('RESOURCE_EXHAUSTED')) {
        return (
          null,
          '😅 Đã hết quota AI hôm nay. Thử lại vào ngày mai nhé!',
          debug,
        );
      }
      return (null, 'AI đang gặp sự cố 😓 Thử lại sau nhé!', debug);
    } catch (e) {
      debugPrint('[MămGo] Lỗi phân tích bữa ăn: $e');
      return (
        null,
        'Có lỗi kết nối 😓 Kiểm tra mạng và thử lại nhé!',
        'Model: $_modelName\n$e',
      );
    }
  }
}
