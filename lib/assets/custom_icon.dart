// custom_icon.dart

import 'package:flutter/material.dart';

class CustomIcon extends StatefulWidget {
  final String imagePath;
  final VoidCallback onTap;
  final bool isClicked;

  const CustomIcon({
    required this.imagePath,
    required this.onTap,
    this.isClicked = false,
    Key? key,
  }) : super(key: key);

  @override
  CustomIconState createState() => CustomIconState();
}

class CustomIconState extends State<CustomIcon> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          color: widget.isClicked ? Colors.grey : Colors.white,
          border: Border.all(
            color: const Color.fromRGBO(0, 0, 0, 1),
            width: 1,
          ),
        ),
        child: Stack(
          children: <Widget>[
            Positioned(
              top: 6,
              left: 7,
              child: Container(
                width: 27,
                height: 28,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(widget.imagePath),
                    fit: BoxFit.fitWidth,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}