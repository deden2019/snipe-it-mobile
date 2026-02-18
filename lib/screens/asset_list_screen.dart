import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/asset_model.dart';
import 'asset_detail_screen.dart';
import 'barcode_scanner_screen.dart';

class AssetListScreen extends StatefulWidget {
  const AssetListScreen({super.key});

  @override
  State<AssetListScreen> createState() => _AssetListScreenState();
}

class _AssetListScreenState extends State<AssetListScreen> {
  List<AssetModel> assets = [];
  List<AssetModel> filteredAssets = [];

  bool loading = true;
  String selectedStatus = "All";

  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchAssets();
  }

  Future<void> fetchAssets() async {
    try {
      final data = await ApiService.getAssets();

      setState(() {
        assets = data;
        filteredAssets = data;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
    }
  }

  void applyFilters() {
    final search = searchController.text.toLowerCase();

    setState(() {
      filteredAssets = assets.where((asset) {
        final tag = asset.assetTag.toLowerCase();
        final name = (asset.name ?? "").toLowerCase();
        final location = (asset.locationName ?? "").toLowerCase();
        final status = (asset.statusLabel ?? "").toLowerCase();

        final matchSearch =
            tag.contains(search) ||
            name.contains(search) ||
            location.contains(search);

        final matchStatus = selectedStatus == "All"
            ? true
            : status.contains(selectedStatus.toLowerCase());

        return matchSearch && matchStatus;
      }).toList();
    });
  }

  Future<void> openScanner() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const BarcodeScannerScreen()),
    );

    if (result != null) {
      searchController.text = result;
      applyFilters();
    }
  }

  Widget buildAssetCard(AssetModel asset) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => AssetDetailScreen(asset: asset)),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              asset.assetTag,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              asset.locationName ?? "-",
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 6),
            Chip(
              label: Text(asset.categoryName ?? "-"),
              backgroundColor: Colors.grey.shade200,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: asset.statusColor(),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                asset.statusLabel ?? "-",
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text("Daftar Asset"),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: openScanner,
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: fetchAssets,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    /// SEARCH
                    TextField(
                      controller: searchController,
                      onChanged: (_) => applyFilters(),
                      decoration: InputDecoration(
                        hintText: "Cari asset / lokasi / nama...",
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    /// STATUS FILTER
                    Row(
                      children: [
                        const Text("Status: "),
                        const SizedBox(width: 10),
                        DropdownButton<String>(
                          value: selectedStatus,
                          items: const [
                            DropdownMenuItem(value: "All", child: Text("All")),
                            DropdownMenuItem(
                              value: "Ready",
                              child: Text("Ready"),
                            ),
                            DropdownMenuItem(
                              value: "Pending",
                              child: Text("Pending"),
                            ),
                            DropdownMenuItem(
                              value: "Broken",
                              child: Text("Broken"),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              selectedStatus = value!;
                              applyFilters();
                            });
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    Expanded(
                      child: filteredAssets.isEmpty
                          ? const Center(
                              child: Text("Tidak ada asset ditemukan"),
                            )
                          : ListView.builder(
                              itemCount: filteredAssets.length,
                              itemBuilder: (context, index) {
                                return buildAssetCard(filteredAssets[index]);
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
