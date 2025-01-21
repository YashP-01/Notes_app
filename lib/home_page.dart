import 'package:db_practice/component/drawer.dart';
import 'package:db_practice/data/local/db_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'edit_page.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

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
    return LiquidPullToRefresh(
      onRefresh: () async {
        await allNotes;
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          title: isSearching
              ? TextField(
            controller: searchController,
            decoration: InputDecoration(hintText: 'Search notes...'),
            onChanged: _filterNotes,
          )
              : Center(
            child: Text(
              'Notes',
              style: TextStyle(fontFamily: 'BethEllen'),
            ),
          ),
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
            ? CustomScrollView(
          slivers: [
            SliverPadding(
              padding: EdgeInsets.all(10),
              sliver: SliverStaggeredGrid.countBuilder(
                crossAxisCount: 2,
                itemCount: filteredNotes.length,
                staggeredTileBuilder: (index) => StaggeredTile.fit(1),
                mainAxisSpacing: 7,
                crossAxisSpacing: 3,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      // On tap, navigate to the EditPage
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditPage(
                            title: filteredNotes[index][DBHelper.COLUMN_NOTE_TITLE],
                            description: filteredNotes[index][DBHelper.COLUMN_NOTE_DESC],
                            sno: filteredNotes[index][DBHelper.COLUMN_NOTE_SNO],
                          ),
                        ),
                      ).then((value){
                        if(value == true){
                          getNotes();
                        }
                      });
                    },
                    onLongPress: () {
                      // Show the confirmation dialog for deleting the note
                      _confirmDelete(filteredNotes[index][DBHelper.COLUMN_NOTE_SNO]);
                    },
                    child: Card(
                      elevation: 4,
                      child: Column(
                        children: [
                          ListTile(
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
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: Text(
                              filteredNotes[index][DBHelper.COLUMN_NOTE_DESC],
                              maxLines: 9,
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.w500,
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
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.teal[400],
          onPressed: () async {
            // Add note - open the same bottom sheet to add a new note
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
          child: Icon(
            Icons.add,
            color: Colors.grey.shade700,
          ),
        ),
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
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
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
                ),
              ),
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
                ),
              ),
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
                        borderRadius: BorderRadius.circular(11),
                      ),
                    ),
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
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Please fill all the required blanks!!')),
                        );
                      }

                      titleController.clear();
                      descController.clear();

                      Navigator.pop(context);
                    },
                    child: Text(isUpdate ? 'Update Note' : 'Add Note'),
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
                      Navigator.pop(context); // Cancel and return to HomePage
                    },
                    child: Text('Cancel'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}