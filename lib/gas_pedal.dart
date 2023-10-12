import 'package:flutter/material.dart';

class GasPedal extends StatefulWidget {
  const GasPedal({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _GasPedalState();
}

class _GasPedalState extends State<GasPedal> {
  double status = 0;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget> [
        Align(
            alignment: Alignment.bottomRight,
            child: SizedBox(
                height: 240,
                width: 130,
                child: Center(
                    child: GestureDetector(
                        onTapDown: (_) => setState(() {status = 1;}),
                        onTapUp: (_) => setState(() {status = 0;}),
                        child: Transform(
                            transform: Matrix4.rotationX(0.3*status),
                            child: Image.asset('assets/images/gasPedal.png', height: 170)
                        )
                    )
                )
            )
        ),
        Align(
          alignment: Alignment.topRight,
          child: Text('$status', style: Theme.of(context).textTheme.headlineLarge,),
        )
      ],
    );
  }
}