import 'dart:convert';

import 'package:diligov_members/models/group_permission_model.dart';
import 'package:flutter/material.dart';

import 'package:flutter/cupertino.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../NetworkHandler.dart';
import '../../../models/user.dart';
import '../models/combined_collection_board_committee_model.dart';
import '../models/member.dart';
import '../models/permission_model.dart';
import '../models/roles_model.dart';

class MemberPageProvider extends ChangeNotifier {
  var log = Logger();
  User user = User();
  NetworkHandler networkHandler = NetworkHandler();
  Member? selectedMember;
  List<dynamic> positions = [];
  List<dynamic> boards = [];
  List<dynamic> committees = [];

  CombinedCollectionBoardCommitteeData? collectionBoardCommitteeData;

  // List to store assigned permission IDs
  List<int> assignedPermissions = [];

  List _selectedMembersNoteList = [];
  List _selectedMembersAudioNoteList = [];
  List _selectedMembers = [];
  List _selectedMembersIds = [];
  List _selectedMembersNoteIds = [];
  List _selectedMembersAudioNoteIds = [];

  List get selectedMembersIds => _selectedMembersIds;
  List get selectedMembersNoteIds => _selectedMembersNoteIds;
  List get selectedMembersAudioNoteIds => _selectedMembersAudioNoteIds;
  List get selectedMembersNoteList => _selectedMembersNoteList;
  List get selectedMembersAudioNoteList => _selectedMembersAudioNoteList;
  List get selectedMembers => _selectedMembers;

  String? selectedCombined;
  Map<String, dynamic>? combined;
  String? _dropdownError;
  String? get dropdownError => _dropdownError;




  void setSelectMemberAudioNote(selectedMembersAudioNote) {
    _selectedMembersAudioNoteList = selectedMembersAudioNote;
    notifyListeners();
  }

  void setSelectMemberAudioNoteId(selectedMembersAudioNoteId) {
    _selectedMembersAudioNoteIds = selectedMembersAudioNoteId;
    notifyListeners();
  }

  void removeSelectedMembersAudioNote(member){
    _selectedMembersAudioNoteList.remove(member);
    notifyListeners();
  }

  void setSelectMemberNote(selectedMembersNote) {
    _selectedMembersNoteList = selectedMembersNote;
    notifyListeners();
  }

  void setSelectedMembersNoteId(selectedMembersNoteIds){
    _selectedMembersNoteIds = selectedMembersNoteIds;
    notifyListeners();
  }

  void removeSelectedMembersNote(member){
    _selectedMembersNoteList.remove(member);
    notifyListeners();
  }

  void setSelectedMembers(selectedMembers){
    _selectedMembers = selectedMembers;
    notifyListeners();
  }

  void setSelectedMembersId(selectedMembersIds){
    _selectedMembersIds = selectedMembersIds;
    notifyListeners();
  }

  void removeSelectedMembers(member){
    _selectedMembers.remove(member);
    notifyListeners();
  }


  MyData? dataOfMembers;
  Member _member = Member();
  Member get member => _member;

  void setMember(Member member) async {
    _member = member;
    notifyListeners();
  }
  Group dataOfGroup = Group();
  DataOfGroups? dataOfGroups;
  Roles? dataOfRoles;
  RoleModel _role = RoleModel();
  RoleModel get role => _role;


  // Fetch guards
  bool _hasFetchedMembers = false;
  bool _hasFetchedGroups = false;
  bool _hasFetchedRoles = false;

  bool get hasFetchedInitialData =>
  _hasFetchedMembers && _hasFetchedGroups && _hasFetchedRoles;



  Permissions? dataOfPermissions;
  PermissionModel _permission = PermissionModel();
  PermissionModel get permission => _permission;

  List<int> assignedRoles = []; // Store assigned roles for the current context

  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  void setPermission(PermissionModel permission) async {
    _permission = permission;
    notifyListeners();
  }

  bool _isBack = false;
  bool get isBack => _isBack;
  void setIsBack(value) async {
    _isBack = value;
    notifyListeners();
  }

  bool get loading => _loading;
  bool _loading = false;
  void setLoading(value) async {
    _loading = value;
    notifyListeners();
  }

  void setCurrentIndex(currentIndex, BuildContext context){
    _currentIndex = currentIndex;
    log.d("_currentIndex is $_currentIndex");

    fetchInitialData(context);
    notifyListeners();
  }

  bool _hasFetchedCombined = false;

  bool get hasFetchedCombined => _hasFetchedCombined;
  Future getListOfMembersDependingOnCombinedCollectionBoardAndCommittee() async{
    if (_hasFetchedCombined) return;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    user =  User.fromJson(json.decode(prefs.getString("user")!)) ;
    var businessId = user.businessId;
    Map<String, dynamic> data = {"business_id": businessId};
    var response = await networkHandler.post1('/combined-collection-board-and-committees',data);
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("get-list-meetings response statusCode == 200");
      var responseData = json.decode(response.body);
      log.d(responseData);
      var meetingsData = responseData['data'];
      collectionBoardCommitteeData = CombinedCollectionBoardCommitteeData.fromJson(meetingsData);
      print(collectionBoardCommitteeData!.combinedCollectionBoardCommitteeData!.length);
      _hasFetchedCombined = true;
      notifyListeners();

    } else {
      log.d("get-list-meetings response statusCode unknown");
      log.d(response.statusCode);
      print(json.decode(response.body)['message']);
    }
  }


  void selectCombinedCollectionBoardCommittee(String? combinedModel, context) {
    if (combinedModel != null) {
      List<String> parts = combinedModel.split('-');
      if (parts.length == 2) {
        String name = parts[0];
        int? id = int.tryParse(parts[1]);
        combined = {"id": id, "type": name};
        log.i(combined);
        selectedCombined = name.toString();
        _dropdownError = null;
        getListOfMember(context);
        notifyListeners();
      }
    }
  }

  Future getDataOfGroups() async{
    if (_hasFetchedGroups) return;
    _hasFetchedGroups = true;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    user =  User.fromJson(json.decode(prefs.getString("user")!)) ;
    var businessId = user.businessId;
    Map<String, dynamic> data = {"business_id": businessId};
    var response = await networkHandler.post1('/get-group-roles',data);
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("get-list-meetings response statusCode == 200");
      var responseData = json.decode(response.body);
      log.d(responseData);
      var meetingsData = responseData['data'];
      dataOfGroups = DataOfGroups.fromJson(meetingsData);

      print(collectionBoardCommitteeData!.combinedCollectionBoardCommitteeData!.length);
      notifyListeners();

    } else {
      log.d("get-list-meetings response statusCode unknown");
      log.d(response.statusCode);
      print(json.decode(response.body)['message']);
    }
  }

  Future getListOfMember(context) async {
    if (_hasFetchedMembers) return;
    _hasFetchedMembers = true;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    user = User.fromJson(json.decode(prefs.getString("user")!));
    Map<String, dynamic> requestData = {"business_id": user.businessId,"combined": combined};
    var response = await networkHandler.post1('/get-list-members-by-filter-board-or-committee', requestData);
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("get-list-members response statusCode == 200");
      var responseData = json.decode(response.body);
      var membersData = responseData['data'];
      dataOfMembers = MyData.fromJson(membersData);
      notifyListeners();
    } else {
      log.d("get-list-members response statusCode unknown");
      log.d(response.statusCode);
      print(json.decode(response.body)['message']);
    }
  }

  Future<void> fetchMemberDetails(int memberId) async {
    setLoading(true);
    notifyListeners();
    log.d("Member fetchMemberDetails $memberId");
    final response = await networkHandler.get('/get-member-details/$memberId');

    if (response.statusCode == 200 || response.statusCode == 201) {
      var responseData = json.decode(response.body);
      var memberData = responseData['data'];
      log.d("Member fetchMemberDetails $memberData");
      _member = Member.fromJson(memberData); // Store the fetched member
      notifyListeners();
    } else {
      log.d("Failed to fetch member details: ${response.statusCode}");
    }

    setLoading(false);
  }


  Future<List<Member>> getListOfMemberMenu() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var userJson = prefs.getString("user");

    if (userJson != null) {
      User user = User.fromJson(json.decode(userJson));

      Map<String, dynamic> requestData = {"business_id": user.businessId.toString()};
      var response = await networkHandler.post1('/get-list-members',requestData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        log.d("get-list-members menu response statusCode == 200");
        var membersData = json.decode(response.body);
        dataOfMembers = MyData.fromJson(membersData['data']);
        log.i(dataOfMembers!.members!);
        return dataOfMembers!.members!; // Return the list of members
      } else {
        log.d("get-list-members menu response statusCode unknown");
        log.d(response.statusCode);
        throw Exception("Failed to load members");
      }
    } else {
      log.d("get-list-members menu response userJson unknown");
      throw Exception("User data not found");
    }
  }


  Future getListOfMembers() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var userJson = prefs.getString("user");

    if (userJson != null) {
      User user = User.fromJson(json.decode(userJson));
      var response = await networkHandler.get('/get-list-members/${user.businessId.toString()}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        log.d("get-list-members menu response statusCode == 200");
        var responseData = json.decode(response.body);
        var membersData = responseData['data'];
        dataOfMembers = MyData.fromJson(membersData);
        notifyListeners();
      } else {
        log.d("get-list-members menu response statusCode unknown");
        log.d(response.statusCode);
        throw Exception("Failed to load members");
      }
    } else {
      log.d("get-list-members menu response userJson unknown");
      throw Exception("User data not found");
    }
  }


  Future<void> fetchDropdownData() async {
    // setLoading(true);
    // final prefs = await SharedPreferences.getInstance();
    // user = User.fromJson(json.decode(prefs.getString("user")!));

    // // Fetch positions
    // final positionsResponse =
    // await networkHandler.get('/get-list-positions/${user.businessId}');
    // if (positionsResponse.statusCode == 200 || positionsResponse.statusCode == 201) {
    //   final data = json.decode(positionsResponse.body)['data'];
    //   log.d("data positions  successfully ${data['positions']}");
    //   positions = data['positions'];
    // }
    //
    // // Fetch boards
    // final boardsResponse =
    // await networkHandler.get('/get-list-boards/${user.businessId}');
    // if (boardsResponse.statusCode == 200 || boardsResponse.statusCode == 201) {
    //   final data = json.decode(boardsResponse.body)['data'];
    //   log.d("data boards  successfully ${data['boards']}");
    //   boards = data['boards'];
    // }
    //
    // // Fetch committees
    // final committeesResponse =
    // await networkHandler.get('/get-list-committees-by-business-id/${user.businessId}');
    // if (committeesResponse.statusCode == 200 || committeesResponse.statusCode == 201) {
    //   final data = json.decode(committeesResponse.body)['data'];
    //   log.d("data committees  successfully ${data['committees']}");
    //   committees = data['committees'];
    // }

    // setLoading(false);
    // notifyListeners();
  }





  Future<void> fetchMyProfileWithRoles() async {
    // setLoading(true);
    final response = await networkHandler.get('/get-list-of-member-roles'); // your backend endpoint
    if (response.statusCode == 200) {
      var responseData = json.decode(response.body);
      var membersData = responseData['data'];
      _member = Member.fromJson(membersData['member']);
      print('-------------------------------------');
      print(membersData);
      setMember(_member);
    }
    setLoading(false);
  }


  Future getListOfPermissions(context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    user = User.fromJson(json.decode(prefs.getString("user")!));
    var response = await networkHandler.get('/get-list-of-roles');
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("get-list-of-roles response statusCode == 200");
      var responseData = json.decode(response.body);
      var membersData = responseData['data'];
      dataOfPermissions = Permissions.fromJson(membersData);
      assignedPermissions.clear();

      // Extract permission IDs from the permissions model
      if (dataOfPermissions!.permissions != null) {
        assignedPermissions = dataOfPermissions!.permissions!.map((permission) => permission.permissionId!).toList();
      }
      notifyListeners();
    } else {
      log.d("get-list-of-roles response statusCode unknown");
      log.d(response.statusCode);
      print(json.decode(response.body)['message']);
    }
  }


  Future getListOfRoles(context) async {
    if (_hasFetchedRoles) return;
    _hasFetchedRoles = true;
    var response = await networkHandler.get('/get-list-of-member-roles');
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("get-list-of-roles response statusCode == 200");
      var responseData = json.decode(response.body);
      var RolesData = responseData['data'];
      log.d(RolesData);
      dataOfRoles = Roles.fromJson(RolesData);
      assignedRoles.clear();

      // Extract permission IDs from the permissions model
      if (dataOfRoles!.roles != null) {
        assignedPermissions = dataOfRoles!.roles!.map((role) => role.roleId!).toList();
      }
      notifyListeners();
    } else {
      log.d("get-list-of-roles response statusCode unknown");
      log.d(response.statusCode);
      print(json.decode(response.body)['message']);
    }
  }

  void assignPermission(int permissionId, BuildContext context) {
    if (!assignedPermissions.contains(permissionId)) {
      assignedPermissions.add(permissionId);
      notifyListeners();
    }
  }

  void removePermission(int permissionId, BuildContext context) {
    // Add the permission removal logic here
    if (assignedPermissions.contains(permissionId)) {
      assignedPermissions.remove(permissionId);
      notifyListeners();
    }
  }



  Future<void> assignRoleToMember(int memberId, int roleId, BuildContext context) async {
    setLoading(true);
    notifyListeners();
    Map<String, dynamic> data = {"member_id": memberId, "role_id": roleId};
    var response = await networkHandler.post1('/assign-role-to-member', data);
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("assignRoleToMember response statusCode == 200");
      var responseData = json.decode(response.body);
      var membersData = responseData['data'];
      _role = RoleModel.fromJson(membersData);
      // Update local state (simulate role assignment)
      final member = dataOfMembers!.members!.firstWhere((m) => m.memberId == memberId);
      member.roles?.add(RoleModel(roleId: roleId, roleName: _role.roleName)); // Example role object
      setLoading(false);
      notifyListeners();
    } else {
      log.d("assignRoleToMember response statusCode unknown");
      log.d(response.statusCode);
      print(json.decode(response.body)['message']);
      setLoading(false);
      notifyListeners();
    }

  }

  Future<void> removeRoleFromMember(int memberId, int roleId, BuildContext context) async {
    setLoading(true);
    notifyListeners();
    Map<String, dynamic> data = {"member_id": memberId, "role_id": roleId};
    var response = await networkHandler.post1('/remove-role-to-member', data);
    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("removeRoleFromMember response statusCode == 200");
      var responseData = json.decode(response.body);
      var membersData = responseData['data'];
      _role = RoleModel.fromJson(membersData);
      final member = dataOfMembers!.members!.firstWhere((m) => m.memberId == memberId);
      member.roles?.removeWhere((role) => role.roleId == roleId);

      setLoading(false);
      notifyListeners();
    } else {
      log.d("removeRoleFromMember response statusCode unknown");
      log.d(response.statusCode);
      print(json.decode(response.body)['message']);
    }

  }

  // Maintain a map for tracking loading state for each member-role combination
  final Set<String> _loadingStates = {};

  // Fetch members and roles (replace with your actual implementation)
  Future<void> fetchInitialData(BuildContext context) async {
    try {
      await getListOfMember(context);
      await getListOfRoles(context);
      await getDataOfGroups();
    } catch (error) {
      // Handle errors here if needed
    }
  }

  // Check if a specific member-role combination is loading
  bool isLoadingForMemberRole(String memberId, String roleId) {
    return _loadingStates.contains('$memberId-$roleId');
  }

  // Set loading state for a specific member-role combination
  void setLoadingForMemberRole(String memberId, String roleId, bool isLoading) {
    final key = '$memberId-$roleId';
    if (isLoading) {
      _loadingStates.add(key);
    } else {
      _loadingStates.remove(key);
    }
    notifyListeners();
  }

  // Check if a specific member-role combination is loading
  bool isLoadingForGroupRole(String groupId, String roleId) {
    return _loadingStates.contains('$groupId-$roleId');
  }

  // Set loading state for a specific member-role combination
  void setLoadingForGroupRole(String groupId, String roleId, bool isLoading) {
    final key = '$groupId-$roleId';
    if (isLoading) {
      _loadingStates.add(key);
    } else {
      _loadingStates.remove(key);
    }
    notifyListeners();
  }

  Future<void> updateGroupRoles(int groupId, String groupType, int roleId, bool assign, BuildContext context) async {
    setLoadingForGroupRole(groupId.toString(), roleId.toString(), true);
    notifyListeners();

    try {
      Map<String, dynamic> data = {
        "group_id": groupId,
        "group_type": groupType,
        "role_id": roleId,
        "assign": assign
      };
      var response = await networkHandler.post1('/update-group-roles', data);
      if (response.statusCode == 200 || response.statusCode == 201) {
        print( assign ? "Role assigned to all members." : "Role removed from all members.");
      } else {
        print("Failed to update role.");
      }
    } catch (error) {
      print( "Something went wrong.");
    } finally {
      setLoadingForGroupRole(groupId.toString(), roleId.toString(), false);
      notifyListeners();
    }
  }

  Future<void> assignRoleToGroup(int groupId, int roleId,String groupType, BuildContext context) async {
    setLoading(true);
    notifyListeners();
    setLoadingForGroupRole(groupId.toString(), roleId.toString(), true);
    Map<String, dynamic> data = {"group_id": groupId, "role_id": roleId, "group_type": groupType};
    var response = await networkHandler.post1('/assign-role-to-group', data);

    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("Role assigned to group successfully");
      await getDataOfGroups(); // Refresh Data
    } else {
      log.d("Failed to assign role to group");
    }
    setLoadingForGroupRole(groupId.toString(), roleId.toString(), false);
    setLoading(false);
    notifyListeners();

  }

  Future<void> removeRoleFromGroup(int groupId, int roleId,String groupType, BuildContext context) async {
    setLoading(true);
    notifyListeners();
    setLoadingForGroupRole(groupId.toString(), roleId.toString(), true);
    Map<String, dynamic> data = {"group_id": groupId, "role_id": roleId, "group_type": groupType};
    var response = await networkHandler.post1('/remove-role-from-group', data);

    if (response.statusCode == 200 || response.statusCode == 201) {
      log.d("Role removed from group successfully");
      await getDataOfGroups(); // Refresh Data
    } else {
      log.d("Failed to remove role from group");
    }
    setLoadingForGroupRole(groupId.toString(), roleId.toString(), false);
    setLoading(false);
    notifyListeners();
  }

}
