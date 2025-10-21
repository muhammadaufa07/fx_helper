import 'package:flutter/material.dart';
import 'package:fx_helper/shimmer_rectangle.dart';
import 'package:google_fonts/google_fonts.dart';

class ExpandableRowWidget<T> extends StatelessWidget {
  final String title;
  final TextStyle? titleStyle;
  final String? subtitle;
  final TextStyle? subtitleStyle;
  final bool isExpanded;
  final bool isLoading;
  final VoidCallback onTap;
  final BoxDecoration? decoration;
  final BoxDecoration? subDecoration;
  final EdgeInsets? subPadding;
  final List<T> childItems;
  final Widget? leadingIcon;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Function(int index, T item)? onChildItemTap;

  const ExpandableRowWidget({
    super.key,
    required this.title,
    this.titleStyle,
    this.subtitle,
    this.subtitleStyle,
    required this.isExpanded,
    required this.isLoading,
    required this.onTap,
    required this.childItems,
    required this.itemBuilder,
    this.decoration,
    this.subDecoration,
    this.leadingIcon,
    this.subPadding,
    this.onChildItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(seconds: 1),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: decoration?.color ?? Colors.white,
            borderRadius: decoration?.borderRadius ?? BorderRadius.circular(10),
            border: decoration?.border ?? Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerRectangle(
                isLoading: isLoading,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: leadingIcon,
                  title: Text(title, style: titleStyle ?? TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: subtitle == null
                      ? null
                      : Text(
                          subtitle ?? "",
                          style:
                              subtitleStyle ??
                              GoogleFonts.inter(
                                fontWeight: FontWeight.normal,
                                color: Colors.black,
                                // fontSize: 7,
                                decoration: TextDecoration.none,
                              ),
                        ),
                  trailing: Icon(isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: Colors.black),
                  onTap: onTap,
                ),
              ),
              _listItem(context),
            ],
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _listItem(BuildContext context) {
    int index = 0;
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      clipBehavior: Clip.antiAlias,
      child: isExpanded
          ? Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: subDecoration?.color ?? Colors.grey.shade50,
                borderRadius:
                    subDecoration?.borderRadius ??
                    BorderRadius.only(
                      /*  */
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                border: subDecoration?.border,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: childItems.map((item) {
                  return Material(
                    clipBehavior: Clip.antiAlias,
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onChildItemTap == null
                          ? null
                          : () {
                              onChildItemTap!(index, item);
                            },
                      child: Container(
                        padding: subPadding ?? EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        child: ShimmerRectangle(
                          isLoading: isLoading,
                          borderRadius: BorderRadius.circular(10),
                          child: itemBuilder(context, item, index++),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}
