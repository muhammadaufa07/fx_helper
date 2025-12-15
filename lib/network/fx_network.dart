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
  bool get showFullLog;
  bool get logEnable => isDevMode;

  int get getTimeOut => 20;
  int get postTimeOut => 20;
  int get postMultipartTimeOut => 60;

  /* Token */
  String? _token;

  String? get token => _token;

  set token(String? newToken) {
    String? t = newToken;
    if (t?.isEmpty == true) t = null;
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

  Future<http.Response> get(
    T net,
    String path, {
    Map<String, String>? params,
    Map<String, String>? headers,
    int? timeout,
    bool? debug,
  }) async {
    Uri fullPath = Uri.parse("${getDomainName(net)}$path");
    return await getGlobal(
      /*  */
      fullPath,
      params: params,
      headers: headers ?? getHeader(),
      timeout: timeout,
      debug: debug,
    );
  }

  Future<http.Response> getGlobal(
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

  Future<http.Response> post(
    T net,
    String path,
    Map<String, dynamic> postData, {
    Map<String, String>? headers,
    int? timeout,
    bool? debug,
  }) async {
    Uri fullPath = Uri.parse("${getDomainName(net)}$path");
    return await postGlobal(fullPath, postData, headers: headers ?? getHeader(), timeout: timeout, debug: debug);
  }

  Future<http.Response> postGlobal(
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

  Future<http.Response> postMultipart(
    T net,
    String path,
    Map<String, String> postData,
    List<MultipartFormItem> files, {
    Map<String, String>? headers,
    int? timeout,
    bool? debug,
  }) async {
    Uri fullPath = Uri.parse("${getDomainName(net)}$path");
    return await postMultipartGlobal(
      fullPath,
      postData,
      files,
      headers: headers ?? getHeader(),
      timeout: timeout,
      debug: debug,
    );
  }

  Future<http.Response> postMultipartGlobal(
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

  Future<http.Response> delete(
    /*  */
    T net,
    String path, {
    Map<String, String>? params,
    Map<String, String>? headers,
    int? timeout,
    bool? debug,
  }) async {
    Uri fullPath = Uri.parse("${getDomainName(net)}$path");
    return await deleteGlobal(
      fullPath,
      params: params,
      headers: headers ?? getHeader(),
      timeout: timeout,
      debug: debug,
    );
  }

  Future<http.Response> deleteGlobal(
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

  Future<http.Response> put(
    T net,
    String path,
    Map<String, dynamic> putData, {
    Map<String, String>? headers,
    int? timeout,
    bool? debug,
  }) async {
    Uri fullPath = Uri.parse("${getDomainName(net)}$path");
    return await putGlobal(fullPath, putData, headers: headers ?? getHeader(), timeout: timeout, debug: debug);
  }

  Future<http.Response> putGlobal(
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

  Future<http.Response> putMultipart(
    T net,
    String path,
    Map<String, String> putData,
    List<MultipartFormItem> files, {
    Map<String, String>? headers,
    int? timeout,
    bool? debug,
  }) async {
    Uri fullPath = Uri.parse("${getDomainName(net)}$path");
    return await putMultipartGlobal(
      fullPath,
      putData,
      files,
      headers: headers ?? getHeader(),
      timeout: timeout,
      debug: debug,
    );
  }

  Future<http.Response> putMultipartGlobal(
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
        buf.write(
          fullPath.toString().padRight(fullPath.toString().length > 100 ? fullPath.toString().length : 80, " "),
        );
        buf.write(" -> ");
        if (res?.reasonPhrase != null) buf.write("${res?.reasonPhrase} | ");

        // truncate body for log safety

        final bodyToLog = (res?.body ?? '');
        if (res != null && bodyToLog.isNotEmpty) {
          try {
            final decoded = jsonDecode(bodyToLog);
            if (decoded is Map && decoded.containsKey('message')) {
              buf.write(decoded['message']);
            } else {
              buf.write(bodyToLog);
            }
          } catch (e) {
            buf.write(bodyToLog);
            buf.write("e31: ${e.toString()}");
          }
        }
        buf.writeln();

        if (headers != null && ((debug ?? false) || showFullLog)) {
          final sanitized = Map<String, String>.from(headers);
          if (sanitized.containsKey('Authorization')) sanitized['Authorization'] = '***REDACTED***';
          buf.writeln(JsonEncoder.withIndent("  ").convert(sanitized));
        }

        if (postData != null) {
          try {
            buf.writeln(JsonEncoder.withIndent("  ").convert(postData));
          } catch (_) {
            buf.writeln(postData.toString());
          }
        }

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
            buf.writeln(JsonEncoder.withIndent("    ").convert(f));
          } catch (e, st) {
            log('Error in FxNetwork (multipart log): $e\n$st');
          }
        }

        if ((res != null && res.statusCode != 200) || (debug ?? false) || showFullLog) {
          try {
            // prefer pretty JSON if possible, otherwise raw truncated string
            if (bodyToLog.isNotEmpty) {
              final decoded = jsonDecode(bodyToLog);
              buf.writeln(JsonEncoder.withIndent("  ").convert(decoded));
            }
          } catch (e, st) {
            buf.writeln(bodyToLog);
            log('Error in FxNetwork (body pretty): $e\n$st');
          }
        }
      } catch (e, st) {
        buf.writeln('Log formatting error: $e\n$st');
      } finally {
        try {
          log(buf.toString(), name: " ${res?.statusCode?.toString()} | ${res?.request?.method} " ?? "FxNetwork");
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
  FxNetworkLocal({http.Client? client}) : super(client: client);

  @override
  get env => throw UnimplementedError();

  @override
  bool get showFullLog => false;

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
