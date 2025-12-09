// ignore_for_file: empty_catches

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http_parser/http_parser.dart';
import 'package:http/http.dart' as http;

abstract class FxNetwork<T> {
  bool get isDevMode;
  dynamic get env;
  bool get showFullLog;

  int get getTimeOut => 20;
  int get postTimeOut => 20;
  int get postMultipartTimeOut => 60;

  /* Token */
  String? _token;

  String? get token {
    return _token;
  }

  set token(String? newToken) {
    String? t = newToken;
    if (t?.isEmpty == true) {
      t = null;
    }
    _token = t;
  }

  Map<String, String> getHeader();

  String getDomainName(T net);

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

  /// Create a GET Request
  ///
  /// ```
  /// Examples:
  ///     get(Net.gateway, url: "home/menu");
  /// ```

  Future<http.Response> get(
    /*  */
    T net,
    String path, {
    Map<String, String>? headers,
    int? timeout,
    bool? debug,
  }) async {
    String uriStr = getDomainName(net) + path;
    return await getGlobal(uriStr, headers: headers ?? getHeader(), timeout: timeout, debug: debug);
  }

  /// Create a GET Request
  ///
  /// ```
  /// Examples:
  ///     get("https://somewhere/api/data"");
  /// ```
  Future<http.Response> getGlobal(
    /*  */
    String fullPath, {
    Map<String, String>? headers,
    int? timeout,
    bool? debug,
  }) async {
    http.Response? res;
    String uriStr = fullPath;
    Uri uri = Uri.parse(uriStr);
    res = await http
        .get(uri, headers: headers)
        .timeout(
          Duration(seconds: timeout ?? getTimeOut),
          onTimeout: () =>
              http.Response("", 408, reasonPhrase: "Timeout: Could not connect to server ${timeout ?? getTimeOut}"),
        );

    _logSimple(fullPath, res, headers: headers, debug: debug);
    if (res.statusCode == 408) throw TimeoutException(res.reasonPhrase);

    return res;
  }

  /* ==== ==== ==== POST ==== ==== ==== */

  /// Create a POST Request
  ///
  /// ```
  /// Examples:
  ///     var postData = {"email": "user@mail.com", "password": "password"};
  ///     post(Net.gateway, postData)
  /// ```

  Future<http.Response> post(
    /*  */
    T net,
    String path,
    Map<String, dynamic> postData, {
    Map<String, String>? headers,
    int? timeout,
    bool? debug,
  }) async {
    String uriStr = getDomainName(net) + path;
    return await postGlobal(uriStr, postData, headers: headers ?? getHeader(), timeout: timeout, debug: debug);
  }

  Future<http.Response> postGlobal(
    String fullPath,
    Map<String, dynamic> postData, {
    Map<String, String>? headers,
    int? timeout,
    bool? debug,
  }) async {
    http.Response res;
    res = await http
        .post(Uri.parse(fullPath), body: jsonEncode(postData), headers: headers)
        .timeout(
          Duration(seconds: timeout ?? postTimeOut),
          onTimeout: () =>
              http.Response("", 408, reasonPhrase: "Timeout: Could not connect to server ${timeout ?? getTimeOut}"),
        );
    _logSimple(fullPath, res, postData: postData, headers: headers, debug: debug);
    if (res.statusCode == 408) throw TimeoutException(res.reasonPhrase);

    return res;
  }

  /// Create Post with Multipart Request
  ///
  /// ```
  /// Examples:
  ///     var data = {"email": "user@mail.com", "password": "password"};
  ///     List<MultipartFormItem> files = [
  ///         MultipartFormItem(fieldName: "foto", file: File("somewhere")),
  ///         MultipartFormItem(fieldName: "foto", file: File("somewhere")),
  ///         MultipartFormItem(fieldName: "foto", file: File("somewhere")),
  ///         MultipartFormItem(fieldName: "foto", file: File("somewhere")),
  ///     ];
  ///     postMultipart(Net.gateway, data, files);
  /// ```

  Future<http.Response> postMultipart(
    T net,
    String path,
    Map<String, String> postData,
    List<MultipartFormItem> files, {
    Map<String, String>? headers,
    int? timeout,
    bool? debug,
  }) async {
    String uriStr = getDomainName(net) + path;
    return await postMultipartGlobal(
      uriStr,
      postData,
      files,
      headers: headers ?? getHeader(),
      timeout: timeout,
      debug: debug,
    );
  }

  Future<http.Response> postMultipartGlobal(
    String fullPath,
    Map<String, String> postData,
    List<MultipartFormItem> files, {
    Map<String, String>? headers,
    int? timeout,
    bool? debug,
  }) async {
    List<http.MultipartFile> multipartFiles = [];

    for (MultipartFormItem f in files) {
      final fileName = f.file.path.split('/').last;
      multipartFiles.add(
        http.MultipartFile.fromBytes(
          f.fieldName,
          f.file.readAsBytesSync(),
          filename: fileName,
          contentType: _getMime(fileName.split(".").last),
        ),
      );
    }
    var request = http.MultipartRequest('POST', Uri.parse(fullPath));
    if (headers != null) request.headers.addAll(headers);
    request.fields.addAll(postData);
    request.files.addAll(multipartFiles);
    var response = await request.send().timeout(
      Duration(seconds: timeout ?? postMultipartTimeOut),
      onTimeout: () {
        return http.StreamedResponse(
          Stream.empty(),
          408,
          reasonPhrase: "Timeout: Could not connect to server ${timeout ?? getTimeOut}",
        );
      },
    );
    http.Response res;
    res = await http.Response.fromStream(response);

    _logSimple(fullPath, res, postData: postData, multipartFiles: multipartFiles, headers: headers, debug: debug);
    if (res.statusCode == 408) throw TimeoutException(res.reasonPhrase);

    return res;
  }

  /* ==== ==== ==== DELETE ==== ==== ==== */
  /// Create a DELETE Request
  ///
  /// ```
  /// Examples:
  ///     delete("https://somewhere/api/data?id=1"");
  /// ```
  Future<http.Response> delete(
    /*  */
    T net,
    String path, {
    Map<String, String>? headers,
    int? timeout,
    bool? debug,
  }) async {
    String uriStr = getDomainName(net) + path;
    return await deleteGlobal(uriStr, headers: headers ?? getHeader(), timeout: timeout, debug: debug);
  }

  Future<http.Response> deleteGlobal(
    /*  */
    String fullPath, {
    Map<String, String>? headers,
    int? timeout,
    bool? debug,
  }) async {
    http.Response? res;
    String uriStr = fullPath;
    Uri uri = Uri.parse(uriStr);
    res = await http
        .delete(uri, headers: headers)
        .timeout(
          Duration(seconds: timeout ?? getTimeOut),
          onTimeout: () =>
              http.Response("", 408, reasonPhrase: "Timeout: Could not connect to server ${timeout ?? getTimeOut}"),
        );

    _logSimple(fullPath, res, headers: headers, debug: debug);
    if (res.statusCode == 408) throw TimeoutException(res.reasonPhrase);

    return res;
  }

  /* ==== ==== ==== PUT ==== ==== ==== */
  Future<http.Response> put(
    /*  */
    T net,
    String path,
    Map<String, dynamic> putData, {
    Map<String, String>? headers,
    int? timeout,
    bool? debug,
  }) async {
    String uriStr = getDomainName(net) + path;
    return await putGlobal(uriStr, putData, headers: headers ?? getHeader(), timeout: timeout, debug: debug);
  }

  Future<http.Response> putGlobal(
    String fullPath,
    Map<String, dynamic> putData, {
    Map<String, String>? headers,
    int? timeout,
    bool? debug,
  }) async {
    http.Response res;
    res = await http
        .put(Uri.parse(fullPath), body: jsonEncode(putData), headers: headers)
        .timeout(Duration(seconds: timeout ?? postTimeOut));
    _logSimple(fullPath, res, postData: putData, headers: headers, debug: debug);
    return res;
  }

  Future<http.Response> putMultipart(
    T net,
    String path,
    Map<String, String> putData,
    List<MultipartFormItem> files, {
    Map<String, String>? headers,
    int? timeout,
    bool? debug,
  }) async {
    String uriStr = getDomainName(net) + path;
    return await putMultipartGlobal(
      uriStr,
      putData,
      files,
      headers: headers ?? getHeader(),
      timeout: timeout,
      debug: debug,
    );
  }

  Future<http.Response> putMultipartGlobal(
    String fullPath,
    Map<String, String> putData,
    List<MultipartFormItem> files, {
    Map<String, String>? headers,
    int? timeout,
    bool? debug,
  }) async {
    List<http.MultipartFile> multipartFiles = [];

    for (MultipartFormItem f in files) {
      final fileName = f.file.path.split('/').last;
      multipartFiles.add(
        http.MultipartFile.fromBytes(
          f.fieldName,
          f.file.readAsBytesSync(),
          filename: fileName,
          contentType: _getMime(fileName.split(".").last),
        ),
      );
    }
    var request = http.MultipartRequest('PUT', Uri.parse(fullPath));
    if (headers != null) request.headers.addAll(headers);
    request.fields.addAll(putData);
    request.files.addAll(multipartFiles);
    var response = await request.send().timeout(
      Duration(seconds: timeout ?? postMultipartTimeOut),
      onTimeout: () {
        return http.StreamedResponse(
          Stream.empty(),
          408,
          reasonPhrase: "Timeout: Could not connect to server ${timeout ?? getTimeOut}",
        );
      },
    );
    http.Response res;
    res = await http.Response.fromStream(response);
    _logSimple(fullPath, res, postData: putData, multipartFiles: multipartFiles, headers: headers, debug: debug);
    if (res.statusCode == 408) throw TimeoutException(res.reasonPhrase);
    return res;
  }
  /* ==== ==== ==== LOG ==== ==== ==== */

  void _logSimple(
    String fullPath,
    http.Response? res, {
    Map<String, dynamic>? postData,
    List<http.MultipartFile>? multipartFiles,
    bool? debug = false,
    Map<String, String>? headers,
  }) {
    String t = "";
    try {
      t += fullPath.padRight(fullPath.length > 100 ? fullPath.length : 80, " ");
      t += " -> ";
      if (res?.reasonPhrase != null) t += "${res?.reasonPhrase ?? ""} | ";
      if (res != null) t += jsonDecode(res.body)?["message"];
      t += "\n";
    } catch (e) {
      // print(e.toString());
    }
    if (headers != null && ((debug ?? false) || showFullLog)) {
      try {
        t += JsonEncoder.withIndent("  ").convert(headers);
        t += "\n";
      } catch (e) {
        // print(e.toString());
      }
    }
    if (postData != null) {
      try {
        t += JsonEncoder.withIndent("  ").convert(postData);
        t += "\n";
      } catch (e) {
        // print(e.toString());
      }
    }
    if (multipartFiles != null) {
      try {
        List<Map<String, String>> f = [];
        for (http.MultipartFile e in multipartFiles) {
          f.add({
            "Field": e.field,
            "File-Name": e.filename.toString(),
            "Type": e.contentType.type,
            "Sub-Type": e.contentType.subtype,
            "Mime-Type": e.contentType.mimeType,
            "Content-Type": e.contentType.toString(),
            "Length": "${(e.length)}B | ${(e.length / 1024)}KB | ${(e.length / 1024 / 1024)}MB",
          });
        }
        log(JsonEncoder.withIndent("    ").convert(f));
      } catch (e) {}
    }
    if ((res != null && res.statusCode != 200) || (debug ?? false) || showFullLog) {
      try {
        if (res != null) t += JsonEncoder.withIndent("  ").convert(jsonDecode(res.body));
      } catch (e) {}
    }
    try {
      log(t, name: res?.statusCode.toString() ?? "error");
    } catch (e) {}
  }
}

/* Utilities */
class ApiException implements Exception {
  final String? message;
  const ApiException(this.message);

  @override
  String toString() => 'ApiException: $message';
}

class MultipartFormItem {
  File file;
  String fieldName;
  MultipartFormItem({required this.fieldName, required this.file});
}

/* 
  this is concrete implementation of FxNetwork for
  internal FxHelper use only
 */
class FxNetworkLocal extends FxNetwork {
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
