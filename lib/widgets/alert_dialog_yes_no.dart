import 'package:flutter/material.dart';
import 'package:fx_helper/widgets/fx_theme.dart';

/// Show dialog with yes and no button
///
/// usage:
/// ```
///     String? t = await showDialog<String>(
///        context: context,
///        barrierDismissible: true,
///        builder: (BuildContext dContext) => AlertDialogYesNo(
///          title: "Keluar Aplikasi?",
///          subtitle: "Keluar dari Aplikasi",
///          yesMsg: "Keluar",
///          noMsg: "Kembali",
///        ),
///      );
///      if (t == AlertDialogYesNo.yes) {
///        SystemChannels.platform.invokeMethod('SystemNavigator.pop');
///      }
/// ```
class AlertDialogYesNo extends StatelessWidget {
  static String yes = "y";
  static String no = "n";
  final String title;
  final String subtitle;
  final String? yesMsg;
  final String? noMsg;

  const AlertDialogYesNo({super.key, required this.title, required this.subtitle, this.yesMsg, this.noMsg});

  @override
  Widget build(BuildContext context) {
    Color primaryColor = Theme.of(context).primaryColor;
    return AlertDialog(
      backgroundColor: Colors.white,
      title: Text(
        title,
        textAlign: TextAlign.center,
        style: textStyleMediumBig(context).copyWith(color: Colors.black, fontWeight: FontWeight.bold),
      ),
      content: Text(
        subtitle,
        textAlign: TextAlign.center,
        style: textStyleTiny(context).copyWith(color: Colors.black, fontWeight: FontWeight.normal),
      ),
      actions: <Widget>[
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context, no);
                },
                style: ButtonStyle(padding: WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 4))),
                child: Text(
                  noMsg ?? "No",
                  style: textStyleTiny(context).copyWith(color: primaryColor, fontWeight: FontWeight.normal),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                style: ButtonStyle(padding: WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 4))),
                onPressed: () {
                  Navigator.pop(context, yes);
                },
                child: Text(
                  yesMsg ?? "Yes",
                  style: textStyleTiny(context).copyWith(color: Colors.white, fontWeight: FontWeight.normal),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
