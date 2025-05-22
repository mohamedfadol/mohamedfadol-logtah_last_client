import 'package:diligov_members/providers/member_page_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:multi_select_flutter/chip_display/multi_select_chip_display.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localization.dart';
import '../../models/member.dart';
import '../../providers/laboratory_file_processing_provider_page.dart';
import '../../widgets/custom_icon.dart';
import '../../widgets/custom_message.dart';
import '../../widgets/custom_slider.dart';
import '../../widgets/custome_text.dart';
import '../../widgets/loading_sniper.dart';
import '../canvas_item.dart';
import '../drawing_painter.dart';

class DraggableCanvas extends StatefulWidget {
  final CanvasItem item;
  final Function(Offset) onPositionChange;
  final VoidCallback onDelete;
  final int canvasPageIndex;

  const DraggableCanvas(
      {Key? key,
      required this.item,
      required this.onPositionChange,
      required this.onDelete,
      required this.canvasPageIndex})
      : super(key: key);

  @override
  _DraggableCanvasState createState() => _DraggableCanvasState();
}

class _DraggableCanvasState extends State<DraggableCanvas> {
  GlobalKey _key = GlobalKey();

  // bool _isDrawing = true; // Initially, we're not drawing
  // Size? _canvasSize; // To hold the canvas size for dynamic bounds checking
  List _membersListIds = []; // To hold the _members List Ids for sharing notes
  //
  // bool _isInsideBounds(Offset position) {
  //   final canvasSize = provider.canvasSize;
  //   if (_canvasSize == null) return false;
  //   return position.dx >= 0 &&
  //       position.dx <= _canvasSize!.width &&
  //       position.dy >= 0 &&
  //       position.dy <= _canvasSize!.height;
  // }

  bool _isInsideBounds(Offset position) {
    final provider = Provider.of<LaboratoryFileProcessingProviderPage>(context, listen: false);
    final canvasSize = provider.canvasSize;

    if (canvasSize == null) return false; // Ensure canvasSize is available

    return position.dx >= 0 &&
        position.dx <= canvasSize.width &&
        position.dy >= 0 &&
        position.dy <= canvasSize.height;
  }


  // void _clearStrokes2() {
  //   if (widget.item.strokes!.isNotEmpty) {
  //     setState(() {
  //       widget.item.clearStrokes();
  //     });
  //   }
  // }

  void _clearStrokes() {
    Provider.of<LaboratoryFileProcessingProviderPage>(context, listen: false).clearStrokes(widget.item.id!);
  }


  void _deleteCanvas() {
    widget.onDelete();
  }

  // void _toggleDrawingMode() {
  //   setState(() {
  //     _isDrawing = !_isDrawing;
  //   });
  // }

  // void _toggleDraggable() {
  //   setState(() {
  //     widget.item.isDraggable = !widget.item!.isDraggable!;
  //   });
  // }

  void _undoLastStroke() {
    Provider.of<LaboratoryFileProcessingProviderPage>(context, listen: false).undoLastStroke(widget.item.id!);
  }


  // @override
  // void _onPanStart2(DragStartDetails details) {
  //    Offset localPosition = details.localPosition;
  //   // Decrease localPosition y by 60 to shift the drawing point up
  //   Offset adjustedPosition = localPosition.translate(-0, -50);
  //   if (!_isInsideBounds(adjustedPosition)) {
  //     return;
  //   }
  //   setState(() {
  //     final newStroke = Stroke(
  //       canvasId: Provider.of<LaboratoryFileProcessingProviderPage>(context, listen: false).generateCanvasStrokesId(),
  //       points: [adjustedPosition],
  //       pageIndex: widget.item.pageIndex!,
  //       position: adjustedPosition,
  //       strokeColor: Provider.of<LaboratoryFileProcessingProviderPage>(context, listen: false).selectedColor,
  //       strokeWidth: Provider.of<LaboratoryFileProcessingProviderPage>(context, listen: false).currentPenWidth,
  //     );
  //     widget.item.strokes!.add(newStroke);
  //     Provider.of<LaboratoryFileProcessingProviderPage>(context, listen: false).addStrokeToCanvasItem(widget.item.id!, newStroke);
  //   });
  // }

  @override
  void _onPanStart(DragStartDetails details, CanvasItem item) {
    final provider = Provider.of<LaboratoryFileProcessingProviderPage>(context, listen: false);
    final Offset localPosition = details.localPosition;
    final Offset adjustedPosition = localPosition.translate(0, -30);

    if (!_isInsideBounds(adjustedPosition)) return;

    provider.handlePanStart(
      widget.item.id!,
      adjustedPosition,
      selectedColor: provider.selectedColor,
      penWidth: provider.currentPenWidth,
      pageIndex: widget.item.pageIndex!,
    );
  }



  @override
  void _onPanUpdate(DragUpdateDetails details, CanvasItem item) {
    final provider = Provider.of<LaboratoryFileProcessingProviderPage>(context, listen: false);
    final Offset localPosition = details.localPosition;
    final Offset adjustedPosition = localPosition.translate(0, -30);

    if (!_isInsideBounds(adjustedPosition)) return;

    provider.handlePanUpdate(
      widget.item.id!,
      adjustedPosition,
      selectedColor: provider.selectedColor,
      penWidth: provider.currentPenWidth,
      pageIndex: widget.item.pageIndex!,
    );
  }



  // void _onPanUpdate2(DragUpdateDetails details) {
  //    Offset localPosition = details.localPosition;
  //   // Decrease localPosition y by 60 to shift the drawing point up
  //   Offset adjustedPosition = localPosition.translate(-0, -50);
  //   if (!_isInsideBounds(adjustedPosition)) return;
  //   setState(() {
  //     // print(' widget.item.id, widget.item.id, widget.item.id, ${widget.item.id}');
  //     final List<Offset> points = widget.item.strokes!.last.points;
  //     points.add(adjustedPosition);
  //     Stroke newStroke = Stroke(
  //       canvasId: Provider.of<LaboratoryFileProcessingProviderPage>(context, listen: false).generateCanvasStrokesId(),
  //       points: points,
  //       pageIndex: widget.item.pageIndex!,
  //       position: adjustedPosition,
  //       strokeColor: Provider.of<LaboratoryFileProcessingProviderPage>(context, listen: false).selectedColor,
  //       strokeWidth: Provider.of<LaboratoryFileProcessingProviderPage>(context, listen: false).currentPenWidth,
  //     );
  //     // Add the stroke to the CanvasItem
  //     Provider.of<LaboratoryFileProcessingProviderPage>(context, listen: false).addStrokeToCanvasItem(widget.item.id!, newStroke);
  //
  //   });
  // }

  @override
  void _onPanEnd(DragEndDetails details) {

  }

  // void _getWidgetSize() {
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     final RenderBox? renderBox = _key.currentContext?.findRenderObject() as RenderBox?;
  //     if (renderBox != null) {
  //       setState(() {
  //         _canvasSize = renderBox.size;
  //       });
  //     }
  //   });
  // }

  void _getWidgetSize(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_key.currentContext != null) {
        final renderBox = _key.currentContext!.findRenderObject() as RenderBox?;
        if (renderBox != null) {
          final size = renderBox.size;

          // Update the size in the provider
          Provider.of<LaboratoryFileProcessingProviderPage>(context, listen: false).updateCanvasSize(size);
        }
      }
    });
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // _getWidgetSize();
      _getWidgetSize(context); // Get the size here
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LaboratoryFileProcessingProviderPage>(
        builder: (BuildContext context, provider, child){
          final item = provider.getCanvasItemById(widget.item.id!);
          return Stack(
            children: [
              (item.isDraggable ?? false)
                  ? _buildDraggableCanvas(provider, item)
                  : _buildStaticCanvas(provider, item),
            ],
          );
        }
    );
  }

  Widget _buildStaticCanvas(LaboratoryFileProcessingProviderPage provider, item) {
    return Positioned(
      left: widget.item.position!.dx,
      top: widget.item.position!.dy,
      child: _buildCanvas(provider, item),
    );
  }

  Widget _buildDraggableCanvas(LaboratoryFileProcessingProviderPage provider, item) {
    return (widget.item.isDraggable ?? false)
        ? Positioned(
      left: widget.item.position!.dx,
      top: widget.item.position!.dy,
      child: Draggable(
        data: widget.item,
        feedback: Material(
          child: LayoutBuilder(
              builder: (context, constraints) {
                print("Max width: ${item.canvasWidth}, Max height: ${item.canvasHeight}");
              return Container(
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                // width: item.canvasWidth * 10,
                // height: item.canvasHeight * 10,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _buildCanvas(provider, item),
              );
            }
          ),
          elevation: 4.0,
        ),

        childWhenDragging: Container(
          width: item.canvasWidth ?? 200.0,
          height: item.canvasHeight ?? 200.0,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.85),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onDragEnd: (details) {
          var newOffset = details.offset;
          final _canvasSize = provider.canvasSize;
          if (_canvasSize != null) {
            // double maxX = _canvasSize!.width - item.canvasWidth!;
            // double maxY = _canvasSize!.height - item.canvasHeight!;
            double maxX = _canvasSize.width - (item.canvasWidth ?? 0);
            double maxY = _canvasSize.height - (item.canvasHeight ?? 0);

            newOffset = Offset(
                newOffset.dx.clamp(0, maxX),
                newOffset.dy.clamp(0, maxY)
            );
          }
          widget.onPositionChange(newOffset);
        },
        child: Listener(
          onPointerDown: (_) => provider.toggleDrawing,
          onPointerUp: (_) => provider.toggleDrawing,
          onPointerMove: (_) => provider.toggleDrawing,
          child: _buildCanvas(provider, item),
        ),
      ),
    ): _buildCanvas(provider, item);
  }

  Widget _buildCanvas(LaboratoryFileProcessingProviderPage provider, CanvasItem item) {
    return LayoutBuilder(builder: (context, constraints) {
      // print("Max width: ${constraints.maxWidth}, Max height: ${constraints.maxHeight}");
      // _canvasSize = Size(constraints.maxWidth, constraints.maxHeight);

      // if (constraints.hasBoundedWidth && constraints.hasBoundedHeight) {
      //   // _canvasSize = Size(constraints.maxWidth, constraints.maxHeight);
      //   final canvasSize = provider.canvasSize;
      // }

      return GestureDetector(
        key: _key,
        // onPanStart: provider.isDrawingMode ? _onPanStart : null,
        // onPanUpdate: provider.isDrawingMode ? _onPanUpdate : null,
        onPanStart: provider.isDrawingMode ? (details) => _onPanStart(details, item) : null,
        onPanUpdate: provider.isDrawingMode ? (details) => _onPanUpdate(details, item) : null,
        onPanEnd: provider.isDrawingMode ? _onPanEnd : null,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Consumer<LaboratoryFileProcessingProviderPage>(
                builder: (BuildContext context, provider, child){
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomIconButton(
                        onPressed: () {
                          provider.toggleDraggable(item.id!);
                        },
                        icon: (item.isDraggable ?? false) ? Icons.lock_open : Icons.lock,
                      ),
                      CustomIconButton(
                        onPressed: _undoLastStroke,
                        icon: Icons.undo,
                      ),
                      CustomIconButton(
                        onPressed: _clearStrokes,
                        icon: Icons.delete,
                        iconColor: Colors.red,
                      ),
                      CustomIconButton(
                        onPressed: _deleteCanvas,
                        icon: Icons.remove_circle_outline,
                        iconColor: Colors.red,
                      ),
                      _selectMenu()
                    ],
                  );
                }
            ),
            Consumer<LaboratoryFileProcessingProviderPage>(
              builder: (context, provider, child) {
                return Column(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        AnimatedContainer(
                          width: 200 * item.canvasWidth!,
                          height: 200 * item.canvasHeight!,
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 0.5),
                          ),
                          child: ClipRect(
                            child: CustomPaint(
                              painter: DrawingPainter(
                                  strokes: item.strokes!,
                                  currentPageIndex: item.pageIndex!),
                            ),
                          ),
                        ),
                        RotatedBox(
                          quarterTurns: 1,
                          child: CustomSlider(
                            min: 0.5,
                            max: 5.0,
                            divisions: 25,
                            value: provider.getCanvasItemById(item.id!).canvasHeight!,
                            onChanged: (double value) {
                            provider.updateCanvasHeightScale(item.id!, value);
                            },
                            label: '${provider.heightScale.toStringAsFixed(2)}',
                            ),
                        )
                      ],
                    ),
                    CustomSlider(
                      min: 0.5,
                      max: 5.0,
                      divisions: 25,
                      value: provider.getCanvasItemById(item.id!).canvasWidth!,
                      onChanged: (double value) {
                        provider.updateCanvasWidthScale(item.id!, value);
                      },
                      label: '${provider.widthScale.toStringAsFixed(2)}',
                    )
                  ],
                );
              },
            ),
            // SizedBox(height: 5),


          ],
        ),
      );
    });
  }

  Widget _selectMenu() {
    return PopupMenuButton<int>(
        position: PopupMenuPosition.under,
        padding: EdgeInsets.only(bottom: 0.0),
        icon: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
          decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.all(Radius.circular(20)),
              border: Border.all(width: 1.0, color: Colors.white24)),
          child: CustomIcon(
            icon: Icons.share,
            size: 30.0,
            color: Colors.green,
          ),
        ),
        onSelected: (value) => 0,
        itemBuilder: (context) => [
              PopupMenuItem<int>(
                onTap: () {
                  Provider.of<MemberPageProvider>(context, listen: false)
                      .getListOfMemberMenu()
                      .then((_) {
                    openMemberSearchBoxDialog(context);
                  });
                },
                value: 0,
                child: ListTile(
                  leading: CustomIcon(
                    icon: Icons.list,
                  ),
                  title: Text("Boards"),
                ),
              ),
              PopupMenuItem<int>(
                value: 1,
                child: ListTile(
                  leading: CustomIcon(
                    icon: Icons.list,
                  ),
                  title: Text("Committees"),
                ),
              ),
              PopupMenuItem<int>(
                onTap: () {
                  Provider.of<MemberPageProvider>(context, listen: false)
                      .getListOfMemberMenu()
                      .then((_) {
                    openMemberSearchBoxDialog(context);
                  });
                },
                value: 2,
                child: ListTile(
                  leading: CustomIcon(
                    icon: Icons.list,
                  ),
                  title: Text("Members"),
                ),
              ),
            ]);
  }

  Future<void> openMemberSearchBoxDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return Consumer<MemberPageProvider>(
          builder: (context, provider, child) {
            if (provider.dataOfMembers?.members == null) {
              provider.getListOfMemberMenu();
              return buildLoadingSniper();
            }

            return provider.dataOfMembers!.members!.isEmpty
                ? buildEmptyMessage(
                    AppLocalizations.of(context)!.no_data_to_show)
                : AlertDialog(
                    backgroundColor: Colors.white,
                    // insetPadding: const EdgeInsets.symmetric(horizontal: 50),
                    title: CustomText(
                        text: 'Share Notes With Members',
                        color: Colors.red,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                    content: Form(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: provider.loading
                            ? CircularProgressIndicator() // Show loading indicator while fetching data
                            : MultiSelectDialogField<dynamic>(
                                decoration: BoxDecoration(
                                    border:
                                        Border.all(color: Colors.blueAccent)),
                                confirmText: const Text(
                                  'add Members',
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold),
                                ),
                                cancelText: const Text(
                                  'cancel',
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold),
                                ),
                                separateSelectedItems: true,
                                buttonIcon: const Icon(
                                    Icons.keyboard_arrow_down,
                                    size: 20,
                                    color: Colors.black),
                                title: CustomText(text: 'Members List'),
                                buttonText: Text(
                                    'You Could Select Multiple Members',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                                items: provider.dataOfMembers!.members!
                                    .map((member) => MultiSelectItem<Member>(
                                        member, member.memberFirstName!,))
                                    .toList(),
                                searchable: true,
                                validator: (values) {
                                  if (values == null || values.isEmpty) {
                                    return "Required";
                                  }
                                  List members = values
                                      .map((member) => member['id'])
                                      .toList();
                                  if (members.contains("member_first_name")) {
                                    return "Member are weird!";
                                  }
                                  return null;
                                },
                                onConfirm: (values) {
                                  provider.setSelectedMembers(values);
                                  _membersListIds = provider.selectedMembers
                                      .map((e) => e.memberId)
                                      .toList();
                                  provider
                                      .setSelectedMembersId(_membersListIds);
                                  print(_membersListIds);
                                },
                                chipDisplay: MultiSelectChipDisplay(
                                  onTap: (item) {
                                    provider.removeSelectedMembers(item);
                                  },
                                ),
                              ),
                      ),
                    ),
                    actions: [
                      // Your actions here, for example, buttons that use model methods
                    ],
                  );
          },
        );
      },
    );
  }

  buildLoadingSniper() {
    return const LoadingSniper();
  }

  buildEmptyMessage(String message) {
    return CustomMessage(
      text: message,
    );
  }
}


class CustomIconButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final Color? iconColor;

  const CustomIconButton({
    Key? key,
    required this.onPressed,
    required this.icon,
    this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Icon(
        icon,
        color: iconColor ?? Theme.of(context).iconTheme.color,
      ),
    );
  }
}

