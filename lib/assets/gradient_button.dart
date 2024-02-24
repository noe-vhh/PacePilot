// gradient_button.dart

import 'package:flutter/material.dart';
import '../assets/theme.dart';

// A custom button with a gradient background
class GradientButton extends StatelessWidget {
  // Callback function to be executed when the button is pressed
  final VoidCallback onPressed;

  // Text to be displayed on the button
  final String text;

  // Optional style for the button
  final ButtonStyle? style;

  // Constructor to initialize the button properties
  const GradientButton({
    Key? key,
    required this.onPressed,
    required this.text,
    this.style,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // The container serves as the background for the button
    return Container(
      width: 120,
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        // Gradient background for the button
        gradient: const LinearGradient(
          begin: Alignment(0.98124098777771, -6.177054867606557e-9),
          end: Alignment(6.1788849592403494e-9, 0.00013581190432887524),
          colors: [
            Color.fromRGBO(153, 188, 157, 1),
            Color.fromRGBO(89, 114, 111, 1),
          ],
        ),
      ),
      // The MaterialButton is used to handle button interactions
      child: MaterialButton(
        onPressed: onPressed,
        padding: const EdgeInsets.all(0),
        // Centered text within the button
        child: Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
            // Styling for the button text
            style: AppTheme.labelText.copyWith(
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}