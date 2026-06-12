import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class ApiService {
  static const String apiKey = "AQ.Ab8RN6IZEEdi8hnMpxYTE4zEsn8VXf8pdpcpYIP-7DlWf1Jh5g";

  static Future<String> envoyerPhotoFrigo(Uint8List imageBytes) async {
    try {
      final Uri url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey',
      );

      final String base64Image = base64Encode(imageBytes);

      final Map<String, dynamic> corpsRequete = {
        "contents": [
          {
            "parts": [
              {
                "text": "Regarde cette photo de mon frigo. Écris une liste de recettes simples et claires avec les ingrédients visibles, étape par étape."
              },
              {
                "inlineData": {
                  "mimeType": "image/jpeg",
                  "data": base64Image
                }
              }
            ]
          }
        ]
      };

      final http.Response response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(corpsRequete),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        
        if (jsonResponse.containsKey('candidates')) {
          final List<dynamic> candidates = jsonResponse['candidates'] as List<dynamic>;
          if (candidates.isNotEmpty) {
            final Map<String, dynamic> firstCandidate = candidates[0] as Map<String, dynamic>;
            if (firstCandidate.containsKey('content')) {
              final Map<String, dynamic> content = firstCandidate['content'] as Map<String, dynamic>;
              if (content.containsKey('parts')) {
                final List<dynamic> parts = content['parts'] as List<dynamic>;
                if (parts.isNotEmpty) {
                  final Map<String, dynamic> firstPart = parts[0] as Map<String, dynamic>;
                  return firstPart['text']?.toString() ?? "L'IA n'a pas renvoyé de texte.";
                }
              }
            }
          }
        }
        return "Format de réponse Gemini non reconnu.";
      } else {
        return "Erreur du serveur Gemini (Code: ${response.statusCode})";
      }
    } catch (e) {
      return "Erreur de connexion internet : $e";
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Frigo Recettes',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _reponseIA = "Prenez une photo de votre frigo pour recevoir des recettes !";
  bool _chargement = false;

  void _simulerAnalyse() async {
    setState(() {
      _chargement = true;
      _reponseIA = "L'intelligence artificielle examine votre frigo...";
    });

    final Uint8List fauxPixel = Uint8List.fromList([71, 73, 70, 56, 57, 97, 1, 0, 1, 0, 128, 0, 0, 0, 0, 0, 255, 255, 255, 33, 249, 4, 1, 0, 0, 0, 0, 44, 0, 0, 0, 0, 1, 0, 1, 0, 0, 2, 2, 68, 1, 0, 59]);
    
    final String resultat = await ApiService.envoyerPhotoFrigo(fauxPixel);

    setState(() {
      _reponseIA = resultat;
      _chargement = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mon Frigo Intelligent 🍳"),
        backgroundColor: const Color(0xFF1E1E1E),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.camera_alt_outlined, size: 60, color: Color(0xFF00C853)),
            ),
            const SizedBox(height: 25),
            ElevatedButton(
              onPressed: _chargement ? null : _simulerAnalyse,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00C853),
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 54),
              ),
              child: Text(_chargement ? "Analyse en cours..." : "Générer mes recettes"),
            ),
            const SizedBox(height: 30),
            const SizedBox(height: 15),
            SelectionArea(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _reponseIA,
                  style: const TextStyle(fontSize: 16, color: Colors.white, height: 1.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
