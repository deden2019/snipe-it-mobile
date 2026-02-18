import 'package:flutter/material.dart';
import '../models/asset_model.dart';
import 'maintenance_form_screen.dart';
import 'maintenance_list_screen.dart';
import 'full_screen_image.dart';

class AssetDetailScreen extends StatelessWidget {
  final AssetModel asset;

  const AssetDetailScreen({super.key, required this.asset});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(title: Text(asset.assetTag)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =============================
            // 🔥 IMAGE SECTION
            // =============================
            GestureDetector(
              onTap: asset.hasImage
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              FullScreenImage(imageUrl: asset.image!),
                        ),
                      );
                    }
                  : null,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: asset.hasImage
                    ? Image.network(
                        asset.image!,
                        height: 220,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        height: 220,
                        width: double.infinity,
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.image,
                          size: 80,
                          color: Colors.grey,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 20),

            // =============================
            // 🔥 INFO CARD
            // =============================
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildInfo("Asset Tag", asset.assetTag),
                  buildInfo("Nama", asset.name ?? "-"),
                  buildInfo("Serial", asset.serial ?? "-"),
                  buildInfo("Lokasi", asset.locationName ?? "-"),
                  buildInfo("Kategori", asset.categoryName ?? "-"),

                  const SizedBox(height: 10),

                  // STATUS BADGE
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: asset.statusColor(),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      asset.statusLabel ?? "-",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // =============================
            // 🔥 BUTTONS
            // =============================
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MaintenanceFormScreen(
                        assetId: asset.id,
                        assetTag: asset.assetTag,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text("Buat Maintenance"),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MaintenanceListScreen(
                        assetId: asset.id,
                        assetTag: asset.assetTag,
                      ),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text("Lihat History"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
