import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ImageNetworkApi2 extends StatelessWidget {
  String? url;
  BoxFit? fit;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final Map<String, String>? headers;
  final Widget Function(BuildContext, String, Object?)? errorBuilder;
  ImageNetworkApi2(
    this.url, {
    super.key,
    this.fit,
    this.width,
    this.height,
    this.backgroundColor,
    this.headers,
    this.errorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    if (url == null || url?.isEmpty == true) {
      return _noImageIcon();
    }
    return CachedNetworkImage(
      imageUrl: url ?? "",

      width: width,
      height: height,
      placeholder: (context, url) {
        /// show shimmer when image not ready
        return _shimmer(width ?? 0, width ?? 0);
      },
      httpHeaders: headers,
      imageBuilder: (context, imageProvider) {
        return LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              height: height ?? (constraints.hasBoundedHeight ? constraints.biggest.height : constraints.biggest.width),
              decoration: BoxDecoration(
                image: DecorationImage(image: imageProvider, fit: fit),
              ),
            );
          },
        );
      },

      /// show no image icon when error
      errorWidget:
          errorBuilder ??
          (context, url, error) {
            return _noImageIcon();
          },
    );
  }

  Widget _shimmer(double width, double height) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade400,
      highlightColor: Colors.grey.shade200,
      child: Container(color: Colors.white, height: width, width: height),
    );
  }

  Widget _noImageIcon() {
    return FittedBox(
      child: Image.asset("assets/images/img_no_image.png", fit: BoxFit.cover, package: 'fx_helper'),
    );
  }
}
