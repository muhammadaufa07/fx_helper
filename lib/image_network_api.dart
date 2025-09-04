import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ImageNetworkApi extends StatelessWidget {
  final String url;
  final BoxFit? fit;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final Map<String, String>? headers;
  const ImageNetworkApi(this.url, {super.key, this.fit, this.width, this.height, this.backgroundColor, this.headers});

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: url,
      placeholder: (context, url) {
        return _shimmer(width ?? 0, width ?? 0);
      },
      httpHeaders: headers,
      imageBuilder: (context, imageProvider) {
        return Row(
          children: [
            Expanded(
              child: Container(
                width: width,
                height: height,
                decoration: BoxDecoration(
                  image: DecorationImage(image: imageProvider, fit: fit),
                ),
              ),
            ),
          ],
        );
      },
      errorWidget: (context, url, error) => _noImageIcon(),
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
    return FittedBox(child: Image.asset("assets/icons/ic_no_image.png", fit: BoxFit.cover));
  }
}
