import 'package:diligov_members/providers/agenda_page_provider.dart';
import 'package:flutter/material.dart';

import '../../colors.dart';
import '../../models/agenda_model.dart';
import '../../models/detail_details_model.dart';
import '../custom_icon.dart';
import '../custome_text.dart';
import '../reusable_quillEditor_widget.dart';

class EnglishGenerateFormWidget extends StatefulWidget {
  final AgendaPageProvider provider;
  final TabController tabController;
  final Agenda agenda;

  const EnglishGenerateFormWidget({Key? key, required this.provider, required this.agenda, required this.tabController}) : super(key: key);

  @override
  _EnglishGenerateFormWidgetState createState() => _EnglishGenerateFormWidgetState();
}

class _EnglishGenerateFormWidgetState extends State<EnglishGenerateFormWidget> with SingleTickerProviderStateMixin {
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
    final List<DetailDetails> resolutions = agenda.details?.detailDetails
        ?.where((detail) => detail.serialNumberResolutionEn != null)
        .toList() ??
        [];
    final List<DetailDetails> directions = agenda.details?.detailDetails
        ?.where((detail) => detail.serialNumberDirectionEn != null)
        .toList() ??
        [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 50,
          width: 230,
          child: TabBar(
            controller: widget.tabController,
            indicatorColor: Colors.red,
            labelColor: Colors.red,
            unselectedLabelColor: Colors.grey,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            tabs: const [
              Tab(child: Text("Resolution")),
              Tab(child: Text("Directions")),
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
                        onPressed: () => provider.addResolution(agenda),
                        child: CustomText(text: 'Add Resolution', color: Colors.white),
                      ),
                    ),
                    resolutions.isNotEmpty
                        ? Container(
                      // width: MediaQuery.of(context).size.width * 0.45,
                      constraints: BoxConstraints(
                        maxHeight: 350, // Set max height to make it scrollable
                      ),
                      child: ListView.builder(
                        itemCount: resolutions.length,
                        shrinkWrap: true, // Ensures ListView doesn't take full height
                        physics: ClampingScrollPhysics(), // Prevents internal scrolling
                        itemBuilder: (context, index) {
                          final resolution = resolutions[index];
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CustomText(
                                text: resolution.serialNumberResolutionEn ?? '',
                                fontWeight: FontWeight.bold,
                                fontSize: 20.0,
                                color: Colors.red,
                              ),
                              const SizedBox(height: 5.0),

                              ReusableQuillEditorWidget(
                                controller: provider.getOrCreateQuillController(provider.englishResolutionControllerss,resolution.detailId!,resolution.textDirectionEn),
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
                                onPressed: () => provider.removeResolution(agenda, resolution.detailId!),
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
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                        onPressed: () => provider.addDirection(agenda),
                        child: CustomText(text: 'Add Direction'),
                      ),
                    ),
                    directions.isNotEmpty
                        ? Container(
                      // width: MediaQuery.of(context).size.width * 0.45,
                      constraints: BoxConstraints(
                        maxHeight: 350, // Set max height to make it scrollable
                      ),
                      child: ListView.builder(
                        itemCount: directions.length,
                        shrinkWrap: true, // Ensures ListView doesn't take full height
                        physics: ClampingScrollPhysics(), // Prevents internal scrolling
                        itemBuilder: (context, index) {
                          final direction = directions[index];
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CustomText(
                                text: direction.serialNumberDirectionEn ?? '',
                                fontWeight: FontWeight.bold,
                                fontSize: 20.0,
                                color: Colors.orange,
                              ),
                              const SizedBox(height: 5.0),
                              ReusableQuillEditorWidget(
                                controller: provider.getOrCreateQuillController(
                                    provider.englishDirectionControllerss,
                                    direction.detailId!,
                                    direction.textDirectionEn),
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
                                onPressed: () => provider.removeDirection(agenda, direction.detailId!),
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
