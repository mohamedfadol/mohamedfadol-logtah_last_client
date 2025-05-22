class PermissionsService {
  static final PermissionsService _instance = PermissionsService._internal();
  factory PermissionsService() => _instance;
  PermissionsService._internal();

  List<String> _permissions = [];

  void setPermissions(List<String> permissions) {
    _permissions = permissions;
  }

  bool hasPermission(String permission) {
    return _permissions.contains(permission);
  }
}


// Future<void> fetchPermissions(String token) async {
//   final response = await http.get(
//     Uri.parse('https://your-api.com/user/permissions'),
//     headers: {'Authorization': 'Bearer $token'},
//   );
//   if (response.statusCode == 200) {
//     final permissions = jsonDecode(response.body)['permissions'];
//     PermissionsService().setPermissions(List<String>.from(permissions));
//   }
// }


// Widget build(BuildContext context) {
//   final permissions = PermissionsService();
//
//   return Column(
//     children: [
//       if (permissions.hasPermission('view file'))
//         ElevatedButton(
//           onPressed: () => print('View File'),
//           child: Text('View'),
//         ),
//       if (permissions.hasPermission('print file'))
//         ElevatedButton(
//           onPressed: () => print('Print File'),
//           child: Text('Print'),
//         ),
//       if (permissions.hasPermission('edit file'))
//         ElevatedButton(
//           onPressed: () => print('Edit File'),
//           child: Text('Edit'),
//         ),
//       if (permissions.hasPermission('sign file'))
//         ElevatedButton(
//           onPressed: () => print('Sign File'),
//           child: Text('Sign'),
//         ),
//     ],
//   );
// }


// void performAction(String permission, Function action) {
//   if (PermissionsService().hasPermission(permission)) {
//     action();
//   } else {
//     print('Permission denied');
//   }
// }
