import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ImageNetworkApi extends StatelessWidget {
  final String? url;
  final BoxFit? fit;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Clip? clipBehavior;
  final Map<String, String>? headers;
  final Widget Function(BuildContext, String, Object?)? errorBuilder;
  final Widget Function(BuildContext context, String url)? loadingBuilder;
  final Color? backgroundColor;
  final bool noCache;
  final bool isLoading;

  const ImageNetworkApi(
    this.url, {
    super.key,
    this.fit,
    this.width,
    this.height,
    this.borderRadius,
    this.clipBehavior,
    this.headers,
    this.errorBuilder,
    this.loadingBuilder,
    this.noCache = false,
    this.isLoading = false,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final cBehavior = borderRadius == null ? Clip.none : (clipBehavior ?? Clip.hardEdge);

    final shimmerSize = MediaQuery.sizeOf(context).shortestSide;

    final shimmerWidth = width ?? shimmerSize;
    final shimmerHeight = height ?? shimmerSize;

    if (noCache && url?.isNotEmpty == true) {
      CachedNetworkImage.evictFromCache(url!);

      if (kDebugMode) {
        print("Remove-cache: $url");
      }
    }

    if (url?.isEmpty ?? true) {
      return _noImageIcon(cBehavior);
    }

    if (isLoading) {
      return _shimmer(shimmerWidth, shimmerHeight, cBehavior);
    }

    return CachedNetworkImage(
      cacheKey: url,
      imageUrl: url!,
      httpHeaders: headers,
      placeholderFadeInDuration: const Duration(milliseconds: 1000),
      fadeInDuration: const Duration(milliseconds: 1000),
      fadeInCurve: Curves.fastEaseInToSlowEaseOut,

      placeholder:
          loadingBuilder ??
          (context, url) {
            return _shimmer(shimmerWidth, shimmerHeight, cBehavior);
          },

      imageBuilder: (context, imageProvider) {
        return ClipRRect(
          borderRadius: borderRadius ?? BorderRadius.zero,
          clipBehavior: cBehavior,
          child: Container(
            decoration: BoxDecoration(color: backgroundColor),
            child: Image(image: imageProvider, width: width, height: height, fit: fit),
          ),
        );
      },

      errorWidget:
          errorBuilder ??
          (context, url, error) {
            return _noImageIcon(cBehavior);
          },

      errorListener: (value) {
        try {
          if (kDebugMode) {
            print("\x1B[31mImage: $url \x1B[0m|\x1B[31m ${value.toString().replaceFirst(url ?? "", "~")} \x1B[0m");
          }
        } catch (_) {}
      },
    );
  }

  Widget _shimmer(double width, double height, Clip cBehavior) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade400,
      highlightColor: Colors.grey.shade200,
      child: Container(
        clipBehavior: cBehavior,
        width: width,
        height: height,
        decoration: BoxDecoration(color: Colors.white, borderRadius: borderRadius ?? BorderRadius.zero),
      ),
    );
  }

  Widget _noImageIcon(Clip cBehavior) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      clipBehavior: cBehavior,
      child: SizedBox(
        width: width,
        height: height,
        child: Image.asset("assets/images/img_no_image.png", fit: BoxFit.cover, package: 'fx_helper'),
      ),
    );
  }
}
