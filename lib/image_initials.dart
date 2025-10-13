import 'package:fx_helper/shimmer_rectangle.dart';
import 'package:flutter/material.dart';

class ImageInitials extends StatelessWidget {
  final String text;
  final TextStyle? style;
  const ImageInitials({super.key, required this.text, required this.style});

  static const List<Color> foreground = [
    Color(0xFF4D5874),
    Color(0xFF001BA3),
    Color(0xFF9B0808),
    Color(0xFFA35F00),
    Color(0xFF019E34),
  ];
  static const background = [
    Color(0xFFEDEEF3),
    Color(0xFFCCD5FF),
    Color(0xFFFCCFCF),
    Color(0xFFFFEACC),
    Color(0xFFB1F1C6),
  ];

  String _getInitials() {
    String t = '';
    try {
      for (String e in text.split(" ")) {
        var char = e.characters.firstOrNull;
        if (char != null) {
          t += char;
        }
        if (t.length >= 2) {
          return t;
        }
      }
    } catch (e) {
      return "  ";
    }
    return t;
  }

  Color _getColorIndex(List<Color> list) {
    int x = 0;
    try {
      x = _getInitials().codeUnitAt(0);
    } catch (e) {
      x = 1;
    }
    return list[x % list.length];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      width: 48,
      height: 48,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(shape: BoxShape.circle, color: _getColorIndex(background)),
      child: ShimmerRectangle(
        isLoading: false,
        width: MediaQuery.sizeOf(context).width * 0.5,
        child: Center(
          child: FittedBox(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                _getInitials(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.start,
                style: style?.copyWith(color: _getColorIndex(foreground)),
                // style: textStyleExtra(context).copyWith(color: _getColorIndex(foreground), fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
