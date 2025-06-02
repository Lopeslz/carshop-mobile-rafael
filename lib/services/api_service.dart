import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Singleton padrão
  static final ApiService instance = ApiService._internal();
  factory ApiService() => instance;

  // Altere o IP abaixo se for rodar em celular físico
  final String baseUrl = 'http://10.0.2.2:8080/api';

  // Construtor privado
  ApiService._internal();

  // Requisição GET com suporte a headers e params (params ainda não aplicados no Uri)
  Future<http.Response> get(
      String endpoint, {
        Map<String, String>? headers,
        Map<String, String>? params,
      }) async {
    Uri uri = Uri.parse('$baseUrl$endpoint');
    if (params != null && params.isNotEmpty) {
      uri = uri.replace(queryParameters: params);
    }
    return await http.get(uri, headers: headers);
  }

  // Requisição POST padrão (JSON)
  Future<http.Response> post(
      String endpoint, {
        Map<String, String>? headers,
        Object? body,
      }) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    return await http.post(
      uri,
      headers: headers ?? {'Content-Type': 'application/json'},
      body: json.encode(body),
    );
  }

  // Requisição POST com multipart/form-data (para envio de arquivos)
  Future<http.Response> postMultipart(
      String endpoint,
      Map<String, String> fields, {
        Map<String, http.MultipartFile>? files,
      }) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    var request = http.MultipartRequest('POST', uri);
    request.fields.addAll(fields);
    if (files != null) {
      request.files.addAll(files.values);
    }
    final streamedResponse = await request.send();
    return await http.Response.fromStream(streamedResponse);
  }

  // Requisição DELETE
  Future<http.Response> delete(String endpoint) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    return await http.delete(uri);
  }
}
