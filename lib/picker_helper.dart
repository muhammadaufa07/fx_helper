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
        // selectedDayHighlightColor: primaryColor,
        calendarType: CalendarDatePicker2Type.range,
        // daySplashColor: primaryColor.withValues(alpha: 0.3),
        firstDate: DateTime(1900),
      ),
      dialogSize: const Size(325, 370),
      borderRadius: BorderRadius.circular(15),
      value: [DateTime.now()],
      dialogBackgroundColor: Colors.white,
      // barrierColor: greyColor.withValues(alpha: 0.6),
      barrierDismissible: true,
      useSafeArea: true,
    );
    return result;
  }

  static Future<DateTime?> pickDate(BuildContext context) async {
    final result = await showCalendarDatePicker2Dialog(
      context: context,
      config: CalendarDatePicker2WithActionButtonsConfig(
        // selectedDayHighlightColor: primaryColor,
        calendarType: CalendarDatePicker2Type.single,
        // daySplashColor: primaryColor.withValues(alpha: 0.3),
        firstDate: DateTime(1900),
      ),
      dialogSize: const Size(325, 370),
      borderRadius: BorderRadius.circular(15),
      value: [DateTime.now()],
      dialogBackgroundColor: Colors.white,
      // barrierColor: greyColor.withValues(alpha: 0.6),
      barrierDismissible: true,
      useSafeArea: true,
    );
    return result?.first;
  }

  static Future<TimeOfDay?> pickTime(BuildContext context) {
    var time = showTimePicker(context: context, initialTime: TimeOfDay.now());
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

  Future<File?> pickPhoto(ImageSource media, {int quality = 50}) async {
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
        headerSettings: PickerHeaderSettings(
          // headerBackgroundColor: primaryColor,
          // headerCurrentPageTextStyle: textStyleBig(appContext).copyWith(fontWeight: FontWeight.bold, color: whiteColor),
          // headerSelectedIntervalTextStyle: textStyleMedium(
          //   appContext,
          // ).copyWith(fontWeight: FontWeight.bold, color: whiteColor),
        ),
        dateButtonsSettings: PickerDateButtonsSettings(
          // monthTextStyle: textStyleSmall(appContext).copyWith(fontWeight: FontWeight.bold),
          // yearTextStyle: textStyleSmall(appContext).copyWith(fontWeight: FontWeight.bold),
          // unselectedMonthsTextColor: primaryColor,
          // currentMonthTextColor: blackColor,
        ),
        dialogSettings: PickerDialogSettings(
          // dialogBackgroundColor: whiteColor,
          dismissible: true,
          locale: Locale('id'),
        ),
        actionBarSettings: PickerActionBarSettings(
          confirmWidget: Text(
            'Pilih',
            // style: textStyleSmall(appContext).copyWith(fontWeight: FontWeight.bold, color: blackColor),
          ),
          cancelWidget: Text(
            'Batal',
            // style: textStyleSmall(appContext).copyWith(fontWeight: FontWeight.bold, color: primaryColor),
          ),
        ),
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
        // headerSettings: PickerHeaderSettings(
        //   headerBackgroundColor: primaryColor,
        //   headerCurrentPageTextStyle: textStyleBig(appContext).copyWith(fontWeight: FontWeight.bold, color: whiteColor),
        //   headerSelectedIntervalTextStyle: textStyleMedium(
        //     appContext,
        //   ).copyWith(fontWeight: FontWeight.bold, color: whiteColor),
        // ),
        // dateButtonsSettings: PickerDateButtonsSettings(
        //   monthTextStyle: textStyleSmall(appContext).copyWith(fontWeight: FontWeight.bold),
        //   yearTextStyle: textStyleSmall(appContext).copyWith(fontWeight: FontWeight.bold),
        //   unselectedMonthsTextColor: primaryColor,
        //   currentMonthTextColor: blackColor,
        // ),
        dialogSettings: PickerDialogSettings(
          // dialogBackgroundColor: whiteColor,
          dismissible: true,
          locale: Locale('id'),
        ),
        actionBarSettings: PickerActionBarSettings(
          confirmWidget: Text(
            'Pilih',
            // style: textStyleSmall(appContext).copyWith(fontWeight: FontWeight.bold, color: blackColor),
          ),
          cancelWidget: Text(
            'Batal',
            // style: textStyleSmall(appContext).copyWith(fontWeight: FontWeight.bold, color: primaryColor),
          ),
        ),
      ),
    );
  }
}
