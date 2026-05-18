import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import '../../core/utils.dart';

class TfliteService {
  Interpreter? _interpreter;
  List<String> _labels = [];
  bool _isBusy = false;

  Future<void> loadModel() async {
    try {
      final options = InterpreterOptions();
      if (Platform.isAndroid) options.threads = 4;

      _interpreter = await Interpreter.fromAsset(
        'assets/models/banano_mobilenetv2.tflite', // Asegúrate que este sea el nombre correcto
        options: options
      );

      final labelData = await rootBundle.loadString('assets/models/labels.txt');
      _labels = labelData.split('\n').where((s) => s.isNotEmpty).toList();
      print("✅ Modelo cargado: $_labels");
    } catch (e) {
      print("❌ Error cargando modelo: $e");
    }
  }

  // OPCIÓN FINAL: VALORES CRUDOS [0 - 255]
  List<List<List<List<double>>>> _preprocesarImagen(img.Image image) {
    // 1. Resize directo (sin crop) para mantener la forma del banano
    img.Image resized = img.copyResize(image, width: 224, height: 224);

    // 2. SIN NORMALIZACIÓN EXTRA
    // Tu modelo Python tiene una capa interna 'preprocess_input'.
    // Esa capa espera recibir valores de 0 a 255.
    // Si nosotros dividimos aquí, rompemos la imagen.
    
    var input = List.generate(1, (i) => List.generate(224, (y) => List.generate(224, (x) {
      var pixel = resized.getPixel(x, y);
      
      return [
        pixel.r.toDouble(), // Valor directo (ej: 150.0)
        pixel.g.toDouble(), // Valor directo (ej: 200.0)
        pixel.b.toDouble()  // Valor directo (ej: 50.0)
      ];
    })));
    
    return input;
  }

  // 📸 Función para FOTOS ESTÁTICAS
  Future<Map<String, dynamic>?> classifyImageFile(File imageFile) async {
   if (_interpreter == null) return null;
    
    try {
      final bytes = await imageFile.readAsBytes();
      img.Image? originalImage = img.decodeImage(bytes);
      if (originalImage == null) return null;

      // Variables para guardar el mejor resultado de los 4 intentos
      Map<String, dynamic>? bestResult;
      double bestConfidence = -1.0;

      // PROBAR 4 ROTACIONES: 0°, 90°, 180°, 270°
      // Esto tarda unos milisegundos más, pero garantiza precisión.
      List<int> angles = [0, 90, 180, 270];

      print("\n🔍 --- INICIANDO SMART SCAN 360 ---");

      for (int angle in angles) {
        // Rotar imagen (si es 0, copyRotate lo maneja rápido)
        img.Image rotatedImg = (angle == 0) 
            ? originalImage 
            : img.copyRotate(originalImage, angle: angle);

        // Preprocesar
        var input = _preprocesarImagen(rotatedImg);
        
        // Ejecutar modelo
        var output = List.filled(1 * _labels.length, 0.0).reshape([1, _labels.length]);
        _interpreter!.run(input, output);
        
        // Procesar salida
        var res = _procesarSalida(output);
        double conf = res['confidence'];

        print("   Angulo $angle° -> Detectó: ${res['label']} (${(conf * 100).toStringAsFixed(1)}%)");

        // Nos quedamos con el resultado que tenga más certeza
        if (conf > bestConfidence) {
          bestConfidence = conf;
          bestResult = res;
        }
      }
      
      print("🏆 GANADOR: ${bestResult?['label']} con ${(bestConfidence * 100).toStringAsFixed(1)}%");
      print("--------------------------------------\n");

      return bestResult;

    } catch (e) {
      print("Error Smart Scan: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> classifyFrame(CameraImage cameraImage) async {
    if (_interpreter == null || _isBusy) return null;
    _isBusy = true;

    try {
      // Conversión YUV -> RGB
      img.Image? image = ImageUtils.convertCameraImage(cameraImage);
      if (image == null) return null;

      // Rotación necesaria para Android (generalmente 90 grados en modo portrait)
      if (Platform.isAndroid) {
        image = img.copyRotate(image, angle: 90);
      }

      // Preprocesamiento (Resize + Normalización [-1, 1])
      var input = _preprocesarImagen(image);

      // Preparar salida: [1, num_clases]
      // MobileNetV2 es Softmax, la suma de todo da 1.0
      var output = List.filled(1 * _labels.length, 0.0).reshape([1, _labels.length]);

      // Inferencia
      _interpreter!.run(input, output);

      // Procesar resultados
      return _procesarSalida(output);

    } catch (e) {
      print("❌ Error en inferencia: $e");
      return null;
    } finally {
      _isBusy = false;
    }
  }


  Map<String, dynamic> _procesarSalida(List<dynamic> output) {
    List<double> result = List<double>.from(output[0]);
    double maxScore = -1;
    int maxIndex = -1;

    for (int i = 0; i < result.length; i++) {
      if (result[i] > maxScore) {
        maxScore = result[i];
        maxIndex = i;
      }
    }

    if (maxIndex != -1 && maxIndex < _labels.length) {
      return {
        "label": _labels[maxIndex],
        "confidence": maxScore
      };
    } else {
      return {"label": "Desconocido", "confidence": 0.0};
    }
  }

  void dispose() {
    _interpreter?.close();
  }
}