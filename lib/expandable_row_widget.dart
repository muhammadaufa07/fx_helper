import 'package:flutter/material.dart';
import 'package:fx_helper/shimmer_rectangle.dart';
import 'package:google_fonts/google_fonts.dart';

class ExpandableRowWidget<T> extends StatefulWidget {
  final String title;
  final TextStyle? titleStyle;
  final String? subtitle;
  final TextStyle? subtitleStyle;
  final bool isLoading;
  final VoidCallback onTap;
  final BoxDecoration? decoration;
  final BoxDecoration? subDecoration;
  final EdgeInsets? subPadding;
  final List<T> childItems;
  final Widget? leadingIcon;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final Function(int index, T item)? onChildItemTap;
  final EdgeInsets? padding;
  const ExpandableRowWidget({
    super.key,
    required this.title,
    this.titleStyle,
    this.subtitle,
    this.subtitleStyle,
    required this.isLoading,
    required this.onTap,
    required this.childItems,
    required this.itemBuilder,
    this.decoration,
    this.subDecoration,
    this.leadingIcon,
    this.subPadding,
    this.onChildItemTap,
    this.padding,
  });

  @override
  _ExpandableRowWidgetState createState() => _ExpandableRowWidgetState();
}

class _ExpandableRowWidgetState extends State<ExpandableRowWidget> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(seconds: 1),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: widget.decoration?.color ?? Colors.white,
            borderRadius: widget.decoration?.borderRadius ?? BorderRadius.circular(10),
            border: widget.decoration?.border ?? Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerRectangle(
                isLoading: widget.isLoading,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
                child: ListTile(
                  contentPadding: widget.padding ?? EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: widget.leadingIcon,
                  title: Text(widget.title, style: widget.titleStyle ?? TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: widget.subtitle == null
                      ? null
                      : Text(
                          widget.subtitle ?? "",
                          style:
                              widget.subtitleStyle ??
                              GoogleFonts.inter(
                                fontWeight: FontWeight.normal,
                                color: Colors.black,
                                // fontSize: 7,
                                decoration: TextDecoration.none,
                              ),
                        ),
                  trailing: Icon(isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: Colors.black),
                  onTap: () {
                    isExpanded = !isExpanded;
                    setState(() {});
                  },
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
                color: widget.subDecoration?.color ?? Colors.grey.shade50,
                borderRadius:
                    widget.subDecoration?.borderRadius ??
                    BorderRadius.only(
                      /*  */
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                border: widget.subDecoration?.border,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget.childItems.map((item) {
                  return Material(
                    clipBehavior: Clip.antiAlias,
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: widget.onChildItemTap == null
                          ? null
                          : () {
                              widget.onChildItemTap!(index, item);
                            },
                      child: Container(
                        padding: widget.subPadding ?? EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        child: ShimmerRectangle(
                          isLoading: widget.isLoading,
                          borderRadius: BorderRadius.circular(10),
                          child: widget.itemBuilder(context, item, index++),
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
