import 'dart:math';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ViewImagePage extends StatelessWidget {
  final String? photoUrl;
  final Map<String, String>? headers;
  final PreferredSizeWidget? appBar;
  final FloatingActionButton? fab;
  final bool hideDefaultFab;
  const ViewImagePage({
    super.key,
    required this.photoUrl,
    this.headers,
    this.appBar,
    this.fab,
    this.hideDefaultFab = false,
  });

  @override
  Widget build(BuildContext context) {
    if (photoUrl == null || photoUrl?.isEmpty == true) {
      return _noImageIcon(context);
    }
    var uri = Uri.tryParse(photoUrl ?? "");
    Map<String, dynamic> q = {};
    q.addAll(uri?.queryParameters ?? {});
    q.addAll({"local_id": "${Random().nextDouble() * pi}"});
    var url = uri?.replace(queryParameters: q);

    return Scaffold(
      backgroundColor: Colors.black,
      floatingActionButton: hideDefaultFab ? null : fab ?? backButton(context),
      appBar: appBar,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerTop,
      body: SafeArea(
        top: false,
        child: PhotoView(
          imageProvider: NetworkImage(url.toString(), headers: headers),
          loadingBuilder: (context, event) => const Center(child: CircularProgressIndicator(color: Colors.white)),
          errorBuilder: (context, error, stackTrace) => Center(
            child: const Text(
              'Load image failed',
              style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }

  Widget _noImageIcon(BuildContext context) {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width * 0.3,
      height: MediaQuery.sizeOf(context).height * 0.3,
      child: Image.asset("assets/images/img_no_image.png", fit: BoxFit.cover, package: 'fx_helper'),
    );
  }

  Row backButton(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(20),
          child: Container(
            width: MediaQuery.sizeOf(context).width / 8.5,
            height: MediaQuery.sizeOf(context).width / 8.5,
            decoration: BoxDecoration(
              color: Color(0xFFF6F4F4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Color(0xFF757575).withValues(alpha: 0.2)),
            ),
            child: Material(
              borderRadius: BorderRadius.circular(12),
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                splashColor: Color(0xFFF6F4F4),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Icon(Icons.arrow_back_ios, color: Colors.black, size: 25),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
