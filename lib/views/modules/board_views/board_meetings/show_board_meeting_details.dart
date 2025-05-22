import 'dart:io';
import 'dart:typed_data';

import 'package:diligov_members/models/meeting_model.dart';
import 'package:diligov_members/views/modules/board_views/board_meetings/pdf_preview_screen.dart';
import 'package:diligov_members/widgets/custome_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import '../../../../core/domains/app_uri.dart';
import '../../../../models/agenda_model.dart';
import '../../../../models/member_signed_model.dart';
import '../../../../models/preview_meeting_model.dart';
import '../../../../providers/meeting_page_provider.dart';
import '../../../../widgets/appBar.dart';
import '../../../../widgets/container_lable_with_box_shadow.dart';
import 'package:http/http.dart' as http;

class ShowBoardMeetingDetails extends StatefulWidget {
  final Meeting meeting;
  static const routeName = '/ShowBoardMeetingDetails';
  const ShowBoardMeetingDetails({super.key, required this.meeting});

  @override
  State<ShowBoardMeetingDetails> createState() =>
      _ShowBoardMeetingDetailsState();
}

class _ShowBoardMeetingDetailsState extends State<ShowBoardMeetingDetails> {

  Future<void> generatePdf(List<Agenda> agendas, MeetingPageProvider provider) async {
    try {
      List<String> pdfUrls = extractPdfUrlsFromAgendas(agendas);
      Uint8List imageBytes =
          await loadImageFromAssets("assets/images/profile.jpg");

      String? pdfPath = await combineMultiplePdfsWithAgendas(
        networkFileUrls: pdfUrls,
        agendasList: agendas,
        centerImageBytes: imageBytes,
        provider: provider,
      );
      await Future.delayed(Duration(seconds: 15));
      if (pdfPath != null) {
        print("PDF generated and saved at: $pdfPath");

      } else {
        print("Failed to generate the PDF.");
        _showSnackbar('Error generating PDF',Colors.red, Duration(seconds: 3));
      }
    } catch (e) {
      print("Error during PDF generation: $e");
      _showSnackbar('Error generating PDF',Colors.red, Duration(seconds: 3));
    }
  }

  List<String> extractPdfUrlsFromAgendas(List<Agenda> agendas) {
    List<String> pdfUrls = [];

    for (var agenda in agendas) {
      // Extract agenda file (first index if available)
      if (agenda.agendaFileOneName != null &&
          agenda.agendaFileOneName!.isNotEmpty) {
        String fileUrl = agenda.agendaFileOneName![0];
        if (fileUrl.endsWith(".pdf")) {
          pdfUrls.add("${AppUri.baseUntilPublicDirectoryMeetings}/${fileUrl}");
        }
      }

      // Extract child files from children
      if (agenda.agendaChildren != null && agenda.agendaChildren!.isNotEmpty) {
        for (var child in agenda.agendaChildren!) {
          if (child.childAgendaFileOneName != null &&
              child.childAgendaFileOneName!.isNotEmpty) {
            String childFileUrl = child.childAgendaFileOneName![0];
            if (childFileUrl.endsWith(".pdf")) {
              pdfUrls.add("${AppUri.baseUntilPublicDirectoryMeetings}/${childFileUrl}");
            }
          }
        }
      }
    }

    return pdfUrls;
  }

// Example function to load an image as Uint8List
  Future<Uint8List> loadImageFromAssets(String path) async {
    final ByteData data = await rootBundle.load(path);
    return data.buffer.asUint8List();
  }

  Future<String?> combineMultiplePdfsWithAgendas({
    required List<String> networkFileUrls, // List of URLs for the PDFs
    required List<Agenda> agendasList, // List of agendas corresponding to each PDF
    required Uint8List centerImageBytes, // Image data as Uint8List
    required MeetingPageProvider provider,
  }) async {
    try {
      print("Starting to process multiple PDFs with agendas...");
      // Load custom fonts
      final ByteData regularFontData = await rootBundle.load('assets/fonts/Al-Mohanad-Regular.ttf');
      final PdfTrueTypeFont regularFont = PdfTrueTypeFont(regularFontData.buffer.asUint8List(), 12);
      final ByteData boldFontData = await rootBundle.load('assets/fonts/Al-Mohanad-Bold.ttf');
      final PdfTrueTypeFont boldFont = PdfTrueTypeFont(boldFontData.buffer.asUint8List(), 14);
      final PdfStringFormat rtlFormat = PdfStringFormat(
        alignment: PdfTextAlignment.right,
        textDirection: PdfTextDirection.rightToLeft,
      );
      // Create a new document to combine everything
      final PdfDocument combinedDocument = PdfDocument();
      for (int fileIndex = 0; fileIndex < networkFileUrls.length; fileIndex++) {
        String networkFileUrl = networkFileUrls[fileIndex];
        List<Agenda> agendas = agendasList;

        // Fetch the PDF from the network
        print("Fetching PDF from $networkFileUrl...");
        final response = await http.get(Uri.parse(networkFileUrl));
        if (response.statusCode != 200)
          throw Exception("Failed to fetch the PDF file");
        if (response.bodyBytes.isEmpty)
          throw Exception("The fetched PDF file is empty");
        print("PDF fetched successfully.");

        // Load the original document
        final PdfDocument originalDocument = PdfDocument(inputBytes: response.bodyBytes);

        // Define landscape settings for the first two pages
        combinedDocument.pageSettings.orientation =
            PdfPageOrientation.landscape;
        combinedDocument.pageSettings.size = PdfPageSize.a4;

        // === Step 1: Add First Page in Landscape ===
        final PdfPage firstPage = combinedDocument.pages.add();
        final PdfGraphics firstPageGraphics = firstPage.graphics;

        // Render Header Information
        firstPageGraphics.drawString(
          "Obtima",
          boldFont,
          bounds: Rect.fromLTWH(500, -3, 250, 20),
          format: rtlFormat,
        );
        firstPageGraphics.drawString(
          "محضر اجتماع A Board",
          regularFont,
          bounds: Rect.fromLTWH(500, 15, 250, 20),
          format: rtlFormat,
        );
        firstPageGraphics.drawString(
          "رقم T/2024/10/3/01",
          regularFont,
          bounds: Rect.fromLTWH(500, 30, 250, 20),
          format: rtlFormat,
        );
        firstPageGraphics.drawString(
          "التاريخ 1446-4-7 06:28:00 AM",
          regularFont,
          bounds: Rect.fromLTWH(500, 45, 250, 20),
          format: rtlFormat,
        );

        // Render Image
        final PdfBitmap image = PdfBitmap(centerImageBytes);
        firstPageGraphics.drawImage(
          image,
          Rect.fromLTWH(350, 15, 50, 40),
        );

        firstPageGraphics.drawString(
          "Obtima",
          regularFont,
          bounds: Rect.fromLTWH(0, -3, 250, 20),
          format: PdfStringFormat(
            alignment: PdfTextAlignment.left,
          ),
        );
        firstPageGraphics.drawString(
          " Minute of Meeting A Board",
          regularFont,
          bounds: Rect.fromLTWH(0, 15, 250, 20),
          format: PdfStringFormat(
            alignment: PdfTextAlignment.left,
          ),
        );
        firstPageGraphics.drawString(
          "No 2024/10/3/01/T",
          regularFont,
          bounds: Rect.fromLTWH(0, 30, 250, 20),
          format: PdfStringFormat(
            alignment: PdfTextAlignment.left,
          ),
        );
        firstPageGraphics.drawString(
          "Dated 10-10-2024 6:28:00 AM",
          regularFont,
          bounds: Rect.fromLTWH(0, 45, 250, 20),
          format: PdfStringFormat(
            alignment: PdfTextAlignment.left,
          ),
        );

        print("First page rendered in landscape orientation.");

        // === Step 2: Add Second Page in Landscape for Agendas ===
        // final PdfPage secondPage = combinedDocument .pages.add();
        // final PdfGraphics secondPageGraphics = secondPage.graphics;
        PdfBookmark mainBookmark = combinedDocument.bookmarks.add("Agendas");

        // Add Agenda Table
        PdfGrid grid = PdfGrid();
        grid.columns.add(count: 5);

        // Add table headers
        grid.headers.add(1);
        PdfGridRow headerRow = grid.headers[0];
        headerRow.cells[0].value = "Index";
        headerRow.cells[1].value = "Title";
        headerRow.cells[2].value = "Description";
        headerRow.cells[3].value = "Presenter";
        headerRow.cells[4].value = "Time";

        // Style the header
        for (int i = 0; i < headerRow.cells.count; i++) {
          headerRow.cells[i].style = PdfGridCellStyle(
            font: boldFont,
            borders: PdfBorders(
              left: PdfPen(PdfColor(0, 0, 0)),
              top: PdfPen(PdfColor(0, 0, 0)),
              bottom: PdfPen(PdfColor(0, 0, 0)),
              right: PdfPen(PdfColor(0, 0, 0)),
            ),
          );
        }

        // Add parent and child agendas
        for (int a1 = 0; a1 < agendas.length; a1++) {
          var agenda = agendas[a1];
          var parentIndex = a1 + 1;
          // Parent Agenda
          PdfGridRow parentRow = grid.rows.add();
          parentRow.cells[0].value = "${parentIndex}";
          parentRow.cells[1].value = agenda.agendaTitle ?? "N/A";
          parentRow.cells[2].value = agenda.agendaDescription ?? "N/A";
          parentRow.cells[3].value = agenda.presenter ?? "N/A";
          parentRow.cells[4].value = agenda.agendaTime ?? "N/A";

          // Add bookmark for parent agenda
          PdfBookmark parentBookmark =
              mainBookmark.add(agenda.agendaTitle ?? "Agenda");
          parentBookmark.destination =
              PdfDestination(firstPage, Offset(10, grid.rows.count * 20));

          for (int i = 0; i < parentRow.cells.count; i++) {
            parentRow.cells[i].style = PdfGridCellStyle(
              font: boldFont,
              borders: PdfBorders(
                left: PdfPen(PdfColor(0, 0, 0)),
                top: PdfPen(PdfColor(0, 0, 0)),
                bottom: PdfPen(PdfColor(0, 0, 0)),
                right: PdfPen(PdfColor(0, 0, 0)),
              ),
            );
          }

          // Child Agendas
          if (agenda.agendaChildren != null &&
              agenda.agendaChildren!.isNotEmpty) {
            for (int ac = 0; ac < agenda.agendaChildren!.length; ac++) {
              var child = agenda.agendaChildren![ac];
              PdfGridRow childRow = grid.rows.add();
              childRow.cells[0].value = "${parentIndex} -- ${ac + 1}";
              childRow.cells[1].value = "${child.childAgendaTitle ?? "N/A"}";
              childRow.cells[2].value = child.childAgendaDescription ?? "N/A";
              childRow.cells[3].value = child.childAgendaPresenter ?? "N/A";
              childRow.cells[4].value = child.childAgendaTime ?? "N/A";

              PdfBookmark childBookmark =
                  parentBookmark.add(child.childAgendaTitle ?? "Child Agenda");
              childBookmark.destination =
                  PdfDestination(firstPage, Offset(10, grid.rows.count * 20));

              for (int i = 0; i < childRow.cells.count; i++) {
                childRow.cells[i].style = PdfGridCellStyle(
                  font: regularFont,
                  borders: PdfBorders(
                    left: PdfPen(PdfColor(200, 200, 200)),
                    top: PdfPen(PdfColor(200, 200, 200)),
                    bottom: PdfPen(PdfColor(200, 200, 200)),
                    right: PdfPen(PdfColor(200, 200, 200)),
                  ),
                );
              }
            }
          }
        }

        PdfLayoutResult? layoutResult = grid.draw(
          page: firstPage,
          bounds: const Rect.fromLTWH(10, 80, 772, 572),
        );

        while (layoutResult != null && layoutResult.bounds.bottom > 612) {
          final PdfPage overflowPage = combinedDocument.pages.add();
          layoutResult = grid.draw(
            page: overflowPage,
            bounds: const Rect.fromLTWH(10, 10, 772, 572),
          );
        }

        print("Second page rendered with agendas in landscape orientation.");

        // === Step 3: Append Original Pages ===
        for (int i = 0; i < originalDocument.pages.count; i++) {
          final PdfPage originalPage = originalDocument.pages[i];

          // Create a new portrait page in the combined document
          final PdfPage portraitPage = combinedDocument.pages.add();

          // Get the content of the original page
          PdfTemplate template = originalPage.createTemplate();

          // Extract the original page dimensions
          final double originalWidth = template.size.width;
          final double originalHeight = template.size.height;

          // Determine if the page is in landscape
          if (originalWidth > originalHeight) {
            // Rotate and scale the content for portrait orientation
            portraitPage.graphics.save();
            portraitPage.graphics.rotateTransform(-90); // Rotate content
            portraitPage.graphics.drawPdfTemplate(
              template,
              Offset(PdfPageSize.a4.height, 0), // Adjust offset for rotation
              Size(PdfPageSize.a4.height,
                  PdfPageSize.a4.width), // Fit content to portrait
            );
            portraitPage.graphics.restore();

          } else {
            // Draw directly for portrait pages
            portraitPage.graphics.drawPdfTemplate(
              template,
              Offset(0, 0),
              Size(PdfPageSize.a4.width, PdfPageSize.a4.height),
            );
          }

          print("Page $i appended in portrait orientation.");
        }

        // for (int i = 0; i < originalDocument.pages.count; i++) {
        //   final PdfPage originalPage = originalDocument.pages[i];
        //   final PdfPage newPage = combinedDocument.pages.add();
        //
        //   // Get content from the original page
        //   PdfTemplate template = originalPage.createTemplate();
        //   newPage.graphics.drawPdfTemplate(template, Offset.zero);
        //
        //   // Add page number at the bottom
        //   final PdfFont font = PdfStandardFont(PdfFontFamily.helvetica, 12);
        //   final PdfStringFormat format = PdfStringFormat(
        //     alignment: PdfTextAlignment.center,
        //   );
        //
        //   newPage.graphics.drawString(
        //     'Page ${i + 1} of ${originalDocument.pages.count}', // Page number format
        //     font,
        //     bounds: Rect.fromLTWH(0, newPage.size.height - 30, newPage.size.width, 20),
        //     format: format,
        //   );
        // }

      }
      // Save the combined document
      final Directory tempDir = await getTemporaryDirectory();
      final String outputPath = "${tempDir.path}/${widget.meeting.meetingTitle}.pdf";
      final File outputFile = File(outputPath);
      await outputFile.writeAsBytes(combinedDocument.saveSync());
      combinedDocument.dispose();
      print("Combined PDF saved at $outputPath");
      provider.uploadAgendasAndChildrenAfterView(outputPath, widget.meeting.meetingId.toString());
      return outputPath;
    } catch (e, stackTrace) {
      print("Error: $e");
      _showSnackbar('$e', Colors.red, Duration(milliseconds: 3));
      print(stackTrace);
      return null;
    }
  }


  List<MemberSignedModel> extractAllMembers(List<Agenda> agendas) {
    List<MemberSignedModel> allMembers = [];

    for (var agenda in agendas) {
      if (agenda.membersSigned != null && agenda.membersSigned!.isNotEmpty) {
        allMembers.addAll(agenda.membersSigned!);
      }

      if (agenda.agendaChildren != null && agenda.agendaChildren!.isNotEmpty) {
        for (var child in agenda.agendaChildren!) {
          if (child.membersSigned != null && child.membersSigned!.isNotEmpty) {
            allMembers.addAll(child.membersSigned!);
          }
        }
      }
    }

    return allMembers;
  }


  @override
  Widget build(BuildContext context) {
    final agendas = widget.meeting.agendas ?? [];
    final allMembers = extractAllMembers(agendas);

    return Scaffold(
      appBar: Header(context),
      body: SingleChildScrollView(
        child: Consumer<MeetingPageProvider>(
            builder: (BuildContext context, provider, child) {
          List<Agenda>? agendas = widget.meeting.agendas;

          if (agendas == null || agendas.isEmpty) {
            return Center(
              child: CustomText(text: 'No agendas available'),
            );
          }
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 7),
            child: Consumer<MeetingPageProvider>(
              builder: (BuildContext context, MeetingPageProvider provider,
                  Widget? ddd) {
                if (provider.dataOfMeetings?.meetings == null) {
                  provider.fetchMeetings(true, false, false,
                      provider.yearSelected, provider.combined);
                  return Center(
                    child: SpinKitThreeBounce(
                      itemBuilder: (BuildContext context, int index) {
                        return DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: index.isEven ? Colors.red : Colors.green,
                          ),
                        );
                      },
                    ),
                  );
                }

                return Builder(
                  builder: (BuildContext context) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        buildMemberImage(memberList: allMembers),
                        SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: [
                            Container(
                              width: 500,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                // mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  ContainerLabelWithBoxShadow(
                                    text: '${widget.meeting.meetingTitle}',
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  ContainerLabelWithBoxShadow(
                                    text:
                                        '${widget.meeting?.meetingDescription}' ??
                                            'No Meeting Description',
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        margin: EdgeInsets.all(5.0),
                                        padding: EdgeInsets.all(10.0),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          boxShadow: <BoxShadow>[
                                            BoxShadow(
                                                color: Colors.black54,
                                                blurRadius: 5.0,
                                                offset: Offset(0.0, 0.75))
                                          ],
                                        ),
                                        child: CustomText(
                                            text:
                                                '${widget.meeting?.meetingStartDate.toString()}',
                                            fontSize: 14.0),
                                      ),
                                      SizedBox(
                                        width: 5.0,
                                      ),
                                      Expanded(
                                        child: Container(
                                          margin: EdgeInsets.all(5.0),
                                          padding: EdgeInsets.all(10.0),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            boxShadow: <BoxShadow>[
                                              BoxShadow(
                                                  color: Colors.black54,
                                                  blurRadius: 5.0,
                                                  offset: Offset(0.0, 0.75))
                                            ],
                                          ),
                                          child: CustomText(
                                              text:
                                                  '${widget.meeting?.meetingEndDate}',
                                              color: Theme.of(context)
                                                  .iconTheme
                                                  .color,
                                              fontSize: 14.0),
                                        ),
                                      ),
                                    ],
                                  ),
                                  ContainerLabelWithBoxShadow(
                                    text: 'More Information',
                                  ),
                                  ContainerLabelWithBoxShadow(
                                    text:
                                        '${widget.meeting?.meetingMediaName}' ??
                                            'No Meeting MediaName',
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        margin: EdgeInsets.all(5.0),
                                        padding: EdgeInsets.all(10.0),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          boxShadow: <BoxShadow>[
                                            BoxShadow(
                                                color: Colors.black54,
                                                blurRadius: 5.0,
                                                offset: Offset(0.0, 0.75))
                                          ],
                                        ),
                                        child: CustomText(
                                            text: 'Quorum:',
                                            color: Theme.of(context)
                                                .iconTheme
                                                .color,
                                            fontSize: 14.0),
                                      ),
                                      SizedBox(
                                        width: 5.0,
                                      ),
                                      Expanded(
                                        child: Container(
                                          margin: EdgeInsets.all(5.0),
                                          padding: EdgeInsets.all(10.0),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            boxShadow: <BoxShadow>[
                                              BoxShadow(
                                                  color: Colors.black54,
                                                  blurRadius: 5.0,
                                                  offset: Offset(0.0, 0.75))
                                            ],
                                          ),
                                          child: CustomText(
                                              text: '71%:',
                                              color: Theme.of(context)
                                                  .iconTheme
                                                  .color,
                                              fontSize: 14.0),
                                        ),
                                      ),
                                    ],
                                  ),
                                  CustomText(
                                      text:
                                          ' Members present / total members 5/7 = 71%',
                                      color: Theme.of(context).iconTheme.color,
                                      fontSize: 14.0),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 15.0,
                            ),
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    width: double.infinity,
                                    margin: EdgeInsets.all(10.0),
                                    padding: EdgeInsets.all(15.0),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      boxShadow: <BoxShadow>[
                                        BoxShadow(
                                            color: Colors.black54,
                                            blurRadius: 5.0,
                                            offset: Offset(0.0, 0.75))
                                      ],
                                      border: Border.all(color: Colors.black12),
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(20)),
                                    ),
                                    child: Center(
                                      child: CustomText(
                                          text: 'Agendas',
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18.0),
                                    ),
                                  ),
                                  AgendaWidget(
                                    meeting: widget.meeting,
                                    onGeneratePdf: (agendas, provider) async{
                                    await  generatePdf(agendas, provider);
                                    },
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder( borderRadius: BorderRadius.zero),
                                  padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                                  elevation: 5,
                                  backgroundColor:Colors.red,
                                ),
                                onPressed: () async {
                                  final provider = Provider.of<MeetingPageProvider>(context,listen: false);
                                  List<Agenda>? agendas = widget.meeting.agendas;

                                  if (agendas == null || agendas.isEmpty) {
                                    _showSnackbar('No agendas available.',
                                        Colors.red, Duration(seconds: 2));
                                    return;
                                  }

                                  provider.setLoading(true);
                                  // await Future.delayed(Duration(seconds: 10));
                                  // Step 1: Generate PDF
                                  await generatePdf(agendas, provider);
                                  _showSnackbar('Waiting for processing ...', Colors.green, Duration(seconds: 10));
                                  await Future.delayed(Duration(seconds: 15));
                                  // Step 2: Fetch Preview Meeting Data
                                  final PreviewMeetingModel? previewMeeting = provider.previewMeeting;

                                  if (previewMeeting != null) {
                                    // Step 3: Navigate to PDF Preview Screen
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PdfPreviewScreen(
                                          fileId: previewMeeting.previewMeetingId.toString(),
                                          previewMeeting: previewMeeting, isAdmin: true,
                                        ),
                                      ),
                                    );
                                  } else {
                                    _showSnackbar('Error generating PDF',Colors.red, Duration(seconds: 3));
                                  }
                                },
                                child: provider.loading ? CircularProgressIndicator(color: Colors.green,) : CustomText(text: "Present", color: Colors.white),
                              )
                            ],
                          ),
                        )
                      ],
                    );
                  },
                );
              },
            ),
          );
        }),
      ),
    );
  }

  void _showSnackbar(String message, Color color, Duration duration) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(message), backgroundColor: color, duration: duration),
    );
  }
}

class buildMemberImage extends StatelessWidget {
  final List<MemberSignedModel> memberList;
  const buildMemberImage({
    super.key, required this.memberList,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: memberList.map((member) {
          // print("member AppUri image ${member.memberProfileImage}");
          return CircleImageWithBorder(
            imageUrl: "${AppUri.profileImages}/${member.businessId}/${member.memberProfileImage!}" ?? 'https://via.placeholder.com/150',
            borderColor: Colors.blue,
          );
        }).toList(),
      ),
    );
  }
}

class AgendaWidget extends StatefulWidget {
  final Meeting meeting;
  final Function(List<Agenda>, MeetingPageProvider) onGeneratePdf;
  const AgendaWidget({
    Key? key,
    required this.meeting,
    required this.onGeneratePdf,
  }) : super(key: key);

  @override
  _AgendaWidgetState createState() => _AgendaWidgetState();
}

class _AgendaWidgetState extends State<AgendaWidget> {

  @override
  Widget build(BuildContext context) {
    final agendas = widget.meeting.agendas;

    if (agendas == null || agendas.isEmpty) {
      return Center(
        child: CustomText(text: 'No agendas available'),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Consumer<MeetingPageProvider>(
          builder: (BuildContext context, provider, child) {
        return ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: agendas.length,
          itemBuilder: (context, index) {
            final agenda = agendas[index];

            var cleanedAgendaFile = '';
            final agendaFile = agenda.agendaFileOneName;
            if (agendaFile != null && agendaFile.isNotEmpty) {
              cleanedAgendaFile = agendaFile.join(', ');
              print(cleanedAgendaFile);
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Parent Agenda
                Container(
                  margin: EdgeInsets.all(5.0),
                  padding: EdgeInsets.all(15.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.black54,
                        blurRadius: 5.0,
                        offset: Offset(0.0, 0.75),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 15,
                        child: CustomText(
                          text: '${index + 1}',
                          fontSize: 14.0,
                        ),
                      ),
                      Expanded(
                        child: CustomText(
                          text: '${agenda.agendaTitle}',
                          fontSize: 14.0,
                        ),
                      ),
                      Expanded(
                        child: CustomText(
                          text: '${agenda.agendaDescription}',
                          fontSize: 14.0,
                        ),
                      ),
                      Expanded(
                        child: CustomText(
                          text: '${agenda.agendaTime}',
                          fontSize: 14.0,
                        ),
                      ),
                      Expanded(
                        child: CustomText(
                          text: '${agenda.presenter}',
                          fontSize: 14.0,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(7),
                  // color: Colors.red,
                  child: CustomText(
                    text: '${cleanedAgendaFile}',
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Padding(
                  padding: EdgeInsets.only(left: 20.0), // Indent children
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: agenda.agendaChildren!.length,
                    itemBuilder: (BuildContext context, int index) {
                      var child = agenda.agendaChildren![index];
                      var cleanedAgendaFile = '';
                      final agendaFile = child.childAgendaFileOneName;
                      if (agendaFile != null && agendaFile.isNotEmpty) {
                        cleanedAgendaFile = agendaFile.join(', ');
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: EdgeInsets.all(5.0),
                            padding: EdgeInsets.all(10.0),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 10,
                                  child: CustomText(
                                    text: '${index + 1}',
                                    fontSize: 14.0,
                                  ),
                                ),
                                Expanded(
                                  child: CustomText(
                                    text: '${child.childAgendaTitle}',
                                    fontSize: 14.0,
                                  ),
                                ),
                                Expanded(
                                  child: CustomText(
                                    text: '${child.childAgendaDescription}',
                                    fontSize: 14.0,
                                  ),
                                ),
                                Expanded(
                                  child: CustomText(
                                    text: '${agenda.agendaTime}',
                                    fontSize: 14.0,
                                  ),
                                ),
                                Expanded(
                                  child: CustomText(
                                    text: '${agenda.presenter}',
                                    fontSize: 14.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (agendaFile != null &&
                              agendaFile.isNotEmpty)
                            Container(
                              padding: EdgeInsets.all(6),
                              // color: Colors.red,
                              child: CustomText(
                                text: '${cleanedAgendaFile}',
                                fontSize: 14.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      }),
    );
  }
}

class CircleImageWithBorder extends StatelessWidget {
  final String imageUrl;
  final Color borderColor;

  CircleImageWithBorder({required this.imageUrl, required this.borderColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(3), // Border width
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 3),
      ),
      child: ClipOval(
        child: Image.network(
          imageUrl ?? "not found",
          width: 50,
          height: 50,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
