import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_app/features/e_commerce/domain/product_model.dart';

class ProductRepo {
  static const String _baseUrl = 'https://dummyjson.com';
  static const String _favoritesKey = 'ecommerce_favorites_v1';

  Future<ProductPageResult> fetchProducts({
    required int page,
    required int pageSize,
    String query = '',
  }) async {
    final int skip = (page - 1) * pageSize;
    final String trimmedQuery = query.trim();

    final Uri url = trimmedQuery.isEmpty
        ? Uri.parse('$_baseUrl/products?limit=$pageSize&skip=$skip')
        : Uri.parse(
            '$_baseUrl/products/search?q=${Uri.encodeQueryComponent(trimmedQuery)}&limit=$pageSize&skip=$skip',
          );

    final response = await http.get(url);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to load products (${response.statusCode})');
    }

    final dynamic decoded = jsonDecode(response.body);
    if (decoded is! Map) {
      throw const FormatException('Unexpected response format');
    }

    final map = Map<String, dynamic>.from(decoded);
    final dynamic productsRaw = map['products'];
    final List<ProductModel> products = productsRaw is List
        ? productsRaw
              .map(
                (item) => ProductModel.fromMap(
                  Map<String, dynamic>.from(item as Map),
                ),
              )
              .toList()
        : const <ProductModel>[];

    final int total = _toInt(map['total']);
    return ProductPageResult(products: products, total: total);
  }

  Future<Set<int>> getFavoriteIds() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> ids =
        prefs.getStringList(_favoritesKey) ?? const <String>[];
    return ids
        .map((id) => int.tryParse(id) ?? -1)
        .where((id) => id >= 0)
        .toSet();
  }

  Future<void> saveFavoriteIds(Set<int> favoriteIds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _favoritesKey,
      favoriteIds.map((id) => id.toString()).toList(),
    );
  }

  int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class ProductPageResult {
  const ProductPageResult({required this.products, required this.total});

  final List<ProductModel> products;
  final int total;
}
