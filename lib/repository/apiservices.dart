import 'dart:convert';

import 'package:testproject/models/currency_conversion_model/currency_conversion_model.dart';
import 'package:http/http.dart' as http;

class ApiServices {

  // Read values from --dart-define
  static const String baseUrl = String.fromEnvironment(
    "BASE_URL",
    defaultValue: "",
  );
  static const String accessKey = String.fromEnvironment(
    "ACCESS_KEY",
    defaultValue: "",
  );

  Future<CurrencyConversionModel> convert(
    String from,
    String to,
    double amount,
  ) async {
    try {
      final uri = Uri.parse(
        "$baseUrl/convert?from=$from&to=$to&amount=$amount&access_key=$accessKey",
      );

      final response = await http.get(uri);
      if (response.statusCode == 200) {
        return CurrencyConversionModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception("Failed to fetch conversion");
      }
    } catch (e) {
      throw Exception("Failed to fetch conversion : ${e.toString()}");
    }
  }
}
