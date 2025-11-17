import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class HtmlText extends StatelessWidget {
  final String? html;
  final TextStyle? style;
  final TextAlign? textAlign;

  /// this class provide wrapper for flutter html to reduce  direct css in project code.
  /// the objective is that we can use standard flutter styling while using Html class.
  ///
  /// ‼️ Be aware that not all text style is implemented ‼️
  const HtmlText({super.key, required this.html, this.style, this.textAlign});
  @override
  Widget build(BuildContext context) {
    return Html(
      data: html ?? "",
      style: {
        /* Base Style */
        "body": Style(
          /*  */
          fontStyle: FontStyle.normal,
          fontSize: FontSize(style?.fontSize ?? 11),
          fontFamily: "inter, arial, times new roman",
          color: style?.color ?? Colors.black,
          textAlign: textAlign ?? TextAlign.start,
          margin: Margins.all(0),
        ),
      },
    );
  }
}
