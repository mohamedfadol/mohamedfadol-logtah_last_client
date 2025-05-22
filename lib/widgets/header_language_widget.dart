import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../colors.dart';
import '../providers/meeting_page_provider.dart';
import 'custome_text.dart';

class LanguageWidget extends StatelessWidget {
  const LanguageWidget({
    super.key,
    required this.enableEnglish,
    required this.enableArabicAndEnglish,
    required this.enableArabic,
  });

  final bool enableEnglish;
  final bool enableArabicAndEnglish;
  final bool enableArabic;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: enableEnglish == true ? Colour().buttonBackGroundMainColor : Colour().buttonBackGroundRedColor,
          ),
          onPressed: () { context.read<MeetingPageProvider>().toggleEnableEnglish(); },
          child: CustomText(text: "English Only", color: Colors.white,),
        ),
        SizedBox(width: 15.0),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: enableArabicAndEnglish == true ? Colour().buttonBackGroundMainColor : Colour().buttonBackGroundRedColor,
          ),
          onPressed: () {
            context.read<MeetingPageProvider>().toggleEnableArabicAndEnglish();
          },
          child: CustomText(text: "Dual", color: Colors.white,),
        ),
        SizedBox(width: 15.0),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: enableArabic == true ? Colour().buttonBackGroundMainColor : Colour().buttonBackGroundRedColor,
          ),
          onPressed: () {
            context.read<MeetingPageProvider>().toggleEnableArabic();
          },
          child: CustomText(text: "Arabic Only", color: Colors.white,),
        ),
      ],
    );
  }
}
// end class

