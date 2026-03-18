import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_app/features/e_commerce/cubit/e_commerce_cubit.dart';
import 'package:todo_app/features/e_commerce/cubit/e_commerce_state.dart';
import 'package:todo_app/features/e_commerce/data/product_repo.dart';
import 'package:todo_app/features/e_commerce/view/widgets/product_card.dart';

class ECommerceView extends StatefulWidget {
  const ECommerceView({super.key});

  @override
  State<ECommerceView> createState() => _ECommerceViewState();
}

class _ECommerceViewState extends State<ECommerceView> {
  late final ECommerceCubit _cubit;
  late final ScrollController _scrollController;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _cubit = ECommerceCubit(ProductRepo())..initialize();
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _cubit.close();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) {
      return;
    }

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      _cubit.loadMore();
    }
  }

  void _onSearchChanged(String value) {
    setState(() {});
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), () {
      _cubit.search(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mini E-Commerce'),
          actions: [
            IconButton(
              tooltip: 'Refresh',
              onPressed: () => _cubit.search(_searchController.text),
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isEmpty
                      ? null
                      : IconButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                            _cubit.search('');
                          },
                          icon: const Icon(Icons.clear),
                        ),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: BlocBuilder<ECommerceCubit, ECommerceState>(
                  builder: (context, state) {
                    if (state.status == ECommerceStatus.loading &&
                        state.products.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state.status == ECommerceStatus.failure &&
                        state.products.isEmpty) {
                      return _ErrorView(
                        message:
                            state.errorMessage ?? 'Failed to load products',
                        onRetry: () => _cubit.search(_searchController.text),
                      );
                    }

                    if (state.products.isEmpty) {
                      return const Center(
                        child: Text('No products found for your search.'),
                      );
                    }

                    return ListView.builder(
                      controller: _scrollController,
                      itemCount:
                          state.products.length + (state.loadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index >= state.products.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        final product = state.products[index];
                        return ProductCard(
                          product: product,
                          isFavorite: state.favoriteIds.contains(product.id),
                          onFavoriteTap: () =>
                              _cubit.toggleFavorite(product.id),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
