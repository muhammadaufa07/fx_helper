import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerRectangle extends StatelessWidget {
  final double? height;
  final double? width;
  final double? minWidth;
  final double? minHeight;
  final bool isLoading;
  final BorderRadius? borderRadius;
  final Widget child;

  const ShimmerRectangle({
    super.key,
    this.height,
    this.width,
    this.minHeight,
    this.minWidth,
    this.borderRadius,
    required this.isLoading,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Shimmer.fromColors(
            baseColor: Colors.grey.shade200,
            highlightColor: Colors.grey.shade400,
            child: Container(
              constraints: BoxConstraints(
                minHeight: minHeight ?? 16,
                minWidth: minWidth ?? MediaQuery.sizeOf(context).width / 5,
              ),
              clipBehavior: Clip.antiAlias,
              width: width,
              height: height,
              decoration: BoxDecoration(color: Colors.white, borderRadius: borderRadius),
              child: child,
            ),
          )
        : child;
  }
}
