import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' as material;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:printing/printing.dart';


import 'dart:async';
import 'dart:convert';
import 'package:diligov_members/utility/utils.dart';
import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../../models/agenda_model.dart';
import '../../../models/detail_details_model.dart';
import '../../../models/minutes_model.dart';



import '../../../utility/pdf_api.dart';
class PagePdf extends material.StatefulWidget {
  final Minute minute;
  const PagePdf({super.key, required this.minute});
  static const routeName = '/PagePdf';

  @override
  material.State<PagePdf> createState() => _PagePdfState();
}

class _PagePdfState extends material.State<PagePdf> {
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
    final pdfBytes = await generatePdf(context, PdfPageFormat.a4, widget.minute);
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
        title: material.Text('${widget.minute.minuteName}'),
      ),
      body: PdfPreview(
        // maxPageWidth: 1000,
        actions: actions,
        onPrinted: showPrintingToast,
        onShared: showSharedToast,
        build: (format) => generatePdf(context, format, widget.minute),
      ),
    );
  }
}


// Function to generate the PDF document with BuildContext
Future<Uint8List> generatePdf(material.BuildContext context,final PdfPageFormat format, Minute minute) async {
  final doc = pw.Document(title: "${minute.minuteName}");
  // final logoImage = pw.MemoryImage((await rootBundle.load('assets/images/profile.jpg')).buffer.asUint8List());
  final Uint8List logoImage = (await rootBundle.load('assets/images/profile.jpg')).buffer.asUint8List();


  final leftColumnContent = _splitLargeListToPages2(minute); // Left column
  final rightColumnContent = _splitLargeListToPagesAr2(minute); // Right column (Arabic)

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
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        buildLeftTableFirstRow(minute),
                        buildLeftTableSecondRow(minute),
                        buildLeftTableThirdRow(minute),
                        buildLeftTableFourRow(minute)
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
                        buildRightTableFirstRow(minute),
                        buildRightTableSecondRow(minute),
                        buildRightTableThirdRow(minute),
                        buildRightTableFourRow(minute)
                      ]
                  ),

                ],
              ),
              pw.Divider(),
              _buildBusinessInformation(minute),
              pw.Divider(),
            ]
        );
      },
      footer: (context) => _buildFooter(context),
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
  final fileCreateTime =  DateTime.now().millisecondsSinceEpoch;
  await downloadPdfFile(context, pdfBytes, '$fileCreateTime+minutes_of_meeting.pdf', minute);
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


List<pw.Widget> _splitLargeListToPages2(Minute minute) {
  final largeList = <pw.Widget>[];
  largeList.add(_buildNoticeAndQuorum(minute));
  largeList.add(_buildNoticeStatic(minute));
  largeList.add(_buildMeetingAgendaTitle(minute));
  largeList.add(_meetingAgendaList(minute));
  for (var i = 0; i < minute.meeting!.agendas!.length; i++) {
    // for (var detail in minute.meeting!.agendas![i].details.arabicDescription!) {
    //   largeList.add(pw.Text('${minute.meeting!.agendas![i].details?.description!}'));
    largeList.add(_buildAgendaDetailSection(minute.meeting!.agendas![i], i));
    // }
  }
  largeList.add(_buildNoticeLastStatic(minute));
  largeList.add(_meetingAttendanceBoardList(minute));
  largeList.add(_buildBoardMembersSection(minute));
  largeList.add(_buildDocumentsPresentedAtTheMeeting(minute));
  return largeList;
}

List<pw.Widget> _splitLargeListToPagesAr2(Minute minute) {
  final arabicList = <pw.Widget>[];
  arabicList.add(_buildNoticeAndQuorumAr(minute));
  arabicList.add(_buildNoticeStaticAr(minute));
  arabicList.add(_buildMeetingAgendaTitleAr(minute));
  arabicList.add(_meetingAgendaListAr(minute));
  for (var i = 0; i < minute.meeting!.agendas!.length; i++) {
    // for (var detail in minute.meeting!.agendas![i].agendaDetails!) {
    //   arabicList.add(pw.Text('${minute.meeting!.agendas![i].details?.arabicDescription!}', textDirection: pw.TextDirection.rtl, textAlign: pw.TextAlign.justify,));
    arabicList.add(_buildAgendaDetailSectionAr(minute.meeting!.agendas![i], i));
    // }
  }
  arabicList.add(_buildNoticeLastStaticAr(minute));
  arabicList.add(_meetingAttendanceBoardListAr(minute));
  arabicList.add(_buildBoardMembersSectionAr(minute));
  arabicList.add(_buildDocumentsPresentedAtTheMeetingAr(minute));
  return arabicList;
}




// Simplified detail builder for each agenda
pw.Widget _buildAgendaDetailSection(Agenda agenda, int i) {
  return pw.Table(
    children: [
      pw.TableRow(
          children: [
            pw.Text('${i+1}- ${agenda.agendaTitle}', style: pw.TextStyle(fontSize: 12,color: PdfColors.blueAccent700, fontWeight: pw.FontWeight.bold)),
          ]),
      pw.TableRow(
          children: [
            pw.SizedBox(
              height: 110,
              child: pw.Text('${agenda.details?.description!}',style: pw.TextStyle(fontSize: 11,), textDirection: pw.TextDirection.ltr, textAlign: pw.TextAlign.justify,),
            )
          ]),
      ..._buildDetailItemsAsTable(agenda.details?.detailDetails),
    ],
  );
}


List<pw.TableRow> _buildDetailItemsAsTable(List<DetailDetails>? details) {
  if (details == null || details.isEmpty) return [];

  return details.map((detail) {
    return pw.TableRow(
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.all(5.0),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey, width: 0.5),
          ),
          child:
          pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Resolution: ${detail.serialNumberResolutionEn ?? ''}',
                  style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColors.red),
                ),
                pw.Text(detail.textResolutionEn ?? '', style: pw.TextStyle(fontSize: 11), textAlign: pw.TextAlign.justify),
                pw.SizedBox(height: 5),
                pw.Text(
                  'Direction: ${detail.serialNumberDirectionEn ?? ''}',
                  style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold , color: PdfColors.orange),
                ),
                pw.Text(detail.textDirectionEn ?? '', style: pw.TextStyle(fontSize: 11), textAlign: pw.TextAlign.justify),
              ]
          ),
        )

      ],
    );
  }).toList();
}


// Arabic version of the agenda detail section
pw.Widget _buildAgendaDetailSectionAr(Agenda agenda, int i) {
  return pw.Directionality(
    textDirection: pw.TextDirection.rtl,
    child: pw.Table(
      children: [
        pw.TableRow(
            children: [
              pw.Text('${i+1}- ${agenda.agendaTitleAr}', style: pw.TextStyle(fontSize: 12,color: PdfColors.blueAccent700, fontWeight: pw.FontWeight.bold)),
            ]),
        pw.TableRow(
            children: [
              pw.SizedBox(
                height: 110,
                child: pw.Text('${agenda.details?.arabicDescription!}',style: pw.TextStyle(fontSize: 11,), textDirection: pw.TextDirection.rtl, textAlign: pw.TextAlign.justify,),)
            ]),
        ..._buildDetailItemsAsTableAr(agenda.details?.detailDetails, i),
      ],
    ),
  );
}

List<pw.TableRow> _buildDetailItemsAsTableAr(List<DetailDetails>? details, int i) {
  if (details == null || details.isEmpty) return [];

  return details.map((detail) {
    return pw.TableRow(
      children: [


        pw.Container(
          padding: const pw.EdgeInsets.all(5.0),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey, width: 0.5),
          ),
          child:
          pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [

                pw.Text(              'القرار: ${detail.serialNumberResolutionAr ?? ''}',
                  style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold , color: PdfColors.red),
                ),
                pw.Text(detail.textResolutionAr ?? '', style: pw.TextStyle(fontSize: 11), textAlign: pw.TextAlign.justify),
                pw.SizedBox(height: 5),
                pw.Text(
                  'التوجيه: ${detail.serialNumberDirectionAr ?? ''}',
                  style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColors.orange),
                ),
                pw.Text(detail.textDirectionAr ?? '', style: pw.TextStyle(fontSize: 11), textAlign: pw.TextAlign.justify),
              ]
          ),
        )
      ],
    );
  }).toList();
}


pw.Widget _buildFooter(pw.Context context) {
  return pw.Column(
      children: [
        pw.Container(
          alignment: pw.Alignment.centerRight,
          child: pw.Text('Page ${context.pageNumber} of ${context.pagesCount}', style: pw.TextStyle(fontSize: 8)),
        ),
        pw.Divider(thickness: 1.0,),
      ]
  );
}


// Simplified helper methods to make them more efficient.
pw.Widget _buildBoardMembersSection(Minute minute) {
  final members = minute.board?.members ?? [];
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(
        '${minute.board?.boardName} Members',
        style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
      ),
      pw.ListView.builder(
        itemCount: members.length,
        itemBuilder: (context, index) {
          final member = members[index];
          return pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                '${member.position?.positionName ?? ''}: ${member.memberFirstName ?? ''} ${member.memberLastName ?? ''}',
                style: pw.TextStyle(fontSize: 10),
              ),
              if (member.minuteSignature?.hasSigned == true)
                pw.Image(pw.MemoryImage(base64Decode(member.memberSignature ?? '')), height: 20, width: 70)
              else
                pw.Text('Signature: .........', style: pw.TextStyle(fontSize: 10)),
            ],
          );
        },
      ),
    ],
  );
}

pw.Widget _buildBoardMembersSectionAr(Minute minute) {
  final members = minute.board?.members ?? [];
  return pw.Directionality(
      textDirection: pw.TextDirection.rtl,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
              'اعضاء ${minute.board?.boardName}',
              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),textAlign: pw.TextAlign.right,textDirection: pw.TextDirection.rtl
          ),
          pw.ListView.builder(
            itemCount: members.length,
            itemBuilder: (context, index) {
              final member = members[index];
              return pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                      ' ${member.memberLastName ?? ''} ${member.memberFirstName ?? ''} : ${member.position?.positionName ?? ''} ',
                      style: pw.TextStyle(fontSize: 10),textAlign: pw.TextAlign.right,textDirection: pw.TextDirection.rtl
                  ),
                  if (member.minuteSignature?.hasSigned == true)
                    pw.Image(pw.MemoryImage(base64Decode(member.memberSignature ?? '')), height: 20, width: 70)
                  else
                    pw.Text('التوقيع : ......... ', style: pw.TextStyle(fontSize: 10),textAlign: pw.TextAlign.right,textDirection: pw.TextDirection.rtl),
                ],
              );
            },
          ),
        ],
      )
  );
}


pw.Widget _buildMeetingAgendaTitle(Minute minute) {
  return pw.Directionality(
      textDirection: pw.TextDirection.ltr,
      child:
      pw.Text(
        'Meeting Agenda',
        style: pw.TextStyle(fontSize: 11.0, fontWeight: pw.FontWeight.bold),
      )
  );
}
pw.Widget _buildMeetingAgendaTitleAr(Minute minute) {
  return pw.Directionality(
      textDirection: pw.TextDirection.rtl,
      child: pw.Text(
        'جدول الإجتماع',
        style: pw.TextStyle(fontSize: 12.0, fontWeight: pw.FontWeight.bold),
      )
  );
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
pw.Widget buildLeftTableSecondRow(Minute minute) {
  return pw.Table(
    // border: pw.TableBorder.all(color: PdfColors.grey, width: 0.5),
    children: [
      // Row 1: Company Name in English and Arabic
      pw.TableRow(
        children: [
          pw.Padding(
            padding: const pw.EdgeInsets.all(1.0),
            child: pw.Text(
                'Minute of Meeting ${minute.meeting?.board?.boardName}',
                style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                textAlign: pw.TextAlign.justify
            ),
          ),


        ],
      ),
    ],
  );
}
pw.Widget buildLeftTableThirdRow(Minute minute) {
  return pw.Table(
    // border: pw.TableBorder.all(color: PdfColors.grey, width: 0.5),
    children: [
      // Row 1: Company Name in English and Arabic
      pw.TableRow(
        children: [
          pw.Padding(
            padding: const pw.EdgeInsets.all(1.0),
            child: pw.Text(
              'No ${minute.meeting?.meetingSerialNumber}',
              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
            ),
          ),


        ],
      ),
    ],
  );
}
pw.Widget buildLeftTableFourRow(Minute minute) {
  return pw.Table(
    // border: pw.TableBorder.all(color: PdfColors.grey, width: 0.5),
    children: [
      // Row 1: Company Name in English and Arabic
      pw.TableRow(
        children: [
          pw.Padding(
            padding: const pw.EdgeInsets.all(1.0),
            child: pw.Text(
              'Dated ${minute.meeting?.meetingStartDate}',
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
pw.Widget buildRightTableSecondRow(Minute minute) {
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
                  'محضر اجتماع ${minute.meeting?.board?.boardName}',
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
pw.Widget buildRightTableThirdRow(Minute minute) {
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
                  'رقم ${minute.meeting?.meetingSerialNumber}',
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
pw.Widget buildRightTableFourRow(Minute minute) {
  String hijriDate = Utils.toHijri(minute.meeting!.meetingStart!);
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
                  'تاريخ ${hijriDate}',
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



pw.Widget _buildDocumentsPresentedAtTheMeeting(Minute minute) {
  final agendas = minute.meeting?.agendas ?? [];
  return pw.Column(
    children: [
      pw.Text('List of Attachments', style: pw.TextStyle(fontSize: 11.0, fontWeight: pw.FontWeight.bold)),
      pw.Column(
        children: List.generate(
          agendas.length,
              (index) {
            final agendaFile = agendas[index].agendaFileOneName;
            if (agendaFile != null && agendaFile.isNotEmpty) {
              final cleanedAgendaFile = agendaFile.join(', ');
              return pw.Column(
                children: [
                  pw.Text('${agendas[index].agendaTitle  ?? agendas[index].agendaTitleAr}', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                  pw.Text('$cleanedAgendaFile', style: pw.TextStyle(fontSize: 11, color: PdfColors.blue), textAlign: pw.TextAlign.justify),
                ],
              );
            }
            return pw.SizedBox.shrink();
          },
        ),
      ),
    ],
  );
}
pw.Widget _buildDocumentsPresentedAtTheMeetingAr(Minute minute) {
  final agendas = minute.meeting?.agendas ?? [];
  return pw.Column(
    children: [
      pw.Text(
        'جدول المرفقات',
        style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
        textDirection: pw.TextDirection.rtl,
      ),
      pw.Column(
        children: List.generate(
          agendas.length,
              (index) {
            final agendaTitle = agendas[index].agendaTitleAr ?? agendas[index].agendaTitle ?? '';
            final agendaFiles = agendas[index].agendaFileOneName ?? [];

            if (agendaFiles.isNotEmpty) {
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    agendaTitle,
                    style: pw.TextStyle(fontSize: 11.0, fontWeight: pw.FontWeight.bold),
                    textDirection: pw.TextDirection.rtl,
                  ),
                  pw.Column(
                    children: agendaFiles.map((fileUrl) {
                      String  file =  "https://diligov.com/public/meetings/${fileUrl}";
                      return  pw.UrlLink(
                        destination: '$file',
                        child: pw.Text(
                          '${fileUrl}',
                          style: pw.TextStyle(
                            color: PdfColors.blue,
                            decoration: pw.TextDecoration.underline,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              );
            }
            return pw.SizedBox.shrink();
          },
        ),
      ),
    ],
  );
}


// "https://diligov.com/public/meetings/${fileUrl}"
pw.Widget buildClickableText(String label, String url) {
  return pw.UrlLink(
    destination: 'https://diligov.com/public/meetings/df3d02102ad1c1010f5f42e9a3296538.1716638006096+nnn.pdf',
    child: pw.Text(
      label,
      style: pw.TextStyle(
        fontSize: 12,
        color: PdfColors.blue,
        decoration: pw.TextDecoration.underline,
      ),
    ),
  );
}

void launchURL(url) async {
  if (await canLaunchUrlString(url)) {
    Uri uri = Uri.parse(url);
    print(url);
    await launchUrl(url, mode: LaunchMode.externalApplication);
  } else {
    throw 'Could not launch $url';
  }
}

pw.Widget _meetingAgendaList(Minute minute) {
  final agendas = minute.meeting?.agendas ?? [];
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    mainAxisAlignment: pw.MainAxisAlignment.start,
    children: [
      pw.ListView.builder(
        itemCount: agendas.length,
        itemBuilder: (context, index) {
          final agenda = agendas[index];
          return pw.Align(  // Enforces start alignment within ListView
            alignment: pw.Alignment.centerLeft,
            child: pw.Paragraph(
              text: '${index + 1} - ${agenda.agendaTitle}',
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
pw.Widget _meetingAgendaListAr(Minute minute) {
  final agendas = minute.meeting?.agendas ?? [];
  return pw.Directionality(
    textDirection: pw.TextDirection.rtl,
    child: pw.ListView.builder(
      itemCount: agendas.length,
      itemBuilder: (context, index) {
        final agenda = agendas[index];
        return pw.Paragraph(
          text: '${index + 1} - ${agenda.agendaTitleAr}',
          style: pw.TextStyle(
            fontSize: 12.0,
            // fontWeight: pw.FontWeight.bold,
          ),
        );
      },
    ),
  );
}


pw.Widget _meetingAttendanceBoardList(Minute minute) {
  final agendas = minute.meeting?.agendas ?? [];
  // If there are no agendas, return an empty widget.
  if (agendas.isEmpty) {
    return pw.SizedBox.shrink();
  }
  return pw.Directionality(
      textDirection: pw.TextDirection.ltr,
      child: pw.ListView.builder(
        itemCount: agendas.length,
        itemBuilder: (context, agendaIndex) {
          final attendanceBoards = agendas[agendaIndex].attendanceDetails ?? [];
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: List.generate(attendanceBoards.length, (boardIndex) {
              final attendance = attendanceBoards[boardIndex];
              return pw.Column(
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.start,
                    children: [
                      pw.Container(
                        child: pw.Text('${boardIndex + 1}. ${attendance.name}', style: pw.TextStyle(fontSize: 8)),
                      ),
                      pw.SizedBox(width: 5),
                      pw.Container(
                        child: pw.Text('${attendance.position}', style: pw.TextStyle(fontSize: 8)),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 5),
                ],
              );
            }),
          );
        },
      )
  );
}
pw.Widget _meetingAttendanceBoardListAr(Minute minute) {
  final agendas = minute.meeting?.agendas ?? [];
  // If there are no agendas, return an empty widget.
  if (agendas.isEmpty) {
    return pw.SizedBox.shrink();
  }
  return pw.Directionality(
      textDirection: pw.TextDirection.rtl,
      child: pw.ListView.builder(
        itemCount: agendas.length,
        itemBuilder: (context, agendaIndex) {
          final attendanceBoards = agendas[agendaIndex].attendanceDetails ?? [];
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: List.generate(attendanceBoards.length, (boardIndex) {
              final attendance = attendanceBoards[boardIndex];
              return pw.Column(
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.start,
                    children: [
                      pw.Container(
                        child: pw.Text('${boardIndex + 1}. ${attendance.nameAr}', style: pw.TextStyle(fontSize: 8)),
                      ),
                      pw.SizedBox(width: 5),
                      pw.Container(
                        child: pw.Text('${attendance.position}', style: pw.TextStyle(fontSize: 8)),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 5),
                ],
              );
            }),
          );
        },
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

pw.Widget _buildBusinessInformation(Minute minute) {
  return pw.Container(
    // padding: pw.EdgeInsets.only(bottom: 2),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.center,
      children: [
        pw.Text("Postal Code: ${minute.business?.postCode}"),
        pw.SizedBox(width: 4.0),
        pw.Text("Country: ${minute.business?.country}"),
        pw.SizedBox(width: 4.0),
        pw.Text("CR: ${minute.business!.registrationNumber}"),
        pw.SizedBox(width: 4.0),
        pw.Text("Paid Capital: ${minute.business?.capital} SAR"),
      ],
    ),
  );
}


pw.Widget _buildNoticeAndQuorum(Minute minute) {
  final text =
      'The meeting was duly convened and chaired by Mr. Georges P., after confirming the legal quorum was valid. All Committee Members have already received notice of attendance. All the Members have attended the meeting ${minute.meeting?.meetingBy}.';
  return pw.Directionality(
      textDirection: pw.TextDirection.ltr,
      child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Notice and Quorum', style: pw.TextStyle(color: PdfColors.blueAccent700,fontWeight: pw.FontWeight.bold, fontSize: 11.0),textAlign: pw.TextAlign.justify),
            pw.Text(text, style: pw.TextStyle(color: PdfColors.black, fontSize: 11.0),textAlign: pw.TextAlign.justify)
          ]
      )
  );
}
pw.Widget _buildNoticeAndQuorumAr(Minute minute) {
  final text ='عُـقد الإجـتماع بـرئـاســــــة الأستاذ/ جيورجس بعد التأكد من إكتمال النصاب القانوني اللازم لعقد الإجتماع، وقد سبق أن تلقى جميع أعضاء لجنة الاستثمار إشعاراً بالحضور. حيث حضر جميع الأعضاء إفتراضياً عبر الإتصال المرئي. ${minute.meeting?.meetingBy}.';
  return pw.Directionality(
      textDirection: pw.TextDirection.rtl,
      child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children:[
            pw.Text('الإشعار والنصاب القانوني', style: pw.TextStyle(color: PdfColors.blueAccent700,fontWeight: pw.FontWeight.bold, fontSize: 12.0),textAlign: pw.TextAlign.justify),
            pw.Text(text, style: pw.TextStyle(color: PdfColors.black, fontSize: 12.0),textAlign: pw.TextAlign.justify)
          ]
      )
  );
}

pw.Widget _buildNoticeStatic(Minute minute) {
  final text = 'The meeting started by a welcome note from the Chairman of the Committee, followed by a review and approval of the agenda and its details as the following:';
  return pw.Directionality(
      textDirection: pw.TextDirection.ltr,
      child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [

            pw.Text(text, style: pw.TextStyle(color: PdfColors.black, fontSize: 11.0),textAlign: pw.TextAlign.justify)
          ]
      )
  );
}
pw.Widget _buildNoticeStaticAr(Minute minute) {
  final text ='بداية الاجتماع رحّب رئيس اللجنة بأصحاب السعادة أعضاء اللجنة، وتم استعراض المواضيع المدرجة على جدول أعمال اللجنة والموافقة عليها وهي على النحو التالي:';
  return pw.Directionality(
      textDirection: pw.TextDirection.rtl,
      child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children:[
            pw.Text(text, style: pw.TextStyle(color: PdfColors.black, fontSize: 12.0),textAlign: pw.TextAlign.justify)
          ]
      )
  );
}

pw.Widget _buildNoticeLastStatic(Minute minute) {
  final text = 'There being no further business or matters, the Chairman of the committee declared the meeting to be concluded.';
  return pw.Directionality(
      textDirection: pw.TextDirection.ltr,
      child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [

            pw.Text(text, style: pw.TextStyle(color: PdfColors.black, fontSize: 11.0),textAlign: pw.TextAlign.justify)
          ]
      )
  );
}
pw.Widget _buildNoticeLastStaticAr(Minute minute) {
  final text =' مع عدم وجود أية أعمال أو مسائل أخرى، أعلن سعادة رئيس اللجنة إنتهاء الإجتماع.';
  return pw.Directionality(
      textDirection: pw.TextDirection.rtl,
      child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children:[
            pw.Text(text, style: pw.TextStyle(color: PdfColors.black, fontSize: 12.0),textAlign: pw.TextAlign.justify)
          ]
      )
  );
}


// Function to handle downloading the PDF file with BuildContext
Future<void> downloadPdfFile(material.BuildContext context, Uint8List pdfBytes, String fileName, Minute minute) async {
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
      print("filePathfilePathfilePathfilePathfilePath $fileName");
      // material.Navigator.of(context).push(material.MaterialPageRoute(builder: (context) => EditLaboratoryLocalFileProcessing(comingLocalPath: '${fileName}',)));
      PDFApi.retrieveFile(context,fileName, minute);
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