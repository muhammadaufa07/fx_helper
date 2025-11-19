import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fx_helper/snackbar_helper.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

enum ViewPdfType { asset, network, file }

class ViewPdfPage extends StatefulWidget {
  final String? title;
  final String? path;
  final ViewPdfType viewPdfType;
  final bool allowDownload;
  final AppBar? appBar;
  final Map<String, String>? headers;
  final String? onDownloadFileName;
  /* 
    path could be local, asset, or from network, 
   */
  const ViewPdfPage({
    super.key,
    @Deprecated("Use [appBar instead]") required this.title,
    this.path,
    this.headers,
    required this.allowDownload,
    this.appBar,
    this.onDownloadFileName,
    required this.viewPdfType,
  });
  @override
  _ViewPdfPageState createState() => _ViewPdfPageState();
}

class _ViewPdfPageState extends State<ViewPdfPage> {
  final _controller = PdfViewerController();
  bool isLoading = false;
  String? pdfUrl;

  @override
  void initState() {
    if (widget.allowDownload == true) {
      assert(widget.onDownloadFileName?.isNotEmpty ?? false, "DownloadFileName is Required");
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> download() async {
    isLoading = true;
    setState(() {});
    try {
      Uint8List? pdfBytes;
      if (widget.viewPdfType == ViewPdfType.asset) {
        final byteData = await rootBundle.load(widget.path ?? "");
        pdfBytes = byteData.buffer.asUint8List();
      } else if (widget.viewPdfType == ViewPdfType.network) {
        final uri = Uri.parse(widget.path ?? "");
        final response = await http.get(uri, headers: widget.headers);
        if (response.statusCode == 200) {
          pdfBytes = response.bodyBytes;
        }
      } else if (widget.viewPdfType == ViewPdfType.file) {
        File f = File(widget.path ?? "");
        pdfBytes = await f.readAsBytes();
      }

      if (pdfBytes != null) {
        await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => pdfBytes!,
          name: widget.onDownloadFileName ?? "",
        );
      } else {
        SnackbarHelper.showSnackBar(SnackbarState.warning, "Could not read pdf");
      }
    } catch (e) {
      print(e.toString());
    }
    isLoading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Color primaryColor = Theme.of(context).primaryColor;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar:
          widget.appBar ??
          AppBar(
            backgroundColor: Colors.white,
            automaticallyImplyLeading: false,
            surfaceTintColor: Colors.transparent,
            toolbarHeight: 80,
            leading: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Container(
                    width: MediaQuery.sizeOf(context).width / 8.5,
                    height: MediaQuery.sizeOf(context).width / 8.5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFCFCFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Color(0xFFF0F0F0)),
                    ),
                    child: Material(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: const Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Icon(Icons.arrow_back_ios, color: Colors.black, size: 25),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            leadingWidth: 90,
            title: Text(widget.title ?? "PDF"),
            centerTitle: true,
            titleTextStyle: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600),
          ),
      floatingActionButton: widget.allowDownload
          ? IconButton(
              icon: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: primaryColor),
                child: Icon(Icons.download, color: Colors.white),
              ),
              onPressed: () {
                download();
              },
            )
          : null,
      body: Builder(
        builder: (context) {
          if (isLoading) {
            return Center(child: CircularProgressIndicator(color: primaryColor));
          }

          if (widget.path == null || widget.path?.isEmpty == true) {
            return Center(
              child: Text("Gagal memuat PDF", style: TextStyle(color: Colors.red)),
            );
          }

          return SfPdfViewerTheme(
            data: SfPdfViewerThemeData(backgroundColor: Colors.white, progressBarColor: primaryColor),
            child: Builder(
              builder: (context) {
                if (widget.viewPdfType == ViewPdfType.asset) {
                  return SfPdfViewer.asset(controller: _controller, widget.path ?? "");
                } else if (widget.viewPdfType == ViewPdfType.network) {
                  return SfPdfViewer.network(controller: _controller, widget.path ?? "", headers: widget.headers);
                } else if (widget.viewPdfType == ViewPdfType.file) {
                  File f = File(widget.path ?? "");
                  return SfPdfViewer.file(f);
                }
                return Text("Err", maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.start);
              },
            ),
          );
        },
      ),
    );
  }
}
