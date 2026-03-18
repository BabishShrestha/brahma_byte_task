import 'package:bloc/bloc.dart';
import 'package:todo_app/features/e_commerce/cubit/e_commerce_state.dart';
import 'package:todo_app/features/e_commerce/data/product_repo.dart';
import 'package:todo_app/features/e_commerce/domain/product_model.dart';

class ECommerceCubit extends Cubit<ECommerceState> {
  ECommerceCubit(this._repo) : super(const ECommerceState());

  final ProductRepo _repo;
  static const int _pageSize = 10;

  Future<void> initialize() async {
    emit(state.copyWith(status: ECommerceStatus.loading, clearError: true));

    try {
      final favoriteIds = await _repo.getFavoriteIds();
      final firstPage = await _repo.fetchProducts(page: 1, pageSize: _pageSize);

      emit(
        state.copyWith(
          status: ECommerceStatus.success,
          products: firstPage.products,
          favoriteIds: favoriteIds,
          page: 1,
          hasMore: firstPage.products.length < firstPage.total,
          loadingMore: false,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ECommerceStatus.failure,
          errorMessage: 'Failed to load products: $e',
        ),
      );
    }
  }

  Future<void> search(String query) async {
    emit(
      state.copyWith(
        status: ECommerceStatus.loading,
        query: query,
        page: 1,
        hasMore: true,
        products: const <ProductModel>[],
        clearError: true,
      ),
    );

    try {
      final page = await _repo.fetchProducts(
        page: 1,
        pageSize: _pageSize,
        query: query,
      );
      emit(
        state.copyWith(
          status: ECommerceStatus.success,
          products: page.products,
          page: 1,
          hasMore: page.products.length < page.total,
          loadingMore: false,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ECommerceStatus.failure,
          errorMessage: 'Search failed: $e',
        ),
      );
    }
  }

  Future<void> loadMore() async {
    if (state.loadingMore ||
        !state.hasMore ||
        state.status != ECommerceStatus.success) {
      return;
    }

    emit(state.copyWith(loadingMore: true));

    try {
      final nextPageIndex = state.page + 1;
      final result = await _repo.fetchProducts(
        page: nextPageIndex,
        pageSize: _pageSize,
        query: state.query,
      );

      final updatedProducts = <ProductModel>[
        ...state.products,
        ...result.products,
      ];

      emit(
        state.copyWith(
          products: updatedProducts,
          page: nextPageIndex,
          hasMore: updatedProducts.length < result.total,
          loadingMore: false,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          loadingMore: false,
          errorMessage: 'Failed to load more: $e',
        ),
      );
    }
  }

  Future<void> toggleFavorite(int productId) async {
    final updated = Set<int>.from(state.favoriteIds);
    if (updated.contains(productId)) {
      updated.remove(productId);
    } else {
      updated.add(productId);
    }

    emit(state.copyWith(favoriteIds: updated));
    await _repo.saveFavoriteIds(updated);
  }
}
