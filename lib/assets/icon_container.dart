// icon_container.dart

import 'package:flutter/material.dart';
import '/../assets/theme.dart';

class IconContainer extends StatelessWidget {
  final double top;
  
  const IconContainer({required this.top, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: MediaQuery.of(context).size.width / 2 - 160,
      child: Container(
        width: 320,
        height: 53,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          boxShadow: [AppTheme.defaultBoxShadow],
          color: Colors.white,
        ),
      ),
    );
  }
}