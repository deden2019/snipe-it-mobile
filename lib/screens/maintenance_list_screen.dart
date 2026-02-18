import 'package:flutter/material.dart';
import '../services/api_service.dart';

class MaintenanceListScreen extends StatefulWidget {
  final int assetId;
  final String assetTag;

  const MaintenanceListScreen({
    super.key,
    required this.assetId,
    required this.assetTag,
  });

  @override
  State<MaintenanceListScreen> createState() => _MaintenanceListScreenState();
}

class _MaintenanceListScreenState extends State<MaintenanceListScreen> {
  List maintenances = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchMaintenances();
  }

  Future<void> fetchMaintenances() async {
    try {
      final data = await ApiService.getMaintenanceByAsset(widget.assetId);

      setState(() {
        maintenances = data;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("History ${widget.assetTag}")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : maintenances.isEmpty
          ? const Center(child: Text("Belum ada maintenance"))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: maintenances.length,
              itemBuilder: (context, index) {
                final maintenance = maintenances[index];

                return Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          maintenance['name'] ?? '-',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Type: ${maintenance['asset_maintenance_type'] ?? '-'}",
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Tanggal: ${maintenance['start_date']?['formatted'] ?? '-'}",
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
