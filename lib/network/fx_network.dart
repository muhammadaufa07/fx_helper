import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http_parser/http_parser.dart';
import 'package:http/http.dart' as http;

abstract class FxNetwork<T> {
  bool get isDevMode;
  dynamic get env;
  bool get showFullLog;

  int get getTimeOut => 10;
  int get postTimeOut => 10;
  int get postMultipartTimeOut => 30;

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

  /// Create a GET Request
  ///
  /// ```
  /// Examples:
  ///     get(Net.gateway, url: "home/menu");
  /// ```

  Future<http.Response> get(T net, String path, {int? timeout, bool? debug}) async {
    String uriStr = getDomainName(net) + path;
    return await getGlobal(uriStr, headers: getHeader(), timeout: timeout, debug: debug);
  }

  /// Create a GET Request
  ///
  /// ```
  /// Examples:
  ///     get("https://somewhere/api/data"");
  /// ```
  Future<http.Response> getGlobal(String fullPath, {Map<String, String>? headers, int? timeout, bool? debug}) async {
    http.Response res;
    String uriStr = fullPath;
    Uri uri = Uri.parse(uriStr);
    res = await http.get(uri, headers: headers).timeout(Duration(seconds: timeout ?? getTimeOut));
    _logSimple(fullPath, res, debug: debug);

    return res;
  }

  /// Create a POST Request
  ///
  /// ```
  /// Examples:
  ///     var postData = {"email": "user@mail.com", "password": "password"};
  ///     post(Net.gateway, postData)
  /// ```

  Future<http.Response> post(T net, String path, Map<String, dynamic> postData, {int? timeout}) async {
    String uriStr = getDomainName(net) + path;
    return await postGlobal(uriStr, postData, timeout: timeout);
  }

  Future<http.Response> postGlobal(String fullPath, Map<String, dynamic> postData, {int? timeout}) async {
    http.Response res;
    res = await http
        .post(Uri.parse(fullPath), body: jsonEncode(postData), headers: getHeader())
        .timeout(Duration(seconds: timeout ?? postTimeOut));
    _logSimple(fullPath, res, postData: postData);
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
    int? timeout,
  }) async {
    String uriStr = getDomainName(net) + path;
    return await postMultipartGlobal(uriStr, postData, files, timeout: timeout);
  }

  Future<http.Response> postMultipartGlobal(
    String fullPath,
    Map<String, String> postData,
    List<MultipartFormItem> files, {
    int? timeout,
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
    request.headers.addAll(getHeader());
    request.fields.addAll(postData);
    request.files.addAll(multipartFiles);
    var response = await request.send().timeout(Duration(seconds: timeout ?? postMultipartTimeOut));
    http.Response res;
    res = await http.Response.fromStream(response);
    _logSimple(fullPath, res, postData: postData, multipartFiles: multipartFiles);
    return res;
  }

  void _logSimple(
    String fullPath,
    http.Response res, {
    Map<String, dynamic>? postData,
    List<http.MultipartFile>? multipartFiles,
    bool? debug,
  }) {
    String t = "";
    try {
      t +=
          "${fullPath.padRight(fullPath.length > 100 ? fullPath.length : 80, " ")} -> ${jsonDecode(res.body)?["message"]}\n";
    } catch (e) {}
    if (postData != null) {
      try {
        t += JsonEncoder.withIndent("  ").convert(postData);
        t += "\n";
      } catch (e) {}
    }
    // if (multipartFiles != null) {
    //   try {
    //     List<Map<String, String>> f = [];
    //     for (var element in multipartFiles) {
    //       f.add({element.field: element.filename.toString()});
    //     }
    //     log(JsonEncoder.withIndent("    ").convert(f));
    //   } catch (e) {}
    // }
    if (res.statusCode != 200 || showFullLog) {
      try {
        t += JsonEncoder.withIndent("  ").convert(jsonDecode(res.body));
      } catch (e) {}
    }
    try {
      log(t, name: res.statusCode.toString());
    } catch (e) {
      print(e.toString());
    }
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
