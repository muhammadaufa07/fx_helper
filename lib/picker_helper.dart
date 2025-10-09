import 'dart:io';

import 'package:fx_helper/snackbar_helper.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

/// A helper class that provides various picker utilities such as:
/// - Date range picker
/// - Single date picker
/// - Time picker
/// - File and image picker
/// - Month and year picker
///
/// This class centralizes different picker dialogs used throughout the app,
/// ensuring consistent styles and behaviors across the application.
class PickerHelper {
  /// Opens a **date range picker** dialog.
  ///
  /// Returns a list of two [DateTime] values representing the **start** and **end** dates.
  /// If the user cancels the picker, this returns `null`.
  ///
  /// ### Example:
  /// ```dart
  /// final range = await PickerHelper.pickDateRange(context);
  /// if (range != null) {
  ///   print('Start: ${range.first}, End: ${range.last}');
  /// }
  /// ```
  static Future<List<DateTime?>?> pickDateRange(BuildContext context) async {
    final result = await showCalendarDatePicker2Dialog(
      context: context,
      config: CalendarDatePicker2WithActionButtonsConfig(
        calendarType: CalendarDatePicker2Type.range,
        firstDate: DateTime(1900),
      ),
      dialogSize: const Size(325, 370),
      borderRadius: BorderRadius.circular(15),
      value: [DateTime.now()],
      dialogBackgroundColor: Colors.white,
      barrierDismissible: true,
      useSafeArea: true,
    );
    return result;
  }

  /// Opens a **single date picker** dialog.
  ///
  /// The [firstDate] and [lastDate] parameters define the selectable date range.
  /// Returns the selected [DateTime], or `null` if the user cancels the picker.
  ///
  /// ### Example:
  /// ```dart
  /// final date = await PickerHelper.pickDate(context);
  /// if (date != null) {
  ///   print('Selected date: $date');
  /// }
  /// ```
  static Future<DateTime?> pickDate(BuildContext context, {DateTime? firstDate, DateTime? lastDate}) async {
    final result = await showCalendarDatePicker2Dialog(
      context: context,
      config: CalendarDatePicker2WithActionButtonsConfig(
        calendarType: CalendarDatePicker2Type.single,
        firstDate: firstDate ?? DateTime(1900),
        lastDate: lastDate,
      ),
      dialogSize: const Size(325, 370),
      borderRadius: BorderRadius.circular(15),
      value: [DateTime.now()],
      dialogBackgroundColor: Colors.white,
      barrierDismissible: true,
      useSafeArea: true,
    );
    return result?.first;
  }

  /// Opens a **24-hour format time picker** dialog.
  ///
  /// Returns the selected [TimeOfDay], or `null` if the user cancels.
  ///
  /// ### Example:
  /// ```dart
  /// final time = await PickerHelper.pickTime(context);
  /// if (time != null) {
  ///   print('Selected time: ${time.format(context)}');
  /// }
  /// ```
  static Future<TimeOfDay?> pickTime(BuildContext context) async {
    var time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (_, Widget? child) {
        return MediaQuery(data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true), child: child!);
      },
    );
    return time;
  }

  /// Opens a **file picker** dialog to select a document.
  ///
  /// Supported file types:
  /// - PDF (`.pdf`)
  /// - Word (`.doc`, `.docx`)
  /// - PowerPoint (`.ppt`, `.pptx`)
  /// - Excel (`.xls`, `.xlsx`)
  ///
  /// Returns the selected [PlatformFile], or `null` if the user cancels the picker.
  ///
  /// ### Example:
  /// ```dart
  /// final file = await PickerHelper.pickFile(context);
  /// if (file != null) {
  ///   print('File name: ${file.name}');
  /// }
  /// ```
  static Future<PlatformFile?> pickFile(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ["pdf", "doc", "docx", "ppt", "pptx", "xls", "xlsx"],
    );
    if (result != null) {
      return result.files.first;
    } else {
      SnackbarHelper.showSnackBar(SnackbarState.success, "Cancelled");
    }
    return null;
  }

  /// Opens an **image picker** dialog to select an image file from the device storage.
  ///
  /// Returns the selected [PlatformFile], or `null` if the user cancels.
  ///
  /// ### Example:
  /// ```dart
  /// final image = await PickerHelper.pickImage(context);
  /// if (image != null) {
  ///   print('Image path: ${image.path}');
  /// }
  /// ```
  static Future<PlatformFile?> pickImage(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      return result.files.first;
    } else {
      SnackbarHelper.showSnackBar(SnackbarState.success, "Cancelled");
    }
    return null;
  }

  /// Opens the **camera** or **gallery** to capture or select a photo.
  ///
  /// The [media] parameter defines the image source:
  /// - `ImageSource.camera` for camera
  /// - `ImageSource.gallery` for gallery
  ///
  /// The [quality] parameter determines image compression level (default is `50`).
  /// Returns a [File] representing the selected image, or `null` if cancelled.
  ///
  /// ### Example:
  /// ```dart
  /// final photo = await PickerHelper.pickPhoto(ImageSource.camera);
  /// if (photo != null) {
  ///   print('Captured photo path: ${photo.path}');
  /// }
  /// ```
  static Future<File?> pickPhoto(ImageSource media, {int quality = 50}) async {
    final ImagePicker picker = ImagePicker();
    var foto = await picker.pickImage(source: media, imageQuality: quality);
    if (foto != null) {
      File image = File(foto.path);
      return image;
    }
    return null;
  }

  /// Opens a **year picker** dialog.
  ///
  /// Displays a month picker restricted to **year-only selection**.
  /// Returns the selected [DateTime] (representing the chosen year), or `null` if cancelled.
  ///
  /// ### Example:
  /// ```dart
  /// final year = await PickerHelper.pickerYear(context, DateTime.now());
  /// if (year != null) {
  ///   print('Selected year: ${year.year}');
  /// }
  /// ```
  static Future<DateTime?> pickerYear(BuildContext appContext, DateTime selectedDate) async {
    return await showMonthPicker(
      context: appContext,
      initialDate: selectedDate,
      firstDate: DateTime(1999, 12, 1),
      lastDate: DateTime.now(),
      onlyYear: true,
      monthPickerDialogSettings: MonthPickerDialogSettings(
        headerSettings: PickerHeaderSettings(),
        dateButtonsSettings: PickerDateButtonsSettings(),
        dialogSettings: PickerDialogSettings(
          // dialogBackgroundColor: whiteColor,
          dismissible: true,
          locale: Locale('id'),
        ),
        actionBarSettings: PickerActionBarSettings(confirmWidget: Text('Pilih'), cancelWidget: Text('Batal')),
      ),
    );
  }

  /// Opens a **month and year picker** dialog.
  ///
  /// Allows selection of both month and year.
  /// The [firstDate] parameter defines the earliest selectable date
  /// (defaults to December 1900).
  ///
  /// Returns the selected [DateTime], or `null` if the user cancels.
  ///
  /// ### Example:
  /// ```dart
  /// final monthYear = await PickerHelper.pickerMonthYear(context, DateTime.now());
  /// if (monthYear != null) {
  ///   print('Selected: ${monthYear.month}/${monthYear.year}');
  /// }
  /// ```
  static Future<DateTime?> pickerMonthYear(
    BuildContext appContext,
    DateTime selectedDate, {
    DateTime? firstDate,
  }) async {
    return await showMonthPicker(
      context: appContext,
      initialDate: selectedDate,
      firstDate: firstDate ?? DateTime(1900, 12, 1),
      lastDate: DateTime.now(),
      monthPickerDialogSettings: MonthPickerDialogSettings(
        dialogSettings: PickerDialogSettings(dismissible: true, locale: Locale('id')),
        actionBarSettings: PickerActionBarSettings(confirmWidget: Text('Pilih'), cancelWidget: Text('Batal')),
      ),
    );
  }
}
