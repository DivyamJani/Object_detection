import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_keys.dart';

/// Sends a base64-encoded JPEG to Vision’s OBJECT_LOCALIZATION endpoint,
/// returns a list of annotations (name, score, normalizedVertices) :contentReference[oaicite:4]{index=4}
Future<List<dynamic>> detectObjects(String base64Image) async {
  final uri = Uri.parse(
    'https://vision.googleapis.com/v1/images:annotate?key=$kVisionApiKey'
  );
  final response = await http.post(
    uri,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'requests': [
        {
          'image': {'content': base64Image},
          'features': [{'type': 'OBJECT_LOCALIZATION'}]
        }
      ]
    }),
  ); // http.post example :contentReference[oaicite:5]{index=5}

  if (response.statusCode != 200) {
    throw Exception('Vision API error: ${response.body}');
  }
  final jsonBody = jsonDecode(response.body);
  return jsonBody['responses'][0]['localizedObjectAnnotations'] as List<dynamic>;
}
