import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart'; 
import '../../data/services/tflite_service.dart';
import '../../data/models/banana_type.dart'; 

class ScannerScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  const ScannerScreen({Key? key, required this.cameras}) : super(key: key);

  @override
  _ScannerScreenState createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  CameraController? controller;
  final TfliteService _tfliteService = TfliteService();
  
  // Estado del escáner
  bool isFlashOn = false;
  bool isProcessing = false;
  int frameCounter = 0;

  // Resultado
  BananaType? currentType; 
  double liveConfianza = 0.0;
  String? lastLabel;
  int stableCount = 0;

  @override
  void initState() {
    super.initState();
    _iniciar();
  }

  void _iniciar() async {
    await _tfliteService.loadModel();

    if (widget.cameras.isEmpty) return;

    controller = CameraController(
      widget.cameras[0], 
      ResolutionPreset.high, 
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid 
          ? ImageFormatGroup.yuv420 
          : ImageFormatGroup.bgra8888,
    );

    await controller!.initialize();
    await controller!.setFlashMode(FlashMode.off);

    if (!mounted) return;
    setState(() {});

    controller!.startImageStream((image) {
      frameCounter++;
      // Procesamos cada 15 frames (aprox 2 veces por segundo) para fluidez
      if (frameCounter % 15 == 0 && !isProcessing) {
        _procesar(image);
      }
    });
  }

  void _procesar(CameraImage image) async {
    isProcessing = true;
    try {
      var res = await _tfliteService.classifyFrame(image);
      
      if (mounted && res != null) {
        if (res['confidence'] >= 0.70) {

          if (res['label'] == lastLabel) {
            stableCount++;
          } else {
            stableCount = 0;
          }

          if (stableCount >= 2) {
            final detectedType = BananaType.list.firstWhere(
              (t) => t.id == res['label'],
              orElse: () => BananaType.list[0]
            );

            setState(() {
              currentType = detectedType;
              liveConfianza = res['confidence'];
            });
          }
          lastLabel = res['label'];
        } else {

           setState(() {
             liveConfianza = 0.0; 
           });
        }
      }
    } catch (e) {
      print("Error procesando frame: $e");
    } finally {
      isProcessing = false;
    }
  }

  void _toggleFlash() async {
    if (controller != null) {
      setState(() => isFlashOn = !isFlashOn);
      await controller!.setFlashMode(
        isFlashOn ? FlashMode.torch : FlashMode.off
      );
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

    // Lógica visual con Traducciones
    final bool hayDeteccion = liveConfianza > 0.0 && currentType != null;
    final String textoMostrar = hayDeteccion ? currentType!.title.tr().toUpperCase() : "aim_banana".tr();
    final Color colorMostrar = hayDeteccion ? currentType!.color : Colors.white;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. CÁMARA
          SizedBox.expand(
            child: CameraPreview(controller!),
          ),

          // 2. BOTÓN FLASH (Derecha Arriba)
          Positioned(
            top: 50, right: 20,
            child: CircleAvatar(
              backgroundColor: Colors.black45,
              child: IconButton(
                icon: Icon(isFlashOn ? Icons.flash_on : Icons.flash_off, color: Colors.yellow),
                onPressed: _toggleFlash,
              ),
            ),
          ),

          // 3. BOTÓN VOLVER (Izquierda Arriba)
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

          // 4. PANEL DE RESULTADOS (Abajo)
          Positioned(
            bottom: 30, left: 20, right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.black87.withOpacity(0.85),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colorMostrar.withOpacity(0.8), width: 3)
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "live_result".tr(), 
                    style: const TextStyle(color: Colors.grey, fontSize: 10, letterSpacing: 1.5)
                  ),
                  const SizedBox(height: 8),
                  
                  // Nombre del Defecto
                  Text(
                    textoMostrar,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colorMostrar,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 5),
                  
                  // Barra de confianza
                  if (hayDeteccion)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.analytics_outlined, color: Colors.white54, size: 14),
                        const SizedBox(width: 5),
                        Text(
                          "${'certainty'.tr()}: ${(liveConfianza * 100).toStringAsFixed(1)}%", // 👈 Traducimos "Certeza"
                          style: const TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    )
                  else
                     Text("focus_hint".tr(), style: const TextStyle(color: Colors.white38, fontSize: 12)) // 👈 Traducimos sugerencia
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}