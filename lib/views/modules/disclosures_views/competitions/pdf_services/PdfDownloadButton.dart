import 'dart:io';
import 'package:diligov_members/models/member.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:convert';
import 'dart:async';
import '../../../../../providers/competition_provider_page.dart';

class PdfDownloadButton extends StatefulWidget {
  final Member member;
  final String type;
  final IconData icon;
  final String label;
  final Color textColor;
  final Color backgroundColor;

  const PdfDownloadButton({
    Key? key,
    required this.member,
    required this.type,
    this.icon = Icons.download,
    this.label = 'Download PDF',
    this.textColor = Colors.white,
    this.backgroundColor = Colors.blue,
  }) : super(key: key);

  @override
  State<PdfDownloadButton> createState() => _PdfDownloadButtonState();

  // Static method to download PDF without needing to add a widget to the tree
  static Future<void> downloadPdf(BuildContext context, Member member, String type) async {
    // Show loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Generating PDF...")),
    );

    try {
      // Get provider to access filtered competitions
      final provider = Provider.of<CompetitionProviderPage>(context, listen: false);
      List<dynamic>? filteredCompetitions;

      // Fetch appropriate competitions based on type
      if (type == 'competition_with_confirmation_of_independence' &&
          provider.competitionsConfirmationOfIndependenceData?.competitions != null) {
        filteredCompetitions = provider.competitionsConfirmationOfIndependenceData!.competitions;
      } else if (type == 'competition_with_related_parties' &&
          provider.competitionsRelatedPartiesData?.competitions != null) {
        filteredCompetitions = provider.competitionsRelatedPartiesData!.competitions;
      } else if (provider.competitionsData?.competitions != null) {
        filteredCompetitions = provider.competitionsData!.competitions;
      } else {
        // If not loaded, fetch them
        await provider.getMemberCompetitions(
            provider.yearSelected,
            member.memberId.toString(),
            type
        );

        // Now get the filtered competitions based on type
        if (type == 'competition_with_confirmation_of_independence') {
          filteredCompetitions = provider.competitionsConfirmationOfIndependenceData?.competitions;
        } else if (type == 'competition_with_related_parties') {
          filteredCompetitions = provider.competitionsRelatedPartiesData?.competitions;
        } else {
          filteredCompetitions = provider.competitionsData?.competitions;
        }
      }

      if (filteredCompetitions == null || filteredCompetitions.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No competition data available to download')),
        );
        return;
      }

      // Generate PDF using the same format as CompetitionWithMembersQuestionsPdfViews
      final pdfBytes = await _generateComprehensivePdf(context, member, type, filteredCompetitions);

      // Create filename with timestamp
      final fileCreateTime = DateTime.now().millisecondsSinceEpoch;
      final fileName = '$fileCreateTime-${member.memberFirstName}-${_getTypeDisplayNameStatic(type)}.pdf';

      // Download PDF
      await _downloadPdfFileStatic(context, pdfBytes, fileName, member);

    } catch (e) {
      print("Error in static PDF download process: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating PDF: $e')),
      );
    }
  }

  // Static helper method to generate PDF - Using same format as CompetitionWithMembersQuestionsPdfViews
  static Future<Uint8List> _generateComprehensivePdf(BuildContext context, Member member, String type, List<dynamic> filteredCompetitions) async {
    final doc = pw.Document(title: "${member.memberFirstName}");
    final Uint8List logoImage = (await rootBundle.load('assets/images/profile.jpg')).buffer.asUint8List();

    // Generate left and right column content
    final leftColumnContent = _splitLargeListToPages2Static(member, filteredCompetitions);
    final rightColumnContent = _splitLargeListToPagesAr2Static(member, filteredCompetitions);

    // Create paginated widgets
    final leftPages = _createPaginatedWidgetsStatic(leftColumnContent, 1000);
    final rightPages = _createPaginatedWidgetsStatic(rightColumnContent, 1000);

    // Get page theme
    final pageTheme = await _myPageThemeStatic(PdfPageFormat.a4);

    // Create document page
    doc.addPage(
      pw.MultiPage(
        pageTheme: pageTheme,
        header: (pw.Context context) {
          return pw.Column(
              children: [
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: [
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(vertical: 8),
                      alignment: pw.Alignment.center,
                      child: _buildBusinessInformationStatic(member),
                    ),
                  ],
                ),
                pw.Divider(),
              ]
          );
        },
        build: (context) {
          final content = <pw.Widget>[];

          // Iterate through left and right column pages
          for (int i = 0; i < leftPages.length || i < rightPages.length; i++) {
            content.add(
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [if (i < leftPages.length) leftPages[i]]),
                  ),
                  pw.SizedBox(width: 10),
                  pw.Expanded(
                    child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [if (i < rightPages.length) rightPages[i]]),
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

    return await doc.save();
  }

  // Static helper methods for PDF generation - similar to CompetitionWithMembersQuestionsPdfViews
  static List<pw.Widget> _splitLargeListToPages2Static(Member member, List<dynamic> filteredCompetitions) {
    final largeList = <pw.Widget>[];
    largeList.add(_competitionListEnStatic(member, filteredCompetitions));
    largeList.add(_buildNoticeAndQuorumStatic(member));
    largeList.add(_buildManagementSignatureMembersEnSectionStatic(member));
    return largeList;
  }

  static List<pw.Widget> _splitLargeListToPagesAr2Static(Member member, List<dynamic> filteredCompetitions) {
    final arabicList = <pw.Widget>[];
    arabicList.add(_competitionListArStatic(member, filteredCompetitions));
    arabicList.add(_buildNoticeAndQuorumArStatic(member));
    arabicList.add(_buildManagementSignatureMembersArSectionStatic(member));
    return arabicList;
  }

  static List<pw.Widget> _createPaginatedWidgetsStatic(List<pw.Widget> widgets, double maxHeight) {
    final paginatedWidgets = <pw.Widget>[];
    double currentHeight = 0;
    List<pw.Widget> currentPage = [];

    for (var widget in widgets) {
      double widgetHeight = 1000; // Approximate height

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

  static pw.Widget _competitionListEnStatic(Member member, List<dynamic> filteredCompetitions) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      mainAxisAlignment: pw.MainAxisAlignment.start,
      children: [
        pw.ListView.builder(
          itemCount: filteredCompetitions.length,
          itemBuilder: (context, index) {
            final competition = filteredCompetitions[index];
            return pw.Align(  // Enforces start alignment within ListView
              alignment: pw.Alignment.centerLeft,
              child: pw.Paragraph(
                text: '${index + 1} - ${competition.competitionEnName}' ?? '',
                style: pw.TextStyle(
                  fontSize: 11.0,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  static pw.Widget _competitionListArStatic(Member member, List<dynamic> filteredCompetitions) {
    return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Directionality(
            textDirection: pw.TextDirection.rtl,
            child: pw.ListView.builder(
              itemCount: filteredCompetitions.length,
              itemBuilder: (context, index) {
                final competition = filteredCompetitions[index];
                return pw.Paragraph(
                  text: '${index + 1} - ${competition.competitionArName}' ?? '',
                  style: pw.TextStyle(
                    fontSize: 12.0,
                  ),
                );
              },
            ),
          )
        ]
    );
  }

  static pw.Widget _buildBusinessInformationStatic(Member member) {
    return pw.Container(
      child: pw.Column(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          pw.Text("Postal Code: ${member.business?.businessName}", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 4.0),
          pw.Text("CR Number: ${member.business!.registrationNumber}", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 4.0),
          pw.Text("Paid Capital: ${member.business?.capital} SAR", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 4.0),
          pw.Text("Postal Code: ${member.business?.postCode}", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 4.0),
          pw.Text("Country: ${member.business?.country}", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }

  static pw.Widget _competitionListEnTitleStatic() {
    return pw.Directionality(
        textDirection: pw.TextDirection.ltr,
        child: pw.Text(
          'Board of Directors - Decision',
          style: pw.TextStyle(fontSize: 11.0, fontWeight: pw.FontWeight.bold),
        )
    );
  }

  static pw.Widget _competitionListArTitleStatic() {
    return pw.Directionality(
        textDirection: pw.TextDirection.rtl,
        child: pw.Text(
          'قرار مجلس الإدارة',
          style: pw.TextStyle(fontSize: 12.0, fontWeight: pw.FontWeight.bold),
        )
    );
  }

  static pw.Widget _buildManagementSignatureMembersEnSectionStatic(Member member) {
    final members = member.managementSignature ?? [];
    return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _competitionListEnTitleStatic(),
          pw.SizedBox(height: 20),
          pw.Divider(),
          pw.ListView.builder(
            itemCount: members.length,
            itemBuilder: (context, index) {
              final member = members[index];
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    '${member.memberFirstName ?? ''} ${member.memberLastName ?? ''}',
                    style: pw.TextStyle(fontSize: 10),
                  ),
                  pw.Text("Decision: ${member.competitionPivot?.isAgree == 1 ? 'Approved' : 'Rejected'}", style: pw.TextStyle(fontSize: 10)),
                  if (member.competitionPivot?.isAgree == true && member.memberSignature != null)
                    pw.Image(pw.MemoryImage(base64Decode(member.memberSignature!)), height: 20, width: 70)
                  else
                    pw.Text('Signature: .........', style: pw.TextStyle(fontSize: 10)),
                  pw.SizedBox(height: 20),
                  pw.Divider(),
                ],
              );
            },
          )
        ]
    );
  }

  static pw.Widget _buildManagementSignatureMembersArSectionStatic(Member member) {
    final members = member.managementSignature ?? [];
    return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          _competitionListArTitleStatic(),
          pw.SizedBox(height: 20),
          pw.Divider(),
          pw.Directionality(
              textDirection: pw.TextDirection.rtl,
              child: pw.ListView.builder(
                itemCount: members.length,
                itemBuilder: (context, index) {
                  final member = members[index];
                  return pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('${member.memberFirstName ?? ''} ${member.memberLastName ?? ''}', style: pw.TextStyle(fontSize: 10)),
                      pw.Text("القرار : ${member.competitionPivot?.isAgree == 1 ? 'موافق' : 'غير موافق'}", style: pw.TextStyle(fontSize: 10)),
                      if (member.competitionPivot?.isAgree == true && member.memberSignature != null)
                        pw.Image(pw.MemoryImage(base64Decode(member.memberSignature!)), height: 20, width: 70)
                      else
                        pw.Text('التوقيع : .........', style: pw.TextStyle(fontSize: 10)),
                      pw.SizedBox(height: 20),
                      pw.Divider(),
                    ],
                  );
                },
              )
          )
        ]
    );
  }

  static pw.Widget _buildNoticeAndQuorumStatic(Member member) {
    return pw.Directionality(
        textDirection: pw.TextDirection.ltr,
        child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Name : ${member.memberFirstName} ${member.memberLastName} ',
                  style: pw.TextStyle(color: PdfColors.blueAccent700, fontWeight: pw.FontWeight.bold, fontSize: 11.0),
                  textAlign: pw.TextAlign.justify
              ),
              pw.Text('Signature :',
                  style: pw.TextStyle(color: PdfColors.black, fontSize: 11.0),
                  textAlign: pw.TextAlign.justify
              )
            ]
        )
    );
  }

  static pw.Widget _buildNoticeAndQuorumArStatic(Member member) {
    return pw.Directionality(
        textDirection: pw.TextDirection.rtl,
        child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children:[
              pw.Text(' ${member.memberLastName} ${member.memberFirstName}: الإسم  ',
                  style: pw.TextStyle(color: PdfColors.blueAccent700, fontWeight: pw.FontWeight.bold, fontSize: 12.0),
                  textAlign: pw.TextAlign.justify
              ),
              pw.Text('التوقيع : ',
                  style: pw.TextStyle(color: PdfColors.black, fontSize: 12.0),
                  textAlign: pw.TextAlign.justify
              )
            ]
        )
    );
  }

  static Future<pw.PageTheme> _myPageThemeStatic(PdfPageFormat format) async {
    final logoImage = pw.MemoryImage((await rootBundle.load('assets/images/profile.jpg')).buffer.asUint8List());
    final form = await rootBundle.load('assets/fonts/Al-Mohanad-Regular.ttf');
    final ttf = await rootBundle.load('assets/fonts/Al-Mohanad-Bold.ttf');
    final theme = pw.ThemeData.withFont(
      base: pw.Font.ttf(form),
      bold: pw.Font.ttf(ttf),
    );
    return pw.PageTheme(
      theme: theme,
      margin: const pw.EdgeInsets.symmetric(
        horizontal: 1 * PdfPageFormat.cm,
        vertical: 0.5 * PdfPageFormat.cm,
      ),
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

  // Static function to download the PDF file
  static Future<void> _downloadPdfFileStatic(BuildContext context, Uint8List pdfBytes, String fileName, Member member) async {
    try {
      print("Starting file download process...");

      // Request storage permission
      if (Platform.isAndroid) {
        print("Requesting storage permission on Android...");
        var status = await Permission.storage.request();
        print("Permission status: $status");

        if (!status.isGranted) {
          print("Storage permission denied");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Storage permission denied")),
          );
          return;
        }
      }

      // Determine directory for saving the file
      Directory? directory;
      try {
        if (Platform.isAndroid) {
          // Try multiple approaches for Android
          try {
            print("Getting external storage directory on Android...");
            directory = await getExternalStorageDirectory();
            if (directory == null) {
              throw Exception("Could not get external storage directory");
            }
            print("External storage directory: ${directory.path}");

            directory = Directory('${directory.path}/Documents');
            print("Target Documents subdirectory: ${directory.path}");
          } catch (e) {
            print("Error with getExternalStorageDirectory: $e, trying alternative path");
            // Try alternative path
            directory = Directory('/storage/emulated/0/Download');
            print("Using alternative path: ${directory.path}");
          }
        } else {
          print("Getting application documents directory...");
          directory = await getApplicationDocumentsDirectory();
          print("Documents directory: ${directory.path}");
        }
      } catch (e) {
        print("Error getting directory: $e");
        throw e;
      }

      // Ensure the directory exists
      try {
        if (!await directory!.exists()) {
          print("Creating directory: ${directory.path}");
          await directory.create(recursive: true);
        }
      } catch (e) {
        print("Error creating directory: $e");
        // Try using Download directory as fallback
        directory = Directory('/storage/emulated/0/Download');
        print("Using fallback download directory: ${directory.path}");
      }

      // Define the complete file path
      final filePath = '${directory!.path}/$fileName';
      print("Final file path: $filePath");

      final file = File(filePath);

      // Write the PDF file to the specified path
      try {
        print("Writing PDF bytes to file...");
        await file.writeAsBytes(pdfBytes);
        print("File write complete");
      } catch (e) {
        print("Error writing file: $e");
        throw e;
      }

      // Verify file exists
      try {
        if (await file.exists()) {
          print("File exists after write: ${await file.length()} bytes");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("PDF saved to ${directory.path}")),
          );
        } else {
          print("File does not exist after write attempt");
          throw Exception("Failed to save PDF file");
        }
      } catch (e) {
        print("Error verifying file: $e");
        throw e;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("PDF downloaded successfully.")),
      );
    } catch (e) {
      print("Error in downloadPdfFile: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error downloading PDF: $e")),
      );
      throw e;
    }
  }

  // Static helper method to get display name for the type
  static String _getTypeDisplayNameStatic(String type) {
    switch (type) {
      case 'competition_with_confirmation_of_independence':
        return 'Confirmation of Independence';
      case 'competition_with_related_parties':
        return 'Related Parties';
      case 'competition_with_company':
        return 'Competition with Company';
      default:
        return type;
    }
  }
}

class _PdfDownloadButtonState extends State<PdfDownloadButton> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: Icon(
        widget.icon,
        color: widget.textColor,
      ),
      label: Text(
        isLoading ? 'Downloading...' : widget.label,
        style: TextStyle(color: widget.textColor),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: widget.backgroundColor,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      onPressed: isLoading ? null : () => _downloadPdf(context),
    );
  }

  // Instance method for button click
  Future<void> _downloadPdf(BuildContext context) async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    try {
      await PdfDownloadButton.downloadPdf(context, widget.member, widget.type);
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }
}