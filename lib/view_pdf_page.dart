import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class ViewPdfPage extends StatefulWidget {
  final String? title;
  final String? url;
  final String? localFile;
  final bool allowDownload;
  final AppBar? appBar;
  final Map<String, String>? headers;

  const ViewPdfPage({
    super.key,
    required this.title,
    this.url,
    this.headers,
    this.localFile,
    this.allowDownload = true,
    required this.appBar,
  });
  @override
  _ViewPdfPageState createState() => _ViewPdfPageState();
}

class _ViewPdfPageState extends State<ViewPdfPage> {
  // Map<String, String>? headers = {};
  bool isLoading = false;
  String? pdfUrl;
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      loadPdf();
    });

    super.initState();
  }

  Future<void> loadPdf() async {
    setState(() {
      isLoading = true;
    });

    try {
      if (widget.url != null) {
        // headers = widget.headers;

        var url = widget.url;
        // var response = await Network.get(Net.gateway, widget.url ?? '');
        // if (response.statusCode == 200) {
        pdfUrl = url;
        // } else {}
      }
      //  else {
      //   pdfUrl = widget.publicUrl ?? '';
      // }
      setState(() {});
    } catch (e) {}

    setState(() {
      isLoading = false;
    });
  }

  Future<void> printPdfFromUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      final headersMap = widget.headers;

      final response = await http.get(uri, headers: headersMap);

      if (response.statusCode == 200) {
        final pdfData = response.bodyBytes;

        await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async => pdfData,
          name: "Payslip ${DateTime.now().toIso8601String()}",
        );
      } else {}
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
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
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: const Color(0xFFAC1F1F)),
                child: Icon(Icons.download, color: Colors.white),
              ),
              onPressed: () {
                printPdfFromUrl(pdfUrl ?? '');
              },
            )
          : null,
      body: Builder(
        builder: (context) {
          if (isLoading) {
            return Center(child: CircularProgressIndicator(color: const Color(0xFFAC1F1F)));
          }

          if ((widget.localFile != null) && pdfUrl == null) {
            return SfPdfViewer.asset(widget.localFile ?? "");
          }

          if ((pdfUrl ?? '').isEmpty || pdfUrl == null) {
            return Center(
              child: Text("Gagal memuat PDF", style: TextStyle(color: Colors.red)),
            );
          }

          return SfPdfViewerTheme(
            data: SfPdfViewerThemeData(backgroundColor: Colors.white, progressBarColor: const Color(0xFFAC1F1F)),
            child: SfPdfViewer.network(pdfUrl ?? "", headers: widget.headers),
          );
        },
      ),
    );
  }
}
