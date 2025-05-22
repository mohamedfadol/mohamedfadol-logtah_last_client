import 'package:diligov_members/utility/pdf_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'dart:io';

class CustomPdfView extends StatefulWidget {
  final String path;

  // Use a key based on the path to force widget recreation
  CustomPdfView({Key? key, required this.path})
      : super(key: ValueKey(path));

  @override
  State<CustomPdfView> createState() => _CustomPdfViewState();
}

class _CustomPdfViewState extends State<CustomPdfView> {
  String localPath = "";
  bool isLoading = true;
  PDFViewController? pdfController;

  @override
  void initState() {
    super.initState();
    // Set to portrait mode for PDF viewing
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    preparePdfFileFromNetwork();
  }

  @override
  void didUpdateWidget(CustomPdfView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the path changes, reload the PDF
    if (oldWidget.path != widget.path) {
      setState(() {
        isLoading = true;
        localPath = "";
      });
      preparePdfFileFromNetwork();
    }
  }

  @override
  void dispose() {
    // Set back to landscape when leaving
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
    ]);
    super.dispose();
  }

  Future<void> preparePdfFileFromNetwork() async {
    try {
      setState(() {
        isLoading = true;
      });

      if (await PDFApi.requestPermission()) {
        final filePath = await PDFApi.loadNetwork(widget.path);

        // Check if widget is still mounted before updating state
        if (mounted) {
          setState(() {
            localPath = filePath.path;
            isLoading = false;
          });
          print("Downloaded PDF to: $localPath");
          print("Original path: ${widget.path}");
        }
      } else {
        print("Storage permission denied");
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print("Error loading PDF: $e");
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("PDF Document"),
        actions: [
          // Add refresh button to force reload
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              preparePdfFileFromNetwork();
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : localPath.isNotEmpty
          ? PDFView(
        key: ValueKey(localPath), // Important: forces recreation when path changes
        filePath: localPath,
        fitEachPage: true,
        autoSpacing: true,
        enableSwipe: true,
        pageSnap: true,
        swipeHorizontal: true,
        nightMode: false,
        onViewCreated: (PDFViewController controller) {
          pdfController = controller;
        },
        onPageChanged: (int? currentPage, int? totalPages) {
          print("Current page: $currentPage, Total pages: $totalPages");
        },
        onError: (error) {
          print("PDF error: $error");
        },
      )
          : Center(
        child: Text("Failed to load PDF",
            style: TextStyle(color: Colors.red)),
      ),
    );
  }
}