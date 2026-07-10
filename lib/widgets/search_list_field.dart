import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fx_helper/widgets/fx_theme.dart';

/// A searchable dropdown widget that allows users to filter
/// and select an item from a list.
///
/// [T] is a generic type, so this widget can be used with
/// String, custom models, or any other object type.
///
/// Supports form [validator], [readOnly] / [enabled] states,
/// [autofocus], a clear button, an [isLoading] state, and
/// debounced filtering for large [items] lists.
///
/// Example with String:
/// ```dart
/// SearchListField<String>(
///   value: selectedCountry,
///   items: countries,
///   itemToString: (country) => country,
///   hint: 'Select country',
///   onChanged: (value) {
///     setState(() => selectedCountry = value);
///   },
///   validator: (value) => value == null ? 'Required' : null,
/// )
/// ```
///
/// Example with custom model:
/// ```dart
/// SearchListField<User>(
///   value: selectedUser,
///   items: users,
///   itemToString: (user) => user.name,
///   hint: 'Select user',
///   onChanged: (user) {
///     setState(() => selectedUser = user);
///   },
/// )
/// ```
class SearchListField<T> extends StatefulWidget {
  /// Currently selected value.
  final T? value;

  /// List of items available in the dropdown.
  ///
  /// Example:
  /// ```dart
  /// items: const [
  ///   'Male',
  ///   'Female',
  /// ]
  /// ```
  final List<T> items;

  /// Callback triggered when an item is selected.
  /// Called when an item is selected.
  ///
  /// Example:
  /// ```dart
  /// onChanged: (value) {
  ///   setState(() {
  ///     selectedCountry = value;
  ///   });
  /// }
  /// ```
  final ValueChanged<T?> onChanged;

  /// Converts an item into a displayable string.
  ///
  /// Example:
  /// ```dart
  /// itemToString: (user) => user.name
  /// ```
  final String Function(T) itemToString;

  /// Label shown above the text field.
  final String? label;

  /// Placeholder text displayed when no value is selected.
  final String hint;

  /// Text style used for the hint.
  final TextStyle? hintStyle;

  /// Text style used for items and selected value.
  final TextStyle? itemTextStyle;

  /// Validates the selected value when used inside a [Form].
  final FormFieldValidator<T>? validator;

  /// Controls when the [validator] runs automatically.
  final AutovalidateMode autovalidateMode;

  /// Called when the enclosing [Form] is saved.
  final FormFieldSetter<T>? onSaved;

  /// When true, the text can't be edited but the dropdown can
  /// still be opened to pick an item.
  final bool readOnly;

  /// When false, the field is disabled: it can't be focused,
  /// edited, or opened.
  final bool enabled;

  /// Whether the field should be focused as soon as it's built.
  final bool autofocus;

  /// Whether to show a button that clears the current value.
  final bool showClearButton;

  /// Shows a loading indicator instead of the dropdown arrow
  /// and replaces the list with a spinner, e.g. while [items]
  /// is being fetched asynchronously.
  final bool isLoading;

  /// Delay before filtering runs after the user types, so large
  /// [items] lists aren't re-filtered on every keystroke.
  final Duration searchDebounce;

  /// A searchable dropdown widget that allows users to filter
  /// and select an item from a list.
  ///
  /// [T] is a generic type, so this widget can be used with
  /// String, custom models, or any other object type.
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
    this.validator,
    this.autovalidateMode = AutovalidateMode.disabled,
    this.onSaved,
    this.readOnly = false,
    this.enabled = true,
    this.autofocus = false,
    this.showClearButton = true,
    this.isLoading = false,
    this.searchDebounce = const Duration(milliseconds: 250),
  });

  @override
  State<SearchListField<T>> createState() => _FormFieldListState<T>();
}

/// Pairs an item with its precomputed lowercase search key so large
/// [SearchListField.items] lists don't recompute it on every keystroke.
class _SearchEntry<T> {
  final T item;
  final String key;

  const _SearchEntry(this.item, this.key);
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

  /// [widget.items] paired with precomputed lowercase search keys.
  List<_SearchEntry<T>> _searchEntries = [];

  /// Current search query, kept to re-filter when [widget.items] changes.
  String _query = '';

  /// Delays filtering until the user stops typing.
  Timer? _debounce;

  /// Set by the internal [FormField] builder so selection/clear can
  /// notify the enclosing [Form] via [FormFieldState.didChange].
  FormFieldState<T>? _fieldState;

  @override
  void initState() {
    super.initState();

    /// Initialize the TextField with the selected value if available.
    _controller = TextEditingController(text: widget.value != null ? widget.itemToString(widget.value!) : '');

    _focusNode = FocusNode();

    _rebuildSearchEntries();

    /// Initially display all items.
    filteredItems = widget.items;
  }

  @override
  void didUpdateWidget(covariant SearchListField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    /// Update the list when data changes.
    if (oldWidget.items != widget.items) {
      _rebuildSearchEntries();
      filteredItems = _applyFilter(_query);
    }

    /// Sync the controller with the value from the parent.
    final newText = widget.value != null ? widget.itemToString(widget.value!) : '';

    if (_controller.text != newText) {
      _controller.text = newText;
    }

    /// Keep the enclosing Form's validation state in sync when the
    /// value is changed externally (e.g. a programmatic reset).
    if (oldWidget.value != widget.value) {
      _fieldState?.didChange(widget.value);
    }

    /// Close the dropdown if the field becomes disabled.
    if (oldWidget.enabled && !widget.enabled && showList) {
      showList = false;
      _focusNode.unfocus();
    }
  }

  @override
  void dispose() {
    /// Prevent memory leaks.
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// Precomputes lowercase search keys for [widget.items] so filtering
  /// doesn't call [SearchListField.itemToString] and `toLowerCase()` on
  /// every item for every keystroke, which matters for large lists.
  void _rebuildSearchEntries() {
    _searchEntries = widget.items.map((item) => _SearchEntry(item, widget.itemToString(item).toLowerCase())).toList();
  }

  /// Filters [_searchEntries] using the given [query].
  List<T> _applyFilter(String query) {
    if (query.isEmpty) return widget.items;

    final lowerQuery = query.toLowerCase();

    return _searchEntries.where((entry) => entry.key.contains(lowerQuery)).map((entry) => entry.item).toList();
  }

  /// Called whenever the text inside the TextField changes.
  ///
  /// Opens the dropdown immediately, but debounces the actual
  /// filtering so large lists aren't re-filtered on every keystroke.
  void _onChanged(String query) {
    _query = query;

    setState(() => showList = true);

    _debounce?.cancel();
    _debounce = Timer(widget.searchDebounce, () {
      if (!mounted) return;

      setState(() {
        filteredItems = _applyFilter(_query);
      });
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
    if (!widget.enabled) return;

    setState(() {
      showList = !showList;

      if (showList) {
        _debounce?.cancel();
        _query = '';
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
    _fieldState?.didChange(item);
  }

  /// Clears the current value and query.
  void _clear() {
    _debounce?.cancel();
    _query = '';

    setState(() {
      _controller.clear();
      filteredItems = widget.items;
      showList = false;
    });

    _focusNode.unfocus();

    widget.onChanged(null);
    _fieldState?.didChange(null);
  }

  @override
  Widget build(BuildContext context) {
    return FormField<T>(
      initialValue: widget.value,
      validator: widget.validator,
      autovalidateMode: widget.autovalidateMode,
      onSaved: widget.onSaved,
      enabled: widget.enabled,
      builder: (field) {
        _fieldState = field;

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
                enabled: widget.enabled,
                readOnly: widget.readOnly,
                autofocus: widget.autofocus,
                decoration: InputDecoration(
                  labelText: widget.label,
                  labelStyle: textStyleTiny(context),
                  filled: true,
                  fillColor: widget.enabled ? Colors.white : const Color(0xFFF2F2F2),

                  /// Clear button and dropdown arrow (or a loading
                  /// spinner while `isLoading` is true).
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.showClearButton && widget.enabled && !widget.isLoading && _controller.text.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          splashRadius: 16,
                          onPressed: _clear,
                        ),
                      if (widget.isLoading)
                        const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      else
                        /// Rotate the arrow icon when the dropdown opens.
                        ///
                        /// 0 turns = arrow down
                        /// 0.5 turns = arrow up (180° rotation)
                        AnimatedRotation(
                          turns: showList ? 0.5 : 0,
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          child: const Icon(Icons.keyboard_arrow_down_rounded),
                        ),
                    ],
                  ),

                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),

                  errorText: field.errorText,
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

                  /// Border shown when disabled.
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.only(
                      topRight: const Radius.circular(10),
                      topLeft: const Radius.circular(10),
                      bottomLeft: Radius.circular(showList ? 0 : 10),
                      bottomRight: Radius.circular(showList ? 0 : 10),
                    ),
                    borderSide: BorderSide(color: Color(0xFFE0E0E0)),
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
                onTap: widget.enabled ? _toggleDropdown : null,
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

                            child: widget.isLoading
                                /// Show a spinner while items are being fetched.
                                ? const Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Center(
                                      child: SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      ),
                                    ),
                                  )
                                : filteredItems.isEmpty
                                ? /// Display message when no data is found.
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Center(
                                      child: Text('Data not found', style: widget.itemTextStyle ?? textStyleTiny(context)),
                                    ),
                                  )
                                : /// Display filtered items.
                                  ///
                                  /// Lazily built via ListView.separated so only
                                  /// visible rows are constructed, keeping this
                                  /// performant even for very large item lists.
                                  ListView.separated(
                                    shrinkWrap: true,
                                    itemCount: filteredItems.length,

                                    /// Divider between items.
                                    separatorBuilder: (_, _) => const Divider(height: 0),

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
      },
    );
  }
}
