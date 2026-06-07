import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ImageNetworkApi extends StatelessWidget {
  final String? url;
  final BoxFit? fit;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final Map<String, String>? headers;
  final Widget Function(BuildContext, String, Object?)? errorBuilder;
  final Widget Function(BuildContext context, String url)? loadingBuilder;
  final bool noCache;

  const ImageNetworkApi(
    this.url, {
    super.key,
    this.fit,
    this.width,
    this.height,
    this.backgroundColor,
    this.headers,
    this.errorBuilder,
    this.loadingBuilder,
    this.noCache = false,
  });

  @override
  Widget build(BuildContext context) {
    if (noCache && url?.isNotEmpty == true) {
      CachedNetworkImage.evictFromCache(url!);

      if (kDebugMode) {
        print("Remove-cache: $url");
      }
    }

    if (url?.isEmpty ?? true) {
      return _noImageIcon();
    }

    return CachedNetworkImage(
      cacheKey: url,
      imageUrl: url!,
      width: width,
      height: height,
      httpHeaders: headers,
      placeholderFadeInDuration: const Duration(milliseconds: 1000),
      fadeInDuration: const Duration(milliseconds: 1000),
      fadeInCurve: Curves.fastEaseInToSlowEaseOut,

      placeholder:
          loadingBuilder ??
          (context, url) {
            return _shimmer(width ?? 100, height ?? 100);
          },

      imageBuilder: (context, imageProvider) {
        return Image(image: imageProvider, width: width, height: height, fit: fit);
      },

      errorWidget:
          errorBuilder ??
          (context, url, error) {
            return _noImageIcon();
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

  Widget _shimmer(double width, double height) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade400,
      highlightColor: Colors.grey.shade200,
      child: Container(width: width, height: height, color: Colors.white),
    );
  }

  Widget _noImageIcon() {
    return SizedBox(
      width: width,
      height: height,
      child: Image.asset("assets/images/img_no_image.png", fit: BoxFit.cover, package: 'fx_helper'),
    );
  }
}
