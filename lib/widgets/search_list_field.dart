import 'package:flutter/material.dart';
import 'package:fx_helper/widgets/fx_theme.dart';

/// A searchable dropdown widget that allows users to filter
/// and select an item from a list.
///
/// [T] is a generic type, so this widget can be used with
/// String, custom models, or any other object type.
class SearchListField<T> extends StatefulWidget {
  /// Currently selected value.
  final T? value;

  /// List of all available items.
  final List<T> items;

  /// Callback triggered when an item is selected.
  final ValueChanged<T?> onChanged;

  /// Converts an item into a displayable string.
  final String Function(T) itemToString;

  /// Label shown above the text field.
  final String? label;

  /// Placeholder text displayed when no value is selected.
  final String hint;

  /// Text style used for the hint.
  final TextStyle? hintStyle;

  /// Text style used for items and selected value.
  final TextStyle? itemTextStyle;

  const SearchListField({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.itemToString,
    this.label,
    required this.hint,
    this.hintStyle,
    this.itemTextStyle,
  });

  @override
  State<SearchListField<T>> createState() => _FormFieldListState<T>();
}

/// TickerProviderStateMixin is required by AnimatedSize
/// to provide animation frames efficiently.
class _FormFieldListState<T> extends State<SearchListField<T>> with TickerProviderStateMixin {
  /// Controller used to manage the text inside the TextField.
  late TextEditingController _controller;

  /// List containing filtered items based on user input.
  List<T> filteredItems = [];

  /// Determines whether the dropdown list is visible.
  bool showList = false;

  /// Used to manage TextField focus.
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();

    /// Initialize the TextField with the selected value if available.
    _controller = TextEditingController(text: widget.value != null ? widget.itemToString(widget.value!) : '');

    _focusNode = FocusNode();

    /// Initially display all items.
    filteredItems = widget.items;
  }

  @override
  void dispose() {
    /// Prevent memory leaks.
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// Called whenever the text inside the TextField changes.
  ///
  /// Displays the dropdown and filters items that contain
  /// the entered text.
  void _onChanged(String query) {
    setState(() {
      showList = true;

      filteredItems = widget.items.where((item) {
        return widget.itemToString(item).toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  /// Opens or closes the dropdown list.
  ///
  /// When opening:
  /// - All items are restored.
  /// - Focus is requested.
  ///
  /// When closing:
  /// - Focus is removed.
  void _toggleDropdown() {
    setState(() {
      showList = !showList;

      if (showList) {
        filteredItems = widget.items;
        _focusNode.requestFocus();
      } else {
        _focusNode.unfocus();
      }
    });
  }

  /// Handles item selection.
  ///
  /// After selecting:
  /// - TextField value is updated.
  /// - Dropdown is closed.
  /// - Parent callback is triggered.
  void _selectItem(T item) {
    _controller.text = widget.itemToString(item);

    setState(() {
      showList = false;
    });

    _focusNode.unfocus();

    widget.onChanged(item);
  }

  @override
  Widget build(BuildContext context) {
    return TapRegion(
      /// Close the dropdown when tapping outside the widget.
      onTapOutside: (_) {
        if (showList) {
          setState(() {
            showList = false;
          });

          _focusNode.unfocus();
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _controller,
            style: widget.itemTextStyle ?? textStyleTiny(context),
            focusNode: _focusNode,
            decoration: InputDecoration(
              labelText: widget.label,
              labelStyle: textStyleTiny(context),
              filled: true,
              fillColor: Colors.white,

              /// Rotate the arrow icon when the dropdown opens.
              ///
              /// 0 turns = arrow down
              /// 0.5 turns = arrow up (180° rotation)
              suffixIcon: AnimatedRotation(
                turns: showList ? 0.5 : 0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                child: const Icon(Icons.keyboard_arrow_down_rounded),
              ),

              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),

              errorStyle: textStyleTiny(context).copyWith(color: Colors.red),

              hint: Text(
                widget.hint,
                style: widget.hintStyle ?? textStyleSmall(context).copyWith(color: Color(0xFFBEBEBE)),
              ),

              /// Default border.
              ///
              /// Bottom radius becomes zero while the dropdown is open
              /// so that the TextField and list look connected.
              border: OutlineInputBorder(
                borderRadius: BorderRadius.only(
                  topRight: const Radius.circular(10),
                  topLeft: const Radius.circular(10),
                  bottomLeft: Radius.circular(showList ? 0 : 10),
                  bottomRight: Radius.circular(showList ? 0 : 10),
                ),
                borderSide: BorderSide(color: Color(0xFFBEBEBE)),
              ),

              /// Border shown when enabled.
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.only(
                  topRight: const Radius.circular(10),
                  topLeft: const Radius.circular(10),
                  bottomLeft: Radius.circular(showList ? 0 : 10),
                  bottomRight: Radius.circular(showList ? 0 : 10),
                ),
                borderSide: BorderSide(color: Color(0xFFBEBEBE)),
              ),

              /// Border shown while focused.
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.only(
                  topRight: const Radius.circular(10),
                  topLeft: const Radius.circular(10),
                  bottomLeft: Radius.circular(showList ? 0 : 10),
                  bottomRight: Radius.circular(showList ? 0 : 10),
                ),
                borderSide: BorderSide(color: Colors.black),
              ),

              /// Border shown when an error occurs.
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.only(
                  topRight: const Radius.circular(10),
                  topLeft: const Radius.circular(10),
                  bottomLeft: Radius.circular(showList ? 0 : 10),
                  bottomRight: Radius.circular(showList ? 0 : 10),
                ),
                borderSide: BorderSide(color: Colors.red),
              ),

              /// Border shown when focused and an error occurs.
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.only(
                  topRight: const Radius.circular(10),
                  topLeft: const Radius.circular(10),
                  bottomLeft: Radius.circular(showList ? 0 : 10),
                  bottomRight: Radius.circular(showList ? 0 : 10),
                ),
                borderSide: BorderSide(color: Colors.red),
              ),
            ),

            onChanged: _onChanged,

            /// Toggle dropdown when TextField is tapped.
            onTap: _toggleDropdown,
          ),

          /// Prevent child overflow during size animation.
          ClipRect(
            child: AnimatedSize(
              /// Animate height changes smoothly.
              duration: const Duration(milliseconds: 300),
              curve: Curves.fastEaseInToSlowEaseOut,

              child: AnimatedOpacity(
                /// Fade in and fade out animation.
                duration: const Duration(milliseconds: 150),

                /// Show opacity only when dropdown is visible.
                opacity: showList ? 1 : 0,

                child: showList
                    ? Container(
                        /// Maximum dropdown height.
                        constraints: const BoxConstraints(maxHeight: 200),

                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: const BorderRadius.only(
                            bottomRight: Radius.circular(10),
                            bottomLeft: Radius.circular(10),
                          ),
                        ),

                        child: filteredItems.isEmpty
                            /// Display message when no data is found.
                            ? Padding(
                                padding: const EdgeInsets.all(16),
                                child: Center(
                                  child: Text('Data not found', style: widget.itemTextStyle ?? textStyleTiny(context)),
                                ),
                              )
                            /// Display filtered items.
                            : ListView.separated(
                                shrinkWrap: true,
                                itemCount: filteredItems.length,

                                /// Divider between items.
                                separatorBuilder: (_, __) => const Divider(height: 0),

                                itemBuilder: (_, index) {
                                  final item = filteredItems[index];

                                  return ListTile(
                                    title: Text(
                                      widget.itemToString(item),
                                      style: widget.itemTextStyle ?? textStyleTiny(context),
                                    ),

                                    /// Select the item when tapped.
                                    onTap: () => _selectItem(item),
                                  );
                                },
                              ),
                      )
                    /// Empty widget when dropdown is hidden.
                    : const SizedBox(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
