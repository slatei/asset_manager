import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import '../models/asset.dart';

class ApiService extends ChangeNotifier {
  final String baseUrl = 'http://localhost:5000/api';
  final Dio dio = Dio(); // Create a Dio instance
  late DioAdapter dioAdapter; // Mark dioAdapter as late

  ApiService() {
    dioAdapter = DioAdapter(dio: dio); // Initialize the adapter
    _setupMockServer(); // Setup the mock server
  }

  void _setupMockServer() {
    // Mock GET /assets
    dioAdapter.onGet(
      '$baseUrl/assets',
      (server) => server.reply(200, {
        'data': [
          {
            'id': 1,
            'name': 'Laptop',
            'category': 'Technology',
            'purchase_date': '2023-01-15',
            'cost': 1200.00,
            'photo_path': null,
          },
          {
            'id': 2,
            'name': 'Desk',
            'category': 'Furniture',
            'purchase_date': '2022-05-10',
            'cost': 300.00,
            'photo_path': null,
          },
        ],
      }),
    );

    // Mock POST /assets
    dioAdapter.onPost(
      '$baseUrl/assets',
      (server) => server.reply(201, {
        'id': 3,
        'name': 'Chair',
        'category': 'Furniture',
        'purchase_date': '2022-05-12',
        'cost': 150.00,
        'photo_path': null,
      }),
    );

    // Add more mock routes as needed
  }

  Future<List<Asset>> fetchAssets() async {
    final response = await dio.get('$baseUrl/assets');

    if (response.statusCode == 200) {
      List jsonResponse = response.data['data'];
      return jsonResponse.map((asset) => Asset.fromJson(asset)).toList();
    } else {
      throw Exception('Failed to load assets');
    }
  }

  Future<Asset> addAsset(Asset asset) async {
    final response = await dio.post(
      '$baseUrl/assets',
      data: jsonEncode(asset.toJson()),
      options: Options(headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      }),
    );

    if (response.statusCode == 201) {
      return Asset.fromJson(response.data);
    } else {
      throw Exception('Failed to add asset');
    }
  }

  // Update and delete methods can be added similarly
}
