import 'package:flutter/material.dart';

// Ein StatelessWidget, das verschiedene Layouts für Hoch- und Querformat bietet
class OrientationWidget extends StatelessWidget {
  const OrientationWidget({
    required this.portrait, // Widget für Hochformat
    required this.landscape, // Widget für Querformat
    super.key,
  });

  final Widget portrait;
  final Widget landscape;

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        // Gibt das entsprechende Widget basierend auf der aktuellen Ausrichtung zurück
        return orientation == Orientation.portrait ? portrait : landscape;
      }
    );
  }
}
