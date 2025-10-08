import 'dart:io';

import 'package:fx_helper/snackbar_helper.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

class PickerHelper {
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

  static Future<PlatformFile?> pickImage(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      return result.files.first;
    } else {
      SnackbarHelper.showSnackBar(SnackbarState.success, "Cancelled");
    }
    return null;
  }

  static Future<File?> pickPhoto(ImageSource media, {int quality = 50}) async {
    final ImagePicker picker = ImagePicker();
    var foto = await picker.pickImage(source: media, imageQuality: quality);
    if (foto != null) {
      File image = File(foto.path);
      return image;
    }
    return null;
  }

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
