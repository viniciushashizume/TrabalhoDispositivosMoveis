import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // IP da rede Wi-Fi local do computador para testes no celuklar
  static const String baseUrl = 'http://192.168.100.186:8000';
  //static const String baseUrl = 'http://10.0.2.2:8000';

  Future<Map<String, dynamic>?> analyzeDiary(
    String text, {
    int? humor,
    int? horasSono,
    int? nivelEstresse,
    int? atividadeFisica,
    int? interacaoSocial,
    String? userEmail,
    String? idRegistro,
    String? tipo,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/predict');
      
      final Map<String, dynamic> bodyData = {
        'text': text,
      };

      if (humor != null) bodyData['humor'] = humor;
      if (horasSono != null) bodyData['horasSono'] = horasSono;
      if (nivelEstresse != null) bodyData['nivelEstresse'] = nivelEstresse;
      if (atividadeFisica != null) bodyData['atividadeFisica'] = atividadeFisica;
      if (interacaoSocial != null) bodyData['interacaoSocial'] = interacaoSocial;
      if (userEmail != null) bodyData['user_email'] = userEmail;
      if (idRegistro != null) bodyData['id_registro'] = idRegistro;
      if (tipo != null) bodyData['tipo'] = tipo;

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(bodyData),
      );

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else {
        print('Erro na API: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Erro ao conectar na API: $e');
      return null;
    }
  }
}
