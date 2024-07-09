import 'dart:ui';

import 'package:flutter/material.dart';

class FrostedCard extends StatelessWidget {
  const FrostedCard({super.key, required this.child, this.frost = 10.0, this.borderRadius = 10.0, this.decoration});

  final Widget child;
  final double frost;
  final double borderRadius;
  final BoxDecoration? decoration;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        decoration: decoration,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: frost, sigmaY: frost),
          child: child,
        ),
      ),
    );
  }
}