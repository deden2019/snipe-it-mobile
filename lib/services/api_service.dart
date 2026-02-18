import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/asset_model.dart';
import 'auth_service.dart';

class ApiService {
  static const String baseUrl = "https://domainserverkalian-ya/api/v1";

  static Future<Map<String, String>> _headers() async {
    final token = await AuthService.getToken();

    if (token == null) {
      throw Exception("Token tidak ditemukan. Silakan login ulang.");
    }

    return {"Authorization": "Bearer $token", "Accept": "application/json"};
  }

  // ===============================
  // GET ASSETS
  // ===============================
  static Future<List<AssetModel>> getAssets() async {
    final headers = await _headers();

    final response = await http.get(
      Uri.parse("$baseUrl/hardware"),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List rows = data['rows'];

      return rows.map((e) => AssetModel.fromJson(e)).toList();
    } else {
      throw Exception("Gagal ambil asset (${response.statusCode})");
    }
  }

  // ===============================
  // CREATE MAINTENANCE TANPA FOTO
  // ===============================
  static Future<void> createMaintenance({
    required int assetId,
    required String maintenanceType,
    required String name,
    required String startDate,
    required String notes,
  }) async {
    final headers = await _headers();

    final response = await http.post(
      Uri.parse("$baseUrl/maintenances"),
      headers: headers,
      body: {
        "asset_id": assetId.toString(),
        "asset_maintenance_type": maintenanceType,
        "name": name,
        "start_date": startDate,
        "notes": notes,
      },
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception("Gagal create maintenance");
    }
  }

  // ===============================
  // CREATE MAINTENANCE + FOTO
  // ===============================
  static Future<void> createMaintenanceWithPhoto({
    required int assetId,
    required String maintenanceType,
    required String name,
    required String startDate,
    required String notes,
    File? imageFile,
  }) async {
    final token = await AuthService.getToken();

    if (token == null) {
      throw Exception("Token tidak ditemukan");
    }

    var request = http.MultipartRequest(
      'POST',
      Uri.parse("$baseUrl/maintenances"),
    );

    request.headers.addAll({
      "Authorization": "Bearer $token",
      "Accept": "application/json",
    });

    request.fields['asset_id'] = assetId.toString();
    request.fields['asset_maintenance_type'] = maintenanceType;
    request.fields['name'] = name;
    request.fields['start_date'] = startDate;
    request.fields['notes'] = notes;

    if (imageFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );
    }

    final response = await request.send();

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception("Gagal upload maintenance");
    }
  }

  // ===============================
  // GET MAINTENANCE BY ASSET
  // ===============================
  static Future<List<dynamic>> getMaintenanceByAsset(int assetId) async {
    final headers = await _headers();

    final response = await http.get(
      Uri.parse("$baseUrl/maintenances?asset_id=$assetId"),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['rows'] ?? [];
    } else {
      throw Exception("Gagal ambil maintenance");
    }
  }

  // ===============================
  // GET MAINTENANCE TODAY COUNT
  // ===============================
  static Future<int> getMaintenanceTodayCount() async {
    final headers = await _headers();

    final response = await http.get(
      Uri.parse("$baseUrl/maintenances"),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List rows = data['rows'] ?? [];

      final today = DateTime.now();
      final todayString =
          "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

      final todayMaintenances = rows.where((m) {
        final startDate = m['start_date'];

        if (startDate == null) return false;

        // Format Snipe-IT kadang object {date: "..."}
        if (startDate is Map && startDate['date'] != null) {
          return startDate['date'] == todayString;
        }

        // Kalau string biasa
        if (startDate is String) {
          return startDate.startsWith(todayString);
        }

        return false;
      }).toList();

      return todayMaintenances.length;
    } else {
      throw Exception("Gagal ambil maintenance hari ini");
    }
  }
}
