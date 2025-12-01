import 'package:flutter/material.dart';
import 'package:fx_helper/widgets/fx_theme.dart';

class DropdownCustom<T> extends StatelessWidget {
  final String label;
  final List<T> items;
  final T? value;
  final ValueChanged<T?>? onChanged;
  final String Function(T) itemToString;
  final InputDecoration? decoration;
  final TextStyle? textStyle;
  final FormFieldValidator<T?>? validator;
  // final bool isEnabled;
  final BorderRadius? borderRadius;
  final BorderRadius? contentBorderRadius;
  final EdgeInsets? padding;
  final Color? backgroundColor;

  const DropdownCustom({
    super.key,
    required this.label,
    required this.items,
    this.value,
    this.onChanged,
    required this.itemToString,
    this.decoration,
    this.textStyle,
    this.validator,
    // this.isEnabled = true,
    this.borderRadius,
    this.contentBorderRadius,
    this.padding,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    Color lightGreyColor = Theme.of(context).inputDecorationTheme.disabledBorder?.borderSide.color ?? Colors.grey;
    Color greyColor = Theme.of(context).inputDecorationTheme.disabledBorder?.borderSide.color ?? Colors.grey;
    double roundedEdge = 10.0;
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: borderRadius ?? BorderRadius.zero,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          child: DropdownButtonFormField<T>(
            isExpanded: true,
            items: items
                .map(
                  (e) => DropdownMenuItem<T>(
                    value: e,
                    child: Text(
                      itemToString(e),
                      textAlign: TextAlign.start,
                      // maxLines: 1,
                      style:
                          textStyle ??
                          textStyleTiny(context).copyWith(color: onChanged != null ? Colors.black : Colors.grey),
                    ),
                  ),
                )
                .toList(),
            onChanged: onChanged,
            initialValue: value,
            barrierDismissible: true,

            hint: Text(label, style: textStyleTiny(context).copyWith(color: greyColor)),
            validator: validator,
            icon: Icon(Icons.keyboard_arrow_down),

            dropdownColor: Colors.white,
            borderRadius: contentBorderRadius ?? BorderRadius.zero,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.transparent,
              // fillColor: Colors.transparent,
              isDense: true,
              contentPadding: padding ?? EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              errorStyle: textStyleTiny(context).copyWith(color: Colors.red),

              border: OutlineInputBorder(
                borderRadius: borderRadius ?? BorderRadius.zero,
                borderSide: BorderSide(color: greyColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: borderRadius ?? BorderRadius.zero,
                borderSide: BorderSide(color: lightGreyColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: borderRadius ?? BorderRadius.zero,
                borderSide: BorderSide(color: greyColor),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: borderRadius ?? BorderRadius.zero,
                borderSide: BorderSide(color: Colors.red),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: borderRadius ?? BorderRadius.zero,
                borderSide: BorderSide(color: Colors.red),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
