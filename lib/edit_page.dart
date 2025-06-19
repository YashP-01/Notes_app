import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:db_practice/data/local/db_helper.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'dart:convert'; // If saving as JSON


class EditPage extends StatefulWidget {
  final String title;
  final String description;
  final int sno;

  const EditPage({
    Key? key,
    required this.title,
    required this.description,
    required this.sno,
  }) : super(key: key);

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  late TextEditingController titleController;
  // late RichTextController descController;
  late quill.QuillController quillController;
  DBHelper? dbRef;

  // Formatting states
  bool isBold = false;
  bool isItalic = false;
  bool isUnderlined = false;
  bool isStrikethrough = false;
  Color currentTextColor = Colors.black87;
  Color currentHighlightColor = Colors.transparent;
  double currentFontSize = 16.0;

  // Available colors
  final List<Color> textColors = [
    Colors.black87,
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.brown,
    Colors.pink,
    Colors.indigo,
  ];

  final List<Color> highlightColors = [
    Colors.transparent,
    Colors.yellow.shade200,
    Colors.green.shade200,
    Colors.blue.shade200,
    Colors.pink.shade200,
    Colors.orange.shade200,
    Colors.purple.shade200,
    Colors.red.shade200,
  ];

  // @override
  // void initState() {
  //   super.initState();
  //   dbRef = DBHelper.getInstance;
  //   titleController = TextEditingController(text: widget.title);
  //
  //   quillController = quill.QuillController(
  //     document: widget.description.trim().isEmpty
  //         ? quill.Document()
  //         : quill.Document.fromPlainText(widget.description),
  //     selection: TextSelection.collapsed(offset: 0),
  //   );
  // }


  @override
  void initState() {
    super.initState();

    dbRef = DBHelper.getInstance;
    titleController = TextEditingController(text: widget.title);

    try {
      final delta = widget.description.trim().isEmpty
          ? Delta()
          : Delta.fromJson(jsonDecode(widget.description));

      quillController = quill.QuillController(
        document: quill.Document.fromDelta(delta),
        selection: const TextSelection.collapsed(offset: 0),
      );
    } catch (e) {
      quillController = quill.QuillController(
        document: quill.Document()..insert(0, widget.description),
        selection: const TextSelection.collapsed(offset: 0),
      );
    }
  }


  //
  // @override
  // void initState() {
  //   super.initState();
  //   dbRef = DBHelper.getInstance;
  //   titleController = TextEditingController(text: widget.title);
  //   descController = RichTextController(
  //     text: widget.description,
  //     style: TextStyle(fontSize: currentFontSize, color: currentTextColor),
  //   );
  // }

  @override
  void dispose() {
    titleController.dispose();
    // descController.dispose();
    super.dispose();
  }

  // void _updateFormattingState() {
  //   final selection = descController.selection;
  //   final style = descController.getSelectionStyle();
  //
  //   setState(() {
  //     isBold = style.fontWeight == FontWeight.bold;
  //     isItalic = style.fontStyle == FontStyle.italic;
  //     isUnderlined = style.decoration == TextDecoration.underline;
  //     isStrikethrough = style.decoration == TextDecoration.lineThrough;
  //     currentTextColor = style.color ?? Colors.black87;
  //     currentHighlightColor = style.backgroundColor ?? Colors.transparent;
  //     currentFontSize = style.fontSize ?? 16.0;
  //   });
  // }

  // void _applyFormatting(String type) {
  //   final selection = descController.selection;
  //   if (!selection.isValid) {
  //     // If no selection, toggle format for future typing
  //     setState(() {
  //       switch (type) {
  //         case 'bold':
  //           isBold = !isBold;
  //           break;
  //         case 'italic':
  //           isItalic = !isItalic;
  //           break;
  //         case 'underline':
  //           isUnderlined = !isUnderlined;
  //           break;
  //         case 'strikethrough':
  //           isStrikethrough = !isStrikethrough;
  //           break;
  //       }
  //     });
  //     return;
  //   }
  //
  //   TextStyle newStyle;
  //   switch (type) {
  //     case 'bold':
  //       setState(() => isBold = !isBold);
  //       newStyle = TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal);
  //       break;
  //     case 'italic':
  //       setState(() => isItalic = !isItalic);
  //       newStyle = TextStyle(fontStyle: isItalic ? FontStyle.italic : FontStyle.normal);
  //       break;
  //     case 'underline':
  //       setState(() => isUnderlined = !isUnderlined);
  //       newStyle = TextStyle(decoration: isUnderlined ? TextDecoration.underline : TextDecoration.none);
  //       break;
  //     case 'strikethrough':
  //       setState(() => isStrikethrough = !isStrikethrough);
  //       newStyle = TextStyle(decoration: isStrikethrough ? TextDecoration.lineThrough : TextDecoration.none);
  //       break;
  //     default:
  //       return;
  //   }
  //
  //   descController.applyStyle(newStyle);
  // }

  // void _applyTextColor(Color color) {
  //   setState(() => currentTextColor = color);
  //   descController.applyStyle(TextStyle(color: color));
  //   Navigator.pop(context);
  // }
  //
  // void _applyHighlightColor(Color color) {
  //   setState(() => currentHighlightColor = color);
  //   descController.applyStyle(TextStyle(backgroundColor: color));
  //   Navigator.pop(context);
  // }
  //
  // void _applyFontSize(double size) {
  //   setState(() => currentFontSize = size);
  //   descController.applyStyle(TextStyle(fontSize: size));
  //   Navigator.pop(context);
  // }
  //
  // void _clearFormatting() {
  //   setState(() {
  //     isBold = false;
  //     isItalic = false;
  //     isUnderlined = false;
  //     isStrikethrough = false;
  //     currentTextColor = Colors.black87;
  //     currentHighlightColor = Colors.transparent;
  //     currentFontSize = 16.0;
  //   });
  //   descController.clearFormatting();
  // }
  //
  // void _insertBulletPoint() {
  //   descController.insertText('• ');
  // }
  //
  // void _insertCheckbox() {
  //   descController.insertText('☐ ');
  // }

  Future<void> _saveNote() async {
    final title = titleController.text.trim();
    // final description = quillController.document.toPlainText().trim();
    final description  = jsonEncode(quillController.document.toDelta().toJson());   // Save deltaJson in DB
    // final description = descController.plainText.trim();

    if (title.isEmpty || description.isEmpty) {
      _showSnackBar('Please fill in both title and description', Colors.orange);
      return;
    }

    try {
      final success = await dbRef!.updateNote(
        mTitle: title,
        mDesc: description,
        sno: widget.sno,
      );

      if (success) {
        _showToast('Note updated successfully!', Colors.green);
        Navigator.pop(context, true);
      } else {
        throw Exception('Failed to update note');
      }
    } catch (e) {
      _showToast('Error: ${e.toString()}', Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showToast(String message, Color color) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: color,
      textColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'Edit Note',
          style: TextStyle(
            color: Colors.grey[800],
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey[700]),
          onPressed: () => Navigator.pop(context),
        ),
        // actions: [
        //   IconButton(
        //     icon: Icon(Icons.save_rounded, color: Colors.blue[600]),
        //     onPressed: _saveNote,
        //     tooltip: 'Save Note',
        //   ),
        //   SizedBox(width: 8),
        // ],
      ),
      body: Column(
        children: [
          // Title Section
          Container(
            margin: EdgeInsets.all(16),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: titleController,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
              decoration: InputDecoration(
                hintText: 'Note Title',
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                  fontWeight: FontWeight.normal,
                ),
                border: InputBorder.none,
              ),
              maxLines: null,
            ),
          ),

          /// Formatting Toolbar
          // Container(
          //   margin: EdgeInsets.symmetric(horizontal: 16),
          //   padding: EdgeInsets.symmetric(vertical: 8),
          //   decoration: BoxDecoration(
          //     color: Colors.white,
          //     borderRadius: BorderRadius.circular(12),
          //     boxShadow: [
          //       BoxShadow(
          //         color: Colors.black.withOpacity(0.05),
          //         blurRadius: 10,
          //         offset: Offset(0, 2),
          //       ),
          //     ],
          //   ),
          //   child: SingleChildScrollView(
          //     scrollDirection: Axis.horizontal,
          //     padding: EdgeInsets.symmetric(horizontal: 8),
          //     child: Row(
          //       children: [
          //         _buildToolbarButton(
          //           Icons.format_bold_rounded,
          //           'Bold',
          //           isBold,
          //               () => _applyFormatting('bold'),
          //         ),
          //         _buildToolbarButton(
          //           Icons.format_italic_rounded,
          //           'Italic',
          //           isItalic,
          //               () => _applyFormatting('italic'),
          //         ),
          //         _buildToolbarButton(
          //           Icons.format_underline_rounded,
          //           'Underline',
          //           isUnderlined,
          //               () => _applyFormatting('underline'),
          //         ),
          //         _buildToolbarButton(
          //           Icons.strikethrough_s_rounded,
          //           'Strikethrough',
          //           isStrikethrough,
          //               () => _applyFormatting('strikethrough'),
          //         ),
          //         _buildVerticalDivider(),
          //         _buildColorButton(
          //           Icons.format_color_text_rounded,
          //           'Text Color',
          //           currentTextColor,
          //           _showTextColorPicker,
          //         ),
          //         _buildColorButton(
          //           Icons.highlight_rounded,
          //           'Highlight',
          //           currentHighlightColor,
          //           _showHighlightColorPicker,
          //         ),
          //         _buildToolbarButton(
          //           Icons.format_size_rounded,
          //           'Font Size',
          //           false,
          //           _showFontSizePicker,
          //         ),
          //         _buildVerticalDivider(),
          //         _buildToolbarButton(
          //           Icons.format_list_bulleted_rounded,
          //           'Bullet Point',
          //           false,
          //           _insertBulletPoint,
          //         ),
          //         _buildToolbarButton(
          //           Icons.check_box_outlined,
          //           'Checkbox',
          //           false,
          //           _insertCheckbox,
          //         ),
          //         _buildVerticalDivider(),
          //         _buildToolbarButton(
          //           Icons.format_clear_rounded,
          //           'Clear Format',
          //           false,
          //           _clearFormatting,
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
          // SizedBox(height: 16),
          /// Rich Text Editor
          // Expanded(
          //   child: Container(
          //     margin: EdgeInsets.symmetric(horizontal: 16),
          //     padding: EdgeInsets.all(16),
          //     decoration: BoxDecoration(
          //       color: Colors.white,
          //       borderRadius: BorderRadius.circular(12),
          //       boxShadow: [
          //         BoxShadow(
          //           color: Colors.black.withOpacity(0.05),
          //           blurRadius: 10,
          //           offset: Offset(0, 2),
          //         ),
          //       ],
          //     ),
          //     child: Column(
          //       children: [
          //         quill.QuillSimpleToolbar.basic(controller: quillController),
          //         Expanded(
          //           child: Container(
          //             padding: EdgeInsets.all(16),
          //             decoration: BoxDecoration(
          //               color: Colors.white,
          //               borderRadius: BorderRadius.circular(12),
          //               boxShadow: [
          //                 BoxShadow(
          //                   color: Colors.black.withOpacity(0.05),
          //                   blurRadius: 10,
          //                   offset: Offset(0, 2),
          //                 ),
          //               ],
          //             ),
          //             child: quill.QuillEditor(
          //               controller: quillController,
          //               scrollController: ScrollController(),
          //               scrollable: true,
          //               focusNode: FocusNode(),
          //               autoFocus: false,
          //               readOnly: false,
          //               expands: true,
          //               padding: EdgeInsets.zero,
          //             ),
          //           ),
          //         ),
          //       ],
          //     ),
          //
          //     // child: RichTextField(
          //     //   controller: descController,
          //     //   decoration: InputDecoration(
          //     //     hintText: 'Start typing your note...\n\nSelect text to format it with the toolbar above.',
          //     //     hintStyle: TextStyle(
          //     //       color: Colors.grey[400],
          //     //       fontSize: 16,
          //     //       height: 1.5,
          //     //     ),
          //     //     border: InputBorder.none,
          //     //   ),
          //     //   style: TextStyle(
          //     //     fontSize: currentFontSize,
          //     //     color: currentTextColor,
          //     //     height: 1.5,
          //     //   ),
          //     //   onSelectionChanged: _updateFormattingState,
          //     // ),
          //   ),
          // ),

          // Bottom Action Buttons

          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Expanded(
                    child: quill.QuillEditor.basic(
                      controller: quillController,
                      config: const quill.QuillEditorConfig(),
                    ),
                  ),
                  quill.QuillSimpleToolbar(
                    controller: quillController,
                    config: const quill.QuillSimpleToolbarConfig(
                      multiRowsDisplay: false
                    ),
                  ),
                ],
              ),
            ),
          ),

          Container(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close_rounded),
                    label: Text('Cancel'),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: Colors.grey[300]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _saveNote,
                    icon: Icon(Icons.save_rounded, color: Colors.white,),
                    label: Text('Update Note'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbarButton(
      IconData icon,
      String tooltip,
      bool isActive,
      VoidCallback onPressed,
      ) {
    return Tooltip(
      message: tooltip,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 2),
        child: IconButton(
          onPressed: onPressed,
          icon: Icon(icon, size: 20),
          color: isActive ? Colors.blue[600] : Colors.grey[600],
          style: IconButton.styleFrom(
            backgroundColor: isActive ? Colors.blue[50] : Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: EdgeInsets.all(8),
          ),
        ),
      ),
    );
  }

  Widget _buildColorButton(
      IconData icon,
      String tooltip,
      Color color,
      VoidCallback onPressed,
      ) {
    return Tooltip(
      message: tooltip,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 2),
        child: IconButton(
          onPressed: onPressed,
          icon: Stack(
            children: [
              Icon(icon, size: 20, color: Colors.grey[600]),
              if (color != Colors.transparent)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 12,
                    height: 3,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
            ],
          ),
          style: IconButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: EdgeInsets.all(8),
          ),
        ),
      ),
    );
  }

  // Widget _buildVerticalDivider() {
  //   return Container(
  //     height: 24,
  //     width: 1,
  //     color: Colors.grey[300],
  //     margin: EdgeInsets.symmetric(horizontal: 8),
  //   );
  // }

  // void _showTextColorPicker() {
  //   _showColorPicker('Text Color', textColors, currentTextColor, _applyTextColor);
  // }
  //
  // void _showHighlightColorPicker() {
  //   _showColorPicker('Highlight Color', highlightColors, currentHighlightColor, _applyHighlightColor);
  // }

  // void _showColorPicker(
  //     String title,
  //     List<Color> colors,
  //     Color currentColor,
  //     Function(Color) onColorSelected,
  //     ) {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: Text(title),
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  //       content: Wrap(
  //         spacing: 8,
  //         runSpacing: 8,
  //         children: colors.map((color) {
  //           final isSelected = color == currentColor;
  //           return GestureDetector(
  //             onTap: () => onColorSelected(color),
  //             child: Container(
  //               width: 36,
  //               height: 36,
  //               decoration: BoxDecoration(
  //                 color: color == Colors.transparent ? Colors.white : color,
  //                 shape: BoxShape.circle,
  //                 border: Border.all(
  //                   color: isSelected ? Colors.blue[600]! : Colors.grey[300]!,
  //                   width: isSelected ? 3 : 1,
  //                 ),
  //               ),
  //               child: color == Colors.transparent
  //                   ? Icon(Icons.format_color_reset, size: 16, color: Colors.grey[600])
  //                   : null,
  //             ),
  //           );
  //         }).toList(),
  //       ),
  //     ),
  //   );
  // }

  // void _showFontSizePicker() {
  //   final sizes = [12.0, 14.0, 16.0, 18.0, 20.0, 22.0, 24.0, 28.0, 32.0];
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: Text('Font Size'),
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  //       content: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: sizes.map((size) {
  //           return ListTile(
  //             contentPadding: EdgeInsets.symmetric(horizontal: 8),
  //             title: Text(
  //               '${size.toInt()}pt',
  //               style: TextStyle(fontSize: size > 24 ? 20 : size),
  //             ),
  //             selected: currentFontSize == size,
  //             selectedTileColor: Colors.blue[50],
  //             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  //             onTap: () => _applyFontSize(size),
  //           );
  //         }).toList(),
  //       ),
  //     ),
  //   );
  // }
}


//
// // Rich Text Controller with proper formatting support
// class RichTextController extends TextEditingController {
//   Map<int, TextStyle> _styleMap = {};
//   TextStyle _defaultStyle = TextStyle(fontSize: 16.0, color: Colors.black87);
//
//   RichTextController({String? text, TextStyle? style}) : super(text: text) {
//     if (style != null) {
//       _defaultStyle = style;
//     }
//   }
//
//   String get plainText => text;
//
//   TextStyle getSelectionStyle() {
//     final selection = this.selection;
//     if (!selection.isValid || selection.isCollapsed) {
//       return _defaultStyle;
//     }
//
//     // Get style at selection start
//     return _styleMap[selection.start] ?? _defaultStyle;
//   }
//
//   void applyStyle(TextStyle newStyle) {
//     final selection = this.selection;
//     if (!selection.isValid) return;
//
//     if (selection.isCollapsed) {
//       // If no selection, apply to next typed text
//       _defaultStyle = _defaultStyle.merge(newStyle);
//       return;
//     }
//
//     // Apply style to selected range
//     for (int i = selection.start; i < selection.end; i++) {
//       _styleMap[i] = (_styleMap[i] ?? _defaultStyle).merge(newStyle);
//     }
//
//     notifyListeners();
//   }
//
//   void clearFormatting() {
//     final selection = this.selection;
//     if (!selection.isValid) return;
//
//     if (selection.isCollapsed) {
//       _defaultStyle = TextStyle(fontSize: 16.0, color: Colors.black87);
//       return;
//     }
//
//     // Clear formatting for selected range
//     for (int i = selection.start; i < selection.end; i++) {
//       _styleMap.remove(i);
//     }
//     notifyListeners();
//   }
//
//   void insertText(String textToInsert) {
//     final selection = this.selection;
//     final currentText = this.text;
//     final newText = currentText.substring(0, selection.start) +
//         textToInsert +
//         currentText.substring(selection.end);
//
//     // Update style map for inserted text
//     final insertLength = textToInsert.length;
//     final newStyleMap = <int, TextStyle>{};
//
//     _styleMap.forEach((position, style) {
//       if (position < selection.start) {
//         newStyleMap[position] = style;
//       } else {
//         newStyleMap[position + insertLength] = style;
//       }
//     });
//
//     // Apply default style to inserted text
//     for (int i = selection.start; i < selection.start + insertLength; i++) {
//       newStyleMap[i] = _defaultStyle;
//     }
//
//     _styleMap = newStyleMap;
//
//     this.text = newText;
//     this.selection = TextSelection.collapsed(
//       offset: selection.start + textToInsert.length,
//     );
//   }
//
//   // Get formatted text spans for rich text display
//   List<TextSpan> getTextSpans() {
//     if (text.isEmpty) return [TextSpan(text: '', style: _defaultStyle)];
//
//     List<TextSpan> spans = [];
//     String currentText = '';
//     TextStyle? currentStyle;
//
//     for (int i = 0; i < text.length; i++) {
//       final charStyle = _styleMap[i] ?? _defaultStyle;
//
//       if (currentStyle == null || !_stylesEqual(currentStyle, charStyle)) {
//         if (currentText.isNotEmpty) {
//           spans.add(TextSpan(text: currentText, style: currentStyle));
//           currentText = '';
//         }
//         currentStyle = charStyle;
//       }
//       currentText += text[i];
//     }
//
//     if (currentText.isNotEmpty) {
//       spans.add(TextSpan(text: currentText, style: currentStyle));
//     }
//     return spans.isEmpty ? [TextSpan(text: '', style: _defaultStyle)] : spans;
//   }
//
//   bool _stylesEqual(TextStyle style1, TextStyle style2) {
//     return style1.fontSize == style2.fontSize &&
//         style1.fontWeight == style2.fontWeight &&
//         style1.fontStyle == style2.fontStyle &&
//         style1.decoration == style2.decoration &&
//         style1.color == style2.color &&
//         style1.backgroundColor == style2.backgroundColor;
//   }
// }
//
// // Custom Rich Text Field with selection tracking
// class RichTextField extends StatefulWidget {
//   final RichTextController controller;
//   final InputDecoration? decoration;
//   final TextStyle? style;
//   final VoidCallback? onSelectionChanged;
//
//   const RichTextField({
//     Key? key,
//     required this.controller,
//     this.decoration,
//     this.style,
//     this.onSelectionChanged,
//   }) : super(key: key);
//
//   @override
//   State<RichTextField> createState() => _RichTextFieldState();
// }
//
// class _RichTextFieldState extends State<RichTextField> {
//   late FocusNode _focusNode;
//   TextSelection? _lastSelection;
//
//   @override
//   void initState() {
//     super.initState();
//     _focusNode = FocusNode();
//     widget.controller.addListener(_onTextChanged);
//   }
//
//   @override
//   void dispose() {
//     widget.controller.removeListener(_onTextChanged);
//     _focusNode.dispose();
//     super.dispose();
//   }
//
//   void _onTextChanged() {
//     final currentSelection = widget.controller.selection;
//     if (_lastSelection != currentSelection) {
//       _lastSelection = currentSelection;
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         widget.onSelectionChanged?.call();
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         _focusNode.requestFocus();
//       },
//       child: Container(
//         width: double.infinity,
//         child: _focusNode.hasFocus
//             ? TextField(
//           controller: widget.controller,
//           focusNode: _focusNode,
//           decoration: widget.decoration,
//           style: widget.style,
//           maxLines: null,
//           expands: true,
//           textAlignVertical: TextAlignVertical.top,
//           onTap: () {
//             // Delay to ensure selection is updated
//             Future.delayed(Duration(milliseconds: 100), () {
//               widget.onSelectionChanged?.call();
//             });
//           },
//         )
//             : SingleChildScrollView(
//           child: Container(
//             width: double.infinity,
//             padding: EdgeInsets.symmetric(vertical: 8),
//             child: widget.controller.text.isEmpty
//                 ? Text(
//               widget.decoration?.hintText ?? '',
//               style: widget.decoration?.hintStyle,
//             )
//                 : SelectableText.rich(
//               TextSpan(
//                 children: widget.controller.getTextSpans(),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }









// import 'package:flutter/material.dart';
// import 'package:db_practice/data/local/db_helper.dart';
// import 'package:fluttertoast/fluttertoast.dart'; // For displaying toast messages
//
// class EditPage extends StatefulWidget {
//   final String title;
//   final String description;
//   final int sno;  // This is the serial number of the note being edited
//
//   const EditPage({
//     Key? key,
//     required this.title,
//     required this.description,
//     required this.sno,
//   }) : super(key: key);
//
//   @override
//   State<EditPage> createState() => _EditPageState();
// }
//
// class _EditPageState extends State<EditPage> {
//   TextEditingController titleController = TextEditingController();
//   TextEditingController descController = TextEditingController();
//   DBHelper? dbRef;
//
//   bool isBold = false;
//   bool isItalic = false;
//   bool isUnderlined = false;
//
//   @override
//   void initState() {
//     super.initState();
//     dbRef = DBHelper.getInstance;
//
//     // Set initial values from the passed data
//     titleController.text = widget.title;
//     descController.text = widget.description;
//   }
//
//   // Function to apply the selected formatting to the text
//   TextStyle _getTextStyle() {
//     TextStyle style = TextStyle();
//     if (isBold) style = style.copyWith(fontWeight: FontWeight.bold);
//     if (isItalic) style = style.copyWith(fontStyle: FontStyle.italic);
//     if (isUnderlined) style = style.copyWith(decoration: TextDecoration.underline);
//     return style;
//   }
//
//   // Function to apply bold, italic, or underline formatting
//   void _applyTextFormatting(String format) {
//     setState(() {
//       if (format == 'bold') {
//         isBold = !isBold;
//       } else if (format == 'italic') {
//         isItalic = !isItalic;
//       } else if (format == 'underline') {
//         isUnderlined = !isUnderlined;
//       }
//     });
//   }
//
//   // Function to remove all text formatting
//   void removeFormatting() {
//     setState(() {
//       isBold = false;
//       isItalic = false;
//       isUnderlined = false;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Update Note'),
//       ),
//
//       body: Container(
//         padding: EdgeInsets.all(11),
//         height: MediaQuery.of(context).size.height,
//         width: double.infinity,
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Column(
//               children: [
//                 SizedBox(height: 19),
//                 TextField(
//                   controller: titleController,
//                   autofocus: true,     // Focus on the title field as soon as it's loaded
//                   decoration: InputDecoration(
//                     hintText: "Title",
//                     label: Text("Title"),
//                     hintStyle: TextStyle(color: Colors.grey),
//                     border: InputBorder.none,
//                   ),
//                   style: TextStyle(
//                     fontSize: 22,
//                     fontWeight: FontWeight.bold,
//                   ),
//                   maxLines: null,
//                   textAlign: TextAlign.start,
//                 ),
//                 SizedBox(height: 11),
//
//                 // Apply the formatting to the description TextField
//                 TextField(
//                   controller: descController,
//                   maxLines: 7,
//                   style: _getTextStyle(),  // Apply the selected text style here
//                   decoration: InputDecoration(
//                     hintText: "Enter description here",
//                     label: Text('Description'),
//                     border: InputBorder.none
//                     // focusedBorder: OutlineInputBorder(
//                     //   borderRadius: BorderRadius.circular(11),
//                     // ),
//                     // enabledBorder: OutlineInputBorder(
//                     //   borderRadius: BorderRadius.circular(11),
//                     // ),
//
//                   ),
//                 ),
//
//
//                 // Buttons to apply formatting
//
//               ],
//             ),
//
//             // Update and Cancel Note outlined buttons
//             Column(
//               children: [
//                 Container(
//                   decoration: BoxDecoration(
//                       border: Border.all(
//                           width: 0.7
//                       ),
//                       borderRadius: BorderRadius.circular(11)),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceAround,
//                     children: [
//                       IconButton(
//                         onPressed: () {
//                           _applyTextFormatting('bold');
//                         },
//                         icon: Icon(
//                           Icons.format_bold,
//                           color: isBold ? Colors.blue : Colors.black,
//                         ),
//                       ),
//                       IconButton(
//                         onPressed: () {
//                           _applyTextFormatting('italic');
//                         },
//                         icon: Icon(
//                           Icons.format_italic,
//                           color: isItalic ? Colors.blue : Colors.black,
//                         ),
//                       ),
//                       IconButton(
//                         onPressed: () {
//                           _applyTextFormatting('underline');
//                         },
//                         icon: Icon(
//                           Icons.format_underline,
//                           color: isUnderlined ? Colors.blue : Colors.black,
//                         ),
//                       ),
//                       IconButton(
//                         onPressed: () {
//                           removeFormatting();
//                         },
//                         icon: Icon(Icons.cancel_presentation),
//                       ),
//                     ],
//                   ),
//                 ),
//                 SizedBox(height: 5,),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: OutlinedButton(
//                         style: OutlinedButton.styleFrom(
//                           side: BorderSide(width: 1),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(11),
//                           ),
//                         ),
//                         onPressed: () async {
//                           var title = titleController.text;
//                           var desc = descController.text;
//
//                           if (title.isNotEmpty && desc.isNotEmpty) {
//                             bool check = await dbRef!.updateNote(
//                               mTitle: title,
//                               mDesc: desc,
//                               sno: widget.sno, // Use the sno passed from the HomePage
//                             );
//
//                             if (check) {
//                               Fluttertoast.showToast(
//                                 msg: "Note updated successfully",
//                                 toastLength: Toast.LENGTH_SHORT,
//                                 gravity: ToastGravity.BOTTOM,
//                               );
//                               Navigator.pop(context, true); // Go back to HomePage
//                             } else {
//                               Fluttertoast.showToast(
//                                 msg: "Failed to update note",
//                                 toastLength: Toast.LENGTH_SHORT,
//                                 gravity: ToastGravity.BOTTOM,
//                               );
//                             }
//                           } else {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               SnackBar(
//                                 content: Text('Please fill all the required blanks!'),
//                               ),
//                             );
//                           }
//                         },
//                         child: Text('Update Note'),
//                       ),
//                     ),
//                     SizedBox(width: 11),
//                     Expanded(
//                       child: OutlinedButton(
//                         style: OutlinedButton.styleFrom(
//                           side: BorderSide(width: 1),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(11),
//                           ),
//                         ),
//                         onPressed: () {
//                           Navigator.pop(context); // Cancel and go back to the HomePage
//                         },
//                         child: Text('Cancel'),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
