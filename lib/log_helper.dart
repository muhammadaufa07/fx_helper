import 'package:fx_helper/formatter_helper.dart';
import 'package:logging/logging.dart';
import 'package:flutter/foundation.dart';

/* 
  This Logger is supposed to be wrapper for logging library.
  in case of broken support of current logging library
  it should be moderately to easy to replace broken dependencies
  or to refactor the project to new library.
 */
class LoggerHelper {
  final String logName;
  late final Logger log;

  LoggerHelper(this.logName) {
    log = Logger(logName);
  }

  static void init({Level? level, void Function(LogRecord record)? logOnListen}) {
    Logger.root.level = level ?? Level.ALL;
    Logger.root.onRecord.listen(
      logOnListen ??
          (record) {
            if (kDebugMode) {
              // print('${record.level.name}: ${record.time}: ${record.message}');
              String lvl = "";
              if (record.level.name == "INFO") {
                lvl = "INFO";
              } else if (record.level.name == "FINE") {
                lvl = "WARNING";
              } else if (record.level.name == "FINER") {
                lvl = "ERROR";
              } else if (record.level.name == "FINEST") {
                lvl = "DEBUG";
              } else {
                lvl = record.level.name;
              }
              print('$lvl: ${FormatterHelper.formatTimeWithSeconds(record.time)}: ${record.message}');
            }
          },
    );
  }

  /*
    INFO
    Informational messages
    */
  void i(Object? message, [Object? error, StackTrace? stackTrace]) {
    log.info(message);
  }

  /* 
    WARNING
    Normal but significant condition
   */
  void w(Object? message, [Object? error, StackTrace? stackTrace]) {
    log.fine(message, [error, stackTrace]);
  }

  /* 
    ERROR
    Error or exception conditions
    Something that should be immediately handled
    */
  void e(Object? message, [Object? error, StackTrace? stackTrace]) {
    log.finer(message, [error, stackTrace]);
  }

  /*
    DEBUG
    Debug-level messages
    */
  void d(Object? message, [Object? error, StackTrace? stackTrace]) {
    log.finest(message, [error, stackTrace]);
  }
}
