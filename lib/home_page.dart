import 'package:db_practice/component/drawer.dart';
import 'package:db_practice/data/local/db_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List<Map<String, dynamic>> filteredNotes = [];
  bool isSearching = false;
  TextEditingController searchController = TextEditingController();

  /// controllers
  TextEditingController titleController = TextEditingController();
  TextEditingController descController = TextEditingController();

  List<Map<String, dynamic>> allNotes = [];
  DBHelper? dbRef;

  @override
  void initState() {
    super.initState();
    dbRef = DBHelper.getInstance;
    getNotes();
    filteredNotes = []; // Initially display all notes
  }

  void getNotes() async {
    allNotes = await dbRef!.getAllNotes();
    setState(() {
      filteredNotes = allNotes; // Set the initial list to all notes
    });
  }

  void _startSearch() {
    setState(() {
      isSearching = true;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: isSearching
            ? TextField(
          controller: searchController,
          decoration: InputDecoration(hintText: 'Search notes...'),
          onChanged: _filterNotes,
        )
            : Center(child: Text('Notes', style: TextStyle(fontFamily: 'BethEllen'),)),    /// appbar title
        actions: [
          isSearching
              ? IconButton(
            icon: Icon(Icons.clear),
            onPressed: _stopSearch,
          )
              : IconButton(
            icon: Icon(Icons.search),
            onPressed: _startSearch,
          ),
        ],
      ),

      drawer: const MyDrawer(),

      body: filteredNotes.isNotEmpty
          ? ListView.builder(
        itemCount: filteredNotes.length,
        itemBuilder: (_, index) {
          return Slidable(
            endActionPane: ActionPane(
              motion: StretchMotion(),
              children: [
                SlidableAction(
                  onPressed: (context) {
                    /// Edit note
                    showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        useSafeArea: true,
                        builder: (context) {
                          titleController.text =
                          filteredNotes[index][DBHelper.COLUMN_NOTE_TITLE];
                          descController.text =
                          filteredNotes[index][DBHelper.COLUMN_NOTE_DESC];
                          return getBottomSheetWidget(
                              isUpdate: true,
                              sno: filteredNotes[index][DBHelper.COLUMN_NOTE_SNO]);
                        });
                  },
                  icon: Icons.edit,
                  backgroundColor: Colors.grey.shade300,
                  label: 'Edit',
                ),
                SlidableAction(
                  onPressed: (context) async {
                    /// Delete note
                    bool check = await dbRef!.deleteNote(
                        sno: filteredNotes[index][DBHelper.COLUMN_NOTE_SNO]);
                    if (check) {
                      getNotes();
                    }
                  },
                  icon: Icons.delete,
                  label: 'Delete',
                  backgroundColor: Colors.red,
                ),
              ],
            ),

            /// main notes list
            child: ListTile(
              leading: Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontSize: 15,
                  ),
              ),
              title: Text(
                filteredNotes[index][DBHelper.COLUMN_NOTE_TITLE],
                style: TextStyle(
                  fontSize: 19,
                  fontFamily: 'Smooch',
                  fontWeight: FontWeight.w500
                ),

              ),
              subtitle: Text(
                filteredNotes[index][DBHelper.COLUMN_NOTE_DESC],
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w500,
                ),

              ),
            ),
          );
        },
      )
          : Center(child: Text(
          'No Notes yet!!',
          style: TextStyle(fontFamily: 'BethEllen'),
      )),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal[400],
        onPressed: () async {
          // Add note
          showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              useSafeArea: true,
              builder: (context) {
                titleController.clear();
                descController.clear();
                return getBottomSheetWidget();
              });
        },
        child: Icon(Icons.add, color: Colors.grey.shade700,),
      ),
    );
  }

  Widget getBottomSheetWidget({bool isUpdate = false, int sno = 0}) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(11),
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
        child: Column(
          children: [
            Text(
              isUpdate ? 'Update Note' : 'Add Note',
              style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 21,
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
                  )),
            ),
            SizedBox(
              height: 11,
            ),
            TextField(
              controller: descController,
              maxLines: 4,
              decoration: InputDecoration(
                  hintText: "Enter desc here",
                  label: Text('Description'),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(11),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(11),
                  )),
            ),
            SizedBox(
              height: 11,
            ),
            Row(
              children: [
                Expanded(
                    child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                            side: BorderSide(width: 1),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(11))),
                        onPressed: () async {
                          var title = titleController.text;
                          var desc = descController.text;
                          if (title.isNotEmpty && desc.isNotEmpty) {
                            bool check = isUpdate
                                ? await dbRef!.updateNote(
                                mTitle: title, mDesc: desc, sno: sno)
                                : await dbRef!.addNote(mTitle: title, mDesc: desc);
                            if (check) {
                              getNotes();
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text('Please fill all the required blanks!!')));
                          }

                          titleController.clear();
                          descController.clear();

                          Navigator.pop(context);
                        },
                        child: Text(isUpdate ? 'Update Note' : 'Add Note'))),
                SizedBox(
                  width: 11,
                ),
                Expanded(
                    child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                            side: BorderSide(width: 1),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(11))),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('Cancel'))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
