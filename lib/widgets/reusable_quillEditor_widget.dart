import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

class ReusableQuillEditorWidget extends StatelessWidget {
  final QuillController controller;
  final double height;
  final Axis toolbarAxis;
  final EdgeInsets padding;
  final Color? backgroundColor;
  final Color borderColor;
  final bool showListNumbers;
  final bool showBoldButton;
  final bool showListBullets;

  ReusableQuillEditorWidget({
    Key? key,
    required this.controller,
    this.height = 300,
    this.toolbarAxis = Axis.horizontal,
    this.padding = const EdgeInsets.symmetric(horizontal: 20.0),
    this.backgroundColor,
    this.borderColor = Colors.red,
    this.showListNumbers = true,
    this.showBoldButton = true,
    this.showListBullets = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: borderColor, spreadRadius: 0.5),
        ],
      ),
      height: height,
      child: Column(
        children: [
          QuillSimpleToolbar(
            configurations: QuillSimpleToolbarConfigurations(
              axis: toolbarAxis,
              showListNumbers: showListNumbers,
              showBoldButton: true,
              showListBullets: showListBullets,
              buttonOptions: QuillSimpleToolbarButtonOptions(listBullets: QuillToolbarToggleStyleButtonOptions()),
              showQuote: false,
              showLink: false,
              showSearchButton: false,
              showListCheck: false,
              showCodeBlock: false,
              showSubscript: false,
              showSuperscript: false,
              showInlineCode: false,
              showItalicButton: false,
              showJustifyAlignment: false,
              showAlignmentButtons: false,
              showSmallButton: false,
              showDirection: false,
              showClearFormat: false,
              showFontSize: false,
              showFontFamily: false,
              showRedo: false,
              showUndo: false,
              showStrikeThrough: false,
              showDividers: false,
              showHeaderStyle: false,
              showLeftAlignment: false,
              showRightAlignment: false,
              showIndent: false,
              showUnderLineButton: false,
              showColorButton: false,
              showCenterAlignment: false,
              showBackgroundColorButton: false,
              controller: controller,
            ),
          ),
          Expanded(
            child: QuillEditor.basic(
              configurations: QuillEditorConfigurations(
                expands: true,
                scrollable: true,
                padding: padding,
                disableClipboard: false,
                controller: controller, // Pass the controller here
              ),
            ),
          ),
        ],
      ),
    );
  }
}
