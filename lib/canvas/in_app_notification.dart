import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InAppNotification {
  static final List<OverlayEntry> _e = [];
  static final double _stackOffset = 2;

  static void show(
    BuildContext context, {
    required String title,
    required String message,
    Widget? icon,
    required Color color,
    Duration? duration,
  }) {
    late OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) {
        int multiplier = _e.indexOf(overlayEntry);
        return Positioned(
          bottom: MediaQuery.of(context).padding.top + 100 + ((multiplier) * _stackOffset),
          left: 16 + ((multiplier) * 1),
          right: 16 - ((multiplier) * 1),
          child: InAppNotifCard(
            title: title,
            message: message,
            icon: icon,
            color: color,
            duration: duration,
            onClose: () {
              if (overlayEntry.mounted) overlayEntry.remove();
              _e.remove(overlayEntry);
            },
          ),
        );
      },
    );
    _e.add(overlayEntry);

    final overlay = Overlay.of(context);

    overlay.insert(overlayEntry);
    // kalau ada durasi, auto dismiss
    if (duration != null) {
      Future.delayed(duration, () {
        if (overlayEntry.mounted) overlayEntry.remove();
        _e.remove(overlayEntry);
      });
    }
  }
}

class InAppNotifCard extends StatefulWidget {
  final String title;
  final String message;
  final Widget? icon;
  final Color color;
  final VoidCallback onClose;
  final Duration? duration;

  const InAppNotifCard({
    super.key,
    required this.title,
    required this.message,
    this.icon,
    required this.color,
    required this.onClose,
    this.duration,
  });

  @override
  State<InAppNotifCard> createState() => _InAppNotifCardState();
}

class _InAppNotifCardState extends State<InAppNotifCard> with TickerProviderStateMixin {
  final GlobalKey _containerKey = GlobalKey();
  late AnimationController _slideController;
  Animation<Offset>? _slideAnimation;
  AnimationController? _progressController;
  double _backdropHeight = 0;

  void _getBackdropHeight() {
    if (_containerKey.currentWidget != null) {
      final RenderBox? renderBox = _containerKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        _backdropHeight = renderBox.size.height;
      }
    }
    setState(() {});
  }

  @override
  void initState() {
    // Slide in animasi
    _slideController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));

    // _slideController.forward().then((value) {
    //   _slideController.
    // });

    // Kalau ada durasi, bikin progress bar countdown
    if (widget.duration != null) {
      _progressController = AnimationController(vsync: this, duration: widget.duration)..forward();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getBackdropHeight();
    });
    super.initState();
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _progressController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color pColor = widget.color;
    return SafeArea(
      top: false,
      child: Material(
        color: Colors.transparent,
        child: Row(
          children: [
            Expanded(
              child: SlideTransition(
                position: _slideAnimation!,
                child: Dismissible(
                  key: UniqueKey(),
                  direction: DismissDirection.vertical, // bisa swipe ke atas buat close
                  onDismissed: (_) => widget.onClose(),

                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadiusGeometry.circular(12),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                          child: Builder(
                            builder: (context) {
                              return Container(height: _backdropHeight);
                            },
                          ),
                        ),
                      ),
                      Container(
                        key: _containerKey,
                        padding: EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: pColor, width: 1),
                        ),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                widget.icon ?? Icon(Icons.check_circle, color: pColor, size: 52),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        widget.title,
                                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: pColor),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        widget.message,
                                        style: GoogleFonts.inter(
                                          fontWeight: FontWeight.w600,
                                          color: pColor,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  visualDensity: VisualDensity.compact,
                                  icon: Icon(Icons.close, color: pColor),
                                  onPressed: widget.onClose,
                                ),
                              ],
                            ),
                            if (_progressController != null) ...[
                              const SizedBox(height: 4),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: Container(
                                  padding: const EdgeInsets.all(1),
                                  decoration: BoxDecoration(color: pColor, borderRadius: BorderRadius.circular(20)),
                                  child: AnimatedBuilder(
                                    animation: _progressController!,
                                    // builder: (context, child) => LinearProgressIndicator(
                                    //   value: 1.0 - (_progressController?.value ?? 0),
                                    //   backgroundColor: Colors.white,
                                    //   borderRadius: BorderRadius.circular(20),
                                    //   valueColor: AlwaysStoppedAnimation<Color>(
                                    //     pColor.withValues(alpha: 1 - ((_progressController?.value ?? 0) * 0.5)),
                                    //   ),
                                    //   minHeight: 16,
                                    // ),
                                    builder: (context, child) => Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        gradient: LinearGradient(
                                          colors: [
                                            pColor.withValues(
                                              red: (pColor.r * 1.2),
                                              green: (pColor.g * 1.2),
                                              blue: (pColor.b * 1.2),
                                            ),
                                            pColor,
                                            Colors.white,
                                          ],
                                          stops: [
                                            (1 - (_progressController?.value ?? 0)) / 2,
                                            (1 - (_progressController?.value ?? 0)),
                                            (1 - (_progressController?.value ?? 0)),
                                          ],
                                        ),
                                      ),
                                      child: const SizedBox(height: 6),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
