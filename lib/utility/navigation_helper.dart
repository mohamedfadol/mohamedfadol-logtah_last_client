import 'package:flutter/material.dart';

class NavigationHelper {
  static void navigateWithCommitteeId({
    required BuildContext context,
    required String routeName,
    required String committeeId,
    bool replace = false,
  }) {
    final args = {'committeeId': committeeId};

    if (replace) {
      Navigator.pushReplacementNamed(context, routeName, arguments: args);
    } else {
      Navigator.pushNamed(context, routeName, arguments: args);
    }
  }
}
