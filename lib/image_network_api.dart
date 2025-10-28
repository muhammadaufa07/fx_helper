import 'package:cached_network_image/cached_network_image.dart';
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
    if (noCache && url != null && url?.isNotEmpty == true) {
      CachedNetworkImage.evictFromCache(url!);
      print("Remove-cache: $url");
    }

    if (url == null || url?.isEmpty == true) {
      return _noImageIcon();
    }

    return CachedNetworkImage(
      cacheKey: url,
      imageUrl: url ?? "",
      placeholderFadeInDuration: Duration(milliseconds: 1000),
      fadeInDuration: Duration(milliseconds: 1000),
      fadeInCurve: Curves.fastEaseInToSlowEaseOut,
      width: width,
      height: height,
      placeholder:
          loadingBuilder ??
          (context, url) {
            /// show shimmer when image not ready
            return _shimmer(width ?? 0, width ?? 0);
          },
      httpHeaders: headers,
      imageBuilder: (context, imageProvider) {
        return Container(
          height: height ?? MediaQuery.sizeOf(context).height,
          decoration: BoxDecoration(
            image: DecorationImage(image: imageProvider, fit: fit ?? BoxFit.cover),
          ),
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
    return SizedBox(
      width: width,
      height: height,
      child: Image.asset("assets/images/img_no_image.png", fit: BoxFit.cover, package: 'fx_helper'),
    );
  }
}
