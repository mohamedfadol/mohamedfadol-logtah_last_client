import 'dart:io';

import 'package:diligov_members/models/annual_audit_report_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' as material;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:printing/printing.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../models/annual_audit_category.dart';
import '../../../models/annual_audit_details_model.dart';
import '../../../models/committee_model.dart';
import '../../../models/member.dart';
import '../../../utility/edit_laboratory_local_file_processing.dart';
import '../../../utility/pdf_api.dart';

class AnnualAuditGenerateForArabicPdfPag extends material.StatefulWidget {
  final AnnualAuditReportModel annual_report;
  const AnnualAuditGenerateForArabicPdfPag({super.key, required this.annual_report});
  static const routeName = '/AnnualAuditGenerateForEnglishPdfPag';


  @override
  material.State<AnnualAuditGenerateForArabicPdfPag> createState() => _AnnualAuditGenerateForArabicPdfPagState();
}

class _AnnualAuditGenerateForArabicPdfPagState extends material.State<AnnualAuditGenerateForArabicPdfPag> {
  PrintingInfo? printingInfo;

  @override
  void initState()  {
    // TODO: implement initState
    super.initState();
    _inti();
  }

  Future<void> _inti() async{
    final info = await Printing.info();
    setState(() {
      printingInfo = info;
    });
  }


  Future<void> saveAsFile(material.BuildContext context) async {
    // Generate PDF bytes and save them
    final pdfBytes = await generatePdf(context, PdfPageFormat.a4, widget.annual_report);
    // await downloadPdfFile(context, pdfBytes, 'minutes_of_meeting2.pdf');
  }

  @override
  material.Widget build(material.BuildContext context) {
    pw.RichText.debug= true;
    final actions =<PdfPreviewAction>[
      if(!kIsWeb)
        PdfPreviewAction(icon: const material.Icon(material.Icons.save) , onPressed: (context, build, pageFormat) => saveAsFile(context),)
    ];
    return  material.Scaffold(
      appBar: material.AppBar(
        title: material.Text('${widget.annual_report.annualAuditReportTitleAr}'),
      ),
      body: PdfPreview(
        // maxPageWidth: 1000,
        actions: actions,
        onPrinted: showPrintingToast,
        onShared: showSharedToast,
        build: (format) => generatePdf(context, format, widget.annual_report),
      ),
    );
  }
}


// Function to generate the PDF document with BuildContext
Future<Uint8List> generatePdf(material.BuildContext context,final PdfPageFormat format, AnnualAuditReportModel annual_report) async {
  final doc = pw.Document(title: "${annual_report.annualAuditReportTitleAr}");
  // final logoImage = pw.MemoryImage((await rootBundle.load('assets/images/profile.jpg')).buffer.asUint8List());
  final Uint8List logoImage = (await rootBundle.load('assets/images/profile.jpg')).buffer.asUint8List();


  final rightColumnContent = _splitLargeListToPagesAr2(annual_report); // Right column (Arabic)

  // Ensure pagination works correctly by splitting content across pages
  // 600 - approximate height for a page
  final rightPages = _createPaginatedWidgets(rightColumnContent, 1000);
  final pageTheme = await _myPageTheme(format);
  // Create pages in the document pw.Divider(thickness: 1.0,),
  doc.addPage(
    pw.MultiPage(
      pageTheme: pageTheme,
      header: (pw.Context context) {
        return pw.Column(
            children: [
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        buildLeftTableFirstRow(annual_report),
                        buildLeftTableSecondRow(annual_report),
                        buildLeftTableThirdRow(annual_report)
                      ]
                  ),

                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(vertical: 8),
                    alignment: pw.Alignment.center,
                    child: pw.Image(
                      pw.MemoryImage(logoImage), // Wrap the Uint8List image data in pw.MemoryImage
                      fit: pw.BoxFit.contain,
                      height: 40, // Adjust the height as needed
                    ),
                  ),

                  pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        buildRightTableFirstRow(annual_report),
                        buildRightTableSecondRow(annual_report),
                        buildRightTableThirdRow(annual_report)
                      ]
                  ),

                ],
              ),
              pw.Divider(),
              _buildBusinessInformation(annual_report),
              pw.Divider(),
            ]
        );
      },
      footer: (context) => _buildFooter(context, annual_report),
      build: (context) {
        final content = <pw.Widget>[];

        // Iterate through left and right column pages
        for (int i = 0; i < rightPages.length; i++) {
          content.add(
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,children: [rightPages[i]]),
                ),
              ],
            ),
          );
          content.add(pw.SizedBox(height: 10)); // Add space between rows
        }

        return content;
      },
    ),
  );

  final pdfBytes = await doc.save();
  final fileCreateTime =  DateTime.now().millisecondsSinceEpoch;
  await downloadPdfFile(context, pdfBytes, '$fileCreateTime+${annual_report.annualAuditReportTitleAr}.pdf', annual_report);
  return pdfBytes;
}

void showPrintingToast(final material.BuildContext context) {
  material.ScaffoldMessenger.of(context).showSnackBar(
    material.SnackBar(content: material.Text('Printing...')),
  );
}

void showSharedToast(final material.BuildContext context) {
  material.ScaffoldMessenger.of(context).showSnackBar(
    material.SnackBar(content: material.Text('Document shared!')),
  );
}
// Function to paginate widgets based on maxHeight available for each page
List<pw.Widget> _createPaginatedWidgets(List<pw.Widget> widgets, double maxHeight) {
  final paginatedWidgets = <pw.Widget>[];
  double currentHeight = 0;
  List<pw.Widget> currentPage = [];

  for (var widget in widgets) {
    // Estimate or calculate widget height, assuming each widget fits within maxHeight
    double widgetHeight = 1000; // Adjust based on your typical widget heights

    // Create a new page if adding the widget exceeds maxHeight
    if ((currentHeight + widgetHeight) > maxHeight) {
      paginatedWidgets.add(pw.Column(children: List.from(currentPage)));
      currentPage = [widget];
      currentHeight = widgetHeight;
    } else {
      currentPage.add(widget);
      currentHeight += widgetHeight;
    }
  }

  // Add any remaining widgets as the last page
  if (currentPage.isNotEmpty) {
    paginatedWidgets.add(pw.Column(children: currentPage));
  }

  return paginatedWidgets;
}

List<pw.Widget> _splitLargeListToPagesAr2(AnnualAuditReportModel annual_report) {
  final arabicList = <pw.Widget>[];
  arabicList.add(_buildAnnualAuditArabicTitle(annual_report));
  for (var i = 0; i < annual_report.annualAuditCategories!.length; i++) {
    arabicList.add(_buildCategoryArabicName(annual_report.annualAuditCategories![i]));
    for (var detail in annual_report.annualAuditCategories![i].details!) {
      arabicList.add(_buildAgendaDetailSectionAr(detail, i));
    }
  }

  return arabicList;
}


// Arabic version of the agenda detail section
pw.Widget _buildAgendaDetailSectionAr(AnnualAuditDetailsModel detail, int i) {
  return pw.Directionality(
    textDirection: pw.TextDirection.rtl,
    child: pw.Table(
      // crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.TableRow(
            children: [
              pw.Text('${i+1}- ${detail.detailArabicName}', style: pw.TextStyle(fontSize: 12,color: PdfColors.blueAccent700, fontWeight: pw.FontWeight.bold)),
            ]),

      ],
    ),
  );
}


// Arabic version of the agenda detail section
pw.Widget _buildAnnualAuditArabicTitle(AnnualAuditReportModel annual_report) {
  return pw.Directionality(
    textDirection: pw.TextDirection.rtl,
    child: pw.Table(
      // crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.TableRow(
            children: [
              pw.Text('${annual_report.annualAuditReportTitleAr}', style: pw.TextStyle(fontSize: 12,color: PdfColors.blueAccent700, fontWeight: pw.FontWeight.bold)),
            ]),

      ],
    ),
  );
}

String getFirstAdminName(Committee committee) {
  return committee.members
      ?.firstWhere((mem) => mem.memberShip?.memberIsAdmin == 1, orElse: () => Member())
      .memberFirstName ?? 'No Admin Found';
}


pw.Widget _buildFooter(pw.Context context, AnnualAuditReportModel annual_report) {
  var memberName = getFirstAdminName(annual_report.committee!);

  return pw.Column(
    children: [
      if (context.pageNumber == context.pagesCount) // Only on the last page
        pw.Container(
          alignment: pw.Alignment.centerRight,
          margin: const pw.EdgeInsets.only(bottom: 10), // Add some spacing
          child: pw.Text(
            '$memberName', // Replace with your text
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.black),
          ),
        ),
      pw.Divider(thickness: 1.0), // The footer divider
      pw.Container(
        alignment: pw.Alignment.centerRight,
        child: pw.Text(
          'Page ${context.pageNumber} of ${context.pagesCount}',
          style: pw.TextStyle(fontSize: 8),
        ),
      ),
    ],
  );
}



pw.Widget _buildCategoryArabicName(AnnualAuditCategoryModel annualAuditCategory) {
  return pw.Directionality(
      textDirection: pw.TextDirection.rtl,
      child: pw.Text(
        '${annualAuditCategory.categoryArabicName}',
        style: pw.TextStyle(fontSize: 12.0, fontWeight: pw.FontWeight.bold),
      )
  );
}

pw.Widget buildLeftTableFirstRow(AnnualAuditReportModel annual_report) {
  return pw.Table(
    // border: pw.TableBorder.all(color: PdfColors.grey, width: 0.5),
    children: [
      // Row 1: Company Name in English and Arabic
      pw.TableRow(
        children: [
          pw.Padding(
            padding: const pw.EdgeInsets.all(1.0),
            child: pw.Text(
              '${annual_report!.business?.businessName}',
              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
            ),
          ),
        ],
      ),
    ],
  );
}
pw.Widget buildLeftTableSecondRow(AnnualAuditReportModel annual_report) {
  return pw.Table(
    // border: pw.TableBorder.all(color: PdfColors.grey, width: 0.5),
    children: [
      // Row 1: Company Name in English and Arabic
      pw.TableRow(
        children: [
          pw.Padding(
            padding: const pw.EdgeInsets.all(1.0),
            child: pw.Text(
                '${annual_report.committee?.committeeName}' ?? '',
                style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                textAlign: pw.TextAlign.justify
            ),
          ),


        ],
      ),
    ],
  );
}
pw.Widget buildLeftTableThirdRow(AnnualAuditReportModel annual_report) {
  return pw.Table(
    // border: pw.TableBorder.all(color: PdfColors.grey, width: 0.5),
    children: [
      // Row 1: Company Name in English and Arabic
      pw.TableRow(
        children: [
          pw.Padding(
            padding: const pw.EdgeInsets.all(1.0),
            child: pw.Text(
              'No ${annual_report.committee?.serialNumber}' ?? '',
              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
            ),
          ),


        ],
      ),
    ],
  );
}

pw.Widget buildRightTableFirstRow(AnnualAuditReportModel annual_report) {
  return pw.Directionality(
      textDirection: pw.TextDirection.rtl,
      child: pw.Table(
        // border: pw.TableBorder.all(color: PdfColors.grey, width: 0.5),
        children: [
          // Row 1: Company Name in English and Arabic
          pw.TableRow(
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(1.0),
                child: pw.Text(
                  '${annual_report.business?.businessName}',
                  textAlign: pw.TextAlign.right,
                  textDirection: pw.TextDirection.rtl,
                  style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                ),
              ),
            ],
          ),

        ],
      )
  );

}
pw.Widget buildRightTableSecondRow(AnnualAuditReportModel annual_report) {
  return pw.Directionality(
      textDirection: pw.TextDirection.rtl,
      child: pw.Table(
        // border: pw.TableBorder.all(color: PdfColors.grey, width: 0.5),
        children: [
          // Row 1: Company Name in English and Arabic
          pw.TableRow(
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(1.0),
                child: pw.Text(
                  '${annual_report.committee?.committeeName}',
                  textAlign: pw.TextAlign.right,
                  textDirection: pw.TextDirection.rtl,
                  style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                ),
              ),
            ],
          ),

        ],
      )
  );
}
pw.Widget buildRightTableThirdRow(AnnualAuditReportModel annual_report) {
  return pw.Directionality(
      textDirection: pw.TextDirection.rtl,
      child: pw.Table(
        // border: pw.TableBorder.all(color: PdfColors.grey, width: 0.5),
        children: [
          // Row 1: Company Name in English and Arabic
          pw.TableRow(
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(1.0),
                child: pw.Text(
                  'رقم ${annual_report.committee?.serialNumber}' ?? '',
                  textAlign: pw.TextAlign.right,
                  textDirection: pw.TextDirection.rtl,
                  style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                ),
              ),
            ],
          ),

        ],
      )
  );
}


Future<pw.PageTheme> _myPageTheme(PdfPageFormat format) async {
  final logoImage = pw.MemoryImage((await rootBundle.load('assets/images/profile.jpg')).buffer.asUint8List());
  final form = await rootBundle.load('assets/fonts/Al-Mohanad-Regular.ttf');
  final ttf = await rootBundle.load('assets/fonts/Al-Mohanad-Bold.ttf');
  final theme = pw.ThemeData.withFont(
    base: pw.Font.ttf(form),
    bold: pw.Font.ttf(ttf),
  );
  return  pw.PageTheme(
    theme: theme,
    margin: const pw.EdgeInsets.symmetric(
      horizontal: 1 * PdfPageFormat.cm,
      vertical: 0.5 * PdfPageFormat.cm,
    ),
    // textDirection: pw.TextDirection.ltr,
    orientation: pw.PageOrientation.portrait,
    buildBackground: (final context) => pw.FullPage(
      ignoreMargins: true,
      child: pw.Stack(
        children: List.generate(
          20, // Adjust the number of rows as needed
              (rowIndex) => pw.Positioned(
            top: rowIndex * 3.5 * PdfPageFormat.mm,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
              children: List.generate(
                5, // Adjust the number of columns as needed
                    (colIndex) => pw.Transform.rotate(
                  angle: 20 * 3.14159 / 600,
                  child: pw.Opacity(
                    opacity: 0.1,
                    child: pw.Text(
                      "",
                      style: const pw.TextStyle(fontSize: 20),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );

}

pw.Widget _buildBusinessInformation(AnnualAuditReportModel annual_report) {
  return pw.Container(
    // padding: pw.EdgeInsets.only(bottom: 2),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.center,
      children: [
        pw.Text("Postal Code: ${annual_report.business?.postCode}"),
        pw.SizedBox(width: 4.0),
        pw.Text("Country: ${annual_report.business?.country}"),
        pw.SizedBox(width: 4.0),
        pw.Text("CR: ${annual_report.business!.registrationNumber}"),
        pw.SizedBox(width: 4.0),
        pw.Text("Paid Capital: ${annual_report.business?.capital} SAR"),
      ],
    ),
  );
}


// Function to handle downloading the PDF file with BuildContext
Future<void> downloadPdfFile(material.BuildContext context, Uint8List pdfBytes, String fileName, AnnualAuditReportModel annual_report) async {
  try {
    if (Platform.isAndroid) {
      var status = await Permission.storage.request();
      if (!status.isGranted) {
        material.ScaffoldMessenger.of(context).showSnackBar(
          material.SnackBar(content: material.Text("Storage permission denied")),
        );
        return;
      }
    }

    // Determine directory for saving the file
    Directory? directory;
    if (Platform.isAndroid) {
      directory = await getExternalStorageDirectory();
      directory = Directory('${directory!.path}/Documents');
    } else {
      directory = await getApplicationDocumentsDirectory();
    }

    // Ensure the directory exists
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    // Define the complete file path
    final filePath = '${directory.path}/$fileName';
    final file = File(filePath);

    // Write the PDF file to the specified path
    await file.writeAsBytes(pdfBytes);

    // Notify user of successful download and open file
    if (await file.exists()) {
      material.ScaffoldMessenger.of(context).showSnackBar(
        material.SnackBar(content: material.Text("PDF saved to ${directory.path}")),
      );
      print("annual report pdf file $fileName");
      // material.Navigator.of(context).push(material.MaterialPageRoute(builder: (context) => EditLaboratoryLocalFileProcessing(comingLocalPath: '${fileName}',)));
      PDFApi.retrieveFileAnnualAudit(context,fileName, annual_report);
      // await OpenFile.open(filePath);
    } else {
      throw Exception("Failed to save PDF file");
    }
    material.ScaffoldMessenger.of(context).showSnackBar(
      const material.SnackBar(content: material.Text("PDF downloaded successfully.")),
    );
  } catch (e) {
    material.ScaffoldMessenger.of(context).showSnackBar(
      material.SnackBar(content: material.Text("Error downloading PDF: $e")),
    );
  }
}
