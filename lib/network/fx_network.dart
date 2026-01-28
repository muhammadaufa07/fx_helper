import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/io_client.dart';
import 'package:http_parser/http_parser.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

abstract class FxNetwork<T> {
  final http.Client httpClient;
  static PackageInfo? _packageInfo;
  static PackageInfo? get packageInfo {
    return _packageInfo;
  }

  Future<void> init() async {
    try {
      _packageInfo = await PackageInfo.fromPlatform();
    } catch (e) {
      log(e.toString());
    }
  }

  FxNetwork({http.Client? client}) : httpClient = client ?? http.Client();

  bool get isDevMode;
  dynamic get env;
  bool get logShowFull => false;
  bool get logEnable => isDevMode;

  /// Show log in production.
  /// [DO NOT ENABLE UNLESS REQUIRED]
  ///
  /// by default log is not visible in production (APK or Release build)
  bool get logInRelease => false;

  bool get logHideSensitiveInfo => true;
  int get logTruncateAt => 30;

  int get getTimeOut => 20;
  int get postTimeOut => 20;
  int get postMultipartTimeOut => 60;

  int get postDelayMs => 0;
  int get getDelayMs => 0;
  int get putDelayMs => 0;
  int get deleteDelayMs => 0;

  /* Token */
  static String? _token;

  String? get token => _token;

  set token(String? newToken) {
    String? t = newToken;
    if (t?.isEmpty == true) {
      t = null;
    }
    _token = t;
  }

  Map<String, String> getHeader();

  String getDomainName(T net);

  Uri _buildUri(Uri path, [Map<String, String>? queryParams]) {
    Map<String, String> p = {};
    p.addAll(path.queryParameters);
    if (queryParams != null) p.addAll(queryParams);
    return path.replace(queryParameters: p);
  }

  MediaType _getMime(String fileExtensions) {
    fileExtensions = fileExtensions.toLowerCase();
    switch (fileExtensions) {
      // images
      case "jpg":
        return MediaType("image", fileExtensions);
      case "jpeg":
        return MediaType("image", fileExtensions);
      case "png":
        return MediaType("image", fileExtensions);
      case "jfif":
        return MediaType("image", fileExtensions);
      case "heic":
        return MediaType("image", fileExtensions);
      case "webp":
        return MediaType("image", fileExtensions);
      case "gif":
        return MediaType("image", fileExtensions);
      // docs
      case "pdf":
        return MediaType("application", fileExtensions);
      case "doc":
        return MediaType("application", "msword");
      case "docx":
        return MediaType("application", "vnd.openxmlformats-officedocument.wordprocessingml.document");
      case "ppt":
        return MediaType("application", "vnd.ms-powerpoint");
      case "pptx":
        return MediaType("application", "vnd.openxmlformats-officedocument.presentationml.presentation");
      // others
      default:
        return MediaType("text", "plain");
    }
  }

  /* ==== ==== ==== GET ==== ==== ==== */

  Future<http.Response> getApi(
    T net,
    String path, {
    Map<String, String>? params,
    Map<String, String>? headers,
    int? timeout,
    bool? debug,
  }) async {
    Uri fullPath = Uri.parse("${getDomainName(net)}$path");
    return await get(
      /*  */
      fullPath,
      params: params,
      headers: headers ?? getHeader(),
      timeout: timeout,
      debug: debug,
    );
  }

  Future<http.Response> get(
    Uri fullPath, {
    Map<String, String>? params,
    Map<String, String>? headers,
    int? timeout,
    bool? debug,
  }) async {
    http.Response? res;

    Uri newUri = _buildUri(fullPath, params);

    final dTimeout = timeout ?? getTimeOut;
    final merged = headers ?? {};

    if (getDelayMs > 0) {
      await Future.delayed(Duration(milliseconds: getDelayMs));
    }
    res = await httpClient
        .get(newUri, headers: merged)
        .timeout(
          Duration(seconds: dTimeout),
          onTimeout: () => http.Response("", 408, reasonPhrase: "Timeout: Could not connect to server $dTimeout"),
        );

    _logSimple(newUri, res, headers: merged, debug: debug);
    if (res.statusCode == 408) throw TimeoutException(res.reasonPhrase);

    return res;
  }

  /* ==== ==== ==== POST ==== ==== ==== */

  Future<http.Response> postApi(
    T net,
    String path,
    Map<String, dynamic> postData, {
    Map<String, String>? headers,
    int? timeout,
    bool? debug,
  }) async {
    Uri fullPath = Uri.parse("${getDomainName(net)}$path");
    return await post(fullPath, postData, headers: headers ?? getHeader(), timeout: timeout, debug: debug);
  }

  Future<http.Response> post(
    Uri fullPath,
    Map<String, dynamic> postData, {
    Map<String, String>? headers,
    int? timeout,
    bool? debug,
  }) async {
    final dTimeout = timeout ?? postTimeOut;
    final merged = headers ?? {};
    http.Response res;
    if (postDelayMs > 0) {
      await Future.delayed(Duration(milliseconds: postDelayMs));
    }
    res = await httpClient
        .post(fullPath, body: jsonEncode(postData), headers: merged)
        .timeout(
          Duration(seconds: dTimeout),
          onTimeout: () => http.Response("", 408, reasonPhrase: "Timeout: Could not connect to server $dTimeout"),
        );
    _logSimple(fullPath, res, postData: postData, headers: merged, debug: debug);
    if (res.statusCode == 408) throw TimeoutException(res.reasonPhrase);

    return res;
  }

  /* ==== ==== ==== POST MULTIPART ==== ==== ==== */

  Future<http.Response> postMultipartApi(
    T net,
    String path,
    Map<String, String> postData,
    List<MultipartFormItem> files, {
    Map<String, String>? headers,
    int? timeout,
    bool? debug,
  }) async {
    Uri fullPath = Uri.parse("${getDomainName(net)}$path");
    return await postMultipart(
      fullPath,
      postData,
      files,
      headers: headers ?? getHeader(),
      timeout: timeout,
      debug: debug,
    );
  }

  Future<http.Response> postMultipart(
    Uri fullPath,
    Map<String, String> postData,
    List<MultipartFormItem> files, {
    Map<String, String>? headers,
    int? timeout,
    bool? debug,
  }) async {
    final dTimeout = timeout ?? postMultipartTimeOut;
    final merged = headers ?? {};

    List<http.MultipartFile> multipartFiles = [];
    for (MultipartFormItem f in files) {
      final fileName = f.file.path.split('/').last;
      final mfile = await http.MultipartFile.fromPath(
        f.fieldName,
        f.file.path,
        filename: fileName,
        contentType: _getMime(fileName.split(".").last),
      );
      multipartFiles.add(mfile);
    }

    // final uri = Uri.parse(fullPath);
    var request = http.MultipartRequest('POST', fullPath);
    if (merged.isNotEmpty) request.headers.addAll(merged);
    request.fields.addAll(postData);
    request.files.addAll(multipartFiles);

    var streamed = await httpClient
        .send(request)
        .timeout(
          Duration(seconds: dTimeout),
          onTimeout: () => _timeOutResponse(httpMethod: "POST", url: fullPath.toString(), timeout: dTimeout),
        );
    if (postDelayMs > 0) {
      await Future.delayed(Duration(milliseconds: postDelayMs));
    }
    final res = await http.Response.fromStream(streamed);
    _logSimple(fullPath, res, postData: postData, multipartFiles: multipartFiles, headers: merged, debug: debug);
    if (res.statusCode == 408) throw TimeoutException(res.reasonPhrase);
    return res;
  }

  /* ==== ==== ==== DELETE ==== ==== ==== */

  Future<http.Response> deleteApi(
    /*  */
    T net,
    String path, {
    Map<String, String>? params,
    Map<String, String>? headers,
    int? timeout,
    bool? debug,
  }) async {
    Uri fullPath = Uri.parse("${getDomainName(net)}$path");
    return await delete(
      /*  */
      fullPath,
      params: params,
      headers: headers ?? getHeader(),
      timeout: timeout,
      debug: debug,
    );
  }

  Future<http.Response> delete(
    /*  */
    Uri fullPath, {
    Map<String, String>? params,
    Map<String, String>? headers,
    int? timeout,
    bool? debug,
  }) async {
    final dTimeout = timeout ?? getTimeOut;
    final merged = headers ?? {};
    Uri newUri = _buildUri(fullPath, params);
    if (deleteDelayMs > 0) {
      await Future.delayed(Duration(milliseconds: deleteDelayMs));
    }
    final res = await httpClient
        .delete(newUri, headers: merged)
        .timeout(
          Duration(seconds: dTimeout),
          onTimeout: () => http.Response("", 408, reasonPhrase: "Timeout: Could not connect to server $dTimeout"),
        );

    _logSimple(newUri, res, headers: merged, debug: debug);
    if (res.statusCode == 408) throw TimeoutException(res.reasonPhrase);

    return res;
  }

  /* ==== ==== ==== PUT ==== ==== ==== */

  Future<http.Response> putApi(
    T net,
    String path,
    Map<String, dynamic> putData, {
    Map<String, String>? headers,
    int? timeout,
    bool? debug,
  }) async {
    Uri fullPath = Uri.parse("${getDomainName(net)}$path");
    return await put(fullPath, putData, headers: headers ?? getHeader(), timeout: timeout, debug: debug);
  }

  Future<http.Response> put(
    Uri fullPath,
    Map<String, dynamic> putData, {
    Map<String, String>? headers,
    int? timeout,
    bool? debug,
  }) async {
    final dTimeout = timeout ?? postTimeOut;
    final merged = headers ?? {};
    final res = await httpClient
        .put(fullPath, body: jsonEncode(putData), headers: merged)
        .timeout(Duration(seconds: dTimeout));
    _logSimple(fullPath, res, postData: putData, headers: merged, debug: debug);
    return res;
  }

  /* ==== ==== ==== PUT MULTIPART ==== ==== ==== */

  Future<http.Response> putMultipartApi(
    T net,
    String path,
    Map<String, String> putData,
    List<MultipartFormItem> files, {
    Map<String, String>? headers,
    int? timeout,
    bool? debug,
  }) async {
    Uri fullPath = Uri.parse("${getDomainName(net)}$path");
    return await putMultipart(
      fullPath,
      putData,
      files,
      headers: headers ?? getHeader(),
      timeout: timeout,
      debug: debug,
    );
  }

  Future<http.Response> putMultipart(
    Uri fullPath,
    Map<String, String> putData,
    List<MultipartFormItem> files, {
    Map<String, String>? headers,
    int? timeout,
    bool? debug,
  }) async {
    final dTimeout = timeout ?? postMultipartTimeOut;
    final merged = headers ?? {};

    List<http.MultipartFile> multipartFiles = [];
    for (MultipartFormItem f in files) {
      final fileName = f.file.path.split('/').last;
      final mfile = await http.MultipartFile.fromPath(
        f.fieldName,
        f.file.path,
        filename: fileName,
        contentType: _getMime(fileName.split(".").last),
      );
      multipartFiles.add(mfile);
    }

    if (putDelayMs > 0) {
      await Future.delayed(Duration(milliseconds: putDelayMs));
    }
    var request = http.MultipartRequest('PUT', fullPath);
    if (merged.isNotEmpty) request.headers.addAll(merged);
    request.fields.addAll(putData);
    request.files.addAll(multipartFiles);

    var streamed = await httpClient
        .send(request)
        .timeout(
          Duration(seconds: dTimeout),
          onTimeout: () => _timeOutResponse(httpMethod: "PUT", url: fullPath.toString(), timeout: dTimeout),
        );

    final res = await http.Response.fromStream(streamed);
    _logSimple(fullPath, res, postData: putData, multipartFiles: multipartFiles, headers: merged, debug: debug);
    if (res.statusCode == 408) throw TimeoutException(res.reasonPhrase);
    return res;
  }

  /* ==== ==== ==== LOG ==== ==== ==== */

  // String _logColor(String string, http.Response? res) =>
  //     res?.statusCode == 200 ? AnsiColor.fGreen(string) : AnsiColor.fRed(string);

  String _logUrl(http.Response? res, Uri fullPath) {
    String t = "";
    try {
      t += res?.statusCode == 200 ? "\x1B[32m" : "\x1B[31m";
      String p = fullPath.toString();
      t += p.padRight(p.length < 75 ? 75 : p.length + 1);
    } catch (e) {
      t += fullPath.toString();
      log("FxHelper: ${e.toString()}");
    }
    t += "\x1B[0m";
    return t;
  }

  String _logMessage(http.Response? res) {
    String t = "";
    t += res?.statusCode == 200 ? "\x1B[32m" : "\x1B[1;91m";
    /* REASON PHRASE */
    if (res?.reasonPhrase != null) t += "${res?.reasonPhrase}";
    t += "\x1B[0m";
    t += res?.statusCode == 200 ? "\x1B[32m" : "\x1B[31m";
    /* STATUS MESSAGE */
    final body = (res?.body ?? '');
    if (res != null && body.isNotEmpty) {
      try {
        final decoded = jsonDecode(body);
        if (decoded is Map && decoded.containsKey('message')) {
          t += " | ${decoded['message']}";
        }
      } catch (e) {
        t += "e31: ${e.toString()}";
      }
    }
    t += "\x1B[0m";
    return t;
  }

  void _logSimple(
    Uri fullPath,
    http.Response? res, {
    Map<String, dynamic>? postData,
    List<http.MultipartFile>? multipartFiles,
    bool? debug,
    Map<String, String>? headers,
  }) {
    // print("\x1B[0m");

    if (logEnable && debug != false) {
      final buf = StringBuffer();
      final sbuf = StringBuffer();
      try {
        /* STATUS CODE */
        if (logShowFull) buf.writeln();

        buf.write(res?.statusCode == 200 ? "\x1B[32m" : "\x1B[31m");
        buf.write("[ ${res?.statusCode.toString()} | ${res?.request?.method} ]  ");
        buf.writeln("\x1B[0m");

        if (logShowFull) {
          buf.writeln(_logMessage(res));
          buf.write(_logUrl(res, fullPath));
        } else {
          buf.write(_logUrl(res, fullPath));
          buf.write(_logMessage(res));
        }

        buf.writeln();

        /* HEADER */
        if (headers != null && ((debug == true) || logShowFull)) {
          final sanitized = Map<String, String>.from(headers);
          if (sanitized.containsKey('Authorization') && logHideSensitiveInfo) {
            sanitized['Authorization'] = '***REDACTED***';
          }

          for (var e in sanitized.entries) {
            buf.write("\x1B[36m");
            buf.write("${e.key.padRight(14, " ")} : ${e.value}");
            buf.write("\x1B[0m\n");
          }
        }

        /* POSTDATA */
        if (postData != null && postData.isNotEmpty) {
          sbuf.clear();
          sbuf.write("\x1B[35m"); //change to 37
          try {
            String encodedBody = JsonEncoder.withIndent("\x1B[35m  ").convert(postData);
            var lines = encodedBody.split("\n").toList();
            for (var i = 0; i < lines.length; i++) {
              sbuf.write(lines[i]);
              sbuf.write("\x1B[0m");
              sbuf.writeln("");
            }

            if (sbuf.length > 0) {
              String s = sbuf.toString().trim();
              debugPrint("deb: [$s]");
              var lastChar = s[s.length - 5];
              sbuf.clear();
              sbuf.write(s.substring(0, s.length - 5));
              sbuf.write("\x1B[35m$lastChar");
              sbuf.write("\x1B[0m");
            }
          } catch (_) {
            sbuf.write(postData.toString());
          }
          sbuf.write("\x1B[0m");
          buf.writeln(sbuf);
        }
        /* POST MULTIPART */
        if (multipartFiles != null && multipartFiles.isNotEmpty) {
          try {
            final f = multipartFiles.map((http.MultipartFile e) {
              return {
                "Field": e.field,
                "File-Name": e.filename,
                "Type": e.contentType.type,
                "Sub-Type": e.contentType.subtype,
                "Length": e.length,
              };
            }).toList();
            buf.writeln(JsonEncoder.withIndent(" ").convert(f));
          } catch (e, st) {
            log('Error in FxNetwork (multipart log): $e\n$st');
          }
        }
        /* BODY */
        final body = (res?.body ?? '');
        if ((res != null && res.statusCode != 200) || (debug == true) || logShowFull) {
          sbuf.clear();
          sbuf.write("\x1B[33m");
          try {
            if (body.isNotEmpty) {
              final decoded = jsonDecode(body);
              String encodedBody = JsonEncoder.withIndent("\x1B[33m  ").convert(decoded);
              var lines = encodedBody.split("\n").toList(growable: false);

              int n = lines.length;
              if (logTruncateAt > 0 && lines.length > logTruncateAt && (debug ?? false) == false) {
                n = logTruncateAt;
              }

              for (var i = 0; i < n; i++) {
                sbuf.write(lines[i]);
                sbuf.writeln("\x1B[0m");
              }
              if (lines.length > logTruncateAt) {
                sbuf.write("\x1B[41m\x1B[37m*** Truncated ***");
                sbuf.write("\x1B[0m");
                sbuf.write("\x1B[0m");
              }

              if (sbuf.length > 1) {
                String s = sbuf.toString();
                sbuf.clear();
                var lastChar = s[s.length - 6];
                sbuf.write(s.substring(0, s.length - 6));
                sbuf.write("\x1B[33m$lastChar");
                sbuf.writeln("\x1B[0m");
              }
              sbuf.writeln("\x1B[0m");
            }
          } catch (e, st) {
            sbuf.write(body);
            log('Error in FxNetwork (body pretty): $e\n$st');
          }
          buf.write(sbuf);
        }
      } catch (e, st) {
        buf.writeln('Log formatting error: $e\n$st');
      } finally {
        try {
          if (logInRelease) {
            /*
              Force logging on PRODUCTION or RELEASE.
              log() is omitted on production by default
            */
            // ignore: avoid_print
            debugPrint(buf.toString());
          } else {
            // another layer to omit logging on production
            if (kDebugMode) {
              // visible on debug console but not in logcat
              log("$buf", name: "\b");
            }
          }
        } catch (e, st) {
          log('Error in FxNetwork (final logging): $e\n$st');
        }
      }
    }
  }

  void dispose() {
    try {
      httpClient.close();
    } catch (e, st) {
      log('Error in FxNetwork.dispose: $e\n$st');
    }
  }

  IOStreamedResponse _timeOutResponse({required String httpMethod, required String url, required int timeout}) {
    final Map<String, dynamic> body = {'status': 408, 'message': 'Timeout: Could not connect to server $timeout'};
    const int statusCode = 408;
    final Uri destination = Uri.parse(url);
    final String jsonBody = jsonEncode(body);

    return IOStreamedResponse(
      Stream.value(jsonBody.codeUnits),
      statusCode,
      request: http.Request(httpMethod, destination),
      headers: {'content-type': 'application/json'},
    );
  }
}

/* Utilities */
class ApiException implements Exception {
  final String? _message;
  const ApiException(this._message);

  @override
  String toString() => 'ApiException: $_message';

  String get message => '$_message';
}

class MultipartFormItem {
  File file;
  String fieldName;
  MultipartFormItem({required this.fieldName, required this.file});
}

/*
  concrete implementation for internal FxHelper use only
*/
class FxNetworkLocal extends FxNetwork {
  FxNetworkLocal({super.client});

  @override
  get env => throw UnimplementedError();

  @override
  bool get logShowFull => false;

  @override
  String getDomainName(net) {
    throw UnimplementedError();
  }

  @override
  Map<String, String> getHeader() {
    throw UnimplementedError();
  }

  @override
  bool get isDevMode => throw UnimplementedError();
}
