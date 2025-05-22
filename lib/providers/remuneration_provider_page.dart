import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../NetworkHandler.dart';
import '../models/board_model.dart';
import '../models/boards_model.dart';
import '../models/committee_model.dart';
import '../models/member.dart';
import '../models/remuneration.dart';
import '../models/user.dart';
import '../services/attendance_tracker_service.dart';

class RemunerationProviderPage extends ChangeNotifier {
  final Logger log = Logger();
  User user = User();
  final NetworkHandler networkHandler = NetworkHandler();
  final AttendanceTrackerService attendanceTrackerService = AttendanceTrackerService();

  // Data models
  Remunerations? remunerationsData;
  MyData? dataOfMembers;
  DataComm? dataOfCommittees;
  Boards? dataOfBoards;
  Remuneration _remuneration = Remuneration();

  // State variables
  String _yearSelected = DateTime.now().year.toString();
  String _quarterSelected = 'All';
  int? _committeeIdSelected;
  int? _boardIdSelected;
  int? _memberIdSelected;
  bool _isLoading = false;
  String? _error;
  String _selectedQuarter = 'Q2';

  // Maps for derived data
  Map<String, List<Remuneration>> committeeRemunerations = {};
  Map<String, List<Remuneration>> boardRemunerations = {};
  Map<int, Map<String, dynamic>> memberSummaries = {};
  Map<int, Map<int, int>> _committeeAttendance = {}; // committeeId -> {memberId -> count}
  Map<int, Map<int, int>> _boardAttendance = {}; // boardId -> {memberId -> count}
  Map<int, Map<int, double>> _committeeRemuneration = {}; // committeeId -> {memberId -> amount}
  Map<int, Map<int, double>> _boardRemuneration = {}; // boardId -> {memberId -> amount}

  // UI Controllers
  final TextEditingController membershipFee = TextEditingController();
  final TextEditingController attendanceFee = TextEditingController();

  // Getters
  String get yearSelected => _yearSelected;
  String get quarterSelected => _quarterSelected;
  int? get committeeIdSelected => _committeeIdSelected;
  int? get boardIdSelected => _boardIdSelected;
  int? get memberIdSelected => _memberIdSelected;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedQuarter => _selectedQuarter;
  Remuneration get remuneration => _remuneration;

  // Collection getters
  List<Committee> get committees => dataOfCommittees?.committees ?? [];
  List<Board> get boards => dataOfBoards?.boards ?? [];
  List<Member> get members => dataOfMembers?.members ?? [];

  // Derived data getters
  Map<int, Map<int, int>> get committeeAttendance => _committeeAttendance;
  Map<int, Map<int, int>> get boardAttendance => _boardAttendance;
  Map<int, Map<int, double>> get committeeRemuneration => _committeeRemuneration;
  Map<int, Map<int, double>> get boardRemuneration => _boardRemuneration;

  RemunerationProviderPage() {
    // Add listeners to update the UI when text changes
    membershipFee.addListener(_updateTotalFee);
    attendanceFee.addListener(_updateTotalFee);

    // Initial data load
    initializeData();
  }

  // Initialization
  Future<void> initializeData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Initialize user
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      if (prefs.containsKey("user")) {
        user = User.fromJson(json.decode(prefs.getString("user")!));
        log.d("User loaded: ${user.businessId}");
      } else {
        log.e("No user data found in SharedPreferences");
      }

      // Load data in sequence
      await getMembers();
      await getCommittees();
      await getBoards();
      await getListOfRemunerationsByFilterDate(_yearSelected);

      log.d("Initialization completed:");
      log.d("Members: ${members.length}");
      log.d("Committees: ${committees.length}");
      log.d("Boards: ${boards.length}");
      log.d("Remunerations: ${remunerationsData?.remunerations?.length ?? 0}");

      _isLoading = false;
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Error initializing data: $e';
      _isLoading = false;
      notifyListeners();
      log.e('Error in initializeData: $e');
    }
  }

  // Data Fetching Methods
  Future<void> getMembers() async {
    try {
      if (user.businessId == null) {
        log.e("Cannot fetch members: No business ID");
        return;
      }

      log.d("Fetching members for business ID: ${user.businessId}");
      var response = await networkHandler.get('/members/business/${user.businessId}');

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        var membersData = responseData['data'];

        log.d("Received members data: ${membersData != null ? 'yes' : 'no'}");

        if (membersData != null) {
          dataOfMembers = MyData.fromJson(membersData);
          log.d("Parsed ${dataOfMembers?.members?.length ?? 0} members");

          if (dataOfMembers?.members != null && dataOfMembers!.members!.isNotEmpty) {
            log.d("First member: ${dataOfMembers!.members!.first.fullName}");
          }
        } else {
          log.e("Members data is null");
        }
      } else {
        log.e("Failed to load members: ${response.statusCode}");
        log.e("Response body: ${response.body}");
      }
    } catch (e) {
      log.e("Error loading members: $e");
    }

    notifyListeners();
  }

  Future<void> getCommittees() async {
    try {
      if (user.businessId == null) {
        log.e("Cannot fetch committees: No business ID");
        return;
      }

      log.d("Fetching committees for business ID: ${user.businessId}");
      var response = await networkHandler.get('/committees/business/${user.businessId}');

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        var committeesData = responseData['data'];

        log.d("Received committees data: ${committeesData != null ? 'yes' : 'no'}");

        if (committeesData != null) {
          dataOfCommittees = DataComm.fromJson(committeesData);
          log.d("Parsed ${dataOfCommittees?.committees?.length ?? 0} committees");

          if (dataOfCommittees?.committees != null && dataOfCommittees!.committees!.isNotEmpty) {
            log.d("First committee: ${dataOfCommittees!.committees!.first.committeeName}");
          }
        } else {
          log.e("Committees data is null");
        }
      } else {
        log.e("Failed to load committees: ${response.statusCode}");
        log.e("Response body: ${response.body}");
      }
    } catch (e) {
      log.e("Error loading committees: $e");
    }

    notifyListeners();
  }

  Future<void> getBoards() async {
    try {
      if (user.businessId == null) {
        log.e("Cannot fetch boards: No business ID");
        return;
      }

      log.d("Fetching boards for business ID: ${user.businessId}");
      var response = await networkHandler.get('/boards/business/${user.businessId}');

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        var boardsData = responseData['data'];

        log.d("Received boards data: ${boardsData != null ? 'yes' : 'no'}");

        if (boardsData != null) {
          dataOfBoards = Boards.fromJson(boardsData);
          log.d("Parsed ${dataOfBoards?.boards?.length ?? 0} boards");

          if (dataOfBoards?.boards != null && dataOfBoards!.boards!.isNotEmpty) {
            log.d("First board: ${dataOfBoards!.boards!.first.boardName}, ID: ${dataOfBoards!.boards!.first.boarId}");
          }
        } else {
          log.e("Boards data is null");
        }
      } else {
        log.e("Failed to load boards: ${response.statusCode}");
        log.e("Response body: ${response.body}");
      }
    } catch (e) {
      log.e("Error loading boards: $e");
    }

    notifyListeners();
  }

  // Filter Methods
  void setYearSelected(year) async {
    _yearSelected = year;
     getListOfRemunerationsByFilterDate(_yearSelected);
  }



  void setQuarterSelected(String quarter) {
    _quarterSelected = quarter;
    refreshData();
  }

  void setCommitteeIdSelected(int? committeeId) {
    _committeeIdSelected = committeeId;
    _boardIdSelected = null; // Clear board selection when committee is selected
    refreshData();
  }

  void setBoardIdSelected(int? boardId) {
    _boardIdSelected = boardId;
    _committeeIdSelected = null; // Clear committee selection when board is selected
    refreshData();
  }

  void setMemberIdSelected(int? memberId) {
    _memberIdSelected = memberId;
    refreshData();
  }

  void clearFilters() {
    _committeeIdSelected = null;
    _boardIdSelected = null;
    _memberIdSelected = null;
    _quarterSelected = 'All';
    refreshData();
  }

  void refreshData() {
    getListOfRemunerationsByFilterDate(_yearSelected);
  }

  // Remuneration methods
  Future<void> getListOfRemunerationsByFilterDate(_yearSelected) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (user.businessId == null) {
        await _initializeUser();
      }

      final Map<String, String> queryParams = {
        'business_id': user.businessId.toString(),
        'yearSelected': yearSelected,
      };


      if (_committeeIdSelected != null) {
        queryParams['committee_id'] = _committeeIdSelected.toString();
      }

      if (_boardIdSelected != null) {
        queryParams['board_id'] = _boardIdSelected.toString();
      }

      if (_memberIdSelected != null) {
        queryParams['member_id'] = _memberIdSelected.toString();
      }

      log.d("Fetching remunerations with params: $queryParams");
      var response = await networkHandler.post1('/get-list-of-remunerations-by-filter-date', queryParams);

      if (response.statusCode == 200 || response.statusCode == 201) {
        var responseData = json.decode(response.body);
        var responseRemunerationsData = responseData['data'];

        remunerationsData = Remunerations.fromJson(responseRemunerationsData);
        log.d("API returned: ${remunerationsData?.remunerations?.length ?? 0} records");

        if (remunerationsData?.remunerations != null) {
          log.d("Parsed ${remunerationsData!.remunerations!.length} remunerations");
        } else {
          log.d("No remunerations found");
        }

        // Organize remunerations by committee and board
        organizeRemunerations();

        // Calculate member summaries
        calculateMemberSummaries();

        _isLoading = false;
        _error = null;
        notifyListeners();
      } else {
        remunerationsData = Remunerations(remunerations: []);
        _error = json.decode(response.body)['message'] ?? 'Failed to load data';
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Error loading data: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _initializeUser() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      if (prefs.containsKey("user")) {
        user = User.fromJson(json.decode(prefs.getString("user")!));
        log.d("User initialized: ${user.businessId}");
      } else {
        log.e("No user data found in SharedPreferences");
      }
    } catch (e) {
      log.e("Error initializing user: $e");
    }
  }

  void organizeRemunerations() {
    committeeRemunerations.clear();
    boardRemunerations.clear();

    remunerationsData?.remunerations?.forEach((remuneration) {
      // Handle committee remunerations
      if (remuneration.committee != null) {
        String committeeName = remuneration.committee?.committeeName ?? 'Unknown';

        if (!committeeRemunerations.containsKey(committeeName)) {
          committeeRemunerations[committeeName] = [];
        }

        committeeRemunerations[committeeName]!.add(remuneration);
      }

      // Handle board remunerations
      if (remuneration.board != null) {
        String boardName = remuneration.board?.boardName ?? 'Unknown';

        if (!boardRemunerations.containsKey(boardName)) {
          boardRemunerations[boardName] = [];
        }

        boardRemunerations[boardName]!.add(remuneration);
      }
    });
  }

  Map<String, List<Remuneration>> get groupedRemunerations {
    Map<String, List<Remuneration>> map = {};

    for (var rem in remunerationsData?.remunerations ?? []) {
      final groupName = rem.committee?.committeeName ?? rem.board?.boardName ?? 'Unknown';

      if (!map.containsKey(groupName)) {
        map[groupName] = [];
      }
      map[groupName]!.add(rem);
    }

    return map;
  }

  // Member summaries and breakdown
  void calculateMemberSummaries() {
    memberSummaries.clear();

    // Process all members in remunerations
    for (var remuneration in remunerationsData?.remunerations ?? []) {
      for (var member in remuneration.members) {
        int memberId = member.memberId ?? 0;

        if (!memberSummaries.containsKey(memberId)) {
          memberSummaries[memberId] = {
            'memberId': memberId,
            'memberName': member.fullName,
            'totalRemunerations': 0.0,
            'totalMeetings': 0,
            'attendedMeetings': 0,
            'entities': [],
          };
        }

        // Get entity name
        String entityName = remuneration.entityName;
        double memberRemuneration = remuneration.getTotalRemuneration(memberId);

        // Update member summary
        memberSummaries[memberId]!['totalRemunerations'] =
            (memberSummaries[memberId]!['totalRemunerations'] as double) + memberRemuneration;

        // Add entity to member's entities if it doesn't exist
        bool entityExists = false;
        for (var entity in memberSummaries[memberId]!['entities'] as List) {
          if (entity['name'] == entityName) {
            entityExists = true;
            break;
          }
        }

        if (!entityExists) {
          // Get attendance stats for this member in this entity
          int entityTotalMeetings = remuneration.totalMeetings;
          int entityAttendedMeetings = remuneration.memberAttendance[memberId] ?? 0;

          // Add to member's total meetings and attended meetings
          memberSummaries[memberId]!['totalMeetings'] =
              (memberSummaries[memberId]!['totalMeetings'] as int) + entityTotalMeetings;

          memberSummaries[memberId]!['attendedMeetings'] =
              (memberSummaries[memberId]!['attendedMeetings'] as int) + entityAttendedMeetings;

          // Add entity details
          (memberSummaries[memberId]!['entities'] as List).add({
            'name': entityName,
            'type': remuneration.entityType,
            'totalMeetings': entityTotalMeetings,
            'attendedMeetings': entityAttendedMeetings,
            'remuneration': memberRemuneration,
          });
        }
      }
    }
  }

  Future<Map<String, dynamic>> getMemberRemunerationBreakdown(int memberId) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (user.businessId == null) {
        await _initializeUser();
      }

      final Map<String, String> queryParams = {
        'business_id': user.businessId.toString(),
        'member_id': memberId.toString(),
        'year': _yearSelected,
      };

      if (_quarterSelected != 'All') {
        queryParams['quarter'] = _quarterSelected;
      }

      log.d("Fetching member remuneration breakdown: $queryParams");
      var response = await networkHandler.post1('/get-member-total-remuneration', queryParams);

      if (response.statusCode == 200 || response.statusCode == 201) {
        var responseData = json.decode(response.body);
        _isLoading = false;
        _error = null;
        notifyListeners();
        return responseData['data'] ?? {'error': 'No data returned'};
      } else {
        _error = json.decode(response.body)['message'] ?? 'Failed to load data';
        _isLoading = false;
        notifyListeners();
        return {'error': _error};
      }
    } catch (e) {
      _error = 'Error loading member data: $e';
      _isLoading = false;
      notifyListeners();
      return {'error': _error};
    }
  }

  // UI Utilities
  void _updateTotalFee() {
    notifyListeners();
  }

  double get totalFee {
    // Remove any non-numeric characters except decimal point
    String membershipText = membershipFee.text.replaceAll(RegExp(r'[^\d.]'), '');
    String attendanceText = attendanceFee.text.replaceAll(RegExp(r'[^\d.]'), '');

    double membership = double.tryParse(membershipText) ?? 0;
    double attendance = double.tryParse(attendanceText) ?? 0;
    return membership + attendance;
  }

  String formatNumber(num number) {
    if (number == 0) return '0';

    final formatter = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    String result = number.toString().replaceAllMapped(
        formatter,
            (Match m) => '${m[1]},'
    );
    return result;
  }

  // Fee management
  void loadCommitteeFees(Committee committee) {
    // Reset the controllers
    membershipFee.text = '';
    attendanceFee.text = '';

    // Check if there's an existing remuneration record for this committee
    if (remunerationsData?.remunerations != null) {
      for (var rem in remunerationsData!.remunerations!) {
        if (rem.committee?.id == committee.id) {
          membershipFee.text = rem.membershipFees ?? '';
          attendanceFee.text = rem.attendanceFees ?? '';
          break;
        }
      }
    }

    notifyListeners();
  }

  void loadBoardFees(Board board) {
    // Reset the controllers
    membershipFee.text = '';
    attendanceFee.text = '';

    // Check if there's an existing remuneration record for this board
    if (remunerationsData?.remunerations != null) {
      for (var rem in remunerationsData!.remunerations!) {
        // Check if this remuneration is for a board
        if (rem.board?.boarId == board.boarId) {
          membershipFee.text = rem.membershipFees ?? '';
          attendanceFee.text = rem.attendanceFees ?? '';
          break;
        }
      }
    }

    notifyListeners();
  }

  void setRemuneration(Remuneration remuneration) {
    _remuneration = remuneration;
    notifyListeners();
  }

  // Attendance calculations
  void calculateAllCommitteeAttendance() {
    _committeeAttendance.clear();

    for (var committee in committees) {
      if (committee.id != null) {
        _committeeAttendance[committee.id!] =
            attendanceTrackerService.calculateCommitteeMemberAttendance(committee);
      }
    }

    notifyListeners();
  }

  void calculateAllBoardAttendance() {
    _boardAttendance.clear();

    for (var board in boards) {
      if (board.boarId != null) {
        _boardAttendance[board.boarId!] =
            attendanceTrackerService.calculateBoardMemberAttendance(board);
      }
    }

    notifyListeners();
  }

  // Remuneration calculations
  void calculateCommitteeRemuneration(Committee committee) {
    if (committee.id == null) return;

    double membershipAmount = double.tryParse(membershipFee.text) ?? 0;
    double attendanceAmount = double.tryParse(attendanceFee.text) ?? 0;

    var remuneration = attendanceTrackerService.calculateCommitteeRemuneration(
        committee, membershipAmount, attendanceAmount
    );

    if (!_committeeRemuneration.containsKey(committee.id)) {
      _committeeRemuneration[committee.id!] = {};
    }

    _committeeRemuneration[committee.id!] = remuneration;
    notifyListeners();
  }

  void calculateBoardRemuneration(Board board) {
    if (board.boarId == null) return;

    double membershipAmount = double.tryParse(membershipFee.text) ?? 0;
    double attendanceAmount = double.tryParse(attendanceFee.text) ?? 0;

    var remuneration = attendanceTrackerService.calculateBoardRemuneration(
        board, membershipAmount, attendanceAmount
    );

    if (!_boardRemuneration.containsKey(board.boarId)) {
      _boardRemuneration[board.boarId!] = {};
    }

    _boardRemuneration[board.boarId!] = remuneration;
    notifyListeners();
  }

  Map<String, dynamic> getMemberTotalAttendance(Member member) {
    return attendanceTrackerService.calculateMemberAttendanceStats(member);
  }

  double calculateTotalMemberRemuneration(int memberId) {
    double total = 0.0;

    // Add committee remunerations
    _committeeRemuneration.forEach((committeeId, remunerations) {
      if (remunerations.containsKey(memberId)) {
        total += remunerations[memberId] ?? 0;
      }
    });

    // Add board remunerations
    _boardRemuneration.forEach((boardId, remunerations) {
      if (remunerations.containsKey(memberId)) {
        total += remunerations[memberId] ?? 0;
      }
    });

    return total;
  }

  Map<String, double> calculateRemunerationTotals() {
    double totalMembershipFees = 0;
    double totalAttendanceFees = 0;
    double grandTotal = 0;

    if (remunerationsData?.remunerations != null) {
      for (var remuneration in remunerationsData!.remunerations!) {
        // Get fees
        double membershipFee = double.tryParse(remuneration.membershipFees ?? '0') ?? 0;
        double attendanceFee = double.tryParse(remuneration.attendanceFees ?? '0') ?? 0;

        // Process each member's remuneration
        for (var member in remuneration.members) {
          int memberId = member.memberId ?? 0;

          // Skip if member filter is applied and doesn't match
          if (_memberIdSelected != null && _memberIdSelected != memberId) {
            continue;
          }

          int attendedCount = remuneration.memberAttendance[memberId] ?? 0;

          // Calculate prorated membership fee
          double proratedMembershipFee = 0;
          if (remuneration.totalMeetings > 0) {
            proratedMembershipFee = (membershipFee / remuneration.totalMeetings) * attendedCount;
          }

          // Calculate attendance fee
          double totalAttendanceFee = attendanceFee * attendedCount;

          // Add to totals
          totalMembershipFees += proratedMembershipFee;
          totalAttendanceFees += totalAttendanceFee;
        }
      }
    }

    grandTotal = totalMembershipFees + totalAttendanceFees;

    return {
      'totalMembershipFees': totalMembershipFees,
      'totalAttendanceFees': totalAttendanceFees,
      'grandTotal': grandTotal,
    };
  }

  // Save data API calls
  Future<bool> saveRemunerationData(Map<String, dynamic> data) async {
    log.i(data);
    if (membershipFee.text.isEmpty && attendanceFee.text.isEmpty) {
      _error = 'Please enter at least one fee amount';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      var response = await networkHandler.post1('/insert-new-remuneration', data);
      if (response.statusCode == 200 || response.statusCode == 201) {
        log.d("insert-new-remuneration response statusCode == 200");
        var responseData = json.decode(response.body);
        log.d(responseData);
        var meetingsData = responseData['data'];
        _remuneration = Remuneration.fromJson(meetingsData);
        setRemuneration(_remuneration);

        // Refresh remunerations data
        await getListOfRemunerationsByFilterDate(_yearSelected);

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        log.d("insert-new-remuneration response statusCode unknown");
        log.d(response.statusCode);
        _error = json.decode(response.body)['message'] ?? 'Failed to save data';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error saving data: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> saveBoardRemunerationData(Map<String, dynamic> data) async {
    log.i(data);
    if (membershipFee.text.isEmpty && attendanceFee.text.isEmpty) {
      _error = 'Please enter at least one fee amount';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      var response = await networkHandler.post1('/insert-new-board-remuneration', data);
      if (response.statusCode == 200 || response.statusCode == 201) {
        log.d("insert-new-board-remuneration response statusCode == 200");
        var responseData = json.decode(response.body);
        log.d(responseData);

        // Refresh remunerations data
        await getListOfRemunerationsByFilterDate(_yearSelected);

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        log.d("insert-new-board-remuneration response statusCode unknown");
        log.d(response.statusCode);
        _error = json.decode(response.body)['message'] ?? 'Failed to save data';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error saving data: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Legacy method for compatibility
  // Future getListOfRemunerationsByFilterDate(_yearSelected_yearSelected) async {
  //   return getListOfRemunerationsByFilterDate(_yearSelected);
  // }

  @override
  void dispose() {
    // Clean up the controllers
    membershipFee.dispose();
    attendanceFee.dispose();
    super.dispose();
  }
}