import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
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
  bool get logHideSensitiveInfo => true;
  int get logTruncateAt => 30;

  int get getTimeOut => 20;
  int get postTimeOut => 20;
  int get postMultipartTimeOut => 60;

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
    return t;
  }

  String _logMessage(http.Response? res) {
    String t = "";
    t += res?.statusCode == 200 ? "\x1B[32m" : "\x1B[31;5m";
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
    return t;
  }

  void _logSimple(
    Uri fullPath,
    http.Response? res, {
    Map<String, dynamic>? postData,
    List<http.MultipartFile>? multipartFiles,
    bool? debug = false,
    Map<String, String>? headers,
  }) {
    if (logEnable) {
      final buf = StringBuffer();
      try {
        /* STATUS CODE */
        if (logShowFull) buf.writeln();

        buf.write(res?.statusCode == 200 ? "\x1B[32m" : "\x1B[31m");
        buf.write("[ ${res?.statusCode.toString()} | ${res?.request?.method} ]  ");

        if (logShowFull) {
          buf.writeln(_logMessage(res));
          buf.write(_logUrl(res, fullPath));
        } else {
          buf.write(_logUrl(res, fullPath));
          buf.write(_logMessage(res));
        }
        buf.writeln("\x1B[0m");

        /* HEADER */
        if (headers != null && ((debug ?? false) || logShowFull)) {
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
          String t = "\x1B[37m";
          try {
            t += JsonEncoder.withIndent("\x1B[37m  ").convert(postData);
            if (t.length > 1) {
              var lastChar = t[t.length - 1];
              t = t.substring(0, t.length - 1);
              t += "\x1B[37m$lastChar\n";
            }
          } catch (_) {
            t += postData.toString();
          }
          buf.write(t);
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
        if ((res != null && res.statusCode != 200) || (debug ?? false) || logShowFull) {
          String t = "\x1B[33m";
          try {
            if (body.isNotEmpty) {
              final decoded = jsonDecode(body);
              String encodedBody = JsonEncoder.withIndent("\x1B[33m  ").convert(decoded);
              var lines = encodedBody.split("\n").toList();
              if (logTruncateAt != 0 && lines.length > logTruncateAt && (debug ?? false) == false) {
                var n = lines.length > logTruncateAt ? logTruncateAt : lines.length;
                for (var i = 0; i < n; i++) {
                  t += "${lines[i]}\n";
                }
                t += "\x1B[41m\x1B[37m*** Truncated ***";
              } else {
                t += encodedBody;
              }

              if (t.length > 1) {
                var lastChar = t[t.length - 1];
                t = t.substring(0, t.length - 1);
                t += "\x1B[33m$lastChar\n";
              }
            }
          } catch (e, st) {
            buf.writeln(body);
            log('Error in FxNetwork (body pretty): $e\n$st');
          }
          buf.write(t);
        }
      } catch (e, st) {
        buf.writeln('Log formatting error: $e\n$st');
      } finally {
        try {
          log("$buf", name: "\b");
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
    final Map<String, dynamic> body = {'status': 408, 'message': 'Timeout: Could not connect to server $timeout"'};
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
