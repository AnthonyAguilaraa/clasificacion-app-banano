import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart'; 
import '../../data/models/banana_type.dart';

class DetailScreen extends StatelessWidget {
  final BananaType bananaType;

  const DetailScreen({Key? key, required this.bananaType}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], 
      appBar: AppBar(
        title: Text(
          bananaType.title.tr(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: bananaType.color,
        foregroundColor: Colors.white, 
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- 1. IMAGEN COMPLETA (Ficha Técnica) ---
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  bananaType.assetPath,
                  fit: BoxFit.contain, 
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      color: Colors.grey[200],
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(bananaType.icon, size: 50, color: Colors.grey),
                          const SizedBox(height: 10),
                          const Text("Imagen no disponible"), 
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 25),

            // --- 2. INFORMACIÓN DETALLADA ---
            _buildInfoSection(
              title: "detail_desc".tr(), 
              content: bananaType.description.tr(), 
              icon: Icons.info_outline,
              color: Colors.blueGrey,
            ),

            const SizedBox(height: 15),

            _buildInfoSection(
              title: "detail_cause".tr(), 
              content: bananaType.cause.tr(), 
              icon: Icons.help_outline,
              color: Colors.orange[800]!,
            ),

            const SizedBox(height: 15),

            // Tarjeta de Solución destacada
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.green.withOpacity(0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.task_alt, color: Colors.green, size: 28),
                      const SizedBox(width: 10),
                      Text(
                        "detail_action".tr(), 
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    bananaType.solution.tr(), 
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // Widget auxiliar para secciones de texto simples
  Widget _buildInfoSection({
    required String title,
    required String content,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 24, color: color),
              const SizedBox(width: 10),
              Text(
                title.toUpperCase(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}