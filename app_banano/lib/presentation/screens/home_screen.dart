import 'dart:io';
import 'package:app_banano/presentation/screens/PhotoCaptureScreen.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:easy_localization/easy_localization.dart'; 
import '../../data/models/banana_type.dart';
import '../../data/services/tflite_service.dart';
import 'scanner_screen.dart';
import 'detail_screen.dart';

class HomeScreen extends StatelessWidget {
  final List<CameraDescription> cameras;

  const HomeScreen({Key? key, required this.cameras}) : super(key: key);

  void _navigateTo(BuildContext context, Widget screen) {
    if (cameras.isNotEmpty) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No se encontró cámara disponible")));
    }
  }

  Future<void> _pickGalleryImage(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image == null) return; 

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: Colors.yellow)),
    );

    try {
      final TfliteService tfliteService = TfliteService();
      await tfliteService.loadModel();

      File file = File(image.path);
      var result = await tfliteService.classifyImageFile(file);
      
      tfliteService.dispose();
      Navigator.pop(context); 

      if (result != null) {
        final BananaType detectedType = BananaType.list.firstWhere(
          (t) => t.id == result['label'], 
          orElse: () => BananaType.list[0]
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PhotoResultScreen(
              imageFile: file,
              bananaType: detectedType,
              confidence: result['confidence'],
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text("No se pudo identificar la imagen."))
        );
      }
    } catch (e) {
      Navigator.pop(context); 
      print("Error galería: $e");
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text("Error al analizar: $e"))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<BananaType> bananaTypes = BananaType.list;

    return Scaffold(
      appBar: AppBar(
        title: Text("main_menu".tr(),
            style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.yellow[700],
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.language, color: Colors.black87), // El color oscuro de tu tema
            label: Text(
              "btn_language".tr(), 
              style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)
            ),
            onPressed: () {
              if (context.locale.languageCode == 'es') {
                context.setLocale(const Locale('en'));
              } else {
                context.setLocale(const Locale('es'));
              }
            },
          ),
          const SizedBox(width: 8), 
        ],
      ),
      body: Column(
        children: [
          // --- SECCIÓN 1: GUÍA ---
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
            child: Text(
              "guide_title".tr(),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.8,
              ),
              itemCount: bananaTypes.length,
              itemBuilder: (context, index) =>
                  _buildInfoCard(context, bananaTypes[index]),
            ),
          ),

          // --- SECCIÓN 2: BOTONES DE ACCIÓN ---
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0,-5))]
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text("select_tool".tr(), style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        context: context,
                        icon: Icons.view_in_ar,
                        label: "btn_scanner".tr(),
                        color: Colors.blueAccent,
                        onTap: () => _navigateTo(context, ScannerScreen(cameras: cameras)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildActionButton(
                        context: context,
                        icon: Icons.camera_alt,
                        label: "btn_photo".tr(),
                        color: Colors.orangeAccent,
                        onTap: () => _navigateTo(context, PhotoCaptureScreen(cameras: cameras)),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 10),

                _buildActionButton(
                  context: context,
                  icon: Icons.photo_library,
                  label: "btn_gallery".tr(), 
                  color: Colors.purpleAccent,
                  onTap: () => _pickGalleryImage(context), 
                ),

                const SizedBox(height: 10),

              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap
  }) {
    return ElevatedButton.icon(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
      ),
      icon: Icon(icon, size: 28),
      label: Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildInfoCard(BuildContext context, BananaType item) {
       return InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
            builder: (context) => DetailScreen(bananaType: item),
            ),
        );
        },
        child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        color: Colors.white,
        child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
                Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: item.color.withOpacity(0.1),
                    shape: BoxShape.circle,
                ),
                child: Hero(
                    tag: item.title, 
                    child: Icon(
                    item.icon,
                    size: 40,
                    color: item.color,
                    ),
                ),
                ),
                const SizedBox(height: 10),
                Text(
                item.title.tr(),
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: item.color,
                ),
                ),
                const SizedBox(height: 5),
                Text(
                item.description.tr(),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                ),
            ],
            ),
        ),
        ),
    );
  }
}