// Anabhay Ventures — Shared Services (API, Network, Storage, WebSockets)

library shared_services;

import 'dart:async';
import 'package:dio/dio.dart';
import 'package:shared_models/shared_models.dart';

class ApiConfig {
  static const String defaultBaseUrl = 'http://localhost:8085/api/v1';
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
}

class ApiClient {
  late final Dio _dio;
  String? _authToken;
  String? _tenantId;
  String? _branchId;

  ApiClient({String baseUrl = ApiConfig.defaultBaseUrl}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-App-Platform': 'Restaurant-Management-OS',
          'X-App-Vendor': 'Anabhay-Ventures',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_authToken != null) {
            options.headers['Authorization'] = 'Bearer $_authToken';
          }
          if (_tenantId != null) {
            options.headers['X-Tenant-ID'] = _tenantId;
          }
          if (_branchId != null) {
            options.headers['X-Branch-ID'] = _branchId;
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) {
          // Centralized error handling
          return handler.next(error);
        },
      ),
    );
  }

  void setAuthCredentials({String? token, String? tenantId, String? branchId}) {
    _authToken = token;
    _tenantId = tenantId;
    _branchId = branchId;
  }

  void clearAuthCredentials() {
    _authToken = null;
    _tenantId = null;
    _branchId = null;
  }

  // ── Health Check ──────────────────────────────────────────
  Future<Map<String, dynamic>> checkHealth() async {
    final response = await _dio.get('/health');
    return response.data as Map<String, dynamic>;
  }

  // ── Authentication ────────────────────────────────────────
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    return response.data as Map<String, dynamic>;
  }

  // ── Dashboard Metrics ─────────────────────────────────────
  Future<Map<String, dynamic>> getDashboardSummary() async {
    final response = await _dio.get('/dashboard/summary');
    return response.data as Map<String, dynamic>;
  }

  // ── Generic REST Helpers ──────────────────────────────────
  Future<Response<T>> get<T>(String path, {Map<String, dynamic>? queryParameters}) {
    return _dio.get<T>(path, queryParameters: queryParameters);
  }

  Future<Response<T>> post<T>(String path, {dynamic data}) {
    return _dio.post<T>(path, data: data);
  }

  Future<Response<T>> put<T>(String path, {dynamic data}) {
    return _dio.put<T>(path, data: data);
  }

  Future<Response<T>> delete<T>(String path) {
    return _dio.delete<T>(path);
  }
}

// ── Realtime Event Hub ──────────────────────────────────────
class RealtimeEventHub {
  static final RealtimeEventHub _instance = RealtimeEventHub._internal();
  factory RealtimeEventHub() => _instance;
  RealtimeEventHub._internal();

  final _orderStreamController = StreamController<Order>.broadcast();
  final _tableStreamController = StreamController<RestaurantTable>.broadcast();

  Stream<Order> get onOrderUpdated => _orderStreamController.stream;
  Stream<RestaurantTable> get onTableUpdated => _tableStreamController.stream;

  void emitOrderUpdate(Order order) {
    _orderStreamController.add(order);
  }

  void emitTableUpdate(RestaurantTable table) {
    _tableStreamController.add(table);
  }

  void dispose() {
    _orderStreamController.close();
    _tableStreamController.close();
  }
}

