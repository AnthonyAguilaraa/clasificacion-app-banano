import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;

class ImageUtils {
  static img.Image? convertCameraImage(CameraImage cameraImage) {
    if (cameraImage.format.group == ImageFormatGroup.yuv420) {
      return _convertYUV420(cameraImage);
    } else if (cameraImage.format.group == ImageFormatGroup.bgra8888) {
      return _convertBGRA8888(cameraImage);
    } else {
      return null;
    }
  }

  static img.Image _convertBGRA8888(CameraImage cameraImage) {
    return img.Image.fromBytes(
      width: cameraImage.width,
      height: cameraImage.height,
      bytes: cameraImage.planes[0].bytes.buffer,
      order: img.ChannelOrder.bgra,
    );
  }

  static img.Image _convertYUV420(CameraImage cameraImage) {
    final int width = cameraImage.width;
    final int height = cameraImage.height;
    
    final int uvRowStride = cameraImage.planes[1].bytesPerRow;
    final int? uvPixelStride = cameraImage.planes[1].bytesPerPixel;
    
    // Creamos una imagen vacía
    final img.Image image = img.Image(width: width, height: height);

    // Recorremos pixel por pixel
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        // 1. Obtener el índice correcto del plano Y (Luminosidad)
        // La clave del éxito: usar bytesPerRow para saltar el relleno
        final int yIndex = y * cameraImage.planes[0].bytesPerRow + x;
        
        // 2. Obtener el índice correcto de los planos UV (Color)
        // Los planos UV suelen ser subsampleados (mitad de tamaño)
        final int uvIndex = uvPixelStride! * (x / 2).floor() + uvRowStride * (y / 2).floor();

        // 3. Extraer los bytes (asegurando que no nos salgamos del array)
        final int yValue = cameraImage.planes[0].bytes[yIndex];
        final int uValue = cameraImage.planes[1].bytes[uvIndex];
        final int vValue = cameraImage.planes[2].bytes[uvIndex];

        // 4. Conversión YUV a RGB
        int r = (yValue + (1.370705 * (vValue - 128))).toInt();
        int g = (yValue - (0.337633 * (uValue - 128)) - (0.698001 * (vValue - 128))).toInt();
        int b = (yValue + (1.732446 * (uValue - 128))).toInt();

        // Clampear valores entre 0 y 255 (para evitar colores locos)
        r = r.clamp(0, 255);
        g = g.clamp(0, 255);
        b = b.clamp(0, 255);

        // 5. Guardar en la imagen final
        image.setPixelRgb(x, y, r, g, b);
      }
    }
    return image;
  }
}