import 'package:flutter/material.dart';

class AssetModel {
  final int id;
  final String assetTag;
  final String? name;
  final String? serial;
  final String? locationName;
  final String? categoryName;
  final String? statusLabel;
  final String? image; // 🔥 TAMBAHAN FOTO

  AssetModel({
    required this.id,
    required this.assetTag,
    this.name,
    this.serial,
    this.locationName,
    this.categoryName,
    this.statusLabel,
    this.image,
  });

  factory AssetModel.fromJson(Map<String, dynamic> json) {
    return AssetModel(
      id: json['id'] ?? 0,
      assetTag: json['asset_tag']?.toString() ?? '',
      name: json['name']?.toString(),
      serial: json['serial']?.toString(),

      // Handle nested safely
      locationName: json['location'] is Map
          ? json['location']['name']?.toString()
          : null,

      categoryName: json['category'] is Map
          ? json['category']['name']?.toString()
          : null,

      statusLabel: json['status_label'] is Map
          ? json['status_label']['name']?.toString()
          : json['status_label']?.toString(),

      image: json['image']?.toString(), // 🔥 ambil image dari API
    );
  }

  // =========================
  // STATUS COLOR LOGIC
  // =========================
  Color statusColor() {
    final status = statusLabel?.toLowerCase() ?? "";

    if (status.contains("deploy")) {
      return Colors.green;
    } else if (status.contains("repair")) {
      return Colors.orange;
    } else if (status.contains("broken")) {
      return Colors.red;
    } else if (status.contains("pending")) {
      return Colors.amber;
    } else {
      return Colors.grey;
    }
  }

  // Optional helper biar gampang cek ada gambar atau tidak
  bool get hasImage => image != null && image!.isNotEmpty;
}
