import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  final String baseUrl;

  ApiClient({required this.baseUrl});

  Future<Map<String, dynamic>> get(String endpoint) async {
    final response = await http.get(Uri.parse('$baseUrl/$endpoint'));
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> post(String endpoint, dynamic data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/$endpoint'),
      body: json.encode(data),
      headers: {'Content-Type': 'application/json'},
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> update(String endpoint, dynamic data, String id) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$endpoint/$id'),
      body: json.encode(data),
      headers: {'Content-Type': 'application/json'},
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> delete(String endpoint, String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/$endpoint/$id'),
    );
    return _handleResponse(response);
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  }
}

