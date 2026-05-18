// lib/main.dart
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:easy_localization/easy_localization.dart'; 
import 'presentation/screens/home_screen.dart';

List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized(); 
  
  try {
    cameras = await availableCameras();
  } catch (e) {
    print("Error detectando cámaras: $e");
  }

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('es', ''), Locale('en', '')],
      path: 'assets/translations', 
      fallbackLocale: const Locale('es', ''),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Banano IA',
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale, 
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.yellow, 
          primary: Colors.yellow[700],
          secondary: Colors.green
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: HomeScreen(cameras: cameras),
    );
  }
}