import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// A widget that shows a **shimmer effect placeholder** while loading,
/// and displays the actual [child] when data is available.
///
/// Useful for loading states in lists, cards, or other UI elements.
class ShimmerRectangle extends StatelessWidget {
  /// The height of the shimmer container.
  final double? height;

  /// The width of the shimmer container.
  final double? width;

  /// The minimum width constraint for the shimmer container.
  final double? minWidth;

  /// The minimum height constraint for the shimmer container.
  final double? minHeight;

  /// Determines whether the shimmer effect should be shown (`true`) or
  /// the actual [child] should be displayed (`false`).
  final bool isLoading;

  /// The border radius of the shimmer container.
  final BorderRadius? borderRadius;

  /// The child widget to display when not loading.
  final Widget child;

  /// Creates a [ShimmerRectangle] widget.
  ///
  /// Example:
  /// ```dart
  /// ShimmerRectangle(
  ///   isLoading: false,
  ///   child: Text('Loaded content'),
  /// )
  /// ```
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

/// A simpler shimmer widget for **rectangular or circular placeholders**.
///
/// Can be used when you only need a fixed shimmer rectangle or circle
/// without wrapping another widget.
class ShimmerWidget extends StatelessWidget {
  /// The width of the shimmer widget.
  final double width;

  /// The height of the shimmer widget.
  final double height;

  /// The border radius of the shimmer widget.
  /// For circular shimmer, use a large radius.
  final double radius;

  /// Creates a rectangular shimmer widget.
  ///
  /// Example:
  /// ```dart
  /// ShimmerWidget.rectangular(
  ///   height: 20,
  ///   width: 100,
  /// )
  /// ```
  const ShimmerWidget.rectangular({super.key, this.width = double.infinity, required this.height, this.radius = 12});

  /// Creates a circular shimmer widget.
  ///
  /// Example:
  /// ```dart
  /// ShimmerWidget.circular(
  ///   height: 50,
  ///   width: 50,
  /// )
  /// ```
  const ShimmerWidget.circular({super.key, this.width = double.infinity, required this.height, this.radius = 1000});

  @override
  Widget build(BuildContext context) => Shimmer.fromColors(
    baseColor: const Color(0xFFBEBEBE),
    highlightColor: Colors.grey[300]!,
    period: Duration(seconds: 2),
    child: Container(
      width: width,
      height: height,
      decoration: BoxDecoration(color: Colors.grey[400]!, borderRadius: BorderRadius.circular(radius)),
    ),
  );
}
