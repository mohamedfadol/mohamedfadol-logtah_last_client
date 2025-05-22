import 'package:diligov_members/providers/laboratory_file_processing_provider_page.dart';
import 'package:diligov_members/widgets/custom_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/member_page_provider.dart';
import '../providers/orientation_page_provider.dart';
class LaboratoryFileProcessingAppBarButtons extends StatelessWidget {
  const LaboratoryFileProcessingAppBarButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LaboratoryFileProcessingProviderPage>(
      builder: (context, laboratoryFileProcessingProvider, child){
        return Container(
          decoration: const BoxDecoration(
              border: Border.symmetric(
                  horizontal: BorderSide(width: 1.0, color: Colors.grey,),
                  vertical: BorderSide(width: 1.0, color: Colors.grey,)
              )
          ),
          padding: const EdgeInsets.symmetric(horizontal: 5.0, ),
          // color: Colors.grey,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                style: OutlinedButton.styleFrom(
                  shape: BeveledRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.blueAccent)
                  ),
                  minimumSize: Size(30, 30),
                ),
                onPressed: () {laboratoryFileProcessingProvider.addCanvasStrokes();},
                child: Icon(
                  Icons.edit_note,
                  size: 20.0,
                  color: laboratoryFileProcessingProvider.selectedColor,
                ),
              ),

              ElevatedButton(
                style: OutlinedButton.styleFrom(
                  shape: BeveledRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.blueAccent)
                  ),
                  minimumSize: Size(30, 30),
                ),
                onPressed: () {laboratoryFileProcessingProvider.addCanvasAudios();},
                child: Icon(
                  Icons.mic,
                  size: 20.0,
                  color: laboratoryFileProcessingProvider.selectedColor,
                ),
              ),

              ElevatedButton(
                style: OutlinedButton.styleFrom(
                  shape: BeveledRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.blueAccent)
                  ),
                  minimumSize: Size(30, 30),
                ),
                onPressed: (){
                  laboratoryFileProcessingProvider.toggleTextInput();
                },
                child: Icon(
                  Icons.text_fields,
                  size: 20.0,
                  color: laboratoryFileProcessingProvider.selectedColor,
                ),
              ),

              ElevatedButton(
                style: OutlinedButton.styleFrom(
                  shape: BeveledRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.blueAccent),
                  ),
                  minimumSize: Size(30, 30),
                ),
                onPressed: () => showPenSettingsDialog(context),
                child: Icon(
                  Icons.color_lens,
                  size: 20.0,
                  color: laboratoryFileProcessingProvider.selectedColor,
                ),
              ),

              ElevatedButton(
                style: OutlinedButton.styleFrom(
                  shape: BeveledRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.blueAccent)
                  ),
                  minimumSize: Size(30, 30),
                ),
                onPressed: () async{
                  laboratoryFileProcessingProvider.toggleShowUsers();
                  final userProvider = Provider.of<MemberPageProvider>(context, listen: false);
                  await  userProvider.getListOfMemberMenu();
                },
                child: Icon(
                  Icons.person,
                  size: 20.0,
                  color: laboratoryFileProcessingProvider.selectedColor,
                ),
              ),

              Consumer<OrientationPageProvider>(
                builder: (context, orientationProvider, child) {
                  return ElevatedButton(
                    onPressed: orientationProvider.toggleOrientation,
                    child: Icon(Icons.screen_rotation_outlined),
                  );
                },
              ),
            ],
          ),
        );
    },

    );
  }


  void showPenSettingsDialog(BuildContext context) {
    // Temporary variables to hold the slider value and selected color locally
    final provider = Provider.of<LaboratoryFileProcessingProviderPage>(context, listen: false);

    double tempPenWidth = provider.currentPenWidth;
    Color tempSelectedColor = provider.selectedColor;
    double tempFontSize = provider.currentFontSize;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Adjust Pen Settings'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                // Pen Width Slider
                StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                    return CustomSlider(
                      min: 2.0,
                      max: 36.0,
                      divisions: 26,
                      value: tempFontSize,
                      label: tempFontSize.round().toString(),
                      onChanged: (double value) {
                        // tempPenWidth = value;
                        // tempFontSize = value;
                        provider.setCurrentFontSize(value);
                        setState(() {
                          tempPenWidth = value;
                          tempFontSize = value;
                        });
                      },
                    );
                  },
                ),
                // Color Picker
                StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                    // Build color picker as a row of color choices
                    List<Color> colors = [Colors.black, Colors.red, Colors.green, Colors.blue, Colors.yellow]; // Add more colors as needed
                    return Wrap(
                      spacing: 8.0, // Spacing between each color circle
                      children: colors.map((color) => GestureDetector(
                        onTap: () {
                          // provider.setCurrentFontSize(tempFontSize);
                          provider.setSelectedColor(color);
                          setState(() {
                            tempSelectedColor = color;
                          });
                        },
                        child: CircleAvatar(
                          backgroundColor: color,
                          child: tempSelectedColor == color ? const Icon(Icons.check, color: Colors.white) : null,
                        ),
                      )).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog without saving changes
              },
            ),
            TextButton(
              child: const Text('Done'),
              onPressed: () {
                provider.setCurrentPenWidth(tempPenWidth);
                provider.setCurrentFontSize(tempFontSize);
                provider.setSelectedColor(tempSelectedColor);
                Navigator.of(context).pop(); // Close the dialog and save changes
              },
            ),
          ],
        );
      },
    );
  }
}
