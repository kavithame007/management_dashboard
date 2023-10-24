import 'package:http/http.dart' as http;
import 'dart:convert';

class Networking {
  static Future<dynamic> fetchData({
    required var apiUrl,
    required var headers,
    required var requestBody,
    String method = 'GET',
  }) async {
    var request = http.Request(
      method,
      Uri.parse(apiUrl),
    );

    if (method == 'GET') {
      request.body = json.encode(requestBody);
    }

    request.headers.addAll(headers);


    http.StreamedResponse response = await request.send();


    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      //print(json.decode(responseData));
      return json.decode(responseData);
    } else {
      print(response.statusCode);
      throw Exception(response.reasonPhrase);
    }
  }
}