class ProductModel {
  const ProductModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.thumbnail,
    required this.category,
  });

  final int id;
  final String title;
  final String description;
  final double price;
  final String thumbnail;
  final String category;

  factory ProductModel.fromMap(Map<String, dynamic> json) {
    return ProductModel(
      id: _toInt(json['id']),
      title: json['title']?.toString() ?? 'Untitled',
      description: json['description']?.toString() ?? '',
      price: _toDouble(json['price']),
      thumbnail: json['thumbnail']?.toString() ?? '',
      category: json['category']?.toString() ?? 'Unknown',
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
