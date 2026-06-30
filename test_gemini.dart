import 'dart:convert';
import 'dart:io';

void main() async {
  final apiKey = 'YOUR_GEMINI_API_KEY_HERE';
  final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models?key=$apiKey');
  
  try {
    final httpClient = HttpClient();
    final request = await httpClient.getUrl(url);
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    print('Status Code: ${response.statusCode}');
    print('Response: $responseBody');
  } catch (e) {
    print('Error: $e');
  }
}
