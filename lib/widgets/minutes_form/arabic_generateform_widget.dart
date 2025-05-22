import 'package:diligov_members/providers/agenda_page_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../colors.dart';
import '../../models/agenda_model.dart';
import '../../models/detail_details_model.dart';
import '../custom_icon.dart';
import '../custome_text.dart';
import '../reusable_quillEditor_widget.dart';

class ArabicGenerateFormWidget extends StatefulWidget {
  final AgendaPageProvider provider;
  final Agenda agenda;
  final TabController tabController; // Add TabController parameter

  const ArabicGenerateFormWidget({Key? key, required this.provider, required this.agenda, required this.tabController}) : super(key: key);

  @override
  _ArabicGenerateFormWidgetState createState() => _ArabicGenerateFormWidgetState();
}

class _ArabicGenerateFormWidgetState extends State<ArabicGenerateFormWidget> with SingleTickerProviderStateMixin {
  // late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Initialize TabController with the number of tabs
    // _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    // Dispose TabController to avoid memory leaks
    // _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = widget.provider;
    final agenda = widget.agenda;

    // Filter resolutions and directions separately
    final List<DetailDetails> arabicResolutions = agenda.details?.detailDetails
        ?.where((detail) => detail.serialNumberResolutionAr != null)
        .toList() ??
        [];
    final List<DetailDetails> arabicDirections = agenda.details?.detailDetails
        ?.where((detail) => detail.serialNumberDirectionAr != null)
        .toList() ??
        [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SizedBox(
          height: 50,
          width: 200,
          child: TabBar(
            controller: widget.tabController,
            indicatorColor: Colors.red,
            labelColor: Colors.red,
            unselectedLabelColor: Colors.grey,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            tabs: const [
              Tab(child: Text("القرارات")),
              Tab(child: Text("التوجيهات")),
            ],
          ),
        ),
        SizedBox(
          height: 400, // Set the height of TabBarView content
          child: TabBarView(
            controller: widget.tabController,
            children: [
              // Tab 1: Boards
              SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        onPressed: () => provider.addArResolution(agenda), // Pass the specific agenda
                        child: CustomText(text: 'اضافة قرار', color: Colors.white,),
                      ),
                    ),
                    arabicResolutions.isNotEmpty
                        ? Container(
                      // width: MediaQuery.of(context).size.width * 0.45,
                      constraints: BoxConstraints(
                        maxHeight: 350, // Set max height to make it scrollable
                      ),
                      child: ListView.builder(
                        itemCount: arabicResolutions.length,
                        shrinkWrap: true, // Ensures ListView doesn't take full height
                        physics: ClampingScrollPhysics(), // Prevents internal scrolling
                        itemBuilder: (context, index) {
                          final resolution = arabicResolutions[index];
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CustomText(
                                text: resolution.serialNumberResolutionAr ?? '',
                                fontWeight: FontWeight.bold,
                                fontSize: 20.0,
                                color: Colors.red,
                              ),
                              const SizedBox(height: 5.0),

                              ReusableQuillEditorWidget(
                                controller: provider.getOrCreateQuillController(provider.arabicResolutionControllerss,resolution.detailId!,resolution.textDirectionAr),
                                height: 250,
                                toolbarAxis: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                                backgroundColor: Colors.grey[50],
                                borderColor: Colour().buttonBackGroundRedColor,
                                showListNumbers: true,
                                showBoldButton: true,
                                showListBullets: true,
                              ),
                              IconButton(
                                icon: CustomIcon(icon: Icons.remove_circle),
                                onPressed: () => provider.removeArabicResolution(agenda, resolution.detailId!),
                              ),
                            ],
                          );
                        },
                      ),
                    )
                        : SizedBox.shrink(),
                  ],
                ),
              ),

              // Tab 2: Committees
              SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                        onPressed: () => provider.addArDirection(agenda), // Pass the specific agenda
                        child: CustomText(text: 'اضافة توجيه'),
                      ),
                    ),
                    arabicDirections.isNotEmpty
                        ? Container(
                      // width: MediaQuery.of(context).size.width * 0.45,
                      constraints: BoxConstraints(
                        maxHeight: 350, // Set max height to make it scrollable
                      ),
                      child: ListView.builder(
                        itemCount: arabicDirections.length,
                        shrinkWrap: true, // Ensures ListView doesn't take full height
                        physics: ClampingScrollPhysics(), // Prevents internal scrolling
                        itemBuilder: (context, index) {
                          final direction = arabicDirections[index];
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CustomText(
                                text: direction.serialNumberDirectionAr ?? '',
                                fontWeight: FontWeight.bold,
                                fontSize: 20.0,
                                color: Colors.orange,
                              ),
                              const SizedBox(height: 5.0),
                              ReusableQuillEditorWidget(
                                controller: provider.getOrCreateQuillController(
                                    provider.arabicDirectionControllerss,
                                    direction.detailId!,
                                    direction.textDirectionAr),
                                height: 250,
                                toolbarAxis: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                                backgroundColor: Colors.grey[50],
                                borderColor: Colour().buttonBackGroundRedColor,
                                showListNumbers: true,
                                showBoldButton: true,
                                showListBullets: true,
                              ),
                              IconButton(
                                icon: CustomIcon(icon: Icons.remove_circle),
                                onPressed: () => provider.removeArabicDirection(agenda, direction.detailId!),
                              ),
                            ],
                          );
                        },
                      ),
                    )
                        : SizedBox.shrink(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
