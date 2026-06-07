import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fx_helper/network/fx_network.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';

/* 
    On Staging:
      > Add development badges to layout.
    On Production: 
      > Does nothing
    
    Usage: 
      > Wrap it to a page just like a Scaffold widget.
*/

class DevInfoWrapper extends StatefulWidget {
  final Widget child;
  final bool isDevMode;
  const DevInfoWrapper({super.key, required this.child, required this.isDevMode});

  @override
  _DevInfoWrapperState createState() => _DevInfoWrapperState();
}

class _DevInfoWrapperState extends State<DevInfoWrapper> {
  PackageInfo? _packageInfo;
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _packageInfo = await PackageInfo.fromPlatform();
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isDevMode) {
      return Stack(
        fit: StackFit.passthrough,
        children: [
          widget.child,
          Positioned(
            top: Platform.isAndroid ? 8 : 3,
            left: Platform.isAndroid
                ? (MediaQuery.sizeOf(context).width * 0.5) - (MediaQuery.sizeOf(context).width * 0.28)
                : (MediaQuery.sizeOf(context).width * 0.5) - (MediaQuery.sizeOf(context).width * 0.3),

            child: Container(
              padding: EdgeInsets.symmetric(vertical: 3, horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.deepOrange,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(1.4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40),
                      border: BoxBorder.all(color: Colors.white),
                    ),
                    child: Icon(Icons.widgets, color: Colors.white, size: 8),
                  ),
                  SizedBox(width: 4),
                  Text(
                    "Dev v${_packageInfo?.version}+${_packageInfo?.buildNumber}",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 9,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }
    return widget.child;
  }
}
