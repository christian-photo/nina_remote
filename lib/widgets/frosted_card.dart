import 'dart:ui';

import 'package:flutter/material.dart';

class FrostedCard extends StatelessWidget {
  const FrostedCard({super.key, required this.child, this.frost = 10.0, this.borderRadius = 10.0, this.opacity = 0.2});

  final Widget child;
  final double frost;
  final double borderRadius;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: frost, sigmaY: frost),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(opacity),
            borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
            border: Border.all(
              width: 2,
              color: Colors.white.withOpacity(0.2),
            )
          ),
          child: child,
        ),
      ),
    );
  }
}