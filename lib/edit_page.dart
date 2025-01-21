import 'package:flutter/material.dart';
import 'package:db_practice/data/local/db_helper.dart';
import 'package:lock_orientation_screen/lock_orientation_screen.dart';
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

  @override
  void initState() {
    super.initState();
    dbRef = DBHelper.getInstance;

    // Set initial values from the passed data
    titleController.text = widget.title;
    descController.text = widget.description;
  }

  @override
  Widget build(BuildContext context) {
    return LockOrientation(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Update Note'),
        ),
        body: Container(
          padding: EdgeInsets.all(11),
          height: MediaQuery.of(context).size.height,
          width: double.infinity,
          child: Column(
            children: [
              SizedBox(
                height: 19,
              ),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  hintText: "Enter title here",
                  label: Text('Title'),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(11),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(11),
                  ),
                ),
              ),
              SizedBox(
                height: 11,
              ),
              TextField(
                controller: descController,
                maxLines: 9,
                decoration: InputDecoration(
                  hintText: "Enter desc here",
                  label: Text('Description'),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(11),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(11),
                  ),
                ),
              ),
              SizedBox(
                height: 11,
              ),
              
              // Container(
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //     children: [
              //       Padding(
              //         padding: const EdgeInsets.only(left: 8.0),
              //         child: IconButton(onPressed: (){}, icon: Icon(Icons.format_bold)),
              //       ),
              //       IconButton(onPressed: (){}, icon: Icon(Icons.format_italic)),
              //       Padding(
              //         padding: const EdgeInsets.only(right: 8.0),
              //         child: IconButton(onPressed: (){}, icon: Icon(Icons.link_outlined)),
              //       )
              //     ],
              //   ),
              // ),
              
              /// update note outlined button
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
                            // Successfully updated the note
                            Fluttertoast.showToast(
                                msg: "Note updated successfully",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM);

                            // Go back to HomePage and refresh the notes
                            Navigator.pop(context, true); // true will indicate the update was successful
                          } else {
                            // If update fails
                            Fluttertoast.showToast(
                                msg: "Failed to update note",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM);
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
                  SizedBox(
                    width: 11,
                  ),
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
        ),
      ),
    );
  }
}
