// ignore_for_file: empty_catches

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http_parser/http_parser.dart';
import 'package:http/http.dart' as http;

/// Simple API exception container
class ApiException implements Exception {
  final int? statusCode;
  final String message;
  final dynamic body;
  final Exception? underlying;

  ApiException(this.message, {this.statusCode, this.body, this.underlying});

  @override
  String toString() => 'ApiException(status:$statusCode, message:$message)';
}

/// Typed network response wrapper
class NetworkResponse<R> {
  final R? data;
  final ApiException? error;

  const NetworkResponse._({this.data, this.error});

  bool get isSuccess => error == null && data != null;
  bool get isError => error != null;

  factory NetworkResponse.success(R data) => NetworkResponse._(data: data);
  factory NetworkResponse.failure(ApiException e) => NetworkResponse._(error: e);
}

abstract class FxNetwork<T> {
  final http.Client httpClient;
  FxNetwork({http.Client? client}) : httpClient = client ?? http.Client();

  bool get isDevMode;
  dynamic get env;
  bool get showFullLog;

  int get getTimeOut => 20;
  int get postTimeOut => 20;
  int get postMultipartTimeOut => 60;
  int get maxLogBody => 4096;

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

  /// build uri safely combining base and path (handles absolute urls too)
  Uri _buildUri(String base, String path, [Map<String, String>? queryParams]) {
    if (path.startsWith('http://') || path.startsWith('https://')) return Uri.parse(path);

    final combinedParams = Uri.parse(path).queryParameters;
    if (queryParams != null) combinedParams.addAll(queryParams);
    // final paramsFromPath = Uri.parse(path).path;
    // print(Uri.parse(path).path);
    // print(paramsFromPath);

    final baseUri = Uri.parse(base);
    final basePath = baseUri.path.endsWith('/') ? baseUri.path.substring(0, baseUri.path.length - 1) : baseUri.path;
    final relPath = path.startsWith('/') ? path : '/$path';
    final newPath = (basePath + relPath).replaceAll('//', '/');
    print("baseUri: $baseUri");
    print("newPath: $newPath");

    final replaced = baseUri.replace(path: newPath, queryParameters: combinedParams);
    print("replaced: $replaced");

    return replaced;
  }

  /// Merge base headers, runtime token and caller headers.
  /// If forMultipart==true, remove any Content-Type so MultipartRequest can set boundary.
  Map<String, String> _mergeHeaders(Map<String, String>? headers, {bool forMultipart = false}) {
    final Map<String, String> m = {};
    try {
      final base = getHeader();
      if (base.isNotEmpty) m.addAll(base);
    } catch (_) {}
    if (_token != null && _token!.isNotEmpty) m['Authorization'] = 'Bearer $_token';

    if (!forMultipart) {
      // default application/json for regular body requests
      m.putIfAbsent('Content-Type', () => 'application/json');
    } else {
      // For multipart, MultipartRequest will provide Content-Type with boundary; remove any JSON header
      m.remove('Content-Type');
    }

    if (headers != null) m.addAll(headers);
    return m;
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
    _buildUri(getDomainName(net), path, params);
    Uri fullPath = Uri.parse("${getDomainName(net)}$path");
    return await getGlobal(
      fullPath,
      // params: params,
      headers: _mergeHeaders(headers, forMultipart: false),
      timeout: timeout,
      debug: debug,
    );
  }

  Future<http.Response> getGlobal(
    Uri fullPath, {
    // Map<String, String>? params,
    Map<String, String>? headers,
    int? timeout,
    bool? debug,
  }) async {
    http.Response? res;

    final dTimeout = timeout ?? getTimeOut;
    final merged = headers ?? {};

    res = await httpClient
        .get(fullPath, headers: merged)
        .timeout(
          Duration(seconds: dTimeout),
          onTimeout: () => http.Response("", 408, reasonPhrase: "Timeout: Could not connect to server $dTimeout"),
        );

    _logSimple(fullPath, res, headers: merged, debug: debug);
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
    Uri fullPath = _buildUri(getDomainName(net), path);
    return await postGlobal(
      fullPath,
      postData,
      headers: _mergeHeaders(headers, forMultipart: false),
      timeout: timeout,
      debug: debug,
    );
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
    Uri fullPath = _buildUri(getDomainName(net), path);
    return await postMultipartGlobal(
      fullPath,
      postData,
      files,
      headers: _mergeHeaders(headers, forMultipart: true),
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
          onTimeout: () => http.StreamedResponse(
            Stream.empty(),
            408,
            reasonPhrase: "Timeout: Could not connect to server $dTimeout",
          ),
        );

    final res = await http.Response.fromStream(streamed);
    _logSimple(fullPath, res, postData: postData, multipartFiles: multipartFiles, headers: merged, debug: debug);
    if (res.statusCode == 408) throw TimeoutException(res.reasonPhrase);
    return res;
  }

  /* ==== ==== ==== DELETE ==== ==== ==== */

  Future<http.Response> delete(T net, String path, {Map<String, String>? headers, int? timeout, bool? debug}) async {
    Uri fullPath = _buildUri(getDomainName(net), path);
    return await deleteGlobal(
      fullPath,
      headers: _mergeHeaders(headers, forMultipart: false),
      timeout: timeout,
      debug: debug,
    );
  }

  Future<http.Response> deleteGlobal(Uri fullPath, {Map<String, String>? headers, int? timeout, bool? debug}) async {
    final dTimeout = timeout ?? getTimeOut;
    final merged = headers ?? {};
    // final uri = Uri.parse(fullPath);

    final res = await httpClient
        .delete(fullPath, headers: merged)
        .timeout(
          Duration(seconds: dTimeout),
          onTimeout: () => http.Response("", 408, reasonPhrase: "Timeout: Could not connect to server $dTimeout"),
        );

    _logSimple(fullPath, res, headers: merged, debug: debug);
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
    Uri fullPath = _buildUri(getDomainName(net), path);
    return await putGlobal(
      fullPath,
      putData,
      headers: _mergeHeaders(headers, forMultipart: false),
      timeout: timeout,
      debug: debug,
    );
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
    Uri fullPath = _buildUri(getDomainName(net), path);
    return await putMultipartGlobal(
      fullPath,
      putData,
      files,
      headers: _mergeHeaders(headers, forMultipart: true),
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
          onTimeout: () => http.StreamedResponse(
            Stream.empty(),
            408,
            reasonPhrase: "Timeout: Could not connect to server $dTimeout",
          ),
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
    final buf = StringBuffer();
    try {
      buf.write(fullPath.toString().padRight(fullPath.toString().length > 100 ? fullPath.toString().length : 80, " "));
      buf.write(" -> ");
      if (res?.reasonPhrase != null) buf.write("${res?.reasonPhrase} | ");

      // truncate body for log safety

      final bodyRaw = (res?.body ?? '');
      final bodyToLog = bodyRaw.length > maxLogBody ? '${bodyRaw.substring(0, maxLogBody)}... (truncated)' : bodyRaw;

      if (res != null && bodyToLog.isNotEmpty) {
        try {
          final decoded = jsonDecode(bodyToLog);
          if (decoded is Map && decoded.containsKey('message')) {
            buf.write(decoded['message']);
          } else {
            buf.write(bodyToLog);
          }
        } catch (_) {
          buf.write(bodyToLog);
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
              "File-Name": e.filename ?? '',
              "Type": e.contentType?.type ?? '',
              "Sub-Type": e.contentType?.subtype ?? '',
              "Length": e.length ?? 'unknown',
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
        log(buf.toString(), name: res?.statusCode?.toString() ?? "FxNetwork");
      } catch (e, st) {
        log('Error in FxNetwork (final logging): $e\n$st');
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

  /* ==== ==== Typed helpers ==== ==== */

  /// Map http.Response to typed NetworkResponse<R>
  // Future<NetworkResponse<R>> _mapResponse<R>({
  //   required http.Response res,
  //   R Function(dynamic decoded)? mapper,
  //   Future<R> Function(dynamic decoded)? asyncMapper,
  // }) async {
  //   final status = res.statusCode;
  //   dynamic decoded;
  //   try {
  //     decoded = res.body.isNotEmpty ? jsonDecode(res.body) : null;
  //   } catch (_) {
  //     decoded = res.body; // fallback raw
  //   }

  //   if (status >= 200 && status < 300) {
  //     try {
  //       if (asyncMapper != null) {
  //         final mapped = await asyncMapper(decoded);
  //         return NetworkResponse.success(mapped);
  //       } else if (mapper != null) {
  //         final mapped = mapper(decoded);
  //         return NetworkResponse.success(mapped);
  //       } else {
  //         // no mapper provided, return decoded as R if possible
  //         return NetworkResponse.success(decoded as R);
  //       }
  //     } catch (e) {
  //       return NetworkResponse.failure(
  //         ApiException(
  //           'Mapping failed',
  //           statusCode: status,
  //           body: decoded,
  //           underlying: e is Exception ? e : Exception(e.toString()),
  //         ),
  //       );
  //     }
  //   } else {
  //     final message = (decoded is Map && decoded['message'] != null)
  //         ? decoded['message'].toString()
  //         : (res.reasonPhrase ?? 'HTTP $status');
  //     return NetworkResponse.failure(ApiException(message, statusCode: status, body: decoded));
  //   }
  // }

  /// Typed POST helper (JSON body)
  // Future<NetworkResponse<R>> postTyped<R>(
  //   String fullPath,
  //   Map<String, dynamic> postData, {
  //   Map<String, String>? headers,
  //   int? timeout,
  //   R Function(dynamic decoded)? mapper,
  //   Future<R> Function(dynamic decoded)? asyncMapper,
  //   bool? debug,
  // }) async {
  //   final merged = _mergeHeaders(headers, forMultipart: false);
  //   final dTimeout = timeout ?? postTimeOut;
  //   try {
  //     final res = await httpClient
  //         .post(Uri.parse(fullPath), body: jsonEncode(postData), headers: merged)
  //         .timeout(
  //           Duration(seconds: dTimeout),
  //           onTimeout: () => http.Response("", 408, reasonPhrase: "Timeout: Could not connect to server $dTimeout"),
  //         );

  //     _logSimple(fullPath, res, postData: postData, headers: merged, debug: debug);
  //     if (res.statusCode == 408) return NetworkResponse.failure(ApiException('Timeout', statusCode: 408));
  //     return await _mapResponse<R>(res: res, mapper: mapper, asyncMapper: asyncMapper);
  //   } catch (e) {
  //     return NetworkResponse.failure(
  //       ApiException('Network error: ${e.toString()}', underlying: e is Exception ? e : Exception(e.toString())),
  //     );
  //   }
  // }

  /// Typed GET helper
  // Future<NetworkResponse<R>> getTyped<R>(
  //   String fullPath, {
  //   Map<String, String>? headers,
  //   int? timeout,
  //   R Function(dynamic decoded)? mapper,
  //   Future<R> Function(dynamic decoded)? asyncMapper,
  //   bool? debug,
  // }) async {
  //   final merged = _mergeHeaders(headers, forMultipart: false);
  //   final dTimeout = timeout ?? getTimeOut;
  //   try {
  //     final res = await httpClient
  //         .get(Uri.parse(fullPath), headers: merged)
  //         .timeout(
  //           Duration(seconds: dTimeout),
  //           onTimeout: () => http.Response("", 408, reasonPhrase: "Timeout: Could not connect to server $dTimeout"),
  //         );

  //     _logSimple(fullPath, res, headers: merged, debug: debug);
  //     if (res.statusCode == 408) return NetworkResponse.failure(ApiException('Timeout', statusCode: 408));
  //     return await _mapResponse<R>(res: res, mapper: mapper, asyncMapper: asyncMapper);
  //   } catch (e) {
  //     return NetworkResponse.failure(
  //       ApiException('Network error: ${e.toString()}', underlying: e is Exception ? e : Exception(e.toString())),
  //     );
  //   }
  // }
}

/* Utilities */
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
