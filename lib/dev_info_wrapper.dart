import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/* 
    On Staging:
      > Add development badges to layout.
    On Production: 
      > Does nothing
    
    Usage: 
      > Wrap it to a page just like a Scaffold widget.
*/
class DevInfoWrapper extends StatelessWidget {
  final Widget child;
  final bool isDevMode;
  const DevInfoWrapper({super.key, required this.child, required this.isDevMode});

  @override
  Widget build(BuildContext context) {
    if (isDevMode) {
      return Stack(
        fit: StackFit.passthrough,
        children: [
          child,
          Positioned(
            top: MediaQuery.sizeOf(context).height * 0.01,
            left: (MediaQuery.sizeOf(context).width * 0.5) - 110,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
              ),
              child: Text(
                "Developer Build",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                  fontSize: 7,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ),
        ],
      );
    }
    return child;
  }
}
