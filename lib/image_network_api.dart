import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fx_helper/view_photo_page.dart';
import 'package:fx_helper/widgets/fx_theme.dart';
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
  final bool openView;

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
    this.openView = false,
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

    var imageWidget = CachedNetworkImage(
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

    if (openView == true) {
      return InkWell(
        borderRadius: borderRadius ?? BorderRadius.zero,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ViewImagePage(photoUrl: url, headers: headers),
            ),
          );
        },
        child: imageWidget,
      );
    }

    return imageWidget;
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

/* 
  === === === === === === === === === === === === === === === === === === === 
               EXPERIMENT ONLY, NOT A COMPLETE CODE YET!!
  === === === === === === === === === === === === === === === === === === ===
  
  ImageNetworkApi2 this class placed in here to simplified changing
  ImageNetworkApi to ImageNetworkApi2 without importing the class
  
  ImageNetworkApi2 is complete copy of ImageNetworkApi
  
 */

class ImageNetworkApi2 extends StatefulWidget {
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

  const ImageNetworkApi2(
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
  _ImageNetworkApi2State createState() => _ImageNetworkApi2State();
}

class _ImageNetworkApi2State extends State<ImageNetworkApi2> {
  double _logicalWidth = 0;
  double _logicalHeight = 0;
  double _actualWidth = 0;
  double _actualheight = 0;
  String _scale = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _calculate(BoxConstraints contraints) async {
    setState(() {
      _logicalHeight = contraints.maxHeight;
      _logicalWidth = contraints.maxWidth;
      _actualheight = _logicalHeight * MediaQuery.devicePixelRatioOf(context);
      _actualWidth = _logicalWidth * MediaQuery.devicePixelRatioOf(context);
      var w = (_actualWidth / 50).round() * 50;
      var h = (_actualheight / 50).round() * 50;

      var gcd = h.toInt().gcd(w.toInt());
      _scale = "${w ~/ gcd}:${h ~/ gcd}";
    });
  }

  @override
  Widget build(BuildContext context) {
    final cBehavior = widget.borderRadius == null ? Clip.none : (widget.clipBehavior ?? Clip.hardEdge);

    final shimmerSize = MediaQuery.sizeOf(context).shortestSide;

    final shimmerWidth = widget.width ?? shimmerSize;
    final shimmerHeight = widget.height ?? shimmerSize;

    if (widget.noCache && widget.url?.isNotEmpty == true) {
      CachedNetworkImage.evictFromCache(widget.url!);

      if (kDebugMode) {
        print("Remove-cache: ${widget.url}");
      }
    }

    if (widget.url?.isEmpty ?? true) {
      return _noImageIcon(cBehavior);
    }

    if (widget.isLoading) {
      return _shimmer(shimmerWidth, shimmerHeight, cBehavior);
    }

    return CachedNetworkImage(
      cacheKey: widget.url,
      imageUrl: widget.url!,
      httpHeaders: widget.headers,
      placeholderFadeInDuration: const Duration(milliseconds: 1000),
      fadeInDuration: const Duration(milliseconds: 1000),
      fadeInCurve: Curves.fastEaseInToSlowEaseOut,

      placeholder:
          widget.loadingBuilder ??
          (context, url) {
            return _shimmer(shimmerWidth, shimmerHeight, cBehavior);
          },

      imageBuilder: (context, imageProvider) {
        // if (true) {
        //   WidgetsBinding.instance.addPostFrameCallback((_) => _calculate());
        // }
        return ClipRRect(
          borderRadius: widget.borderRadius ?? BorderRadius.zero,
          clipBehavior: cBehavior,
          child: Container(
            decoration: BoxDecoration(color: widget.backgroundColor),
            child: true
                ? imageSizeWidget(context)
                : Image(image: imageProvider, width: widget.width, height: widget.height, fit: widget.fit),
          ),
        );
      },

      errorWidget:
          widget.errorBuilder ??
          (context, url, error) {
            return _noImageIcon(cBehavior);
          },

      errorListener: (value) {
        try {
          if (kDebugMode) {
            print(
              "\x1B[31mImage: ${widget.url} \x1B[0m|\x1B[31m ${value.toString().replaceFirst(widget.url ?? "", "~")} \x1B[0m",
            );
          }
        } catch (_) {}
      },
    );
  }

  Widget imageSizeWidget(BuildContext context) {
    return LayoutBuilder(
      builder: (context, contraints) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _calculate(contraints));
        _calculate(contraints);
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            /*  */
            color: Colors.pink.shade400,
          ),
          child: Center(
            child: Text(
              "${_logicalWidth.round()}x${_logicalHeight.round()}\n$_scale",
              style: textStyleTiny(context).copyWith(fontSize: 8, color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
    );
  }

  Widget _shimmer(double width, double height, Clip cBehavior) {
    if (true) {
      return imageSizeWidget(context);
    }
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade400,
      highlightColor: Colors.grey.shade200,
      child: Container(
        clipBehavior: cBehavior,
        width: width,
        height: height,
        decoration: BoxDecoration(color: Colors.white, borderRadius: widget.borderRadius ?? BorderRadius.zero),
      ),
    );
  }

  Widget _noImageIcon(Clip cBehavior) {
    if (true) {
      return imageSizeWidget(context);
    }
    return ClipRRect(
      borderRadius: widget.borderRadius ?? BorderRadius.zero,
      clipBehavior: cBehavior,
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: Image.asset("assets/images/img_no_image.png", fit: BoxFit.cover, package: 'fx_helper'),
      ),
    );
  }
}
