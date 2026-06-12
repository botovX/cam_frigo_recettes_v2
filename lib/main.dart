import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class ApiService {
  static const String _apiKey = "AQ.Ab8RN6IZEEdi8hnMpxYTE4zEsn8VXf8pdpcpYIP-7DlWf1Jh5g";

  static Future<String> genererRecettes(Uint8List imageBytes) async {
    try {
      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$_apiKey',
      );

      final base64Image = base64Encode(imageBytes);

      final corpsRequete = {
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

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(corpsRequete),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        if (jsonResponse.containsKey('candidates') && jsonResponse['candidates'].isNotEmpty) {
          final candidate = jsonResponse['candidates'][0];
          if (candidate.containsKey('content') && candidate['content'].containsKey('parts')) {
            final parts = candidate['content']['parts'];
            if (parts.isNotEmpty) {
              final dynamic texteExtrait = parts[0]['text'];
              return texteExtrait?.toString() ?? "Aucun texte trouvé.";
            }
          }
        }
        return "Format de réponse inconnu.";
      } 
      return "Erreur Gemini (Code ${response.statusCode})";
    } catch (e) {
      return "Erreur de connexion : $e";
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Frigo Recettes',
      theme: ThemeData(
        useMaterialDesign: true,
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
  String _resultat = "Prenez une photo de votre frigo pour commencer !";
  bool _enChargement = false;

  void _envoyerImage() async {
    setState(() {
      _enChargement = true;
      _resultat = "Analyse du frigo en cours...";
    });

    final reponseIA = await ApiService.genererRecettes(Uint8List(0));

    setState(() {
      _resultat = reponseIA;
      _enChargement = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("FrigoRecettes 🍳"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _envoyerImage,
              child: const Text("Générer mes recettes"),
            ),
            const SizedBox(height: 20),
            _enChargement
                ? const CircularProgressIndicator()
                : SelectableText(_resultat),
          ],
        ),
      ),
    );
  }
}
