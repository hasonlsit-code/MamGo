import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:mamgo/data/models/user_preference.dart';

class GeminiService {
  static const _apiKey = 'YOUR_GEMINI_API_KEY_HERE'; // Thay bằng key từ aistudio.google.com/apikey
  static const _modelName = 'gemini-2.5-flash';

  static ChatSession? _session;

  static void initialize(UserPreference? pref) {
    if (_apiKey.isEmpty) {
      debugPrint('[MămGo] ⚠️ API key trống!');
      return;
    }
    try {
      final model = GenerativeModel(
        model: _modelName,
        apiKey: _apiKey,
        systemInstruction: Content.system(_buildSystemPrompt(pref)),
        generationConfig: GenerationConfig(
          temperature: 0.7,
          maxOutputTokens: 600,
        ),
      );
      _session = model.startChat();
    } catch (e) {
      debugPrint('[MămGo] Lỗi khởi tạo Gemini: $e');
    }
  }

  static void reset(UserPreference? pref) => initialize(pref);

  static String _buildSystemPrompt(UserPreference? pref) {
    final sb = StringBuffer('''
Bạn là MămGo - người bạn ẩm thực thân thiện trong app MămGo.

NGUYÊN TẮC:
• Trả lời tiếng Việt, TỐI ĐA 2-3 câu ngắn, dùng 1-2 emoji
• Xưng "mình", gọi "bạn" - nói như bạn bè, thoải mái tự nhiên
• KHÔNG liệt kê tên món ăn (app tự hiển thị thẻ gợi ý bên dưới)
• Tập trung: tâm trạng/cảm xúc → gợi ý kiểu ăn phù hợp + 1 lợi ích sức khỏe
• Kết bằng câu hỏi ngắn hoặc lời động viên ấm
• Chỉ về ẩm thực và sức khỏe; không nội dung nhạy cảm
''');

    if (pref != null) {
      final tastes = pref.tastePreferences.isEmpty
          ? 'Chưa thiết lập'
          : pref.tastePreferences.join(', ');
      final cuisines = pref.favoriteCuisines.isEmpty
          ? 'Chưa thiết lập'
          : pref.favoriteCuisines.join(', ');
      final diets = pref.dietaryRestrictions.isEmpty
          ? 'Không hạn chế'
          : pref.dietaryRestrictions.join(', ');

      sb.writeln('''
THÔNG TIN NGƯỜI DÙNG (cá nhân hóa gợi ý theo đây):
• Tên: ${pref.name}
• Khẩu vị yêu thích: $tastes
• Ẩm thực yêu thích: $cuisines
• Chế độ ăn: $diets

Hãy ưu tiên gợi ý các món phù hợp với khẩu vị và chế độ ăn trên.
Gọi tên người dùng là "${pref.name}" khi phù hợp để thân thiện hơn.''');
    }

    return sb.toString();
  }

  static Future<String> chat(String message) async {
    if (_session == null) initialize(null);
    if (_session == null) {
      return '⚠️ Chưa cấu hình API key Gemini. Vui lòng thêm key vào gemini_service.dart và hot-restart app!';
    }
    try {
      final response = await _session!
          .sendMessage(Content.text(message))
          .timeout(const Duration(seconds: 20));
      final text = response.text;
      if (text == null || text.trim().isEmpty) {
        return 'Mình chưa hiểu câu hỏi đó lắm 😅 Bạn thử hỏi về món ăn hoặc công thức nấu nướng nhé!';
      }
      return text.trim();
    } on TimeoutException {
      _session = null;
      return 'Kết nối quá lâu ⏱️ Thử lại sau vài giây nhé bạn!';
    } on GenerativeAIException catch (e) {
      debugPrint('[MămGo] GenerativeAIException: ${e.message}');
      if (e.message.contains('API_KEY') ||
          e.message.contains('API key') ||
          e.message.contains('INVALID_ARGUMENT')) {
        _session = null;
        return '🔑 API key không hợp lệ. Vào aistudio.google.com/apikey để lấy key mới nhé!';
      }
      if (e.message.contains('RESOURCE_EXHAUSTED') ||
          e.message.contains('quota')) {
        return '😅 Đã hết quota miễn phí hôm nay. Thử lại vào ngày mai nhé!';
      }
      if (e.message.contains('MODEL_NOT_FOUND')) {
        _session = null;
        return '⚙️ Model AI không tìm thấy. Vui lòng kiểm tra lại cấu hình!';
      }
      _session = null;
      return 'Ôi, mình đang gặp sự cố 😅 Lỗi: ${e.message.length > 60 ? '${e.message.substring(0, 60)}...' : e.message}';
    } catch (e) {
      debugPrint('[MămGo] Lỗi không xác định: $e');
      return 'Có lỗi kết nối 😓 Kiểm tra mạng internet và thử lại nhé!';
    }
  }
}
