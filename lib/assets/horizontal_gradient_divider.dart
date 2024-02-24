// horizontal_gradient_divider.dart

import 'package:flutter/material.dart';

class HorizontalGradientDivider extends StatelessWidget {
  final double top;

  const HorizontalGradientDivider({
    Key? key,
    required this.top,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      // Position the divider at the specified 'top' position
      top: top,

      // Center the divider horizontally on the screen
      left: (MediaQuery.of(context).size.width - 340) / 2,

      // Container for the horizontal gradient divider
      child: Container(
        width: 340,
        height: 4,
        decoration: const BoxDecoration(
          boxShadow: [
            // Apply a shadow effect to the divider
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.25),
              offset: Offset(0, 4),
              blurRadius: 4,
            ),
          ],
          borderRadius: BorderRadius.all(Radius.circular(10)),
          gradient: LinearGradient(
            // Define the gradient colors for the divider
            begin: Alignment(0.98124098777771, -6.177054867606557e-9),
            end: Alignment(6.1788849592403494e-9, 0.00013581190432887524),
            colors: [
              Color.fromRGBO(153, 188, 157, 1),
              Color.fromRGBO(89, 114, 111, 1),
            ],
          ),
        ),
      ),
    );
  }
}
