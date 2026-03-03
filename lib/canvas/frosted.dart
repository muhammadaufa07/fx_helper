import 'dart:ui';
import 'package:flutter/material.dart';

class Frosted extends StatelessWidget {
  final Widget child;
  final BorderRadius? borderRadius;
  final EdgeInsets? padding;
  final Color? color;
  final double? blurSigmaX;
  final double? blurSigmaY;

  const Frosted({
    /*  */
    super.key,
    required this.child,
    this.borderRadius,
    this.padding,
    this.color,
    this.blurSigmaX,
    this.blurSigmaY,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      clipBehavior: Clip.antiAlias,
      /*  */
      child: BackdropFilter(
        /*  */
        filter: ImageFilter.blur(
          /*  */
          sigmaX: blurSigmaX ?? 5.0,
          sigmaY: blurSigmaY ?? 5.0,
        ),
        child: Container(
          clipBehavior: Clip.antiAlias,
          padding: padding,
          decoration: BoxDecoration(
            /*  */
            borderRadius: borderRadius,
            gradient: LinearGradient(
              /*  */
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                /*  */
                Color.fromARGB(255, 227, 227, 227).withValues(alpha: 0.4),
                Color.fromARGB(255, 227, 227, 227).withValues(alpha: 0.5),
              ],
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
