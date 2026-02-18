import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class MaintenanceFormScreen extends StatefulWidget {
  final int assetId;
  final String assetTag;

  const MaintenanceFormScreen({
    super.key,
    required this.assetId,
    required this.assetTag,
  });

  @override
  State<MaintenanceFormScreen> createState() => _MaintenanceFormScreenState();
}

class _MaintenanceFormScreenState extends State<MaintenanceFormScreen> {
  final _formKey = GlobalKey<FormState>();

  String maintenanceType = "repair";

  final TextEditingController nameController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  final ImagePicker picker = ImagePicker();
  File? selectedImage;

  bool loading = false;

  String todayDate() {
    final now = DateTime.now();
    return "${now.year}-"
        "${now.month.toString().padLeft(2, '0')}-"
        "${now.day.toString().padLeft(2, '0')}";
  }

  Future<void> pickImage() async {
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
      });
    }
  }

  Future<void> submitMaintenance() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      await ApiService.createMaintenanceWithPhoto(
        assetId: widget.assetId,
        maintenanceType: maintenanceType,
        name: nameController.text.trim(),
        startDate: todayDate(),
        notes: notesController.text.trim(),
        imageFile: selectedImage,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Maintenance berhasil dibuat"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Maintenance ${widget.assetTag}")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                value: maintenanceType,
                decoration: const InputDecoration(
                  labelText: "Type",
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: "repair", child: Text("Repair")),
                  DropdownMenuItem(
                    value: "inspection",
                    child: Text("Inspection"),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => maintenanceType = value);
                  }
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Nama Maintenance",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? "Nama wajib diisi" : null,
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: "Notes",
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
              ),

              const SizedBox(height: 20),

              selectedImage != null
                  ? Column(
                      children: [
                        Image.file(selectedImage!, height: 180),
                        const SizedBox(height: 8),
                      ],
                    )
                  : const Text("Belum ada foto", textAlign: TextAlign.center),

              const SizedBox(height: 8),

              OutlinedButton.icon(
                onPressed: pickImage,
                icon: const Icon(Icons.camera_alt),
                label: const Text("Ambil Foto"),
              ),

              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: loading ? null : submitMaintenance,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text("Submit"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
