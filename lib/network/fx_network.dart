import 'dart:convert';
import 'dart:io';
import 'package:http_parser/http_parser.dart';
import 'package:http/http.dart' as http;

/* This is Testing Only [ Simple Network ]*/

/* 
   /// 1. add implements FxNet to Net ///
        enum Net implements FxNet { gateway }
         
   /// 2. Replace Network with this ///
  
        class Network extends FxNetwork {
          static final Network _instance = Network._internal();
          factory Network() => _instance;
          Network._internal();

          static String? TOKEN;
          
          bool get isDevMode => true;

          EnvModel get env => isDevMode ? EnvStaging() : EnvProduction();

          @override
          getHeader() {
            final String date = Crypt().timestamp(DateTime.now());
            var h = {"x-Date": date};
            if (TOKEN != null && TOKEN?.isNotEmpty == true) {
              h.addAll({"Authorization": "Bearer $TOKEN"});
            }
            return h;
          }

          @override
          String getDomainName(FxNet net) {
            switch (net) {
              case Net.gateway:
                return env.baseUrlGateway;
            }
            return env.baseUrlGateway;
          }
        }
        
   /// 3. Call in this way ///
   /// res = await Network().get(Net.gateway, url)
 */

abstract class FxNetwork {
  const FxNetwork();
  // bool get isDevMode;
  Map<String, String> getHeader();
  String getDomainName(FxNet net);

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

  Future<http.Response> get(FxNet net, String path) async {
    String uriStr = getDomainName(net) + path;
    Uri uri = Uri.parse(uriStr);
    return await http.get(uri, headers: getHeader()).timeout(Duration(seconds: 5));
  }

  /// Create a POST Request
  ///
  /// ```
  /// Examples:
  ///     var postData = {"email": "user@mail.com", "password": "password"};
  ///     post(Net.gateway, postData)
  /// ```

  Future<http.Response> post(FxNet net, String path, Map<String, dynamic> postData) async {
    String uriStr = getDomainName(net) + path;
    var res = await http
        .post(Uri.parse(uriStr), body: jsonEncode(postData), headers: getHeader())
        .timeout(Duration(seconds: 5));
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
    FxNet net,
    String path,
    Map<String, String> postData,
    List<MultipartFormItem> files,
  ) async {
    String uriStr = getDomainName(net) + path;
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
    var request = http.MultipartRequest('POST', Uri.parse(uriStr));
    request.headers.addAll(getHeader());
    request.fields.addAll(postData);
    request.files.addAll(multipartFiles);
    var response = await request.send().timeout(Duration(seconds: 30));
    return await http.Response.fromStream(response);
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

class FxNet {}
