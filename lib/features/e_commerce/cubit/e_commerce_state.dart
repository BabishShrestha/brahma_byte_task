import 'package:todo_app/features/e_commerce/domain/product_model.dart';

enum ECommerceStatus { initial, loading, success, failure }

class ECommerceState {
  const ECommerceState({
    this.status = ECommerceStatus.initial,
    this.products = const <ProductModel>[],
    this.favoriteIds = const <int>{},
    this.page = 1,
    this.hasMore = true,
    this.loadingMore = false,
    this.query = '',
    this.errorMessage,
  });

  final ECommerceStatus status;
  final List<ProductModel> products;
  final Set<int> favoriteIds;
  final int page;
  final bool hasMore;
  final bool loadingMore;
  final String query;
  final String? errorMessage;

  ECommerceState copyWith({
    ECommerceStatus? status,
    List<ProductModel>? products,
    Set<int>? favoriteIds,
    int? page,
    bool? hasMore,
    bool? loadingMore,
    String? query,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ECommerceState(
      status: status ?? this.status,
      products: products ?? this.products,
      favoriteIds: favoriteIds ?? this.favoriteIds,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      loadingMore: loadingMore ?? this.loadingMore,
      query: query ?? this.query,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
