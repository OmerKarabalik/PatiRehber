import 'package:flutter/material.dart';

/// Wraps any screen or modal content in a responsive container that:
/// 1. Stays 100% width on mobile phones (< 600px).
/// 2. Elegantly centers and limits width on tablets, foldables, and desktop (>= 600px).
class ResponsiveCenter extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;

  const ResponsiveCenter({
    super.key,
    required this.child,
    this.maxWidth = 720.0,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: padding != null
            ? Padding(padding: padding!, child: child)
            : child,
      ),
    );
  }
}
