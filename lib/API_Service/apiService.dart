import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl;

  ApiService(this.baseUrl);

  Future<dynamic> get(String endpoint) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$endpoint'));

      if (response.statusCode == 200) {
        final dynamic jsonData = json.decode(response.body);
        return jsonData;
      } else if (response.statusCode == 400 || response.statusCode == 401 || response.statusCode == 403 || response.statusCode == 500) {
        // Handle specific HTTP status codes
        throw Exception('Failed to load data: ${response.statusCode}');
      } else {
        // Handle other HTTP status codes here if needed
        throw Exception('Failed to load data with status code: ${response.statusCode}');
      }
    } on SocketException catch (e) {
      // Handle Socket Exceptions
      throw Exception('Socket Exception: $e');
    } catch (e) {
      // Handle other exceptions
      throw Exception('Failed to load data: $e');
    }
  }


  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {"Content-Type": "application/json"},
        body: json.encode(data),
      );

      if (response.statusCode == 201) {
        final dynamic jsonData = json.decode(response.body);
        return jsonData;
      } else {
        throw Exception('Failed to post data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to post data: $e');
    }
  }
}
