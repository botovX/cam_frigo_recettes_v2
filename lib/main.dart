import 'package:flutter/material';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Frigo Recettes Ready'),
        ),
      ),
    );
  }
}

class ApiService {
  static const String _apiKey = "AQ.Ab8RN6IZEEdi8hnMpxYTE4zEsn8VXf8pdpcpYIP-7DlWf1Jh5g";

  static Future<String> genererRecettes() async {
    try {
      final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$_apiKey');
      final response = await http.post(
        url, 
        headers: {"Content-Type": "application/json"}, 
        body: '{"contents": [{"parts": [{"text": "Test"}]}]}',
      );
      return response.statusCode == 200 ? "OK" : "Error";
    } catch (e) {
      return "Error";
    }
  }
}
