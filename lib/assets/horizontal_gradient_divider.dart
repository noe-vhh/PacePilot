// horizontal_gradient_divider.dart

import 'package:flutter/material.dart';

class HorizontalGradientDivider extends StatelessWidget {
  const HorizontalGradientDivider({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Container widget representing the horizontal gradient divider
    return Container(
      width: 340,
      height: 4,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: const LinearGradient(
          begin: Alignment(0.981, 0.0),
          end: Alignment(0.0, 0.000135811904),
          colors: [Color.fromRGBO(153, 188, 157, 1), Color.fromRGBO(89, 114, 111, 1)],
        ),
      ),
    );
  }
}