import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = 'http://YOUR_SERVER_IP:8000';

  Future<List<Map<String, dynamic>>> getDevices(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl/devices/$userId'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['devices']);
    } else {
      throw Exception('فشل في جلب البيانات');
    }
  }
}
