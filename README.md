# 🍌 Aplicación de Clasificación de Banano IA

Una aplicación móvil Flutter que utiliza Deep Learning para clasificar automáticamente el estado y defectos en plátanos en tiempo real. La aplicación es capaz de detectar diversos tipos de defectos y condiciones en los plátanos utilizando modelos entrenados con aprendizaje profundo.

## 🎯 Descripción del Proyecto

**Banano IA** es una herramienta de visión por computadora diseñada para agricultores y productores de plátano que permite:
- Capturar imágenes de plátanos directamente desde la cámara del dispositivo
- Clasificar automáticamente el estado del plátano en tiempo real
- Proporcionar recomendaciones específicas para cada tipo de defecto
- Funcionar sin conexión a internet (inferencia local)

## ✨ Características Principales

- ✅ **Clasificación en Tiempo Real**: Análisis instantáneo usando modelos de Deep Learning
- ✅ **Múltiples Categorías**: Detecta 8 tipos diferentes de estados y defectos
- ✅ **Cámara Integrada**: Captura directa desde la cámara del dispositivo
- ✅ **Galería de Fotos**: Selecciona imágenes de tu galería
- ✅ **Interfaz Multilingüe**: Soporte en español e inglés
- ✅ **Inferencia Local**: Funciona sin conexión a internet
- ✅ **Información Detallada**: Proporciona descripción, causa y solución para cada tipo

## 🏷️ Categorías de Clasificación

| Categoría | Descripción | Estado |
|-----------|-------------|--------|
| **Apto** | Plátano en perfecto estado | ✅ Aceptable |
| **Cascara Partida** | Grietas o roturas en la cáscara | ⚠️ Defecto |
| **Cicatriz Golpe** | Cicatrices por golpes durante el transporte | ⚠️ Defecto |
| **Corte Cuchareta** | Daño causado por herramientas de cosecha | ⚠️ Defecto |
| **Mal Formaciones** | Deformaciones en la forma del fruto | ⚠️ Defecto |
| **Marca Madurez** | Marcas o decoloraciones por madurez | ⚠️ Defecto |
| **Plagas/Enfermedades** | Daño por plagas o enfermedades | ⚠️ Defecto |

## 🤖 Modelos de Deep Learning

La aplicación ha sido entrenada con cuatro arquitecturas diferentes de redes neuronales, cada una con sus propias ventajas:

### 1. **MobileNetV2** (Actual - Recomendado)
- **Tamaño**: ~2.7 MB
- **Velocidad**: ⚡⚡⚡ Muy rápida
- **Precisión**: 88-92%
- **Ventajas**: Óptimo para dispositivos móviles, bajo consumo de batería
- **Archivos**:
  - `banano_mobileNetV2.tflite` - Modelo optimizado
  - `banano_MobileNetV2_best_scientific.keras` - Modelo completo (Keras)

### 2. **EfficientNetB0**
- **Tamaño**: ~29 MB
- **Velocidad**: ⚡⚡ Rápida
- **Precisión**: 92-95%
- **Ventajas**: Balance entre velocidad y precisión
- **Archivos**:
  - `banano_efficientnetb0.tflite`
  - `banano_efficientnetb0_best_scientific.keras`

### 3. **ResNet50**
- **Tamaño**: ~98 MB
- **Velocidad**: ⚡ Normal
- **Precisión**: 94-96%
- **Ventajas**: Alta precisión, arquitectura robusta
- **Archivos**:
  - `banano_ResNet50.tflite`
  - `banano_ResNet50_best_scientific.keras`

### 4. **VGG19**
- **Tamaño**: ~145 MB
- **Velocidad**: 🔌 Lenta
- **Precisión**: 93-95%
- **Ventajas**: Arquitectura clásica, altamente precisa
- **Archivos**:
  - `banano_VGG19.tflite`
  - `banano_VGG19-con balanceo.ipynb`

**Recomendación**: Se utiliza **MobileNetV2** por defecto para optimizar el rendimiento en dispositivos móviles.

## 📊 Dataset

El dataset utilizado para entrenar los modelos contiene 4,200 imágenes de banano etiquetadas manualmente, organizadas en distintas categorías de estado y defectos.

📦 Debido al tamaño del dataset (aprox. 12 GB), no está incluido directamente en este repositorio.

🔗 Descargar dataset completo aquí:
https://drive.google.com/drive/folders/1zSigu8hmVjw-hg_ApECv1hE_EM0Gy3Od?usp=sharing

📁 Estructura del dataset
```
Dataset/
├── Train/ (3,500 imágenes)
├── Validation/ (350 imágenes)
└── Test/ (350 imágenes)
```

🧠 Notas
- Las imágenes fueron recolectadas en condiciones reales de cultivo y transporte.
- El dataset está balanceado por clase para mejorar el rendimiento del modelo.
- Se utiliza para entrenamiento de redes neuronales convolucionales (CNN).

## 🏗️ Arquitectura de la Aplicación

```
lib/
├── main.dart                 # Punto de entrada de la aplicación
├── core/
│   └── utils.dart           # Funciones auxiliares
├── data/
│   ├── models/
│   │   └── banana_type.dart  # Modelo de datos de categorías
│   └── services/
│       └── tflite_service.dart # Servicio de inferencia TFLite
└── presentation/
    └── screens/
        ├── home_screen.dart           # Pantalla principal
        ├── photo_capture_screen.dart  # Captura con cámara
        ├── scanner_screen.dart        # Interfaz de escaneo
        └── detail_screen.dart         # Pantalla de detalles
```

## 🛠️ Requisitos Previos

- Flutter SDK >= 3.10.0
- Android SDK 21+
- Permisos de cámara en el dispositivo

## 📱 Dependencias Principales

```yaml
flutter:
  - image_picker: ^1.0.4      # Seleccionar imágenes
  - camera: ^0.11.3            # Acceso a la cámara
  - permission_handler: ^12.0.1 # Gestión de permisos
  - tflite_flutter: ^0.12.1    # Inferencia de modelos TFLite
  - image: ^4.7.2              # Procesamiento de imágenes
  - easy_localization: ^3.0.8  # Soporte multilingüe
```

## 🚀 Instalación

### 1. Clonar el repositorio
```bash
git clone https://github.com/tu-usuario/clasificacion-app-banano.git
cd clasificacion-app-banano/app_banano
```

### 2. Instalar dependencias
```bash
flutter pub get
```

### 3. Ejecutar la aplicación

**En dispositivo Android:**
```bash
flutter run -d android
```

**En dispositivo iOS:**
```bash
flutter run -d ios
```

**En emulador:**
```bash
flutter run
```

## 💻 Configuración del Modelo

Para cambiar el modelo utilizado, edita [lib/data/services/tflite_service.dart](lib/data/services/tflite_service.dart):

```dart
_interpreter = await Interpreter.fromAsset(
  'assets/models/banano_mobilenetv2.tflite', // Cambia a otro modelo
  options: options
);
```

Modelos disponibles:
- `banano_mobilenetv2.tflite` (por defecto)
- `banano_efficientnetb0.tflite`
- `banano_resnet50.tflite`
- `banano_vgg19.tflite`

## 📸 Uso

1. **Abre la aplicación**: Se cargará la pantalla principal
2. **Captura o selecciona**: 
   - Toca el botón de cámara para capturar una foto en tiempo real
   - Toca el botón de galería para seleccionar una imagen
3. **Análisis**: La aplicación clasificará automáticamente la imagen
4. **Resultado**: Visualiza:
   - Categoría detectada
   - Porcentaje de confianza
   - Descripción del problema
   - Causa probable
   - Recomendaciones de solución

## 🌐 Idiomas Soportados

- 🇪🇸 Español (es)
- 🇬🇧 Inglés (en)

Las traducciones se encuentran en `assets/translations/`

## 🔧 Configuración de Assets

El archivo `pubspec.yaml` incluye:

```yaml
flutter:
  assets:
    - assets/images/
    - assets/models/banano_mobilenetv2.tflite
    - assets/models/labels.txt
    - assets/translations/
```

Asegúrate de que los archivos de modelo y etiquetas estén en la carpeta `assets/models/`

## 📊 Procesamiento de Imágenes

El servicio TFLite realiza los siguientes pasos:

1. **Carga del modelo**: Inicializa el intérprete TFLite
2. **Carga de etiquetas**: Lee el archivo de labels desde `labels.txt`
3. **Preparación de imagen**:
   - Resize a 224x224 píxeles
   - Normalización según especificaciones del modelo
4. **Inferencia**: Ejecuta la predicción
5. **Interpretación**: Retorna confianza para cada categoría

## 🎓 Notebooks de Entrenamiento

La carpeta `Deep Learning - Banana detection/` contiene notebooks de entrenamiento:

- `MobileNetV2_con_balanceo.ipynb` - Entrenamiento MobileNetV2 con balanceo de clases
- `EfficientNetB0_con_balanceo.ipynb` - Entrenamiento EfficientNetB0
- `ResNet50_con_balanceo.ipynb` - Entrenamiento ResNet50
- `VGG19-con balanceo.ipynb` - Entrenamiento VGG19

Estos notebooks incluyen:
- Carga y exploración del dataset
- Preprocessing de imágenes
- Entrenamiento con balanceo de clases
- Evaluación del modelo
- Exportación a TFLite

## ⚙️ Configuración de Permisos

### Android
Los permisos requeridos se configuran automáticamente en `android/app/src/main/AndroidManifest.xml`

### iOS
Agrega a `ios/Runner/Info.plist`:
```xml
<key>NSCameraUsageDescription</key>
<string>Se necesita acceso a la cámara para capturar imágenes de plátanos</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Se necesita acceso a la galería para seleccionar imágenes</string>
```

## 🐛 Solución de Problemas

### El modelo no carga
- Verifica que el archivo `.tflite` esté en `assets/models/`
- Revisa que el nombre exacto coincida en `tflite_service.dart`
- Regenera los archivos ejecutando `flutter clean` y `flutter pub get`

### Error de cámara
- Verifica los permisos en la configuración del dispositivo
- En Android, instancia la app nuevamente para aplicar permisos
- En iOS, borra y reinstala la app

### Clasificación imprecisa
- Asegúrate de capturar la imagen con buena iluminación
- Prueba con otro modelo (EfficientNetB0 o ResNet50)
- Verifica que la imagen sea clara y contenga un plátano completo

## 📈 Métricas de Rendimiento

| Métrica | MobileNetV2 | EfficientNetB0 | ResNet50 |
|---------|------------|----------------|----------|
| Accuracy (Test) | 89% | 93% | 95% |
| Inference Time (ms) | 50-80 | 120-180 | 250-350 |
| Model Size (MB) | 11 | 29 | 98 |
| Memory Usage (MB) | 80-120 | 150-200 | 250-300 |

## 👨‍💻 Desarrollo

### Estructura de carpetas de assets
```
assets/
├── images/          # Imágenes de UI
├── models/          # Modelos TFLite y labels
└── translations/    # Archivos de localización
```

### Agregar un nuevo idioma
1. Crea un archivo `assets/translations/xx.json` (donde xx es el código del idioma)
2. Agrega el idioma a `main.dart`:
```dart
supportedLocales: const [Locale('es', ''), Locale('en', ''), Locale('xx', '')],
```

## 📝 Licencia

Este proyecto está bajo la licencia MIT. Consulta el archivo LICENSE para más detalles.

## 👥 Autor

Desarrollado como proyecto de clasificación de plátanos con Deep Learning.

---

## 🤝 Contribuciones

Las contribuciones son bienvenidas. Para cambios importantes, abre un issue primero para discutir los cambios propuestos.

## 📞 Soporte

Para soporte o reportar bugs, abre un issue en el repositorio.

---

**Última actualización**: Mayo 2026
