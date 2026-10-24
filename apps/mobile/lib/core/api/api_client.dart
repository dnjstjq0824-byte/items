import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  final String baseUrl;

  ApiClient({this.baseUrl = 'http://10.0.2.2:8080/api/v1'});

  Future<Map<String, dynamic>> checkTradePolicy({
    required String gameId,
    required String countryCode,
    required String productType,
  }) async {
    final uri = Uri.parse('$baseUrl/games/$gameId/trade-availability?country=$countryCode&product_type=$productType');
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'];
    }
    throw Exception('Failed to check policy: ${response.body}');
  }

  Future<Map<String, dynamic>> createQuote({
    required String buyerId,
    required String listingId,
    required int quantity,
    required String countryCode,
  }) async {
    final uri = Uri.parse('$baseUrl/orders/quotes');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'buyer_user_id': buyerId,
        'listing_id': listingId,
        'quantity': quantity,
        'buyer_country': countryCode,
      }),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['data'];
    }
    throw Exception('Quote rejected by compliance gate: ${response.body}');
  }
}

