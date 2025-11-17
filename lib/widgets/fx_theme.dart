import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// const Gradient secondaryGradientColor = LinearGradient(
//   begin: Alignment.centerLeft,
//   end: Alignment.centerRight,
//   colors: [primaryColor, secondaryColor],
// );

// const Gradient primaryGradientColor = LinearGradient(
//   stops: [0.05, 0.5],
//   begin: Alignment.topCenter,
//   end: Alignment.bottomCenter,
//   colors: [Color.fromRGBO(255, 129, 106, 1), Color.fromRGBO(245, 62, 77, 1)],
// );

// const Gradient primaryGradientColorDisabled = const LinearGradient(
//   begin: Alignment.centerLeft,
//   end: Alignment.centerRight,
//   colors: [Color.fromRGBO(241, 61, 61, 0.5), Color.fromRGBO(246, 184, 47, 0.5)],
// );
// const Gradient primaryTopBottomGradientColor = const LinearGradient(
//   begin: Alignment.topCenter,
//   end: Alignment.bottomCenter,
//   colors: [Color.fromRGBO(245, 62, 77, 1), Color.fromRGBO(255, 129, 106, 1)],
// );
// const Gradient greyGradientColor = LinearGradient(
//   begin: Alignment.centerLeft,
//   end: Alignment.centerRight,
//   colors: [whiteColor, whiteColor],
// );

// const Color primaryColor = Color(0xFFA0111D);
// const Color secondaryColor = Color(0xFFDA4B57);
// const Color backgroundColor = Color(0xFFFBFAFA);

// const Color secondaryAccentColor = Color.fromRGBO(255, 212, 146, 1);
// const Color whiteColor = Colors.white;
// const Color brokenWhite = Color(0xFFF0F0F0);
// const Color blackColor = Colors.black;
// const Color greyColor = Color(0xFFB3B3B3);
// const Color lightGreyColor = Color(0xFFE7E7E7);
// const Color redColor = Color(0xFFED2828);
// const Color softRed = Color.fromRGBO(241, 61, 61, 1);
// const Color redAccentColor = Color.fromRGBO(238, 61, 96, 1);
// const Color darkOrangeColor = Color.fromRGBO(253, 107, 40, 1);
// const Color orangeColor = Color.fromRGBO(255, 180, 89, 1);
// const Color highlightGreenColor = Color.fromRGBO(76, 217, 100, 0.2);
// const Color greenColor = Color(0xFF04B422);
// const Color greenAccentColor = Color.fromARGB(255, 214, 255, 221);
// const Color transparentColor = Colors.transparent;
// const Color cardColor = Color.fromRGBO(244, 245, 243, 1);
// const Color formColor = Color.fromRGBO(240, 240, 240, 1);
// const Color lightRedColor = Color.fromRGBO(253, 230, 235, 1);
// const double edge = 20;
// const double roundedEdge = 10;
// const double circularEdge = 50;

// double getMaxWidth(BuildContext context) {
//   return MediaQuery.sizeOf(context).width;
// }

// double getMaxHeight(BuildContext context) {
//   return MediaQuery.sizeOf(context).height;
// }

TextStyle _getFont(BuildContext context, int size) {
  var smallFormFactor = MediaQuery.sizeOf(context).shortestSide < 550;
  var fontSize = MediaQuery.sizeOf(context).width / size;
  if (smallFormFactor) {
    if (MediaQuery.orientationOf(context) == Orientation.portrait) {
      fontSize *= 1;
    } else {
      fontSize *= 0.5;
    }
  } else {
    if (MediaQuery.orientationOf(context) == Orientation.portrait) {
      fontSize *= 0.7;
    } else {
      fontSize *= 0.4;
    }
  }

  return GoogleFonts.inter(fontWeight: FontWeight.w400, color: Colors.black, fontSize: fontSize);
}

// /* Defines global text style associated with design at 8px*/
// TextStyle textStyleMoreTinySpacing(BuildContext context) {
//   return _getFont(context, 36).copyWith(color: blackColor, fontSize: 10, letterSpacing: 0, height: 1.25);
// }

// /* Defines global text style associated with design at 8px*/
// TextStyle textStyleMoreTiny(BuildContext context) {
//   return _getFont(context, 36);
// }

/* Defines global text style associated with design at 10px*/
TextStyle textStyleTiny(BuildContext context) {
  return _getFont(context, 32);
}

/* Defines global text style associated with design at 12px*/
TextStyle textStyleSmall(BuildContext context) {
  return _getFont(context, 28);
}

// /* Defines global text style associated with design at 14px*/
// TextStyle textStyleMedium(BuildContext context) {
//   return _getFont(context, 24);
// }

/* Defines global text style associated with design at 16px*/
TextStyle textStyleMediumBig(BuildContext context) {
  return _getFont(context, 22);
}

// /* Defines global text style associated with design at 18px*/
// TextStyle textStyleBig(BuildContext context) {
//   return _getFont(context, 18);
// }

// /*Defines global text style associated with design at 20px*/
// TextStyle textStyleHuge(BuildContext context) {
//   return _getFont(context, 17);
// }

// BoxShadow shadow = BoxShadow(
//   color: Colors.grey.withValues(alpha: 0.5),
//   spreadRadius: 1,
//   blurRadius: 4,
//   offset: Offset(0, 4),
// );

// PinTheme pinThemeDefault(BuildContext context) {
//   return PinTheme(
//     width: MediaQuery.sizeOf(context).width / 8,
//     height: MediaQuery.sizeOf(context).width / 8,
//     textStyle: textStyleMediumBig(context),
//     decoration: BoxDecoration(
//       color: whiteColor,
//       border: Border.all(color: lightGreyColor),
//       borderRadius: BorderRadius.circular(roundedEdge),
//     ),
//   );
// }

// pinThemeFocused(BuildContext context) {
//   return pinThemeDefault(context).copyWith(
//     decoration: BoxDecoration(
//       /*  */
//       border: Border.all(color: primaryColor),
//       borderRadius: BorderRadius.circular(roundedEdge),
//     ),
//   );
// }

// getInputDecoration() {
//   return InputDecorationThemeData(
//     fillColor: whiteColor,
//     filled: true,
//     enabledBorder: OutlineInputBorder(
//       borderSide: BorderSide(color: greyColor),
//       borderRadius: BorderRadius.circular(roundedEdge),
//     ),
//     border: OutlineInputBorder(
//       borderSide: BorderSide(color: lightGreyColor),
//       borderRadius: BorderRadius.circular(roundedEdge),
//     ),
//     errorBorder: OutlineInputBorder(
//       borderSide: BorderSide(color: redColor),
//       borderRadius: BorderRadius.circular(roundedEdge),
//     ),
//     focusedBorder: OutlineInputBorder(
//       borderSide: BorderSide(color: lightGreyColor),
//       borderRadius: BorderRadius.circular(roundedEdge),
//     ),
//     disabledBorder: OutlineInputBorder(
//       borderSide: BorderSide(color: lightGreyColor.withValues(alpha: 0.3)),
//       borderRadius: BorderRadius.circular(roundedEdge),
//     ),
//   );
// }

// ThemeData customTheme = ThemeData(
//   colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
//   useMaterial3: true,

//   elevatedButtonTheme: ElevatedButtonThemeData(
//     style: ButtonStyle(
//       padding: WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 16)),
//       shape: WidgetStatePropertyAll(
//         RoundedRectangleBorder(
//           borderRadius: BorderRadiusGeometry.circular(roundedEdge),
//           // side: BorderSide(color: lightGreyColor),
//         ),
//       ),
//       backgroundColor: WidgetStateColor.resolveWith((states) {
//         if (states.contains(WidgetState.disabled)) {
//           return lightGreyColor;
//         } else if (states.contains(WidgetState.dragged)) {
//           return Colors.yellowAccent;
//         } else if (states.contains(WidgetState.error)) {
//           return Colors.deepOrangeAccent.withValues(alpha: 0.8);
//         } else if (states.contains(WidgetState.focused)) {
//           return Colors.purpleAccent;
//         } else if (states.contains(WidgetState.hovered)) {
//           return primaryColor.withValues(alpha: 0.2);
//         } else if (states.contains(WidgetState.scrolledUnder)) {
//           return Colors.lime;
//         } else if (states.contains(WidgetState.selected)) {
//           return Colors.lightGreenAccent;
//         }

//         return primaryColor;
//       }),
//     ),
//   ),
//   textButtonTheme: TextButtonThemeData(
//     style: ButtonStyle(
//       visualDensity: VisualDensity.compact,
//       minimumSize: WidgetStatePropertyAll(Size.zero),
//       tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//       padding: WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 2, horizontal: 12)),
//     ),
//   ),
//   outlinedButtonTheme: OutlinedButtonThemeData(
//     style: ButtonStyle(
//       padding: WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 16)),
//       shape: WidgetStatePropertyAll(
//         RoundedRectangleBorder(
//           borderRadius: BorderRadiusGeometry.circular(roundedEdge),
//           side: BorderSide(width: 3, color: primaryColor),
//         ),
//       ),
//       side: WidgetStateBorderSide.resolveWith((states) {
//         if (states.contains(WidgetState.disabled)) {
//           return BorderSide(color: lightGreyColor);
//         } else if (states.contains(WidgetState.dragged)) {
//           return BorderSide(color: lightGreyColor);
//         } else if (states.contains(WidgetState.error)) {
//           return BorderSide(color: redColor);
//         } else if (states.contains(WidgetState.focused)) {
//           return BorderSide(color: lightGreyColor);
//         } else if (states.contains(WidgetState.hovered)) {
//           return BorderSide(color: primaryColor);
//         } else if (states.contains(WidgetState.scrolledUnder)) {
//           return BorderSide(color: lightGreyColor);
//         } else if (states.contains(WidgetState.selected)) {
//           return BorderSide(color: lightGreyColor);
//         }
//         return BorderSide(color: primaryColor);
//       }),
//       backgroundColor: WidgetStateColor.resolveWith((states) {
//         if (states.contains(WidgetState.disabled)) {
//           return lightGreyColor.withValues(alpha: 0.3);
//         } else if (states.contains(WidgetState.dragged)) {
//           return Colors.yellowAccent;
//         } else if (states.contains(WidgetState.error)) {
//           return primaryColor.withValues(alpha: 0.8);
//         } else if (states.contains(WidgetState.focused)) {
//           return Colors.purpleAccent;
//         } else if (states.contains(WidgetState.hovered)) {
//           return primaryColor.withValues(alpha: 0.2);
//         } else if (states.contains(WidgetState.scrolledUnder)) {
//           return Colors.lime;
//         } else if (states.contains(WidgetState.selected)) {
//           return Colors.lightGreenAccent;
//         }

//         return whiteColor;
//       }),
//     ),
//   ),
//   inputDecorationTheme: getInputDecoration(),
//   dropdownMenuTheme: DropdownMenuThemeData(
//     menuStyle: MenuStyle(backgroundColor: WidgetStatePropertyAll(whiteColor)),
//     inputDecorationTheme: getInputDecoration(),
//   ),
// );
