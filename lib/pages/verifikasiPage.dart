import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/verifikasiController.dart';
import '../routes/route.dart';

class VerifikasiPage extends StatelessWidget {
  VerifikasiPage({super.key});

  final controller = Get.put(VerifikasiController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EDE2),
      appBar: AppBar(
        title: const Text("Verifikasi Lokasi"),
        backgroundColor: const Color(0xFFF5EDE2),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              height: 200,
              color: Colors.orange[200],
              child: const Center(child: Text("Preview")),
            ),
            const SizedBox(height: 20),
            Obx(() => Text(controller.alamat.value)),
            Obx(() => Text(controller.koordinat.value)),
            Obx(() => Text(controller.status.value)),
            const Spacer(),
            ElevatedButton(
              onPressed: () {Get.offAllNamed(AppRoutes.mainPage);},
              child: const Text("Selesaikan"),
            )
          ],
        ),
      ),
    );
  }
}