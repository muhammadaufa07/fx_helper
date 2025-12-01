import 'package:flutter/material.dart';
import 'package:fx_helper/widgets/fx_theme.dart';

enum StatusWidgetColor { black, red, blue, green, yellow }

class StatusWidget extends StatelessWidget {
  final String text;
  final Map<String, StatusWidgetColor>? mapColor;
  // final Color? backgroundColor;

  const StatusWidget(this.text, {super.key, this.mapColor});

  StatusWidgetColor _getCurrentColor() {
    return mapColor?.entries.firstWhere((element) => element.key == text).value ?? StatusWidgetColor.black;
  }

  Color? _getFontColor() {
    switch (_getCurrentColor()) {
      case StatusWidgetColor.black:
        return Colors.white;
      case StatusWidgetColor.red:
        return Colors.white;
      case StatusWidgetColor.blue:
        return Colors.white;
      case StatusWidgetColor.green:
        return Colors.white;
      case StatusWidgetColor.yellow:
        return Colors.white;
    }
    return Colors.white;
  }

  Color? _getBgColor() {
    switch (_getCurrentColor()) {
      case StatusWidgetColor.black:
        return Colors.black;
      case StatusWidgetColor.red:
        return Colors.red;
      case StatusWidgetColor.blue:
        return Colors.blue;
      case StatusWidgetColor.green:
        return Colors.green;
      case StatusWidgetColor.yellow:
        return Colors.yellow;
    }
    return Colors.yellow;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 2, horizontal: 16),
      decoration: BoxDecoration(color: _getBgColor(), borderRadius: BorderRadius.circular(20)),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.start,
        style: textStyleTiny(context).copyWith(color: _getFontColor(), fontWeight: FontWeight.bold),
      ),
    );
  }
}
