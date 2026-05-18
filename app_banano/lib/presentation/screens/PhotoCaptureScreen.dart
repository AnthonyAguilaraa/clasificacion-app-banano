import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart'; 
import '../../data/services/tflite_service.dart';
import '../../data/models/banana_type.dart';
import 'detail_screen.dart'; 

class PhotoCaptureScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  const PhotoCaptureScreen({Key? key, required this.cameras}) : super(key: key);

  @override
  _PhotoCaptureScreenState createState() => _PhotoCaptureScreenState();
}

class _PhotoCaptureScreenState extends State<PhotoCaptureScreen> {
  CameraController? controller;
  final TfliteService _tfliteService = TfliteService();
  
  bool isFlashOn = false;
  bool isTakingPicture = false; 

  @override
  void initState() {
    super.initState();
    _iniciarCamara();
    _tfliteService.loadModel();
  }

  void _iniciarCamara() async {
    if (widget.cameras.isEmpty) return;

    controller = CameraController(
      widget.cameras[0], 
      ResolutionPreset.high, 
      enableAudio: false
    );

    await controller!.initialize();
    await controller!.setFlashMode(FlashMode.off);
    await controller!.setFocusMode(FocusMode.locked); 

    if (mounted) setState(() {});
  }

  Future<void> _tomarYAnalizar() async {
    if (controller == null || !controller!.value.isInitialized || isTakingPicture) return;

    setState(() => isTakingPicture = true);

    try {
      // 1. Configurar flash si el usuario lo activó (modo linterna para enfocar bien)
      if (isFlashOn) {
        await controller!.setFlashMode(FlashMode.torch);
        await Future.delayed(const Duration(milliseconds: 300)); // Dar tiempo a la luz
      }

      // 2. Tomar la foto
      final XFile imageFile = await controller!.takePicture();
      
      // Apagar flash rápido
      if (isFlashOn) await controller!.setFlashMode(FlashMode.off);

      // 3. Analizar con el servicio 
      final File file = File(imageFile.path);
      final result = await _tfliteService.classifyImageFile(file);

      if (result != null && mounted) {
        final BananaType detectedType = BananaType.list.firstWhere(
          (t) => t.id == result['label'],
          orElse: () => BananaType.list[0] 
        );

        // 4. Navegar a la pantalla de resultado
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
          const SnackBar(content: Text("No se pudo clasificar la imagen.")) 
        );
      }

    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => isTakingPicture = false);
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    _tfliteService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller!.value.isInitialized) {
      return const Scaffold(backgroundColor: Colors.black, body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Cámara (Ocupa toda la pantalla)
          SizedBox.expand(
            child: CameraPreview(controller!),
          ),

          // 2. Botón de Flash (Arriba derecha)
          Positioned(
            top: 50, right: 20,
            child: CircleAvatar(
              backgroundColor: Colors.black45,
              child: IconButton(
                icon: Icon(isFlashOn ? Icons.flash_on : Icons.flash_off, color: Colors.yellow),
                onPressed: () {
                  setState(() => isFlashOn = !isFlashOn);
                },
              ),
            ),
          ),

          // 3. Botón de Volver (Arriba izquierda)
          Positioned(
            top: 50, left: 20,
            child: CircleAvatar(
              backgroundColor: Colors.black45,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          // 4. Botón Disparador
          Positioned(
            bottom: 40, left: 0, right: 0,
            child: Column(
              children: [
                if (isTakingPicture) 
                  const Padding(
                    padding: EdgeInsets.only(bottom: 20),
                    child: CircularProgressIndicator(color: Colors.yellow),
                  ),

                GestureDetector(
                  onTap: _tomarYAnalizar,
                  child: Container(
                    height: 80, width: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      color: Colors.white24,
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text("tap_to_analyze".tr(), style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold))
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------
// PANTALLA DE RESULTADO (Reutilizada y mejorada)
// ---------------------------------------------------
class PhotoResultScreen extends StatelessWidget {
  final File imageFile;
  final BananaType bananaType;
  final double confidence;

  const PhotoResultScreen({
    Key? key,
    required this.imageFile,
    required this.bananaType,
    required this.confidence,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Definir qué tan confiable es el resultado usando las traducciones
    String reliabilityMsg = "";
    Color reliabilityColor = Colors.grey;

    if (confidence > 0.85) {
      reliabilityMsg = "high_confidence".tr(); // 👈 Traducido
      reliabilityColor = Colors.green;
    } else if (confidence > 0.50) {
      reliabilityMsg = "med_confidence".tr(); // 👈 Traducido
      reliabilityColor = Colors.orange;
    } else {
      reliabilityMsg = "low_confidence".tr(); // 👈 Traducido
      reliabilityColor = Colors.red;
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("analysis_result".tr()), // 👈 Traducido
        backgroundColor: bananaType.color,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. La Foto Tomada
            Container(
              height: 350,
              width: double.infinity,
              color: Colors.black,
              child: Image.file(imageFile, fit: BoxFit.contain),
            ),

            // 2. Panel de Resultado
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    "ai_detected".tr(), // 👈 Traducido
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    bananaType.title.tr(), // 👈 Traducido el tipo de banano
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: bananaType.color,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 15),
                  
                  // Barra de Confianza
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: reliabilityColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: reliabilityColor),
                    ),
                    child: Text(
                      "$reliabilityMsg: ${(confidence * 100).toStringAsFixed(1)}%",
                      style: TextStyle(color: reliabilityColor, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // 3. Botón para ver detalles (Ficha técnica)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailScreen(bananaType: bananaType),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: bananaType.color,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 5
                      ),
                      icon: const Icon(Icons.info_outline, size: 28),
                      // 👇 Traducimos el texto del botón
                      label: Text("btn_recommendations".tr(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}