import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fx_helper/widgets/fx_theme.dart';

// /// A searchable dropdown widget that allows users to filter
// /// and select an item from a list.
// ///
// /// [T] is a generic type, so this widget can be used with
// /// String, custom models, or any other object type.
// /// A searchable dropdown widget.
// ///
// /// Supports any type `T`.
// ///
// /// Example with String:
// /// ```dart
// /// SearchListField<String>(
// ///   value: selectedCountry,
// ///   items: countries,
// ///   itemToString: (country) => country,
// ///   hint: 'Select country',
// ///   onChanged: (value) {
// ///     setState(() => selectedCountry = value);
// ///   },
// /// )
// /// ```
// ///
// /// Example with custom model:
// /// ```dart
// /// SearchListField<User>(
// ///   value: selectedUser,
// ///   items: users,
// ///   itemToString: (user) => user.name,
// ///   hint: 'Select user',
// ///   onChanged: (user) {
// ///     setState(() => selectedUser = user);
// ///   },
// /// )
// /// ```
// class SearchListField<T> extends StatefulWidget {
//   /// Currently selected value.
//   final T? value;

//   /// List of items available in the dropdown.
//   ///
//   /// Example:
//   /// ```dart
//   /// items: const [
//   ///   'Male',
//   ///   'Female',
//   /// ]
//   /// ```
//   final List<T> items;

//   /// Callback triggered when an item is selected.
//   /// Called when an item is selected.
//   ///
//   /// Example:
//   /// ```dart
//   /// onChanged: (value) {
//   ///   setState(() {
//   ///     selectedCountry = value;
//   ///   });
//   /// }
//   /// ```
//   final ValueChanged<T?> onChanged;

//   /// Converts an item into a displayable string.
//   ///
//   /// Example:
//   /// ```dart
//   /// itemToString: (user) => user.name
//   /// ```
//   final String Function(T) itemToString;

//   /// Label shown above the text field.
//   final String? label;

//   /// Placeholder text displayed when no value is selected.
//   final String hint;

//   /// Text style used for the hint.
//   final TextStyle? hintStyle;

//   /// Text style used for items and selected value.
//   final TextStyle? itemTextStyle;

//   /// A searchable dropdown widget that allows users to filter
//   /// and select an item from a list.
//   ///
//   /// [T] is a generic type, so this widget can be used with
//   /// String, custom models, or any other object type.
//   /// A searchable dropdown widget.
//   ///
//   /// Supports any type `T`.
//   ///
//   /// Example with String:
//   /// ```dart
//   /// SearchListField<String>(
//   ///   value: selectedCountry,
//   ///   items: countries,
//   ///   itemToString: (country) => country,
//   ///   hint: 'Select country',
//   ///   onChanged: (value) {
//   ///     setState(() => selectedCountry = value);
//   ///   },
//   /// )
//   /// ```
//   ///
//   /// Example with custom model:
//   /// ```dart
//   /// SearchListField<User>(
//   ///   value: selectedUser,
//   ///   items: users,
//   ///   itemToString: (user) => user.name,
//   ///   hint: 'Select user',
//   ///   onChanged: (user) {
//   ///     setState(() => selectedUser = user);
//   ///   },
//   /// )
//   /// ```
//   const SearchListField({
//     super.key,
//     required this.value,
//     required this.items,
//     required this.onChanged,
//     required this.itemToString,
//     this.label,
//     required this.hint,
//     this.hintStyle,
//     this.itemTextStyle,
//   });

//   @override
//   State<SearchListField<T>> createState() => _FormFieldListState<T>();
// }

// /// TickerProviderStateMixin is required by AnimatedSize
// /// to provide animation frames efficiently.
// class _FormFieldListState<T> extends State<SearchListField<T>> with TickerProviderStateMixin {
//   /// Controller used to manage the text inside the TextField.
//   late TextEditingController _controller;

//   /// List containing filtered items based on user input.
//   List<T> filteredItems = [];

//   /// Determines whether the dropdown list is visible.
//   bool showList = false;

//   /// Used to manage TextField focus.
//   late FocusNode _focusNode;

//   @override
//   void initState() {
//     super.initState();

//     /// Initialize the TextField with the selected value if available.
//     _controller = TextEditingController(text: widget.value != null ? widget.itemToString(widget.value!) : '');

//     _focusNode = FocusNode();

//     /// Initially display all items.
//     filteredItems = widget.items;
//   }

//   @override
//   void dispose() {
//     /// Prevent memory leaks.
//     _controller.dispose();
//     _focusNode.dispose();
//     super.dispose();
//   }

//   /// Called whenever the text inside the TextField changes.
//   ///
//   /// Displays the dropdown and filters items that contain
//   /// the entered text.
//   void _onChanged(String query) {
//     setState(() {
//       showList = true;

//       filteredItems = widget.items.where((item) {
//         return widget.itemToString(item).toLowerCase().contains(query.toLowerCase());
//       }).toList();
//     });
//   }

//   /// Opens or closes the dropdown list.
//   ///
//   /// When opening:
//   /// - All items are restored.
//   /// - Focus is requested.
//   ///
//   /// When closing:
//   /// - Focus is removed.
//   void _toggleDropdown() {
//     setState(() {
//       showList = !showList;

//       if (showList) {
//         filteredItems = widget.items;
//         _focusNode.requestFocus();
//       } else {
//         _focusNode.unfocus();
//       }
//     });
//   }

//   /// Handles item selection.
//   ///
//   /// After selecting:
//   /// - TextField value is updated.
//   /// - Dropdown is closed.
//   /// - Parent callback is triggered.
//   void _selectItem(T item) {
//     _controller.text = widget.itemToString(item);

//     setState(() {
//       showList = false;
//     });

//     _focusNode.unfocus();

//     widget.onChanged(item);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return TapRegion(
//       /// Close the dropdown when tapping outside the widget.
//       onTapOutside: (_) {
//         if (showList) {
//           setState(() {
//             showList = false;
//           });

//           _focusNode.unfocus();
//         }
//       },
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           TextField(
//             controller: _controller,
//             style: widget.itemTextStyle ?? textStyleTiny(context),
//             focusNode: _focusNode,
//             decoration: InputDecoration(
//               labelText: widget.label,
//               labelStyle: textStyleTiny(context),
//               filled: true,
//               fillColor: Colors.white,

//               /// Rotate the arrow icon when the dropdown opens.
//               ///
//               /// 0 turns = arrow down
//               /// 0.5 turns = arrow up (180° rotation)
//               suffixIcon: AnimatedRotation(
//                 turns: showList ? 0.5 : 0,
//                 duration: const Duration(milliseconds: 200),
//                 curve: Curves.easeInOut,
//                 child: const Icon(Icons.keyboard_arrow_down_rounded),
//               ),

//               contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),

//               errorStyle: textStyleTiny(context).copyWith(color: Colors.red),

//               hint: Text(
//                 widget.hint,
//                 style: widget.hintStyle ?? textStyleSmall(context).copyWith(color: Color(0xFFBEBEBE)),
//               ),

//               /// Default border.
//               ///
//               /// Bottom radius becomes zero while the dropdown is open
//               /// so that the TextField and list look connected.
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.only(
//                   topRight: const Radius.circular(10),
//                   topLeft: const Radius.circular(10),
//                   bottomLeft: Radius.circular(showList ? 0 : 10),
//                   bottomRight: Radius.circular(showList ? 0 : 10),
//                 ),
//                 borderSide: BorderSide(color: Color(0xFFBEBEBE)),
//               ),

//               /// Border shown when enabled.
//               enabledBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.only(
//                   topRight: const Radius.circular(10),
//                   topLeft: const Radius.circular(10),
//                   bottomLeft: Radius.circular(showList ? 0 : 10),
//                   bottomRight: Radius.circular(showList ? 0 : 10),
//                 ),
//                 borderSide: BorderSide(color: Color(0xFFBEBEBE)),
//               ),

//               /// Border shown while focused.
//               focusedBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.only(
//                   topRight: const Radius.circular(10),
//                   topLeft: const Radius.circular(10),
//                   bottomLeft: Radius.circular(showList ? 0 : 10),
//                   bottomRight: Radius.circular(showList ? 0 : 10),
//                 ),
//                 borderSide: BorderSide(color: Colors.black),
//               ),

//               /// Border shown when an error occurs.
//               errorBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.only(
//                   topRight: const Radius.circular(10),
//                   topLeft: const Radius.circular(10),
//                   bottomLeft: Radius.circular(showList ? 0 : 10),
//                   bottomRight: Radius.circular(showList ? 0 : 10),
//                 ),
//                 borderSide: BorderSide(color: Colors.red),
//               ),

//               /// Border shown when focused and an error occurs.
//               focusedErrorBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.only(
//                   topRight: const Radius.circular(10),
//                   topLeft: const Radius.circular(10),
//                   bottomLeft: Radius.circular(showList ? 0 : 10),
//                   bottomRight: Radius.circular(showList ? 0 : 10),
//                 ),
//                 borderSide: BorderSide(color: Colors.red),
//               ),
//             ),

//             onChanged: _onChanged,

//             /// Toggle dropdown when TextField is tapped.
//             onTap: _toggleDropdown,
//           ),

//           /// Prevent child overflow during size animation.
//           ClipRect(
//             child: AnimatedSize(
//               /// Animate height changes smoothly.
//               duration: const Duration(milliseconds: 300),
//               curve: Curves.fastEaseInToSlowEaseOut,

//               child: AnimatedOpacity(
//                 /// Fade in and fade out animation.
//                 duration: const Duration(milliseconds: 150),

//                 /// Show opacity only when dropdown is visible.
//                 opacity: showList ? 1 : 0,

//                 child: showList
//                     ? Container(
//                         /// Maximum dropdown height.
//                         constraints: const BoxConstraints(maxHeight: 200),

//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           border: Border.all(color: Colors.grey.shade300),
//                           borderRadius: const BorderRadius.only(
//                             bottomRight: Radius.circular(10),
//                             bottomLeft: Radius.circular(10),
//                           ),
//                         ),

//                         child: filteredItems.isEmpty
//                             /// Display message when no data is found.
//                             ? Padding(
//                                 padding: const EdgeInsets.all(16),
//                                 child: Center(
//                                   child: Text('Data not found', style: widget.itemTextStyle ?? textStyleTiny(context)),
//                                 ),
//                               )
//                             /// Display filtered items.
//                             : ListView.separated(
//                                 shrinkWrap: true,
//                                 itemCount: filteredItems.length,

//                                 /// Divider between items.
//                                 separatorBuilder: (_, __) => const Divider(height: 0),

//                                 itemBuilder: (_, index) {
//                                   final item = filteredItems[index];

//                                   return ListTile(
//                                     title: Text(
//                                       widget.itemToString(item),
//                                       style: widget.itemTextStyle ?? textStyleTiny(context),
//                                     ),

//                                     /// Select the item when tapped.
//                                     onTap: () => _selectItem(item),
//                                   );
//                                 },
//                               ),
//                       )
//                     /// Empty widget when dropdown is hidden.
//                     : const SizedBox(),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fx_helper/widgets/fx_theme.dart';

/// ---------------------------------------------------------------------------
///
/// SearchListField<T>
///
/// A reusable searchable dropdown widget.
///
/// Features:
///
/// • Generic
/// • Search
/// • Form Validation
/// • Provider Friendly
/// • Clear Button
/// • Loading State
/// • ReadOnly
/// • Enabled
/// • Compare Key
/// • Custom Item Builder
/// • Async Search
/// • Keyboard Navigation
/// • Auto Scroll
/// • Highlight Search
///
/// Example:
///
/// ```dart
/// SearchListField<User>(
///   value: provider.selectedUser,
///   items: provider.users,
///   itemToString: (e) => e.name,
///   compareKey: (e) => e.id,
///   onChanged: (e){
///      provider.selectedUser = e;
///   },
/// )
/// ```
///
/// ---------------------------------------------------------------------------
class SearchListField<T> extends StatefulWidget {
  /// Current selected value.
  final T? value;

  /// Source data.
  final List<T> items;

  /// Converts item into display text.
  final String Function(T item) itemToString;

  /// Called whenever selection changes.
  final ValueChanged<T?> onChanged;

  /// Compare object equality.
  ///
  /// Example:
  ///
  /// compareKey: (user) => user.id
  ///
  final Object? Function(T item)? compareKey;

  /// Optional async search callback.
  final Future<List<T>> Function(String keyword)? onSearch;

  /// Validator.
  final String? Function(T?)? validator;

  /// Hint text.
  final String hint;

  /// Label text.
  final String? label;

  /// Enable widget.
  final bool enabled;

  /// Read only mode.
  final bool readOnly;

  /// Autofocus.
  final bool autofocus;

  /// Show loading indicator.
  final bool loading;

  /// Allow clearing selected item.
  final bool showClearButton;

  /// Highlight searched keyword.
  final bool highlightSearch;

  /// Enable keyboard navigation.
  final bool enableKeyboardNavigation;

  /// Automatically scroll to selected item.
  final bool scrollToSelected;

  /// Search debounce duration.
  final Duration debounceDuration;

  /// Maximum dropdown height.
  final double maxDropdownHeight;

  /// Text style.
  final TextStyle? itemTextStyle;

  /// Hint style.
  final TextStyle? hintStyle;

  /// Background color.
  final Color backgroundColor;

  /// Border radius.
  final BorderRadius borderRadius;

  /// Custom suffix icon.
  final Widget? suffixIcon;

  /// Custom widget when list empty.
  final Widget? emptyWidget;

  /// Custom item builder.
  final Widget Function(BuildContext context, T item, bool selected)? itemBuilder;

  const SearchListField({
    super.key,
    required this.value,
    required this.items,
    required this.itemToString,
    required this.onChanged,
    required this.hint,
    this.compareKey,
    this.onSearch,
    this.validator,
    this.label,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.loading = false,
    this.showClearButton = true,
    this.highlightSearch = true,
    this.enableKeyboardNavigation = true,
    this.scrollToSelected = true,
    this.debounceDuration = const Duration(milliseconds: 300),
    this.maxDropdownHeight = 220,
    this.itemTextStyle,
    this.hintStyle,
    this.backgroundColor = Colors.white,
    this.borderRadius = const BorderRadius.all(Radius.circular(10)),
    this.suffixIcon,
    this.emptyWidget,
    this.itemBuilder,
  });

  @override
  State<SearchListField<T>> createState() => _SearchListFieldState<T>();
}

class _SearchListFieldState<T> extends State<SearchListField<T>> with TickerProviderStateMixin {
  //---------------------------------------------------------
  // Controller
  //---------------------------------------------------------

  late final TextEditingController _controller;

  late final FocusNode _focusNode;

  late final ScrollController _scrollController;

  //---------------------------------------------------------
  // Search
  //---------------------------------------------------------

  Timer? _debounce;

  String _keyword = '';

  //---------------------------------------------------------
  // Data
  //---------------------------------------------------------

  late List<T> filteredItems;

  //---------------------------------------------------------
  // State
  //---------------------------------------------------------

  bool showList = false;

  int _hoverIndex = -1;

  //---------------------------------------------------------
  // Getter
  //---------------------------------------------------------

  String get _selectedText {
    if (widget.value == null) {
      return '';
    }

    return widget.itemToString(widget.value as T);
  }

  //---------------------------------------------------------
  // Init
  //---------------------------------------------------------

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController(text: _selectedText);

    _focusNode = FocusNode();

    _scrollController = ScrollController();

    filteredItems = List<T>.from(widget.items);

    _focusNode.addListener(_handleFocusChanged);
  }

  //---------------------------------------------------------
  // Update
  //---------------------------------------------------------

  @override
  void didUpdateWidget(covariant SearchListField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    filteredItems = List<T>.from(widget.items);

    bool shouldUpdate = false;

    if (widget.compareKey != null) {
      final oldKey = oldWidget.value == null ? null : widget.compareKey!(oldWidget.value as T);

      final newKey = widget.value == null ? null : widget.compareKey!(widget.value as T);

      shouldUpdate = oldKey != newKey;
    } else {
      shouldUpdate = oldWidget.value != widget.value;
    }

    if (shouldUpdate) {
      _restoreSelectedValue();
    }
  }

  //---------------------------------------------------------
  // Dispose
  //---------------------------------------------------------

  @override
  void dispose() {
    _debounce?.cancel();

    _focusNode.removeListener(_handleFocusChanged);

    _focusNode.dispose();

    _controller.dispose();

    _scrollController.dispose();

    super.dispose();
  }

  //---------------------------------------------------------
  // Focus
  //---------------------------------------------------------

  void _handleFocusChanged() {
    if (!_focusNode.hasFocus) {
      _restoreSelectedValue();

      if (mounted) {
        setState(() {
          showList = false;
        });
      }
    }
  }

  //---------------------------------------------------------
  // Restore Selected Value
  //---------------------------------------------------------

  void _restoreSelectedValue() {
    final text = widget.value == null ? '' : widget.itemToString(widget.value as T);

    if (_controller.text == text) return;

    _controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  //---------------------------------------------------------
  // Clear Selection
  //---------------------------------------------------------

  void _clearSelection() {
    _keyword = '';

    _controller.clear();

    filteredItems = List<T>.from(widget.items);

    widget.onChanged(null);

    if (mounted) {
      setState(() {});
    }
  }

  //---------------------------------------------------------
  // Search
  //---------------------------------------------------------

  void _onSearchChanged(String keyword) {
    _debounce?.cancel();

    _debounce = Timer(widget.debounceDuration, () async {
      _keyword = keyword;

      if (widget.onSearch != null) {
        final result = await widget.onSearch!(keyword);

        if (!mounted) return;

        setState(() {
          filteredItems = result;
          showList = true;
        });

        return;
      }

      _filterItems(keyword);
    });
  }

  //---------------------------------------------------------
  // Filter
  //---------------------------------------------------------

  void _filterItems(String keyword) {
    final query = keyword.trim().toLowerCase();

    setState(() {
      showList = true;

      if (query.isEmpty) {
        filteredItems = List<T>.from(widget.items);
        return;
      }

      filteredItems = widget.items.where((item) {
        return widget.itemToString(item).trim().toLowerCase().contains(query);
      }).toList();
    });
  }

  //---------------------------------------------------------
  // Toggle Dropdown
  //---------------------------------------------------------

  void _toggleDropdown() {
    if (!widget.enabled) return;

    if (widget.loading) return;

    setState(() {
      showList = !showList;

      if (showList) {
        filteredItems = List<T>.from(widget.items);

        _scrollToSelected();

        _focusNode.requestFocus();
      } else {
        _restoreSelectedValue();

        _focusNode.unfocus();
      }
    });
  }

  //---------------------------------------------------------
  // Select Item
  //---------------------------------------------------------

  void _selectItem(T item) {
    final text = widget.itemToString(item);

    _controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );

    setState(() {
      showList = false;

      filteredItems = List<T>.from(widget.items);
    });

    _focusNode.unfocus();

    widget.onChanged(item);
  }

  //---------------------------------------------------------
  // Scroll To Selected
  //---------------------------------------------------------

  void _scrollToSelected() {
    if (!widget.scrollToSelected) return;

    if (widget.value == null) return;

    final index = filteredItems.indexWhere((item) {
      if (widget.compareKey != null) {
        return widget.compareKey!(item) == widget.compareKey!(widget.value as T);
      }

      return item == widget.value;
    });

    if (index == -1) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;

      _scrollController.animateTo(index * 48.0, duration: const Duration(milliseconds: 250), curve: Curves.ease);
    });
  }

  //---------------------------------------------------------
  // Keyboard Navigation
  //---------------------------------------------------------

  void _handleKey(RawKeyEvent event) {
    if (!widget.enableKeyboardNavigation) return;

    if (event is! RawKeyDownEvent) return;

    if (event.logicalKey == LogicalKeyboardKey.escape) {
      _toggleDropdown();
      return;
    }

    if (!showList) return;

    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      setState(() {
        if (_hoverIndex < filteredItems.length - 1) {
          _hoverIndex++;
        }
      });

      return;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      setState(() {
        if (_hoverIndex > 0) {
          _hoverIndex--;
        }
      });

      return;
    }

    if (event.logicalKey == LogicalKeyboardKey.enter) {
      if (_hoverIndex >= 0 && _hoverIndex < filteredItems.length) {
        _selectItem(filteredItems[_hoverIndex]);
      }
    }
  }

  //---------------------------------------------------------
  // Highlight Search
  //---------------------------------------------------------

  Widget _buildHighlightText(BuildContext context, String text) {
    if (!widget.highlightSearch) {
      return Text(text, style: widget.itemTextStyle ?? textStyleTiny(context));
    }

    final keyword = _keyword.trim();

    if (keyword.isEmpty) {
      return Text(text, style: widget.itemTextStyle ?? textStyleTiny(context));
    }

    final index = text.toLowerCase().indexOf(keyword.toLowerCase());

    if (index == -1) {
      return Text(text, style: widget.itemTextStyle ?? textStyleTiny(context));
    }

    return RichText(
      text: TextSpan(
        style: widget.itemTextStyle ?? textStyleTiny(context),
        children: [
          TextSpan(text: text.substring(0, index)),
          TextSpan(
            text: text.substring(index, index + keyword.length),
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
          ),
          TextSpan(text: text.substring(index + keyword.length)),
        ],
      ),
    );
  }

  //---------------------------------------------------------
  // Suffix Icon
  //---------------------------------------------------------

  Widget _buildSuffixIcon() {
    if (widget.loading) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    if (widget.suffixIcon != null) {
      return widget.suffixIcon!;
    }

    final hasValue = widget.value != null && _controller.text.isNotEmpty;

    if (widget.showClearButton && hasValue && widget.enabled) {
      return IconButton(splashRadius: 18, icon: const Icon(Icons.close), onPressed: _clearSelection);
    }

    return AnimatedRotation(
      turns: showList ? .5 : 0,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: const Icon(Icons.keyboard_arrow_down_rounded),
    );
  }

  //---------------------------------------------------------
  // Border Builder
  //---------------------------------------------------------

  OutlineInputBorder _buildBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.only(
        topLeft: widget.borderRadius.topLeft,
        topRight: widget.borderRadius.topRight,
        bottomLeft: Radius.circular(showList ? 0 : widget.borderRadius.bottomLeft.x),
        bottomRight: Radius.circular(showList ? 0 : widget.borderRadius.bottomRight.x),
      ),
      borderSide: BorderSide(color: color),
    );
  }

  //---------------------------------------------------------
  // Empty Widget
  //---------------------------------------------------------

  Widget _buildEmptyWidget(BuildContext context) {
    if (widget.emptyWidget != null) {
      return widget.emptyWidget!;
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Center(child: Text('Data not found', style: widget.itemTextStyle ?? textStyleTiny(context))),
    );
  }

  //---------------------------------------------------------
  // Build
  //---------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: FocusNode(),
      onKey: _handleKey,
      child: TapRegion(
        onTapOutside: (_) {
          if (showList) {
            _restoreSelectedValue();

            setState(() {
              showList = false;
            });

            _focusNode.unfocus();
          }
        },
        child: FormField<T>(
          initialValue: widget.value,
          validator: widget.validator,
          builder: (field) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //--------------------------------------------------
                // TextField
                //--------------------------------------------------
                TextFormField(
                  controller: _controller,
                  focusNode: _focusNode,

                  enabled: widget.enabled,

                  autofocus: widget.autofocus,

                  readOnly: widget.readOnly,

                  style: widget.itemTextStyle ?? textStyleTiny(context),

                  onChanged: _onSearchChanged,

                  onTap: _toggleDropdown,

                  decoration: InputDecoration(
                    filled: true,

                    fillColor: widget.backgroundColor,

                    labelText: widget.label,

                    hintText: widget.hint,

                    hintStyle: widget.hintStyle ?? textStyleSmall(context).copyWith(color: const Color(0xffBEBEBE)),

                    errorText: field.errorText,

                    suffixIcon: _buildSuffixIcon(),

                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),

                    border: _buildBorder(const Color(0xffBEBEBE)),

                    enabledBorder: _buildBorder(const Color(0xffBEBEBE)),

                    focusedBorder: _buildBorder(Colors.black),

                    disabledBorder: _buildBorder(Colors.grey.shade300),

                    errorBorder: _buildBorder(Colors.red),

                    focusedErrorBorder: _buildBorder(Colors.red),
                  ),
                ),

                //--------------------------------------------------
                // Dropdown
                //--------------------------------------------------
                ClipRect(
                  child: AnimatedSize(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 150),
                      opacity: showList ? 1 : 0,
                      child: showList
                          ? Container(
                              constraints: BoxConstraints(maxHeight: widget.maxDropdownHeight),
                              decoration: BoxDecoration(
                                color: widget.backgroundColor,
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.only(
                                  bottomLeft: widget.borderRadius.bottomLeft,
                                  bottomRight: widget.borderRadius.bottomRight,
                                ),
                              ),
                              child: filteredItems.isEmpty
                                  ? _buildEmptyWidget(context)
                                  : ListView.separated(
                                      controller: _scrollController,
                                      padding: EdgeInsets.zero,
                                      shrinkWrap: true,
                                      itemCount: filteredItems.length,
                                      separatorBuilder: (_, __) => Divider(height: 0, color: Colors.grey.shade300),
                                      itemBuilder: (context, index) {
                                        final item = filteredItems[index];

                                        final isSelected =
                                            widget.value != null &&
                                            ((widget.compareKey != null &&
                                                    widget.compareKey!(widget.value as T) ==
                                                        widget.compareKey!(item)) ||
                                                (widget.compareKey == null && widget.value == item));

                                        if (widget.itemBuilder != null) {
                                          return InkWell(
                                            onTap: () => _selectItem(item),
                                            child: widget.itemBuilder!(context, item, isSelected),
                                          );
                                        }

                                        return Material(
                                          color: isSelected ? Colors.grey.shade100 : Colors.transparent,
                                          child: InkWell(
                                            onTap: () => _selectItem(item),
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: _buildHighlightText(context, widget.itemToString(item)),
                                                  ),

                                                  if (isSelected) const Icon(Icons.check, size: 18),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                            )
                          : const SizedBox(),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
