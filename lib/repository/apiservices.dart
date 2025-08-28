import 'dart:convert';

import 'package:testproject/models/currency_conversion_model/currency_conversion_model.dart';
import 'package:http/http.dart' as http;

class ApiServices {
  static const String baseUrl = "https://api.exconvert.com";
  static const String accessKey = "270ca084-96a82de7-ae4aff0f-60b941d9";

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
      print('>>> ${response.body}');
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
