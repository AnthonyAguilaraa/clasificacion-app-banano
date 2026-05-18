import 'package:flutter/material.dart';

class BananaType {
  final String id;
  final String title;
  final String description;
  final String cause;
  final String solution;
  final Color color;
  final IconData icon;
  final String assetPath; 

  const BananaType({
    required this.id,
    required this.title,
    required this.description,
    required this.cause,
    required this.solution,
    required this.color,
    required this.icon,
    required this.assetPath, 
  });

  static const List<BananaType> list = [
    BananaType(
      id: "apto",
      title: "type_apto_title",
      description: "type_apto_desc",
      cause: "type_apto_cause",
      solution: "type_apto_solution",
      color: Colors.green,
      icon: Icons.check_circle_outline,
      assetPath: "assets/images/apto.png", 
    ),
    BananaType(
      id: "cascara_partida",
      title: "type_cascara_partida_title",
      description: "type_cascara_partida_desc",
      cause: "type_cascara_partida_cause",
      solution: "type_cascara_partida_solution",
      color: Colors.orange,
      icon: Icons.broken_image_outlined,
      assetPath: "assets/images/cascara_partida.png",
    ),
    BananaType(
      id: "cicatriz_golpe",
      title: "type_cicatriz_golpe_title",
      description: "type_cicatriz_golpe_desc",
      cause: "type_cicatriz_golpe_cause",
      solution: "type_cicatriz_golpe_solution",
      color: Colors.brown,
      icon: Icons.healing,
      assetPath: "assets/images/cicatriz_golpe.png",
    ),
    BananaType(
      id: "corte_cuchareta",
      title: "type_corte_cuchareta_title",
      description: "type_corte_cuchareta_desc",
      cause: "type_corte_cuchareta_cause",
      solution: "type_corte_cuchareta_solution",
      color: Colors.redAccent,
      icon: Icons.cut,
      assetPath: "assets/images/corte_cuchareta.png",
    ),
    BananaType(
      id: "mal_formaciones",
      title: "type_mal_formaciones_title",
      description: "type_mal_formaciones_desc",
      cause: "type_mal_formaciones_cause",
      solution: "type_mal_formaciones_solution",
      color: Colors.purple,
      icon: Icons.gesture,
      assetPath: "assets/images/mal_formacion.png",
    ),
    BananaType(
      id: "marca_madurez",
      title: "type_marca_madurez_title",
      description: "type_marca_madurez_desc",
      cause: "type_marca_madurez_cause",
      solution: "type_marca_madurez_solution",
      color: Colors.amber,
      icon: Icons.wb_sunny,
      assetPath: "assets/images/marca_madurez.png",
    ),
    BananaType(
      id: "plaga_enfermedades",
      title: "type_plaga_enfermedades_title",
      description: "type_plaga_enfermedades_desc",
      cause: "type_plaga_enfermedades_cause",
      solution: "type_plaga_enfermedades_solution",
      color: Colors.blueGrey,
      icon: Icons.bug_report,
      assetPath: "assets/images/plaga_enfermedades.png",
    ),
  ];
}