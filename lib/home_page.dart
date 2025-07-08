import 'package:db_practice/component/drawer.dart';
import 'package:db_practice/data/local/db_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:intl/intl.dart';
import 'edit_page.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'dart:convert';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // late TextEditingController titleController;
  // late quill.QuillController descController;
  List<Map<String, dynamic>> filteredNotes = [];
  bool isSearching = false;
  TextEditingController searchController = TextEditingController();
  Set<int> selectedNoteIds = {};
  bool selectionMode = false;
  bool isMultiSelectMode = false;
  Set<int> selectedNoteSno = {};
  bool isGridView = true;

  /// controllers
  TextEditingController titleController = TextEditingController();
  // late quill.QuillController descController;
  TextEditingController descController = TextEditingController();
  FocusNode _focusNode = FocusNode();

  final int maxTitleLength = 7;   /// maximum title length

  List<Map<String, dynamic>> allNotes = [];
  DBHelper? dbRef;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    dbRef = DBHelper.getInstance;
    getNotes();
    filteredNotes = [];

    for (var note in allNotes) {
      print(formatDate(note['created_at']));
    }

    // descController = quill.QuillController.basic();

    // Avoid calling setState during build
    // descController.addListener(() {
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     if (mounted) setState(() {});
    //   });
    // });
    // loadAndApplySortOrder();
  }


  String formatDate(String? isoDate) {
    if (isoDate == null) return '';
    final dt = DateTime.tryParse(isoDate);
    if (dt == null) return '';
    return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
  }

  // Future<void> loadAndApplySortOrder() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final savedSortOrder = prefs.getString('sortOrder') ?? 'newest'; // default sort
  //   await getNotes();
  //   _sortNotes(savedSortOrder);
  // }

  // void _sortNotes(String order) {
  //   setState(() {
  //     if (order == 'newest') {
  //       filteredNotes.sort((a, b) => b['modifiedDate'].compareTo(a['modifiedDate']));
  //     } else if (order == 'oldest') {
  //       filteredNotes.sort((a, b) => a['modifiedDate'].compareTo(b['modifiedDate']));
  //     }
  //     // else if (order == 'az') {
  //     //   filteredNotes.sort((a, b) =>
  //     //       a['title'].toLowerCase().compareTo(b['title'].toLowerCase()));
  //     // } else if (order == 'za') {
  //     //   filteredNotes.sort((a, b) =>
  //     //       b['title'].toLowerCase().compareTo(a['title'].toLowerCase()));
  //     // }
  //   });
  // }

  String getPlainTextFromDeltaJson(dynamic deltaJson) {
    try {
      dynamic parsedDelta;

      if (deltaJson is String) {
        try {
          parsedDelta = jsonDecode(deltaJson);
        } catch (_) {
          // It's plain text, wrap it in Quill's Delta format
          parsedDelta = [
            {'insert': deltaJson + '\n'}
          ];
        }
      } else {
        parsedDelta = deltaJson;
      }

      final delta = Delta.fromJson(parsedDelta);
      final document = quill.Document.fromDelta(delta);
      return document.toPlainText().trim();
    } catch (e) {
      print("Error building document: $e");
      return '[Error loading note]';
    }
  }

  // String getPlainTextFromDeltaJson(String deltaJson) {
  //   try {
  //     final delta = quill.Delta.fromJson(jsonDecode(deltaJson));
  //     final document = quill.Document.fromDelta(delta);
  //     return document.toPlainText().trim();
  //   } catch (e) {
  //     return '[Error loading note]';
  //   }
  // }

  Future<void> getNotes() async {
    allNotes = await dbRef!.getAllNotes();
    setState(() {
      filteredNotes = allNotes;
    });
  }

  void _startSearch() {
    // FocusScope.of(context).requestFocus(_focusNode);
    setState(() {
      isSearching = true;
    });
    // Ensure focus happens after the UI updates
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  void _stopSearch() {
    setState(() {
      isSearching = false;
      filteredNotes = allNotes; // Reset the list when search is canceled
      searchController.clear();
    });
  }

  void _filterNotes(String query) {
    setState(() {
      filteredNotes = allNotes
          .where((note) =>
      note[DBHelper.COLUMN_NOTE_TITLE]
          .toLowerCase()
          .contains(query.toLowerCase()) ||
          note[DBHelper.COLUMN_NOTE_DESC]
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> _confirmDelete(int sno) async {
    // Show confirmation dialog before deleting
    bool? confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete Note"),
          content: Text("Are you sure you want to delete this note?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false); // Cancel the deletion
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true); // Confirm the deletion
              },
              child: Text("Delete"),
            ),
          ],
        );
      },
    );

    // If user confirmed, delete the note
    if (confirmDelete != null && confirmDelete) {
      bool check = await dbRef!.deleteNote(sno: sno);
      if (check) {
        getNotes(); // Refresh the list after deletion
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Note deleted successfully')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: isSearching
            ? TextField(
          focusNode: _focusNode,
          autofocus: true,
          controller: searchController,
          // decoration: InputDecoration(hintText: 'Search notes...'),
          style: TextStyle(color: Colors.grey),
          cursorColor: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black,
          decoration: InputDecoration(
            hintText: 'Search...',
            hintStyle: TextStyle(color: Colors.grey),
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 12),
          ),
          onChanged: _filterNotes,
        )
            : Center(
          child: Text(
            isMultiSelectMode
                ? '${selectedNoteSno.length} Selected'
                : 'Notes',
            style: TextStyle(fontFamily: 'BethEllen'),
          ),
        ),
        actions: [
          if (isMultiSelectMode) ...[
            IconButton(
              icon: Icon(Icons.delete_rounded),
              onPressed: selectedNoteSno.isEmpty
                  ? null
                  : () async {
                bool confirm = await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text("Delete Notes"),
                    content: Text(
                        "Are you sure you want to delete ${selectedNoteSno.length} notes?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text("Delete"),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  for (var sno in selectedNoteSno) {
                    await dbRef!.deleteNote(sno: sno); // named argument used correctly
                  }
                  await getNotes();
                  setState(() {
                    print("selected notes to delete first: ${selectedNoteSno.length}");
                    isMultiSelectMode = false;
                    // selectedNoteSno.clear();
                    // print("selected notes to delete: $selectedNoteSno");
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          '${selectedNoteSno.length} ${selectedNoteSno.length == 1 ? 'note' : 'notes'} deleted'
                      ),
                      backgroundColor: Colors.red[600],
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(seconds: 3),
                      action: SnackBarAction(
                        label: 'Undo',
                        textColor: Colors.white,
                        onPressed: () {
                          // Add undo functionality if needed
                        },
                      ),
                    ),
                  );
                  // ScaffoldMessenger.of(context).showSnackBar(
                  //   SnackBar(
                  //     content: Text('${selectedNoteSno.length} notes deleted'),
                  //   ),
                  // );
                }
              },
            ),
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                setState(() {
                  isMultiSelectMode = false;
                  selectedNoteSno.clear();
                });
              },
            ),
          ] else ...[
            if (isSearching)
              IconButton(
                icon: Icon(Icons.clear),
                onPressed: _stopSearch,
              )
            else
              Row(
                children: [
                  IconButton(
                    icon: Icon(isGridView ? Icons.view_agenda : Icons.grid_view),
                    tooltip: isGridView ? 'Switch to List View' : 'Switch to Grid View',
                    onPressed: () {
                      // getNotes();
                      setState(() {
                        isGridView = !isGridView;
                      });
                    },
                  ),

                  IconButton(
                    icon: Icon(Icons.search),
                    onPressed: _startSearch,
                  ),
                ],
              ),
          ],
        ],
      ),
      drawer: MyDrawer(
        onDeleteMultipleTap: () {
          /// cause of the application crash
          // Navigator.pop(context);
          setState(() {
            isMultiSelectMode = true;
            selectedNoteSno.clear();
          });
        },
      ),
      body: RefreshIndicator.adaptive(
        onRefresh: () async {
          await getNotes();
        },
        child: filteredNotes.isNotEmpty
            ? CustomScrollView(
          slivers: [
            SliverPadding(
              padding: EdgeInsets.all(10),
              sliver: SliverStaggeredGrid.countBuilder(
                crossAxisCount: 2,
                // crossAxisCount: isGridView ? 2 : 1,
                itemCount: filteredNotes.length,
                // staggeredTileBuilder: (index) => StaggeredTile.fit(1),
                // staggeredTileBuilder: (index) =>
                // isGridView ? StaggeredTile.fit(1) : StaggeredTile.extent(1, 2),
                staggeredTileBuilder: (index) => StaggeredTile.fit(isGridView ? 1 : 2),
                mainAxisSpacing: 7,
                crossAxisSpacing: isGridView ? 3 : 0,
                itemBuilder: (context, index) {
                  final note = filteredNotes[index];
                  final sno = note[DBHelper.COLUMN_NOTE_SNO];
                  final isSelected = selectedNoteSno.contains(sno);

                  return GestureDetector(
                    onTap: () {
                      if (isMultiSelectMode) {
                        setState(() {
                          if (isSelected) {
                            selectedNoteSno.remove(sno);
                          } else {
                            selectedNoteSno.add(sno);
                          }
                          // Exit multi-select mode automatically if no notes are selected
                          if (selectedNoteSno.isEmpty) {
                            isMultiSelectMode = false;
                          }
                        });
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditPage(
                              title: note[DBHelper.COLUMN_NOTE_TITLE],
                              description: note[DBHelper.COLUMN_NOTE_DESC],
                              sno: sno,
                            ),
                          ),
                        ).then((value) {
                          if (value == true) {
                            getNotes();
                          }
                        });
                      }
                    },
                    onLongPress: () {
                      if (!isMultiSelectMode) {
                        setState(() {
                          isMultiSelectMode = true;
                          selectedNoteSno.add(sno);
                        });
                      }
                    },
                    child: Card(
                      margin: EdgeInsets.symmetric(horizontal: isGridView ? 0 : 5, vertical: 3),
                      elevation: 4,
                      color: isSelected ? Colors.red[200] : null,
                      child: Column(
                        children: [
                          ListTile(
                            title: Row(
                              children: [
                                Text(
                                  '${index + 1}',
                                  style: TextStyle(fontSize: 15),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                    note[DBHelper.COLUMN_NOTE_TITLE],
                                    style: TextStyle(
                                      fontSize: 19,
                                      fontFamily: 'Smooch',
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(left: 16.0),
                              child: Text(
                                note[DBHelper.COLUMN_NOTE_DESC] != null &&
                                    note[DBHelper.COLUMN_NOTE_DESC]
                                        .toString()
                                        .trim()
                                        .isNotEmpty
                                    ? getPlainTextFromDeltaJson(note[
                                DBHelper.COLUMN_NOTE_DESC])
                                    : '',
                                maxLines: 5,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        )
            : Center(
          child: Text(
            'No Notes yet!!',
            style: TextStyle(fontFamily: 'BethEllen'),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal[400],
        onPressed: () async {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            useSafeArea: true,
            builder: (context) {
              titleController.clear();
              descController.clear();
              return getBottomSheetWidget();
            },
          );
        },
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget getBottomSheetWidget({bool isUpdate = false, int sno = 0}) {
    // Define a form key to control the form validation
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(11),
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
        child: Column(
          children: [
            Text(
              'Add Note',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 21,
            ),
            // Wrap the form fields in a Form widget for validation
            Form(
              key: _formKey, // Assign the form key
              child: Column(
                children: [
                  // Title Input Field
                  TextFormField(
                    controller: titleController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: "Title",
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none, // No border to mimic Google Keep
                    ),
                    // Add validator for title field
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Title cannot be empty';
                      }
                      // if (value.length > maxTitleLength) {
                      //   return 'Title cannot exceed $maxTitleLength characters';
                      // }
                      return null;
                    },
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: null,
                    textAlign: TextAlign.start,
                  ),
                  SizedBox(
                    height: 11,
                  ),
                  TextField(
                    controller: descController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: "Enter description here",
                      label: Text('Description'),
                      border: InputBorder.none,
                    ),
                  ),
                  SizedBox(
                    height: 11,
                  ),
                  // Action Buttons
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
                            if (_formKey.currentState!.validate()) {
                              var title = titleController.text;
                              var desc = descController.text;
                              if (title.isNotEmpty && desc.isNotEmpty) {
                              bool check = isUpdate
                                  ? await dbRef!.updateNote(
                                  mTitle: title, mDesc: desc, sno: sno)
                                  : await dbRef!
                                  .addNote(mTitle: title, mDesc: desc);
                              if (check) {
                                getNotes();
                              }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    content: Text(
                                    'Please fill all the required blanks!!')));
                            }
                              // Convert Quill document to Delta JSON string
                              // var descDeltaJson = jsonEncode(descController.document.toDelta().toJson());

                              // bool check = isUpdate
                              //     ? await dbRef!.updateNote(mTitle: title, mDesc: descDeltaJson, sno: sno)
                              //     : await dbRef!.addNote(mTitle: title, mDesc: descDeltaJson);

                              // if (check) {
                              //   getNotes();
                              // }

                              titleController.clear();
                              descController.clear();
                              // descController.document.close(); // Clear Quill controller
                              Navigator.pop(context);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Please fix the errors in the form!')),
                              );
                            }
                          },
                          child: Text(isUpdate ? 'Update Note' : 'Add Note'),
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
                            Navigator.pop(context);
                          },
                          child: Text('Cancel'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// @override
// Widget build(BuildContext context) {
//   return Scaffold(
//     backgroundColor: Theme.of(context).colorScheme.surface,
//     appBar: AppBar(
//       title: isSearching
//           ? TextField(
//         controller: searchController,
//         decoration: InputDecoration(hintText: 'Search notes...'),
//         onChanged: _filterNotes,
//       )
//           : Center(
//         child: Text(
//           'Notes',
//           style: TextStyle(fontFamily: 'BethEllen'),
//         ),
//       ),
//       actions: [
//         isSearching
//             ? IconButton(
//           icon: Icon(Icons.clear),
//           onPressed: _stopSearch,
//         )
//             : IconButton(
//           icon: Icon(Icons.search),
//           onPressed: _startSearch,
//         ),
//       ],
//     ),
//     drawer: const MyDrawer(),
//
//     body: RefreshIndicator.adaptive(
//       onRefresh: () async {
//         await getNotes(); // Your DB fetch method
//       },
//       child: filteredNotes.isNotEmpty
//           ? CustomScrollView(
//         slivers: [
//           SliverPadding(
//             padding: EdgeInsets.all(10),
//             sliver: SliverStaggeredGrid.countBuilder(
//               crossAxisCount: 2,
//               itemCount: filteredNotes.length,
//               staggeredTileBuilder: (index) => StaggeredTile.fit(1),
//               mainAxisSpacing: 7,
//               crossAxisSpacing: 3,
//               itemBuilder: (context, index) {
//                 return GestureDetector(
//                   onTap: () {
//                     /// On tap, navigate to the EditPage
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => EditPage(
//                           title: filteredNotes[index][DBHelper.COLUMN_NOTE_TITLE],
//                           description: filteredNotes[index][DBHelper.COLUMN_NOTE_DESC],
//                           sno: filteredNotes[index][DBHelper.COLUMN_NOTE_SNO],
//                         ),
//                       ),
//                     ).then((value){
//                       if(value == true){
//                         getNotes();
//                       }
//                     });
//                   },
//                   onLongPress: () {
//                     // Show the confirmation dialog for deleting the note
//                     _confirmDelete(filteredNotes[index][DBHelper.COLUMN_NOTE_SNO]);
//                   },
//
//                   child: Card(
//                     elevation: 4,
//                     child: Column(
//                       children: [
//                         ListTile(
//                           title: Row(
//                             children: [
//                               /// notes index
//                               Text(
//                                 '${index + 1}',
//                                 style: TextStyle(
//                                   fontSize: 15,
//                                 ),
//                               ),
//
//                               SizedBox(width: 8,),
//                               /// notes title
//                               Expanded(
//                                 child: Text(
//                                   overflow: TextOverflow.ellipsis,
//                                   maxLines: 2,
//                                   filteredNotes[index][DBHelper.COLUMN_NOTE_TITLE],
//                                   style: TextStyle(
//                                     fontSize: 19,
//                                     fontFamily: 'Smooch',
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           /// notes description
//                           subtitle: Padding(
//                             padding: const EdgeInsets.only(left: 16.0),
//                             child: Text(
//                               filteredNotes[index][DBHelper.COLUMN_NOTE_DESC] != null &&
//                                   filteredNotes[index][DBHelper.COLUMN_NOTE_DESC].toString().trim().isNotEmpty
//                                   ? getPlainTextFromDeltaJson(filteredNotes[index][DBHelper.COLUMN_NOTE_DESC])
//                                   : '', // fallback text if null or invalid
//                               maxLines: 5,
//                               overflow: TextOverflow.ellipsis,
//                               style: TextStyle(
//                                 fontSize: 14,
//                                 fontFamily: 'Roboto',
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           ),
//
//                           // subtitle: Padding(
//                           //   padding: const EdgeInsets.only(left: 16.0),
//                           //   child: Text(
//                           //     filteredNotes[index][DBHelper.COLUMN_NOTE_DESC],
//                           //     maxLines: 9,
//                           //     style: TextStyle(
//                           //       fontSize: 14,
//                           //       fontFamily: 'Roboto',
//                           //       fontWeight: FontWeight.w500,
//                           //     ),
//                           //   ),
//                           // ),
//                         ),
//
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       )
//           : Center(
//         child: Text(
//           'No Notes yet!!',
//           style: TextStyle(fontFamily: 'BethEllen'),
//         ),
//       ),
//     ),
//
//     floatingActionButton: FloatingActionButton(
//       backgroundColor: Colors.teal[400],
//       onPressed: () async {
//         // Add note - open the same bottom sheet to add a new note
//         showModalBottomSheet(
//           context: context,
//           isScrollControlled: true,
//           useSafeArea: true,
//           builder: (context) {
//             titleController.clear();
//             descController.clear();
//             return getBottomSheetWidget();
//           },
//         );
//       },
//       child: Icon(
//         Icons.add,
//         color: Colors.white,
//         // color: Colors.grey.shade700,
//       ),
//     ),
//   );
// }




// import 'package:db_practice/component/drawer.dart';
// import 'package:db_practice/data/local/db_helper.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
// import 'package:intl/intl.dart';
// import 'edit_page.dart';
// import 'package:flutter_quill/flutter_quill.dart' as quill;
// import 'package:dart_quill_delta/dart_quill_delta.dart';
// import 'dart:convert';
// import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
//
// class HomePage extends StatefulWidget {
//   @override
//   State<HomePage> createState() => _HomePageState();
// }
//
// class _HomePageState extends State<HomePage> {
//   // late TextEditingController titleController;
//   // late quill.QuillController descController;
//   List<Map<String, dynamic>> filteredNotes = [];
//   List<Map<String, dynamic>> pinnedNotes = [];
//   List<Map<String, dynamic>> unpinnedNotes = [];
//   bool isSearching = false;
//   TextEditingController searchController = TextEditingController();
//   Set<int> selectedNoteIds = {};
//   bool selectionMode = false;
//
//   /// controllers
//   TextEditingController titleController = TextEditingController();
//   // late quill.QuillController descController;
//   TextEditingController descController = TextEditingController();
//   FocusNode _focusNode = FocusNode();
//
//   final int maxTitleLength = 7;   /// maximum title length
//
//   List<Map<String, dynamic>> allNotes = [];
//   DBHelper? dbRef;
//
//   @override
//   void initState() {
//     super.initState();
//     dbRef = DBHelper.getInstance;
//     getNotes();
//     filteredNotes = [];
//
//     for (var note in allNotes) {
//       print(formatDate(note['created_at']));
//     }
//
//     // descController = quill.QuillController.basic();
//
//     // Avoid calling setState during build
//     // descController.addListener(() {
//     //   WidgetsBinding.instance.addPostFrameCallback((_) {
//     //     if (mounted) setState(() {});
//     //   });
//     // });
//     loadAndApplySortOrder();
//   }
//
//   String formatDate(String? isoDate) {
//     if (isoDate == null) return '';
//     final dt = DateTime.tryParse(isoDate);
//     if (dt == null) return '';
//     return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
//   }
//
//   Future<void> loadAndApplySortOrder() async {
//     final prefs = await SharedPreferences.getInstance();
//     final savedSortOrder = prefs.getString('sortOrder') ?? 'newest'; // default sort
//     await getNotes();
//     _sortNotes(savedSortOrder);
//   }
//
//   void _sortNotes(String order) {
//     setState(() {
//       if (order == 'newest') {
//         pinnedNotes.sort((a, b) => b['modifiedDate'].compareTo(a['modifiedDate']));
//         unpinnedNotes.sort((a, b) => b['modifiedDate'].compareTo(a['modifiedDate']));
//       } else if (order == 'oldest') {
//         pinnedNotes.sort((a, b) => a['modifiedDate'].compareTo(b['modifiedDate']));
//         unpinnedNotes.sort((a, b) => a['modifiedDate'].compareTo(b['modifiedDate']));
//       }
//       // else if (order == 'az') {
//       //   pinnedNotes.sort((a, b) =>
//       //       a['title'].toLowerCase().compareTo(b['title'].toLowerCase()));
//       //   unpinnedNotes.sort((a, b) =>
//       //       a['title'].toLowerCase().compareTo(b['title'].toLowerCase()));
//       // } else if (order == 'za') {
//       //   pinnedNotes.sort((a, b) =>
//       //       b['title'].toLowerCase().compareTo(a['title'].toLowerCase()));
//       //   unpinnedNotes.sort((a, b) =>
//       //       b['title'].toLowerCase().compareTo(a['title'].toLowerCase()));
//       // }
//     });
//   }
//
//   void _separatePinnedNotes() {
//     pinnedNotes = filteredNotes.where((note) => note['is_pinned'] == 1).toList();
//     unpinnedNotes = filteredNotes.where((note) => note['is_pinned'] != 1).toList();
//   }
//
//   Future<void> _togglePinNote(int sno, bool currentlyPinned) async {
//     bool success = await dbRef!.togglePinNote(sno: sno, isPinned: !currentlyPinned);
//     if (success) {
//       await getNotes();
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(currentlyPinned ? 'Note unpinned' : 'Note pinned'),
//           duration: Duration(seconds: 1),
//         ),
//       );
//     }
//   }
//
//   String getPlainTextFromDeltaJson(dynamic deltaJson) {
//     try {
//       dynamic parsedDelta;
//
//       if (deltaJson is String) {
//         try {
//           parsedDelta = jsonDecode(deltaJson);
//         } catch (_) {
//           // It's plain text, wrap it in Quill's Delta format
//           parsedDelta = [
//             {'insert': deltaJson + '\n'}
//           ];
//         }
//       } else {
//         parsedDelta = deltaJson;
//       }
//
//       final delta = Delta.fromJson(parsedDelta);
//       final document = quill.Document.fromDelta(delta);
//       return document.toPlainText().trim();
//     } catch (e) {
//       print("Error building document: $e");
//       return '[Error loading note]';
//     }
//   }
//
//   // String getPlainTextFromDeltaJson(String deltaJson) {
//   //   try {
//   //     final delta = quill.Delta.fromJson(jsonDecode(deltaJson));
//   //     final document = quill.Document.fromDelta(delta);
//   //     return document.toPlainText().trim();
//   //   } catch (e) {
//   //     return '[Error loading note]';
//   //   }
//   // }
//
//   Future<void> getNotes() async {
//     allNotes = await dbRef!.getAllNotes();
//     setState(() {
//       filteredNotes = allNotes;
//       _separatePinnedNotes();
//     });
//   }
//
//   void _startSearch() {
//     FocusScope.of(context).requestFocus(_focusNode);
//     setState(() {
//       isSearching = true;
//     });
//   }
//
//   void _stopSearch() {
//     setState(() {
//       isSearching = false;
//       filteredNotes = allNotes; // Reset the list when search is canceled
//       _separatePinnedNotes();
//       searchController.clear();
//     });
//   }
//
//   void _filterNotes(String query) {
//     setState(() {
//       filteredNotes = allNotes
//           .where((note) =>
//       note[DBHelper.COLUMN_NOTE_TITLE]
//           .toLowerCase()
//           .contains(query.toLowerCase()) ||
//           note[DBHelper.COLUMN_NOTE_DESC]
//               .toLowerCase()
//               .contains(query.toLowerCase()))
//           .toList();
//       _separatePinnedNotes();
//     });
//   }
//
//   Future<void> _confirmDelete(int sno) async {
//     // Show confirmation dialog before deleting
//     bool? confirmDelete = await showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text("Delete Note"),
//           content: Text("Are you sure you want to delete this note?"),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context, false); // Cancel the deletion
//               },
//               child: Text("Cancel"),
//             ),
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context, true); // Confirm the deletion
//               },
//               child: Text("Delete"),
//             ),
//           ],
//         );
//       },
//     );
//
//     // If user confirmed, delete the note
//     if (confirmDelete != null && confirmDelete) {
//       bool check = await dbRef!.deleteNote(sno: sno);
//       if (check) {
//         getNotes(); // Refresh the list after deletion
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Note deleted successfully')),
//         );
//       }
//     }
//   }
//
//   Widget _buildNoteCard(Map<String, dynamic> note, int index, bool isPinned) {
//     return GestureDetector(
//       onTap: () {
//         /// On tap, navigate to the EditPage
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => EditPage(
//               title: note[DBHelper.COLUMN_NOTE_TITLE],
//               description: note[DBHelper.COLUMN_NOTE_DESC],
//               sno: note[DBHelper.COLUMN_NOTE_SNO],
//             ),
//           ),
//         ).then((value){
//           if(value == true){
//             getNotes();
//           }
//         });
//       },
//       onLongPress: () {
//         // Show the confirmation dialog for deleting the note
//         _confirmDelete(note[DBHelper.COLUMN_NOTE_SNO]);
//       },
//
//       child: Card(
//         elevation: 4,
//         child: Stack(
//           children: [
//             Column(
//               children: [
//                 ListTile(
//                   title: Row(
//                     children: [
//                       /// notes index
//                       Text(
//                         '${index + 1}',
//                         style: TextStyle(
//                           fontSize: 15,
//                         ),
//                       ),
//
//                       SizedBox(width: 8,),
//                       /// notes title
//                       Expanded(
//                         child: Text(
//                           overflow: TextOverflow.ellipsis,
//                           maxLines: 2,
//                           note[DBHelper.COLUMN_NOTE_TITLE],
//                           style: TextStyle(
//                             fontSize: 19,
//                             fontFamily: 'Smooch',
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   /// notes description
//                   subtitle: Padding(
//                     padding: const EdgeInsets.only(left: 16.0),
//                     child: Text(
//                       note[DBHelper.COLUMN_NOTE_DESC] != null &&
//                           note[DBHelper.COLUMN_NOTE_DESC].toString().trim().isNotEmpty
//                           ? getPlainTextFromDeltaJson(note[DBHelper.COLUMN_NOTE_DESC])
//                           : '', // fallback text if null or invalid
//                       maxLines: 5,
//                       overflow: TextOverflow.ellipsis,
//                       style: TextStyle(
//                         fontSize: 14,
//                         fontFamily: 'Roboto',
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ),
//
//                   // subtitle: Padding(
//                   //   padding: const EdgeInsets.only(left: 16.0),
//                   //   child: Text(
//                   //     note[DBHelper.COLUMN_NOTE_DESC],
//                   //     maxLines: 9,
//                   //     style: TextStyle(
//                   //       fontSize: 14,
//                   //       fontFamily: 'Roboto',
//                   //       fontWeight: FontWeight.w500,
//                   //     ),
//                   //   ),
//                   // ),
//                 ),
//               ],
//             ),
//             // Pin icon positioned at top-right
//             Positioned(
//               top: 8,
//               right: 8,
//               child: GestureDetector(
//                 onTap: () => _togglePinNote(
//                     note[DBHelper.COLUMN_NOTE_SNO],
//                     note['is_pinned'] == 1
//                 ),
//                 child: Container(
//                   padding: EdgeInsets.all(4),
//                   decoration: BoxDecoration(
//                     color: Colors.white.withOpacity(0.8),
//                     shape: BoxShape.circle,
//                   ),
//                   child: Icon(
//                     note['is_pinned'] == 1 ? Icons.push_pin : Icons.push_pin_outlined,
//                     size: 20,
//                     color: note['is_pinned'] == 1 ? Colors.orange : Colors.grey,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildSection(String title, List<Map<String, dynamic>> notes, bool isPinned) {
//     if (notes.isEmpty) return SizedBox.shrink();
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         if (pinnedNotes.isNotEmpty && unpinnedNotes.isNotEmpty)
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             child: Text(
//               title,
//               style: TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.grey[600],
//                 letterSpacing: 0.5,
//               ),
//             ),
//           ),
//
//         /// Wrap in LayoutBuilder to avoid unbounded height
//         Padding(
//           padding: EdgeInsets.symmetric(horizontal: 10),
//           child: LayoutBuilder(
//             builder: (context, constraints) {
//               return StaggeredGrid.count(
//                 crossAxisCount: 2,
//                 mainAxisSpacing: 7,
//                 crossAxisSpacing: 3,
//                 children: notes.asMap().entries.map((entry) {
//                   int index = entry.key;
//                   Map<String, dynamic> note = entry.value;
//                   return StaggeredGridTile.fit(
//                     crossAxisCellCount: 1,
//                     child: _buildNoteCard(note, index, isPinned),
//                   );
//                 }).toList(),
//               );
//             },
//           ),
//         ),
//
//         if (pinnedNotes.isNotEmpty && unpinnedNotes.isNotEmpty && isPinned)
//           SizedBox(height: 16),
//       ],
//     );
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Theme.of(context).colorScheme.surface,
//       appBar: AppBar(
//         title: isSearching
//             ? TextField(
//           controller: searchController,
//           decoration: InputDecoration(hintText: 'Search notes...'),
//           onChanged: _filterNotes,
//         )
//             : Center(
//           child: Text(
//             'Notes',
//             style: TextStyle(fontFamily: 'BethEllen'),
//           ),
//         ),
//         actions: [
//           isSearching
//               ? IconButton(
//             icon: Icon(Icons.clear),
//             onPressed: _stopSearch,
//           )
//               : IconButton(
//             icon: Icon(Icons.search),
//             onPressed: _startSearch,
//           ),
//         ],
//       ),
//       drawer: const MyDrawer(),
//       body: (pinnedNotes.isNotEmpty || unpinnedNotes.isNotEmpty)
//           ? RefreshIndicator.adaptive(
//         onRefresh: () async {
//           await getNotes(); // Your DB fetch method
//         },
//         child: CustomScrollView(
//           slivers: [
//             // Pinned notes section
//             if (pinnedNotes.isNotEmpty) ...[
//               SliverToBoxAdapter(
//                 child: _buildSection('PINNED', pinnedNotes, true),
//               ),
//             ],
//             // Regular notes section
//             if (unpinnedNotes.isNotEmpty) ...[
//               SliverToBoxAdapter(
//                 child: _buildSection('OTHERS', unpinnedNotes, false),
//               ),
//             ],
//           ],
//         ),
//       )
//           : RefreshIndicator.adaptive(
//         onRefresh: () async {
//           await getNotes();
//         },
//         child: SingleChildScrollView(
//           physics: AlwaysScrollableScrollPhysics(),
//           child: SizedBox(
//             height: MediaQuery.of(context).size.height * 0.8,
//             child: Center(
//               child: Text(
//                 'No Notes yet!!',
//                 style: TextStyle(fontFamily: 'BethEllen'),
//               ),
//             ),
//           ),
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         backgroundColor: Colors.teal[400],
//         onPressed: () async {
//           // Add note - open the same bottom sheet to add a new note
//           showModalBottomSheet(
//             context: context,
//             isScrollControlled: true,
//             useSafeArea: true,
//             builder: (context) {
//               titleController.clear();
//               descController.clear();
//               return getBottomSheetWidget();
//             },
//           );
//         },
//         child: Icon(
//           Icons.add,
//           color: Colors.white,
//         ),
//       ),
//     );
//   }
//
//   Widget getBottomSheetWidget({bool isUpdate = false, int sno = 0}) {
//     // Define a form key to control the form validation
//     final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//
//     return SingleChildScrollView(
//       child: Container(
//         padding: EdgeInsets.all(11),
//         height: MediaQuery.of(context).size.height,
//         width: double.infinity,
//         child: Column(
//           children: [
//             Text(
//               'Add Note',
//               style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(
//               height: 21,
//             ),
//             // Wrap the form fields in a Form widget for validation
//             Form(
//               key: _formKey, // Assign the form key
//               child: Column(
//                 children: [
//                   // Title Input Field
//                   TextFormField(
//                     controller: titleController,
//                     autofocus: true,
//                     decoration: InputDecoration(
//                       hintText: "Title",
//                       hintStyle: TextStyle(color: Colors.grey),
//                       border: InputBorder.none, // No border to mimic Google Keep
//                     ),
//                     // Add validator for title field
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Title cannot be empty';
//                       }
//                       // if (value.length > maxTitleLength) {
//                       //   return 'Title cannot exceed $maxTitleLength characters';
//                       // }
//                       return null;
//                     },
//                     style: TextStyle(
//                       fontSize: 22,
//                       fontWeight: FontWeight.bold,
//                     ),
//                     maxLines: null,
//                     textAlign: TextAlign.start,
//                   ),
//                   SizedBox(
//                     height: 11,
//                   ),
//                   TextField(
//                     controller: descController,
//                     maxLines: 4,
//                     decoration: InputDecoration(
//                       hintText: "Enter description here",
//                       label: Text('Description'),
//                       border: InputBorder.none,
//                     ),
//                   ),
//                   SizedBox(
//                     height: 11,
//                   ),
//                   // Action Buttons
//                   Row(
//                     children: [
//                       Expanded(
//                         child: OutlinedButton(
//                           style: OutlinedButton.styleFrom(
//                             side: BorderSide(width: 1),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(11),
//                             ),
//                           ),
//                           onPressed: () async {
//                             if (_formKey.currentState!.validate()) {
//                               var title = titleController.text;
//                               var desc = descController.text;
//                               if (title.isNotEmpty && desc.isNotEmpty) {
//                                 bool check = isUpdate
//                                     ? await dbRef!.updateNote(
//                                     mTitle: title, mDesc: desc, sno: sno)
//                                     : await dbRef!
//                                     .addNote(mTitle: title, mDesc: desc);
//                                 if (check) {
//                                   getNotes();
//                                 }
//                               } else {
//                                 ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//                                     content: Text(
//                                         'Please fill all the required blanks!!')));
//                               }
//                               // Convert Quill document to Delta JSON string
//                               // var descDeltaJson = jsonEncode(descController.document.toDelta().toJson());
//
//                               // bool check = isUpdate
//                               //     ? await dbRef!.updateNote(mTitle: title, mDesc: descDeltaJson, sno: sno)
//                               //     : await dbRef!.addNote(mTitle: title, mDesc: descDeltaJson);
//
//                               // if (check) {
//                               //   getNotes();
//                               // }
//
//                               titleController.clear();
//                               descController.clear();
//                               // descController.document.close(); // Clear Quill controller
//                               Navigator.pop(context);
//                             } else {
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 SnackBar(content: Text('Please fix the errors in the form!')),
//                               );
//                             }
//                           },
//                           child: Text(isUpdate ? 'Update Note' : 'Add Note'),
//                         ),
//                       ),
//                       SizedBox(width: 11),
//                       Expanded(
//                         child: OutlinedButton(
//                           style: OutlinedButton.styleFrom(
//                             side: BorderSide(width: 1),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(11),
//                             ),
//                           ),
//                           onPressed: () {
//                             Navigator.pop(context);
//                           },
//                           child: Text('Cancel'),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }








//       ListTile(
//       onLongPress: () {
// setState(() {
// selectionMode = true;
// selectedNoteIds.add(filteredNotes[index]['id']); // or your ID key
// });
// },
//   onTap: () {
//     if (selectionMode) {
//       int noteId = filteredNotes[index]['id'];
//       setState(() {
//         if (selectedNoteIds.contains(noteId)) {
//           selectedNoteIds.remove(noteId);
//           if (selectedNoteIds.isEmpty) selectionMode = false;
//         } else {
//           selectedNoteIds.add(noteId);
//         }
//       });
//     } else {
//       // Normal navigation or view logic
//     }
//   },
//   leading: selectionMode
//       ? Checkbox(
//     value: selectedNoteIds.contains(filteredNotes[index]['id']),
//     onChanged: (isChecked) {
//       setState(() {
//         if (isChecked == true) {
//           selectedNoteIds.add(filteredNotes[index]['id']);
//         } else {
//           selectedNoteIds.remove(filteredNotes[index]['id']);
//           if (selectedNoteIds.isEmpty) selectionMode = false;
//         }
//       });
//     },
//   )
//       : null,
//   title: Text(filteredNotes[index]['title'] ?? 'Untitled'),
//   subtitle: Text(
//     getPlainTextFromDeltaJson(filteredNotes[index]['desc']),
//     maxLines: 2,
//     overflow: TextOverflow.ellipsis,
//   ),
// ),


// Description Input Field
// Container(
//   height: 200, // Adjust as needed
//   // padding: EdgeInsets.symmetric(vertical: 8),
//   // decoration: BoxDecoration(
//   //   border: Border.all(color: Colors.grey),
//   //   borderRadius: BorderRadius.circular(8),
//   // ),
//   child: Stack(
//     children: [
//       quill.QuillEditor.basic(
//         controller: descController,
//         // readOnly: false,
//       ),
//       // Show hint only when document is empty
//       if (descController.document.toPlainText().replaceAll('\n', '').trim().isEmpty)
//       // if (descController.document.isEmpty() || descController.document.toPlainText().trim().isEmpty)
//         Positioned(
//           top: 8,
//           child: Text(
//             'Description',
//             style: TextStyle(
//               color: Colors.grey,
//               fontSize: 22,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//     ],
//   ),
//   // quill.QuillEditor.basic(
//   //   controller: descController,
//   //   // readOnly: false,
//   // ),
// ),



// Row(
//   children: [
//     Expanded(
//       child: OutlinedButton(
//         style: OutlinedButton.styleFrom(
//           side: BorderSide(width: 1),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(11),
//           ),
//         ),
//         onPressed: () async {
//           // Validate form before proceeding
//           if (_formKey.currentState!.validate()) {
//             var title = titleController.text;
//             var desc = descController.text;
//             bool check = isUpdate
//                 ? await dbRef!.updateNote(
//                 mTitle: title, mDesc: desc, sno: sno)
//                 : await dbRef!.addNote(mTitle: title, mDesc: desc);
//             if (check) {
//               getNotes();
//             }
//             titleController.clear();
//             descController.clear();
//             Navigator.pop(context);
//           } else {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(content: Text('Please fix the errors in the form!')),
//             );
//           }
//         },
//         child: Text(isUpdate ? 'Update Note' : 'Add Note'),
//       ),
//     ),
//     SizedBox(
//       width: 11,
//     ),
//     Expanded(
//       child: OutlinedButton(
//         style: OutlinedButton.styleFrom(
//           side: BorderSide(width: 1),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(11),
//           ),
//         ),
//         onPressed: () {
//           Navigator.pop(context); // Cancel and return to HomePage
//         },
//         child: Text('Cancel'),
//       ),
//     ),
//   ],
// ),