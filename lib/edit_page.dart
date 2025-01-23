import 'package:flutter/material.dart';
import 'package:db_practice/data/local/db_helper.dart';
import 'package:fluttertoast/fluttertoast.dart'; // For displaying toast messages

class EditPage extends StatefulWidget {
  final String title;
  final String description;
  final int sno;  // This is the serial number of the note being edited

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
  TextEditingController titleController = TextEditingController();
  TextEditingController descController = TextEditingController();
  DBHelper? dbRef;

  bool isBold = false;
  bool isItalic = false;
  bool isUnderlined = false;

  @override
  void initState() {
    super.initState();
    dbRef = DBHelper.getInstance;

    // Set initial values from the passed data
    titleController.text = widget.title;
    descController.text = widget.description;
  }

  // Function to apply the selected formatting to the text
  TextStyle _getTextStyle() {
    TextStyle style = TextStyle();
    if (isBold) style = style.copyWith(fontWeight: FontWeight.bold);
    if (isItalic) style = style.copyWith(fontStyle: FontStyle.italic);
    if (isUnderlined) style = style.copyWith(decoration: TextDecoration.underline);
    return style;
  }

  // Function to apply bold, italic, or underline formatting
  void _applyTextFormatting(String format) {
    setState(() {
      if (format == 'bold') {
        isBold = !isBold;
      } else if (format == 'italic') {
        isItalic = !isItalic;
      } else if (format == 'underline') {
        isUnderlined = !isUnderlined;
      }
    });
  }

  // Function to remove all text formatting
  void removeFormatting() {
    setState(() {
      isBold = false;
      isItalic = false;
      isUnderlined = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Note'),
      ),

      body: Container(
        padding: EdgeInsets.all(11),
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                SizedBox(height: 19),
                TextField(
                  controller: titleController,
                  autofocus: true,     // Focus on the title field as soon as it's loaded
                  decoration: InputDecoration(
                    hintText: "Title",
                    label: Text("Title"),
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                  ),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: null,
                  textAlign: TextAlign.start,
                ),
                SizedBox(height: 11),

                // Apply the formatting to the description TextField
                TextField(
                  controller: descController,
                  maxLines: 7,
                  style: _getTextStyle(),  // Apply the selected text style here
                  decoration: InputDecoration(
                    hintText: "Enter description here",
                    label: Text('Description'),
                    border: InputBorder.none
                    // focusedBorder: OutlineInputBorder(
                    //   borderRadius: BorderRadius.circular(11),
                    // ),
                    // enabledBorder: OutlineInputBorder(
                    //   borderRadius: BorderRadius.circular(11),
                    // ),

                  ),
                ),


                // Buttons to apply formatting

              ],
            ),

            // Update and Cancel Note outlined buttons
            Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                      border: Border.all(
                          width: 0.7
                      ),
                      borderRadius: BorderRadius.circular(11)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                        onPressed: () {
                          _applyTextFormatting('bold');
                        },
                        icon: Icon(
                          Icons.format_bold,
                          color: isBold ? Colors.blue : Colors.black,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          _applyTextFormatting('italic');
                        },
                        icon: Icon(
                          Icons.format_italic,
                          color: isItalic ? Colors.blue : Colors.black,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          _applyTextFormatting('underline');
                        },
                        icon: Icon(
                          Icons.format_underline,
                          color: isUnderlined ? Colors.blue : Colors.black,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          removeFormatting();
                        },
                        icon: Icon(Icons.cancel_presentation),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 5,),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(width: 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(11),
                          ),
                        ),
                        onPressed: () async {
                          var title = titleController.text;
                          var desc = descController.text;

                          if (title.isNotEmpty && desc.isNotEmpty) {
                            bool check = await dbRef!.updateNote(
                              mTitle: title,
                              mDesc: desc,
                              sno: widget.sno, // Use the sno passed from the HomePage
                            );

                            if (check) {
                              Fluttertoast.showToast(
                                msg: "Note updated successfully",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                              );
                              Navigator.pop(context, true); // Go back to HomePage
                            } else {
                              Fluttertoast.showToast(
                                msg: "Failed to update note",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                              );
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Please fill all the required blanks!'),
                              ),
                            );
                          }
                        },
                        child: Text('Update Note'),
                      ),
                    ),
                    SizedBox(width: 11),
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(width: 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(11),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context); // Cancel and go back to the HomePage
                        },
                        child: Text('Cancel'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
