import 'package:diligov_members/providers/actions_tracker_page_provider.dart';
import 'package:diligov_members/providers/agenda_page_provider.dart';
import 'package:diligov_members/providers/annual_audit_report_provider.dart';
import 'package:diligov_members/providers/annual_reports_provider_page.dart';
import 'package:diligov_members/providers/audio_recording_provider.dart';
import 'package:diligov_members/providers/authentications/auth_provider.dart';
import 'package:diligov_members/providers/authentications/user_provider.dart';
import 'package:diligov_members/providers/board_page_provider.dart';
import 'package:diligov_members/providers/committee_provider_page.dart';
import 'package:diligov_members/providers/disclosure_page_provider.dart';
import 'package:diligov_members/providers/document_page_provider.dart';
import 'package:diligov_members/providers/evaluation_page_provider.dart';
import 'package:diligov_members/providers/file_upload_page_provider.dart';
import 'package:diligov_members/providers/financial_page_provider.dart';
import 'package:diligov_members/providers/global_search_provider.dart';
import 'package:diligov_members/providers/icons_provider.dart';
import 'package:diligov_members/providers/laboratory_file_processing_provider_page.dart';
import 'package:diligov_members/providers/localizations_provider.dart';
import 'package:diligov_members/providers/meeting_page_provider.dart';
import 'package:diligov_members/providers/member_page_provider.dart';
import 'package:diligov_members/providers/menus_provider.dart';
import 'package:diligov_members/providers/minutes_provider_page.dart';
import 'package:diligov_members/providers/navigation_model_provider.dart';
import 'package:diligov_members/providers/navigator_provider.dart';
import 'package:diligov_members/providers/nomination_page_provider.dart';
import 'package:diligov_members/providers/note_page_provider.dart';
import 'package:diligov_members/providers/notification_page_provider.dart';
import 'package:diligov_members/providers/orientation_page_provider.dart';
import 'package:diligov_members/providers/resolutions_page_provider.dart';
import 'package:diligov_members/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

List<SingleChildWidget> getProviders(context) {
  return [
    ChangeNotifierProvider<IconsProvider>(create:(_) => IconsProvider(context.read<ThemeProvider>())),
    ChangeNotifierProvider(create: (context) => NominationPageProvider()),
    ChangeNotifierProvider<MenusProvider>(create:(_) => MenusProvider()),
    ChangeNotifierProvider<AnnualAuditReportProvider>(create:(_) => AnnualAuditReportProvider()),
    ChangeNotifierProvider<AuthProvider>(create:(_) => AuthProvider()),
    ChangeNotifierProvider<UserProfilePageProvider>(create:(_) => UserProfilePageProvider()),
    ChangeNotifierProvider<NavigatorProvider>(create:(_) => NavigatorProvider()),
    ChangeNotifierProvider<MemberPageProvider>(create:(_) => MemberPageProvider()),
    ChangeNotifierProvider<BoardPageProvider>(create:(_) => BoardPageProvider()),
    ChangeNotifierProvider<ThemeProvider>(create:(_) => ThemeProvider()),
    ChangeNotifierProvider<CommitteeProviderPage>(create:(_) => CommitteeProviderPage()),
    ChangeNotifierProvider<MeetingPageProvider>(create:(_) => MeetingPageProvider()),
    ChangeNotifierProvider<EvaluationPageProvider>(create:(_) => EvaluationPageProvider()),
    ChangeNotifierProvider<AnnualAuditReportProvider>(create: (_) => AnnualAuditReportProvider()),
    ChangeNotifierProvider<MinutesProviderPage>(create: (_) => MinutesProviderPage()),
    ChangeNotifierProvider<ResolutionsPageProvider>(create:(_) => ResolutionsPageProvider()),
    ChangeNotifierProvider<LocalizationsProvider>(create:(_) => LocalizationsProvider()),
    ChangeNotifierProvider<ActionsTrackerPageProvider>(create:(_) => ActionsTrackerPageProvider()),
    ChangeNotifierProvider<FinancialPageProvider>(create:(_) => FinancialPageProvider()),
    ChangeNotifierProvider<AnnualReportsProviderPage>(create:(_) => AnnualReportsProviderPage()),
    ChangeNotifierProvider<DisclosurePageProvider>(create:(_) => DisclosurePageProvider()),
    ChangeNotifierProvider<NotePageProvider>(create:(_) => NotePageProvider()),
    ChangeNotifierProvider<NavigationModelProvider>(create:(_) => NavigationModelProvider()),
    ChangeNotifierProvider<NotificationPageProvider>(create:(_) => NotificationPageProvider()),
    ChangeNotifierProvider<GlobalSearchProvider>(create:(_) => GlobalSearchProvider()),
    ChangeNotifierProvider<AudioRecordingProvider>(create:(_) => AudioRecordingProvider()),
    ChangeNotifierProvider<LaboratoryFileProcessingProviderPage>(create:(_) => LaboratoryFileProcessingProviderPage()),
    ChangeNotifierProvider<OrientationPageProvider>(create:(_) => OrientationPageProvider()),
    ChangeNotifierProvider<DocumentPageProvider>(create:(_) => DocumentPageProvider()),
    ChangeNotifierProvider<FileUploadPageProvider>(create:(_) => FileUploadPageProvider()),
    ChangeNotifierProvider<AgendaPageProvider>(create:(_) => AgendaPageProvider()),
    // ChangeNotifierProvider<AgendaPageProvider>.value(value: AgendaPageProvider()),

    // Add all your providers here
  ];
}
