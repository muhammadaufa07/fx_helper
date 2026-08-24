import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fx_helper/shimmer_shines.dart';
import 'package:fx_helper/snackbar_helper.dart';
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
    // return ImageNetworkApi2(
    //   url,
    //   fit: fit,
    //   width: width,
    //   height: height,
    //   borderRadius: borderRadius,
    //   clipBehavior: clipBehavior,
    //   headers: headers,
    //   errorBuilder: errorBuilder,
    //   loadingBuilder: loadingBuilder,
    //   noCache: noCache,
    //   isLoading: isLoading,
    //   backgroundColor: backgroundColor,
    // );

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
  BoxConstraints? _contraints;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _calculate());
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _calculate() async {
    if (_contraints == null) return;
    String info = "";
    setState(() {
      try {
        _logicalHeight = _contraints!.maxHeight;
        if (_logicalHeight.isInfinite) {
          _logicalHeight = MediaQuery.sizeOf(context).height;
        }
        info += "_logicalHeight: ${_logicalHeight.toStringAsFixed(2)}";
        _logicalWidth = _contraints!.maxWidth;

        if (_logicalWidth.isInfinite) {
          _logicalWidth = MediaQuery.sizeOf(context).width;
        }
        info += "_logicalWidth: ${_logicalWidth.toStringAsFixed(2)}, ";
        _actualheight = (_logicalHeight * MediaQuery.devicePixelRatioOf(context)).truncateToDouble();
        _actualWidth = (_logicalWidth * MediaQuery.devicePixelRatioOf(context)).truncateToDouble();
        info += "_actualheight: $_actualheight, ";
        info += "_actualWidth: $_actualWidth, ";
        var divisor = 100;
        info += "divisor:$divisor, ";
        var w = (_actualWidth / divisor).round() * divisor;
        var h = (_actualheight / divisor).round() * divisor;
        info += "w:$w, ";
        info += "h:$h, ";
        var gcd = h.toInt().gcd(w.toInt());
        info += "gcd:$gcd, ";
        _scale = "${w ~/ gcd}:${h ~/ gcd}";
        info += "_scale:$_scale, ";
      } catch (e) {
        print(e.toString());
      }
      print(info);
    });
  }

  @override
  Widget build(BuildContext context) {
    String scaleT = "";
    scaleT += "\n$_actualWidth x $_actualheight";
    scaleT += "\n$_scale";
    String scaleMsg = "$_actualWidth x $_actualheight $_scale";
    return InkWell(
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      hoverColor: Colors.transparent,
      overlayColor: WidgetStatePropertyAll(Colors.transparent),
      focusColor: Colors.transparent,
      onLongPress: () {
        SnackbarHelper.showSnackBar(SnackbarState.success, scaleMsg, duration: Duration(seconds: 5));
      },
      child: LayoutBuilder(
        builder: (context, contraints) {
          _contraints = contraints;
          return ShimmerShines(
            isVisible: true,
            child: Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                color: [
                  const Color.fromARGB(255, 182, 136, 0),
                  Colors.pink.shade400,
                  Colors.red.shade400,
                  Colors.blueAccent.shade400,
                  Colors.orange.shade400,
                  Colors.deepOrange.shade400,
                  Colors.purple.shade400,
                  Colors.teal.shade400,
                ][Random.secure().nextInt(7)],
              ),
              child: Center(
                child: Text(
                  scaleT,
                  style: textStyleTiny(context).copyWith(fontSize: 10, color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
