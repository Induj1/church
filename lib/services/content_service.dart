import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/content_item.dart';

class ContentService {
  /// Fetch all content rows from the local admin proxy.
  /// The proxy may return either a JSON array or an object containing
  /// a `value` or `data` array. Be tolerant of both shapes.
  static Future<List<ContentItem>> fetchAll() async {
  // Prefer an API base provided at build time via --dart-define=API_BASE=<url>.
  // If not provided, fall back to sensible development defaults:
  // - web: localhost (proxy running on developer machine)
  // - Android emulator: 10.0.2.2 maps to host machine
  const apiBaseFromEnv = String.fromEnvironment('API_BASE', defaultValue: '');
  final base = apiBaseFromEnv.isNotEmpty
      ? apiBaseFromEnv
      : (kIsWeb ? 'http://localhost:3000' : 'http://10.0.2.2:3000');
  final uri = Uri.parse('$base/api/content');
    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Failed to fetch content: ${res.statusCode} ${res.body}');
    }

    final dynamic decoded = json.decode(res.body);

    late final List<dynamic> list;
    if (decoded is List) {
      list = decoded;
    } else if (decoded is Map<String, dynamic>) {
      if (decoded['value'] is List) {
        list = decoded['value'] as List<dynamic>;
      } else if (decoded['data'] is List) {
        list = decoded['data'] as List<dynamic>;
      } else {
        // Try to find the first List value in the map
        final firstList = decoded.values.firstWhere((v) => v is List, orElse: () => null);
        if (firstList is List) {
          list = firstList;
        } else {
          // Nothing iterable found: return empty list
          list = <dynamic>[];
        }
      }
    } else {
      // Unknown shape
      list = <dynamic>[];
    }

    return list.map((e) {
      if (e is Map<String, dynamic>) {
        return ContentItem.fromJson(e);
      }
      // If the element is JS map (LinkedHashMap) or other, try to convert
      if (e is Map) {
        return ContentItem.fromJson(Map<String, dynamic>.from(e));
      }
      throw Exception('Unexpected content item shape: ${e.runtimeType}');
    }).toList();
  }
}
