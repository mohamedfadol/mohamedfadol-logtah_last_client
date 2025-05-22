import 'package:diligov_members/models/agenda_model.dart';
import 'package:diligov_members/utility/pdf_api.dart';
import 'package:flutter/material.dart';

import '../../../core/domains/app_uri.dart';
import '../../../models/audio_annotation_model.dart';
import '../../../src/render_file_manager.dart';
import '../../../src/text_annotation.dart';
import '../../../widgets/custome_text.dart';

class NotesExpansionPanel extends StatefulWidget {
  final Agenda? agenda;
  const NotesExpansionPanel({super.key, this.agenda});

  @override
  State<NotesExpansionPanel> createState() => _NotesExpansionPanelState();
}

class _NotesExpansionPanelState extends State<NotesExpansionPanel> with SingleTickerProviderStateMixin{
  TabController? defaultTabBarViewController;
  String? localPath;
  int tabIndex = 0;

  @override
  void initState() {
    // TODO: implement initState
    defaultTabBarViewController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    defaultTabBarViewController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 50,
          width: 400,
          child: TabBar(
            onTap: (index) {
              setState(() {
                tabIndex = index;
              });
              print(index);
            },
            enableFeedback: true,
            controller: defaultTabBarViewController,
            dividerColor: Colors.grey,
            indicatorColor: Colors.red,
            labelColor: Colors.red,
            unselectedLabelColor: Colors.grey,
            labelStyle: TextStyle(fontWeight: FontWeight.bold,fontSize: 16,color: Colors.red),
            tabs: [
              Tab(child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                // mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.text_fields_rounded),
                  CustomText(text:"Text Notes"),
                ],
              )),
              Tab(child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Icon(Icons.record_voice_over),
                  CustomText(text:"Voice Notes"),
                ],
              )),
            ],
          ),
        ),
        SizedBox(
          width: 400,
          height: 200,
          child: TabBarView(
            controller: defaultTabBarViewController,
            children: [
              SizedBox(
                height: 300,
                child: ListView.separated(
                  itemCount: widget.agenda!.notes!.length,
                  itemBuilder: (BuildContext context, int index){
                    final TextAnnotation note = widget.agenda!.notes![index];
                    return Container(
                      color: note.isClicked ? Colors.red[100] :  Colors.blueGrey[50],
                      child: ListTile(
                        key: UniqueKey(),
                        onTap: () async {
                          setState(() {
                            widget.agenda!.isClicked = !widget.agenda!.isClicked!;
                            final baseUri = '${AppUri.baseUntilPublicDirectory}/meetings';
                            String? output = widget.agenda!.agendaFileOneName?[0].replaceAll('[', '').replaceAll(']', '');
                            localPath =  '${baseUri}/${output.toString()}' ?? '';
                          });
                          try {
                            if(await PDFApi.requestPermission()){
                              print('agenda full path == $localPath');
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => RenderFileManager(path: localPath!,agenda: widget.agenda!)),
                              );
                            } else {
                              print("Lacking permissions to access the file in preparePdfFileFromNetwork function");
                              return;
                            }
                          } catch (e) { print("Error preparePdfFileFromNetwork function PDF: $e"); }

                        },
                        contentPadding: EdgeInsets.only(left: 30.0, right: 15.0),
                        leading: Icon(Icons.note_alt_outlined),
                        title: CustomText(text: note.text ?? 'no file attached'),
                        subtitle: CustomText(text: 'add by  ${note.user?.firstName} ${note.user?.lastName}' ?? ''),
                      ),
                    );
                  },
                  separatorBuilder: (BuildContext, int) => buildStaticDividerSizeBox(Colors.white24),

                ),
              ),
              SizedBox(
                height: 300,
                child: ListView.separated(
                  itemCount: widget.agenda!.audioNotes!.length,
                  itemBuilder: (BuildContext context, int index){
                    final AudioAnnotationModel audio = widget.agenda!.audioNotes![index];
                    return Container(
                      color: audio.isClicked ? Colors.red[100] :  Colors.blueGrey[50],
                      child: ListTile(
                        key: UniqueKey(),
                        onTap: () async {
                          setState(() {
                            widget.agenda!.isClicked = !widget.agenda!.isClicked!;
                            final baseUri = '${AppUri.baseUntilPublicDirectory}';
                            localPath =  '${baseUri}/${widget.agenda!.agendaFileFullPath.toString()}' ?? '';
                          });
                          try {
                            if(await PDFApi.requestPermission()){
                              print('agenda full path == $localPath');
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => RenderFileManager(path: localPath!,agenda: widget.agenda!)),
                              );
                            } else {
                              print("Lacking permissions to access the file in preparePdfFileFromNetwork function");
                              return;
                            }
                          } catch (e) { print("Error preparePdfFileFromNetwork function PDF: $e"); }

                        },
                        contentPadding: EdgeInsets.only(left: 30.0, right: 15.0),
                        leading: Icon(Icons.note_alt_outlined),
                        title: CustomText(text: audio.audioNoteName ?? 'no file attached'),
                        subtitle: CustomText(text: 'add by  ${audio.user?.firstName} ${audio.user?.lastName}' ?? ''),
                      ),
                    );
                  },
                  separatorBuilder: (BuildContext, int) => buildStaticDividerSizeBox(Colors.white24),

                ),
              )
            ] ,
          ),
        ),
      ],
    );
  }

  Widget buildStaticDividerSizeBox(Color dividerColor) {
    return new SizedBox(
      height: 2.0,
      width: 400,
      child: new Container(
        margin: new EdgeInsetsDirectional.only(start: 50.0, end: 1.0),
        height: 2.0,
        color: dividerColor,
      ),
    );
  }
}
