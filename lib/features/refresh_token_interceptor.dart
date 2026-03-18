// lib/core/network/auth_interceptor.dart

import 'dart:async';
import 'package:dio/dio.dart';
import '../auth/auth_repository.dart';
import '../auth/token_storage.dart';

class AuthInterceptor extends Interceptor {
  final Dio _dio;
  final TokenStorage _storage; //for local storage of tokens
  final AuthRepository _authRepo;
  final Future<void> Function() _onSessionExpired; // → triggers logout in BLoC

  // Mutex: prevent multiple simultaneous refresh calls
  bool _isRefreshing = false;
  final _pendingRequests = <_PendingRequest>[];

  AuthInterceptor({
    required Dio dio,
    required TokenStorage storage,
    required AuthRepository authRepo,
    required Future<void> Function() onSessionExpired,
  }) : _dio = dio,
       _storage = storage,
       _authRepo = authRepo,
       _onSessionExpired = onSessionExpired;
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _storage.accessToken;
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401) {
      handler.next(err);
      return;
    }

    final refreshToken = _storage.refreshToken;
    if (refreshToken == null) {
      await _onSessionExpired();
      handler.next(err);
      return;
    }

    if (_isRefreshing) {
      final completer = Completer<Response>();
      _pendingRequests.add(
        _PendingRequest(options: err.requestOptions, completer: completer),
      );
      try {
        handler.resolve(await completer.future);
      } catch (e) {
        handler.next(err);
      }
      return;
    }

    _isRefreshing = true;

    try {
      await _authRepo.refreshAccessToken(refreshToken);

      final retried = await _retry(err.requestOptions);
      handler.resolve(retried);

      for (final pending in _pendingRequests) {
        try {
          pending.completer.complete(await _retry(pending.options));
        } catch (e) {
          pending.completer.completeError(e);
        }
      }
    } catch (refreshError) {
      for (final pending in _pendingRequests) {
        pending.completer.completeError(refreshError);
      }
      await _onSessionExpired();
      handler.next(err);
    } finally {
      _isRefreshing = false;
      _pendingRequests.clear();
    }
  }

  Future<Response> _retry(RequestOptions options) {
    return _dio.request(
      options.path,
      data: options.data,
      queryParameters: options.queryParameters,
      options: Options(
        method: options.method,
        headers: {
          ...options.headers,
          'Authorization': 'Bearer ${_storage.accessToken}',
        },
      ),
    );
  }
}

class _PendingRequest {
  final RequestOptions options;
  final Completer<Response> completer;
  _PendingRequest({required this.options, required this.completer});
}
