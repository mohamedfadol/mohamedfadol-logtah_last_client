
import 'package:flutter/services.dart';
import 'package:diligov_members/utility/pdf_api.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/material.dart' as mat;
import 'package:pdf/pdf.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../../../models/minutes_model.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import '../../../providers/localizations_provider.dart';
import '../../../views/modules/minutes_meeting_views/CustomMultiPage.dart';

class PdfMinutesMeetingApi {
  static NumberFormat formatCurrency = NumberFormat.simpleCurrency();

  static pw.TextDirection getTextDirection(mat.BuildContext context) {
    final providerLanguage = Provider.of<LocalizationsProvider>(
        context, listen: false);
    return providerLanguage.locale.toString() == 'ar'
        ? pw.TextDirection.rtl
        : pw.TextDirection.ltr;
  }

  static pw.TextAlign getTextAlign(mat.BuildContext context) {
    final providerLanguage = Provider.of<LocalizationsProvider>(
        context, listen: false);
    return providerLanguage.locale.toString() == 'ar' ? pw.TextAlign.right : pw
        .TextAlign.left;
  }

  static AppLocalizations? getLang(mat.BuildContext context) {
    return AppLocalizations.of(context);
  }

  static Future<File> generate(Minute minute, mat.BuildContext context) async {
    final pdf = pw.Document();
    final theme = pw.ThemeData.withFont(
      base: pw.Font.ttf(
          await rootBundle.load('assets/fonts/Al-Mohanad-Regular.ttf')),
      bold: pw.Font.ttf(
          await rootBundle.load('assets/fonts/Al-Mohanad-Bold.ttf')),
    );

    // Dynamically generate content widgets based on minute object
    final List<pw.Widget> contentWidgets = _generateContentWidgets(
        minute, context);

    // Get total items per page
    final totalItemsPerPage = _calculateTotalItemsPerPage(contentWidgets);

    int itemsProcessed = 0;

    // Page generation loop (no fixed maxPages)
    while (itemsProcessed < contentWidgets.length) {
      final remainingItems = contentWidgets.length - itemsProcessed;
      final itemsToProcess = remainingItems < totalItemsPerPage
          ? remainingItems
          : totalItemsPerPage;

      pdf.addPage(
        CustomMultiPage(
          build: (pw.Context context) {
            return [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: contentWidgets
                    .skip(itemsProcessed)
                    .take(itemsToProcess)
                    .toList(),
              ),
            ];
          },
          header: (context) => _buildHeader(context, minute),
          footer: (context) => _buildFooter(context),
          theme: theme,
        ),
      );

      itemsProcessed += itemsToProcess;
    }

    return PDFApi.saveDocument(
      name: 'minutes_${DateTime.now().toIso8601String()}.pdf',
      pdf: pdf,
    );
  }

  // Dynamically calculates the total number of items per page based on content height
  static int _calculateTotalItemsPerPage(List<pw.Widget> contentWidgets) {
    const double itemHeight = 20.0; // Average height per item
    final double availableHeight = PdfPageFormat.a4.availableHeight;

    // Calculate number of items that can fit within the available page height
    return (availableHeight / itemHeight).floor();
  }

  static List<pw.Widget> _generateContentWidgets(Minute minute,
      mat.BuildContext context) {
    final List<pw.Widget> widgets = [];
    widgets.add(_buildLogoWidgetTitle(minute));
    widgets.add(_buildBusinessInformation(minute, context));
    widgets.add(pw.Divider(thickness: 1.0));
    widgets.add(_buildPageContent(minute, context));
    return widgets;
  }

  static pw.Widget _buildLogoWidgetTitle(Minute minute) {
    return pw.Center(
      child: pw.Container(
        height: 50,
        width: 50,
        padding: const pw.EdgeInsets.all(10.0),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(width: 2.0, color: PdfColors.grey),
          borderRadius: pw.BorderRadius.circular(10),
        ),
        child: pw.PdfLogo(),
      ),
    );
  }

  static pw.Widget _buildBusinessInformation(Minute minute,
      mat.BuildContext context) {
    return pw.Container(
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          pw.Text("postal_code: ${minute.business?.postCode}"),
          pw.SizedBox(width: 7.0),
          pw.Text("country: ${minute.business?.country}"),
          pw.SizedBox(width: 7.0),
          pw.Text("phone_number:  ${minute.business?.mobile}"),
          pw.SizedBox(width: 7.0),
          pw.Text(".fax: ${minute.business?.fax}"),
        ],
      ),
    );
  }

  static pw.Widget _buildPageContent(Minute minute, mat.BuildContext context) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildMeetingDetails(minute, context),
        pw.SizedBox(height: 10),
        _buildAgendaSection(minute, context),
        pw.SizedBox(height: 10),
        _buildBoardMembersSection(minute, context),
        _buildMeetingDetails(minute, context),
        pw.SizedBox(height: 10),
        _buildAgendaSection(minute, context),
        pw.SizedBox(height: 10),
        _buildBoardMembersSection(minute, context),
        _buildMeetingDetails(minute, context),
        pw.SizedBox(height: 10),
        _buildAgendaSection(minute, context),
        pw.SizedBox(height: 10),
        _buildBoardMembersSection(minute, context),
        _buildMeetingDetails(minute, context),
        pw.SizedBox(height: 10),
        _buildAgendaSection(minute, context),
        pw.SizedBox(height: 10),
        _buildBoardMembersSection(minute, context),
        _buildMeetingDetails(minute, context),
        pw.SizedBox(height: 10),
        _buildAgendaSection(minute, context),
        pw.SizedBox(height: 10),
        _buildBoardMembersSection(minute, context),
        _buildMeetingDetails(minute, context),
        pw.SizedBox(height: 10),
        _buildAgendaSection(minute, context),
        pw.SizedBox(height: 10),
        _buildBoardMembersSection(minute, context),
        _buildMeetingDetails(minute, context),
        pw.SizedBox(height: 10),
        _buildAgendaSection(minute, context),
        pw.SizedBox(height: 10),
        _buildBoardMembersSection(minute, context),
        _buildMeetingDetails(minute, context),
        pw.SizedBox(height: 10),
        _buildAgendaSection(minute, context),
        pw.SizedBox(height: 10),
        _buildBoardMembersSection(minute, context),
        _buildMeetingDetails(minute, context),
        pw.SizedBox(height: 10),
        _buildAgendaSection(minute, context),
        pw.SizedBox(height: 10),
        _buildBoardMembersSection(minute, context),
      ],
    );
  }

  static pw.Widget _buildMeetingDetails(Minute minute,
      mat.BuildContext context) {
    return pw.Text(
      '${getLang(context)?.minutes_of} ${minute.minuteName} - ${getLang(context)
          ?.held_on} ${minute.minuteDate}',
      style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
    );
  }

  static pw.Widget _buildAgendaSection(Minute minute,
      mat.BuildContext context) {
    final List<pw.Widget> agendaWidgets = minute.meeting?.agendas?.map((
        agenda) {
      return pw.Text(
          '${agenda.agendaTitle}', style: pw.TextStyle(fontSize: 10));
    }).toList() ?? [];

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: agendaWidgets,
    );
  }

  static pw.Widget _buildBoardMembersSection(Minute minute,
      mat.BuildContext context) {
    final List<pw.Widget> memberWidgets = minute.board?.members?.map((member) {
      return pw.Text(
        '${member.position?.positionName}: ${member.memberFirstName} ${member
            .memberMiddleName} ${member.memberLastName}',
        style: pw.TextStyle(fontSize: 8),
      );
    }).toList() ?? [];

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: memberWidgets,
    );
  }

  static pw.Widget _buildHeader(pw.Context context, Minute minute) {
    return pw.Center(
      child: pw.Text(
        'Minutes of Meeting - ${minute.minuteName}',
        style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
      ),
    );
  }

  static pw.Widget _buildFooter(pw.Context context) {
    final text = 'Page ${context.pageNumber} of ${context.pagesCount}';
    return pw.Column(
      mainAxisAlignment: pw.MainAxisAlignment.end,
      children: [
        pw.Divider(),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.end,
          children: [
            pw.Text(text, style: pw.TextStyle(fontSize: 8)),
          ],
        ),
      ],
    );
  }

  static pw.Widget boardMembersDetails(Minute minute,
      mat.BuildContext context) {
    final members = minute.board?.members?.map((member) {
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('${member.position?.positionName}: ',
              style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
          pw.Row(
            children: [
              pw.Text(
                  '${member.memberFirstName} ${member.memberMiddleName} ${member
                      .memberLastName}', style: pw.TextStyle(fontSize: 8)),
              pw.SizedBox(width: 1.0),
              member.minuteSignature?.hasSigned == true
                  ? pw.Image(
                  pw.MemoryImage(base64Decode(member.memberSignature ?? '')),
                  height: 20, width: 70)
                  : pw.Text('......', style: pw.TextStyle(fontSize: 8)),
            ],
          ),
        ],
      );
    }).toList() ?? [];

    return pw.Column(children: members);
  }

  static pw.Widget boardMembersDetailsAr(Minute minute,
      mat.BuildContext context) {
    final members = minute.board?.members?.map((member) {
      return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Text('${member.position?.positionName}: ',
              style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
          pw.Row(
            children: [
              pw.Text(
                  '${member.memberFirstName} ${member.memberMiddleName} ${member
                      .memberLastName}', style: pw.TextStyle(fontSize: 8)),
              pw.SizedBox(width: 1.0),
              member.minuteSignature?.hasSigned == true
                  ? pw.Image(
                  pw.MemoryImage(base64Decode(member.memberSignature ?? '')),
                  height: 20, width: 70)
                  : pw.Text('......', style: pw.TextStyle(fontSize: 8)),
            ],
          ),
        ],
      );
    }).toList() ?? [];

    return pw.Column(children: members);
  }

  static pw.Widget meetingAgendaList(Minute minute, mat.BuildContext context) {
    final agendas = minute.meeting?.agendas ?? [];
    final agendaWidgets = agendas.map((agenda) {
      return pw.Text('${agenda.agendaTitle}',
          style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold));
    }).toList();

    return pw.Column(children: agendaWidgets);
  }

  static pw.Widget meetingAgendaListAr(Minute minute) {
    final agendas = minute.meeting!.agendas!.map((agenda) {
      return agenda;
    }).toList();
    return pw.Directionality(
        textDirection: pw.TextDirection.rtl,
        child: pw.Wrap(
            children: List.generate(
                agendas.length,
                    (index) =>
                    pw.Column(
                        mainAxisAlignment: pw.MainAxisAlignment.end,
                        children: [
                          pw.SizedBox(height: 4.0),
                          pw.Text(
                              '${index + 1} -  ${agendas[index].agendaTitleAr}',
                              style: pw.TextStyle(
                                  fontSize: 8, fontWeight: pw.FontWeight.bold)),
                        ]
                    )
            )
        ));
  }
}
