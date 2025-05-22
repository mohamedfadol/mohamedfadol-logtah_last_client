import 'package:diligov_members/models/member.dart';
import 'package:diligov_members/widgets/custome_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/member_page_provider.dart';
import '../widgets/appBar.dart';
import '../widgets/custom_message.dart';
import '../widgets/loading_sniper.dart';

class PermissionsListView extends StatelessWidget {
  final Member member;
  const PermissionsListView({super.key, required this.member});
  static const routeName = '/PermissionsListView';


  buildEmptyMessage(String message) {
    return CustomMessage(
      text: message,
    );
  }

  buildLoadingSniper() {
    return const LoadingSniper();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(context),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: Consumer<MemberPageProvider>(
          builder: (context, provider, child) {
            if (provider.dataOfPermissions?.permissions == null) {
              context.read<MemberPageProvider>().getListOfPermissions(context);
              return buildLoadingSniper();
            }

            if (provider.dataOfPermissions!.permissions!.isEmpty) {
              return buildEmptyMessage("no_data_to_show");
            }

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: provider.dataOfPermissions!.permissions!.map((permission) {
                  return GestureDetector(
                    onTap: () {
                      // Toggle permission on text click
                      if (provider.assignedPermissions.contains(permission.permissionId!)) {
                        provider.removePermission(permission.permissionId!, context);
                      } else {
                        provider.assignPermission(permission.permissionId!, context);
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blue, width: 1.5),
                        borderRadius: BorderRadius.circular(8),
                        color: provider.assignedPermissions.contains(permission.permissionId!)
                            ? Colors.blue.withOpacity(0.2)
                            : Colors.white,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                      CustomText(text:'namedkcendsc'),
                          Checkbox(
                            value: provider.assignedPermissions.contains(permission.permissionId!),
                            onChanged: (bool? value) {
                              if (value == true) {
                                provider.assignPermission(permission.permissionId!, context);
                              } else {
                                provider.removePermission(permission.permissionId!, context);
                              }
                            },
                          ),
                          SizedBox(width: 8),
                          CustomText(text:
                            permission.permissionName!,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: provider.assignedPermissions.contains(permission.permissionId!)
                                ? Colors.blue
                                : Colors.black,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            );
          },
        ),
      ),
    );

  }
}
