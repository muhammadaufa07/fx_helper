import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ViewImagePage extends StatelessWidget {
  final String photoUrl;
  final Map<String, String>? headers;
  const ViewImagePage({super.key, required this.photoUrl, this.headers});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      floatingActionButton: backButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerTop,
      body: SafeArea(
        top: false,
        child: PhotoView(
          imageProvider: NetworkImage(photoUrl, headers: headers),
          loadingBuilder: (context, event) => const Center(child: CircularProgressIndicator(color: Colors.white)),
          errorBuilder: (context, error, stackTrace) => Center(
            child: Text(
              'Load image failed',
              style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
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
