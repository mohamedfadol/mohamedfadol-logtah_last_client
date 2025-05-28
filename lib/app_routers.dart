import 'package:diligov_members/utility/signature_view.dart';
import 'package:diligov_members/views/auth/login_screen.dart';
import 'package:diligov_members/views/auth/password_screen.dart';
import 'package:diligov_members/views/auth/reset_password_screen.dart';
import 'package:diligov_members/views/boards_views/boards_list_views.dart';
import 'package:diligov_members/views/boards_views/quick_access_board_list_view.dart';
import 'package:diligov_members/views/calenders/calendar_page.dart';
import 'package:diligov_members/views/committee_views/annual_audit_report/forms/build_annual_audit_report_form_card.dart';
import 'package:diligov_members/views/committee_views/calenders/committee_calendar_page.dart';
import 'package:diligov_members/views/committee_views/committee_list.dart';
import 'package:diligov_members/views/committee_views/committee_resolutions_views/committee_resolutions_list_views.dart';
import 'package:diligov_members/views/committee_views/nominations_view/nominations_list.dart';
import 'package:diligov_members/views/committee_views/quick_access_committee_list_view.dart';
import 'package:diligov_members/views/dashboard/dashboard_home_screen.dart';
import 'package:diligov_members/views/dashboard/setting.dart';
import 'package:diligov_members/views/modules/C_Suite_KPIs/forms/create_suite_kpi_form.dart';
import 'package:diligov_members/views/modules/C_Suite_KPIs/suite_kpi_list_view.dart';
import 'package:diligov_members/views/modules/actions_tracker_view/actions_tracker_list.dart';
import 'package:diligov_members/views/committee_views/annual_audit_report/annual_audit_report_list.dart';
import 'package:diligov_members/views/modules/disclosures_views/competitions/views/competitions_questions_with_company_list_views.dart';
import 'package:diligov_members/views/modules/disclosures_views/confirmation_of_independence/views/competitions_questions_with_confirmation_of_independence_list_views.dart';
import 'package:diligov_members/views/modules/disclosures_views/disclosures_how_menus.dart';
import 'package:diligov_members/views/modules/disclosures_views/related_parties/views/competitions_questions_with_related_parties_list_views.dart';
import 'package:diligov_members/views/modules/performance_reward/performance_reward_list_view.dart';
import 'package:diligov_members/views/modules/remuneration_policy/remuneration_policy_list_views.dart';
import '../../views/modules/committees_annual_audit_report_views/committees_annual_audit_report_list_view.dart';
import 'package:diligov_members/views/modules/board_views/board_meetings/board_meetings_list_view.dart';
import 'package:diligov_members/views/modules/board_views/tab_bar_list_view.dart';
import 'package:diligov_members/views/modules/disclosures_views/disclosures_list_view.dart';
import 'package:diligov_members/views/modules/evaluation_views/board_effectiveness.dart';
import 'package:diligov_members/views/modules/evaluation_views/evaluation_home.dart';
import 'package:diligov_members/views/modules/evaluation_views/evaluation_list_views.dart';
import 'package:diligov_members/views/modules/evaluation_views/member_page_assessment.dart';
import 'package:diligov_members/views/modules/financials_views/financial_list_views.dart';
import 'package:diligov_members/views/modules/minutes_meeting_views/minutes_meeting_list.dart';
import 'package:diligov_members/views/modules/note_views/note_list_views.dart';
import 'package:diligov_members/views/modules/reports_views/reports_list_views.dart';
import 'package:diligov_members/views/modules/resolutions_views/resolutions_list_views.dart';
import 'package:diligov_members/views/searching_views/full_screen_search_views.dart';
import 'package:diligov_members/views/tab_bar_view/member_and_committees.dart';
import 'package:diligov_members/views/members_view/members_list.dart';
import 'package:diligov_members/views/members_view/quick_access_member_list_view.dart';
import 'package:diligov_members/views/user/edit_profile.dart';
import 'package:diligov_members/views/user/profile.dart';
import 'package:diligov_members/widgets/build_meeting_form_card.dart';
import 'package:flutter/material.dart';

class AppRoutes {

  static Map<String, WidgetBuilder> routes =  {
    "/loginPage" : (context) => LoginScreen(),
    '/dashboardHome': (context) => const DashboardHomeScreen(),
    ProfileUser.routeName: (context) => const ProfileUser(),
    NominationsList.routeName: (context) => const NominationsList(),
    PerformanceRewardListView.routeName: (context) => const PerformanceRewardListView(),
    SuiteKpiListView.routeName: (context) => const SuiteKpiListView(),
    CreateSuiteKpiForm.routeName: (context) => const CreateSuiteKpiForm(),
    DisclosuresHowMenus.routeName: (context) => const DisclosuresHowMenus(),
    CompetitionsQuestionsWithCompanyListViews.routeName: (context) => const CompetitionsQuestionsWithCompanyListViews(),
    CompetitionsQuestionsWithRelatedPartiesListViews.routeName: (context) => const CompetitionsQuestionsWithRelatedPartiesListViews(),
    CompetitionsQuestionsWithConfirmationOfIndependenceListViews.routeName: (context) => const CompetitionsQuestionsWithConfirmationOfIndependenceListViews(),
    RemunerationPolicyListViews.routeName: (context) => const RemunerationPolicyListViews(),
    EditProfile.routeName: (context) => const EditProfile(),
    Setting.routeName: (context) => const Setting(),
    MembersList.routeName: (context) => const MembersList(),
    MemberAndCommittees.routeName: (context) => const MemberAndCommittees(),
    BoardsListViews.routeName: (context) => const BoardsListViews(),
    CommitteeList.routeName: (context) => const CommitteeList(),
    SignatureView.routeName: (context) => const SignatureView(),
    CalendarPage.routeName: (context) => const CalendarPage(),
    CommitteeCalendarPage.routeName: (context) => const CommitteeCalendarPage(),
    BoardListView.routeName: (context) => const BoardListView(),
    ReportsListViews.routeName: (context) => const ReportsListViews(),
    ResolutionsListViews.routeName: (context) => const ResolutionsListViews(),
    EvaluationHome.routeName: (context) => const EvaluationHome(),
    MemberPageAssessment.routeName: (context) => const MemberPageAssessment(),
    BoardEffectiveness.routeName: (context) => const BoardEffectiveness(),
    EvaluationListViews.routeName: (context) => const EvaluationListViews(),
    AnnualAuditReport.routeName: (context) => const AnnualAuditReport(),
    MinutesMeetingList.routeName: (context) => const MinutesMeetingList(),
    QuickAccessBoardListView.routeName: (context) => const QuickAccessBoardListView(),
    QuickAccessMemberListView.routeName: (context) => const QuickAccessMemberListView(),
    QuickAccessCommitteeListView.routeName: (context) => const QuickAccessCommitteeListView(),
    ActionsTrackerList.routeName: (context) =>  ActionsTrackerList(),
    FinancialListViews.routeName: (context) =>  FinancialListViews(),
    CommitteesAnnualAuditReportListView.routeName: (context) =>  CommitteesAnnualAuditReportListView(),
    DisclosureListViews.routeName: (context) =>  DisclosureListViews(),
    CommitteeResolutionsListViews.routeName: (context) =>  CommitteeResolutionsListViews(),
    "/notes": (context) =>  NoteListViews(),
    BoardMeetingsListView.routeName: (context) =>  BoardMeetingsListView(),
    PasswordScreen.routeName: (context) =>  PasswordScreen(),
    ResetPasswordScreen.routeName: (context) =>  ResetPasswordScreen(),
    BuildMeetingFormCard.routeName: (context) =>  BuildMeetingFormCard(),
    BuildAnnualAuditReportFormCard.routeName: (context) =>  BuildAnnualAuditReportFormCard(),

    FullScreenSearchViews.routeName: (context) =>  FullScreenSearchViews(searchResults: [],),



  };
}
