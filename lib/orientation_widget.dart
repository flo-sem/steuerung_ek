import 'package:flutter/material.dart';

class OrientationWidget extends StatelessWidget {
  const OrientationWidget({
    required this.portrait,
    required this.landscape,
    super.key,
  });

  final Widget portrait;
  final Widget landscape;


  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(builder: (context, orientation) {
      return orientation == Orientation.portrait ? portrait : landscape;
    });
  }
}