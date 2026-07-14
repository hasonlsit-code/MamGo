import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:mamgo/data/models/user_preference.dart';

class GeminiService {

  static const apiKey = String.fromEnvironment('GEMINI_API_KEY');
  static const _apiKey = apiKey;

  static const modelName = 'gemini-2.5-flash';
  static const _modelName = modelName;

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
          maxOutputTokens: 2048,
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
Bạn là MămGo - người bạn ẩm thực thân thiện và chuyên gia nấu ăn trong app MămGo.

NGUYÊN TẮC:
• Trả lời tiếng Việt bằng giọng điệu ấm áp, xưng "mình", gọi "bạn" như bạn bè thân thiết.
• Khi khuyên người dùng nên nấu món gì, hãy luôn đưa ra gợi ý món ăn cụ thể và hướng dẫn chi tiết các bước nấu (bao gồm nguyên liệu chi tiết và các bước thực hiện rõ ràng từng bước một).
• Tập trung tư vấn món ăn phù hợp với tâm trạng, cảm xúc hoặc yêu cầu của người dùng, giải thích lý do tại sao món đó tốt cho sức khỏe hoặc tâm trạng của họ.
• Trình bày thông tin rõ ràng, khoa học bằng cách sử dụng các gạch đầu dòng và số thứ tự cho các bước.
• Chỉ trả lời về chủ đề ẩm thực, dinh dưỡng, sức khỏe và hướng dẫn nấu ăn; tuyệt đối không trả lời các nội dung nhạy cảm hoặc không liên quan.
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

  /// Sinh công thức nấu ăn THUẦN TUÝ cho một món cụ thể — dùng model độc lập
  /// (không chung session hội thoại tâm trạng) để tránh lẫn giọng điệu tâm sự,
  /// chỉ trả về đúng phần nguyên liệu + các bước nấu, không chào hỏi hay bình luận.
  static Future<String> getRecipe(String foodName) async {
    if (_apiKey.isEmpty) {
      return '⚠️ Chưa cấu hình API key Gemini. Vui lòng thêm key vào gemini_service.dart và hot-restart app!';
    }
    try {
      final model = GenerativeModel(
        model: _modelName,
        apiKey: _apiKey,
        systemInstruction: Content.system('''
Bạn là đầu bếp chuyên nghiệp. Khi được hỏi công thức một món ăn, CHỈ trả lời phần công thức nấu
— không chào hỏi, không hỏi lại, không bình luận thêm, không emoji thừa ngoài 2 tiêu đề bên dưới.

Trình bày đúng 2 phần theo mẫu:
🛒 Nguyên liệu:
- <nguyên liệu 1 kèm định lượng>
- <nguyên liệu 2 kèm định lượng>

👨‍🍳 Cách làm:
1. <bước 1, ngắn gọn rõ ràng>
2. <bước 2>

Đủ chi tiết để người mới nấu cũng làm được. Tuyệt đối không thêm lời mở đầu hay lời chúc ngon miệng.
'''),
        generationConfig: GenerationConfig(temperature: 0.4, maxOutputTokens: 1400),
      );
      final response = await model.generateContent([
        Content.text('Công thức nấu món "$foodName".'),
      ]).timeout(const Duration(seconds: 25));
      final text = response.text?.trim();
      if (text == null || text.isEmpty) {
        return 'Mình chưa tìm được công thức chi tiết cho món này 😅 Thử lại sau nhé!';
      }
      return text;
    } on TimeoutException {
      return 'Kết nối quá lâu ⏱️ Thử lại sau vài giây nhé bạn!';
    } on GenerativeAIException catch (e) {
      debugPrint('[MămGo] GenerativeAIException (getRecipe): ${e.message}');
      if (e.message.contains('API_KEY') || e.message.contains('API key')) {
        return '🔑 API key không hợp lệ. Vào aistudio.google.com/apikey để lấy key mới nhé!';
      }
      if (e.message.contains('RESOURCE_EXHAUSTED') ||
          e.message.contains('quota')) {
        return '😅 Đã hết quota miễn phí hôm nay. Thử lại vào ngày mai nhé!';
      }
      return 'Ôi, mình đang gặp sự cố khi soạn công thức 😅 Thử lại sau nhé!';
    } catch (e) {
      debugPrint('[MămGo] Lỗi getRecipe: $e');
      return 'Có lỗi kết nối 😓 Kiểm tra mạng internet và thử lại nhé!';
    }
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
