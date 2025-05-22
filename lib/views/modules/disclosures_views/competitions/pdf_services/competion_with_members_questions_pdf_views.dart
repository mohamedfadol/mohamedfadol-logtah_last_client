import 'dart:io';
import 'package:diligov_members/models/member.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' as material;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:printing/printing.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:provider/provider.dart';
import '../../../../../models/minutes_model.dart';
import '../../../../../providers/competition_provider_page.dart';

class CompetitionWithMembersQuestionsPdfViews extends material.StatefulWidget {
  final Member member;
  final String type;
  const CompetitionWithMembersQuestionsPdfViews({super.key, required this.member, required this.type,});
  static const routeName = '/CompetitionWithMembersQuestionsPdfViews';
  @override
  material.State<CompetitionWithMembersQuestionsPdfViews> createState() => _CompetitionWithMembersQuestionsPdfViewsState();
}

class _CompetitionWithMembersQuestionsPdfViewsState extends material.State<CompetitionWithMembersQuestionsPdfViews> {
  PrintingInfo? printingInfo;
  List<dynamic>? filteredCompetitions;
  @override
  void initState()  {
    // TODO: implement initState
    super.initState();
    _inti();
  var  cc =  widget.member.competitions;
  print("cc cc $cc");
  }

  Future<void> _inti() async{
    final info = await Printing.info();
    setState(() {
      printingInfo = info;
    });

    await _fetchFilteredCompetitions();

  }

  // Fetch competitions with the specific type
  Future<void> _fetchFilteredCompetitions() async {
    try {
      final provider =  Provider.of<CompetitionProviderPage>(context, listen: false);

      // If we already have the data loaded with the correct type, use it
      if (widget.type == 'competition_with_confirmation_of_independence' &&
          provider.competitionsConfirmationOfIndependenceData?.competitions != null) {
        setState(() {
          filteredCompetitions = provider.competitionsConfirmationOfIndependenceData!.competitions;
        });
      } else if (widget.type == 'competition_with_related_parties' &&
          provider.competitionsRelatedPartiesData?.competitions != null) {
        setState(() {
          filteredCompetitions = provider.competitionsRelatedPartiesData!.competitions;
        });
      } else if (provider.competitionsData?.competitions != null) {
        setState(() {
          filteredCompetitions = provider.competitionsData!.competitions;
        });
      } else {
        // If not loaded, fetch them
        await provider.getMemberCompetitions(
            provider.yearSelected,
            widget.member.memberId.toString(),
            widget.type
        );

        // Now set the filtered competitions based on type
        if (widget.type == 'competition_with_confirmation_of_independence') {
          setState(() {
            filteredCompetitions = provider.competitionsConfirmationOfIndependenceData?.competitions;
          });
        } else if (widget.type == 'competition_with_related_parties') {
          setState(() {
            filteredCompetitions = provider.competitionsRelatedPartiesData?.competitions;
          });
        } else {
          setState(() {
            filteredCompetitions = provider.competitionsData?.competitions;
          });
        }
      }
    } catch (e) {
      print("Error fetching filtered competitions: $e");
    }
  }
  bool isLoading = false;

  // Function to directly download the PDF without preview
  Future<void> downloadPdfDirectly() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Generate the PDF bytes
      final pdfBytes = await generatePdf(context, PdfPageFormat.a4, widget.member);

      // Create a unique filename based on timestamp
      final fileCreateTime = DateTime.now().millisecondsSinceEpoch;
      final fileName = '$fileCreateTime-${widget.member.memberFirstName}-${_getTypeDisplayName()}.pdf';

      // Download the file
      await downloadPdfFile(context, pdfBytes, fileName, widget.member);
    } catch (e) {
      material.ScaffoldMessenger.of(context).showSnackBar(
        material.SnackBar(content: material.Text('Error generating PDF: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> saveAsFile(material.BuildContext context) async {
    // Generate PDF bytes and save them
    final pdfBytes = await generatePdf(context, PdfPageFormat.a4, widget.member);
    // await downloadPdfFile(context, pdfBytes, 'minutes_of_meeting2.pdf');
  }

  @override
  material.Widget build(material.BuildContext context) {
    pw.RichText.debug= true;
    final actions =<PdfPreviewAction>[
      if(!kIsWeb)
        PdfPreviewAction(icon: const material.Icon(material.Icons.save) , onPressed: (context, build, pageFormat) => saveAsFile(context),)
    ];
    return material.Scaffold(
      appBar: material.AppBar(
        title: material.Text('${widget.member.memberFirstName} - ${_getTypeDisplayName()}'),
      ),
      body: filteredCompetitions == null
          ? material.Center(child: material.CircularProgressIndicator())
          : PdfPreview(
        actions: actions,
        onPrinted: showPrintingToast,
        onShared: showSharedToast,
        canChangeOrientation: false,
        canChangePageFormat: false,
        allowSharing: false,
        allowPrinting: false,
        build: (format) => generatePdf(context, format, widget.member),
      ),
    );
  }

  // Helper method to get a display name for the type
  String _getTypeDisplayName() {
    switch (widget.type) {
      case 'competition_with_confirmation_of_independence':
        return 'Confirmation of Independence';
      case 'competition_with_related_parties':
        return 'Related Parties';
      case 'competition_with_company':
        return 'Competition with Company';
      default:
        return widget.type;
    }
  }


// Function to generate the PDF document with BuildContext
  Future<Uint8List> generatePdf(material.BuildContext context,final PdfPageFormat format, Member  member) async {
    final doc = pw.Document(title: "${member.memberFirstName}");
    // final logoImage = pw.MemoryImage((await rootBundle.load('assets/images/profile.jpg')).buffer.asUint8List());
    final Uint8List logoImage = (await rootBundle.load('assets/images/profile.jpg')).buffer.asUint8List();


    final leftColumnContent = _splitLargeListToPages2(member); // Left column
    final rightColumnContent = _splitLargeListToPagesAr2(member); // Right column (Arabic)

    // Ensure pagination works correctly by splitting content across pages
    final leftPages = _createPaginatedWidgets(leftColumnContent, 1000); // 600 - approximate height for a page
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
                  mainAxisAlignment: pw.MainAxisAlignment.center,
                  children: [
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(vertical: 8),
                      alignment: pw.Alignment.center,
                      child: _buildBusinessInformation(member),
                    ),
                  ],
                ),
                pw.Divider(),
              ]
          );
        },
        // footer: (context) => _buildFooter(context),
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
                        crossAxisAlignment: pw.CrossAxisAlignment.start,children: [if (i < leftPages.length) leftPages[i]]),
                  ),
                  pw.SizedBox(width: 10),
                  pw.Expanded(
                    child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,children: [if (i < rightPages.length) rightPages[i]]),
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
    // final fileCreateTime =  DateTime.now().millisecondsSinceEpoch;
    // await downloadPdfFile(context, pdfBytes, '$fileCreateTime+minutes_of_meeting.pdf', member);
    return pdfBytes;
  }

  pw.Widget buildLeftTableFirstRow(Minute minute) {
    return pw.Table(
      // border: pw.TableBorder.all(color: PdfColors.grey, width: 0.5),
      children: [
        // Row 1: Company Name in English and Arabic
        pw.TableRow(
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(1.0),
              child: pw.Text(
                '${minute!.business?.businessName}',
                style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
              ),
            ),
          ],
        ),
      ],
    );
  }


  pw.Widget buildRightTableFirstRow(Minute minute) {
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
                    '${minute.business?.businessName}',
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


  List<pw.Widget> _splitLargeListToPages2(Member member) {
    final largeList = <pw.Widget>[];
    largeList.add(_competitionListEn(member));
    largeList.add(_buildNoticeAndQuorum(member));
    largeList.add(_buildManagementSignatureMembersEnSection(member));
    return largeList;
  }

  List<pw.Widget> _splitLargeListToPagesAr2(Member member) {
    final arabicList = <pw.Widget>[];
    arabicList.add(_competitionListAr(member));
    arabicList.add(_buildNoticeAndQuorumAr(member));
    arabicList.add(_buildManagementSignatureMembersArSection(member));
    return arabicList;
  }

  pw.Widget _competitionListEn(Member member) {
    final competitions = filteredCompetitions  ?? [];
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      mainAxisAlignment: pw.MainAxisAlignment.start,
      children: [
        pw.ListView.builder(
          itemCount: competitions.length,
          itemBuilder: (context, index) {
            final competition = competitions[index];
            return pw.Align(  // Enforces start alignment within ListView
              alignment: pw.Alignment.centerLeft,
              child: pw.Paragraph(
                text: '${index + 1} - ${competition.competitionEnName}' ?? '',
                style: pw.TextStyle(
                  fontSize: 11.0,
                  // fontWeight: pw.FontWeight.bold,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
  pw.Widget _competitionListAr(Member member) {
    final competitions = filteredCompetitions  ?? [];
    return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        // mainAxisAlignment: pw.MainAxisAlignment.end,
      children: [
        pw.Directionality(
          textDirection: pw.TextDirection.rtl,
          child: pw.ListView.builder(
            itemCount: competitions.length,
            itemBuilder: (context, index) {
              final competition = competitions[index];
              return pw.Paragraph(
                text: '${index + 1} - ${competition.competitionArName}' ?? '',
                style: pw.TextStyle(
                  fontSize: 12.0,
                  // fontWeight: pw.FontWeight.bold,
                ),
              );
            },
          ),
        )
      ]
    );
  }




  pw.Widget _buildBusinessInformation(Member member) {
    return pw.Container(
      // padding: pw.EdgeInsets.only(bottom: 2),
      child: pw.Column(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          pw.Text("Postal Code: ${member.business?.businessName}",style: pw.TextStyle(fontWeight: pw.FontWeight.bold),),
          pw.SizedBox(height: 4.0),
          pw.Text("CR Number: ${member.business!.registrationNumber}",style: pw.TextStyle(fontWeight: pw.FontWeight.bold),),
          pw.SizedBox(height: 4.0),
          pw.Text("Paid Capital: ${member.business?.capital} SAR",style: pw.TextStyle(fontWeight: pw.FontWeight.bold),),
          pw.SizedBox(height: 4.0),
          pw.Text("Postal Code: ${member.business?.postCode}",style: pw.TextStyle(fontWeight: pw.FontWeight.bold),),
          pw.SizedBox(height: 4.0),
          pw.Text("Country: ${member.business?.country}",style: pw.TextStyle(fontWeight: pw.FontWeight.bold),),

        ],
      ),
    );
  }

  pw.Widget _competitionListEnTitle() {
    return pw.Directionality(
        textDirection: pw.TextDirection.ltr,
        child:
        pw.Text(
          'Board of Directors - Decision',
          style: pw.TextStyle(fontSize: 11.0, fontWeight: pw.FontWeight.bold),
        )
    );
  }
  pw.Widget _competitionListArTitle() {
    return pw.Directionality(
        textDirection: pw.TextDirection.rtl,
        child: pw.Text(
          'قرار مجلس الإدارة',
          style: pw.TextStyle(fontSize: 12.0, fontWeight: pw.FontWeight.bold),
        )
    );
  }

  // Simplified helper methods to make them more efficient.
  pw.Widget _buildManagementSignatureMembersEnSection(Member member) {
    final members = member?.managementSignature ?? [];
    return  pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _competitionListEnTitle(),
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
                pw.Text("Decision :  ${member.competitionPivot?.isAgree == 1 ? 'Approved' : 'Rejected'} ",style: pw.TextStyle(fontSize: 10),),
                // pw.SizedBox(height: 15),
                if (member.competitionPivot?.isAgree == true)
                  pw.Image(pw.MemoryImage(base64Decode(member.memberSignature ?? '')), height: 20, width: 70)
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

  pw.Widget _buildManagementSignatureMembersArSection(Member member) {
  final members = member?.managementSignature ?? [];
    return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        _competitionListArTitle(),
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
                    pw.Text('${member.memberFirstName ?? ''} ${member.memberLastName ?? ''}',style: pw.TextStyle(fontSize: 10),),
                    pw.Text("  القرار : ${member.competitionPivot?.isAgree == 1 ? 'موافق' : 'غير موافق'}   ",style: pw.TextStyle(fontSize: 10),),
                    // pw.SizedBox(height: 10),
                    if (member.competitionPivot?.isAgree == true)
                      pw.Image(pw.MemoryImage(base64Decode(member.memberSignature ?? '')), height: 20, width: 70)
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



  pw.Widget _buildNoticeAndQuorum(Member member) {
    return pw.Directionality(
        textDirection: pw.TextDirection.ltr,
        child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Name : ${member.memberFirstName} ${member.memberLastName} ', style: pw.TextStyle(color: PdfColors.blueAccent700,fontWeight: pw.FontWeight.bold, fontSize: 11.0),textAlign: pw.TextAlign.justify),
              pw.Text('Signature :', style: pw.TextStyle(color: PdfColors.black, fontSize: 11.0),textAlign: pw.TextAlign.justify)
            ]
        )
    );
  }
  pw.Widget _buildNoticeAndQuorumAr(Member member) {
    return pw.Directionality(
        textDirection: pw.TextDirection.rtl,
        child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children:[
              pw.Text(' ${member.memberLastName} ${member.memberFirstName}: الإسم  ', style: pw.TextStyle(color: PdfColors.blueAccent700,fontWeight: pw.FontWeight.bold, fontSize: 12.0),textAlign: pw.TextAlign.justify),
              pw.Text('التوقيع : ', style: pw.TextStyle(color: PdfColors.black, fontSize: 12.0),textAlign: pw.TextAlign.justify)
            ]
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

  // Function to handle downloading the PDF file with BuildContext
  Future<void> downloadPdfFile(material.BuildContext context, Uint8List pdfBytes, String fileName, Member member) async {
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
        // PDFApi.retrieveFile(context,fileName, minute);
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

}

