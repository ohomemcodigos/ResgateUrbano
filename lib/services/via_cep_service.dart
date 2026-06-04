import 'dart:convert';
import 'package:http/http.dart' as http;

class ViaCepService {
  static Future<Map<String, String>?> buscarEnderecoPorCep(String cep) async {
    // Remove qualquer caractere que não seja número (ex: hífens ou pontos)
    final cleanCep = cep.replaceAll(RegExp(r'[^0-9]'), '');

    if (cleanCep.length != 8) return null;

    try {
      final response =
          await http.get(Uri.parse('https://viacep.com.br/ws/$cleanCep/json/'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data.containsKey('erro') && data['erro'] == true) {
          return null;
        }

        return {
          // Retorna a rua e o bairro encontrados
          'rua': data['logradouro'] ?? '',
          'bairro': data['bairro'] ?? '',
        };
      }
    } catch (e) {
      // Falha silenciosa: se a internet cair, o app não quebra,
      // apenas exige que o usuário digite o bairro manualmente.
      return null;
    }
    return null;
  }
}
