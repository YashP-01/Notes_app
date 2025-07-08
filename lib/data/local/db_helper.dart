import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  // singleton constructor
  DBHelper._();

  static final DBHelper getInstance = DBHelper._();

  // table note
  static final String TABLE_NOTE = "note";
  static final String COLUMN_NOTE_SNO = "s_no";
  static final String COLUMN_NOTE_TITLE = "title";
  static final String COLUMN_NOTE_DESC = "desc";

  Database? myDB;

  /// db open (path -> if exists then open else create db)
  Future<Database> getDB() async {
    myDB = myDB ?? await openDB();
    return myDB!;
  }

  Future<Database> openDB() async {
    Directory appDir = await getApplicationDocumentsDirectory();
    String dbPath = join(appDir.path, "nodeDB.db");

    return await openDatabase(
      dbPath,
      onCreate: (db, version) async {
        // Create all your tables here
        await db.execute('''
          CREATE TABLE $TABLE_NOTE (
            $COLUMN_NOTE_SNO INTEGER PRIMARY KEY AUTOINCREMENT,
            $COLUMN_NOTE_TITLE TEXT,
            $COLUMN_NOTE_DESC TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // Handle schema changes here if upgrading the database version
        if (oldVersion < 2) {
          // Add necessary migrations (like adding new tables, altering columns, etc.)
          // Example: Creating the table if it doesn't exist
          await db.execute('''
            CREATE TABLE IF NOT EXISTS $TABLE_NOTE (
              $COLUMN_NOTE_SNO INTEGER PRIMARY KEY AUTOINCREMENT,
              $COLUMN_NOTE_TITLE TEXT,
              $COLUMN_NOTE_DESC TEXT
            )
          ''');
        }
      },
      version: 2, // Increment version number if the schema changes
    );
  }

  /// all queries
  /// insertion
  Future<bool> addNote({required String mTitle, required String mDesc}) async {
    var db = await getDB();
    int rowsEffected = await db.insert(TABLE_NOTE, {
      COLUMN_NOTE_TITLE: mTitle,
      COLUMN_NOTE_DESC: mDesc,
    });
    return rowsEffected > 0;
  }

  /// reading all data
  Future<List<Map<String, dynamic>>> getAllNotes() async {
    var db = await getDB();

    try {
      // Fetch all notes from the table
      List<Map<String, dynamic>> mData = await db.query(TABLE_NOTE);
      return mData;
    } catch (e) {
      // Handle any errors (like no table found)
      print("Error while fetching notes: $e");
      return [];
    }
  }

  /// update data
  Future<bool> updateNote({
    required String mTitle,
    required String mDesc,
    required int sno,
  }) async {
    var db = await getDB();
    int rowsEffected = await db.update(
      TABLE_NOTE,
      {
        COLUMN_NOTE_TITLE: mTitle,
        COLUMN_NOTE_DESC: mDesc,
      },
      where: "$COLUMN_NOTE_SNO = ?",
      whereArgs: [sno],
    );
    return rowsEffected > 0;
  }

  /// delete data
  Future<bool> deleteNote({required int sno}) async {
    var db = await getDB();
    int rowsEffected = await db.delete(
      TABLE_NOTE,
      where: "$COLUMN_NOTE_SNO = ?",
      whereArgs: [sno],
    );
    return rowsEffected > 0;
  }
}




















// import 'dart:io';
// import 'package:path/path.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:sqflite/sqflite.dart';
//
// class DBHelper {
//
//   // singleton constructor
//   DBHelper._();
//
//   static final DBHelper getInstance = DBHelper._();
//
//   // table note
//   static final String TABLE_NOTE = "note";
//   static final String COLUMN_NOTE_SNO = "s_no";
//   static final String COLUMN_NOTE_TITLE = "title";
//   static final String COLUMN_NOTE_DESC = "desc";
//   static final String COLUMN_NOTE_CREATED_AT = "created_at"; // NEW COLUMN
//   static const String COLUMN_NOTE_IS_PINNED = 'is_pinned';
//
//   Database? myDB;
//
//   /// db open (path -> if exists then open else create db)
//   Future<Database> getDB() async {
//     myDB = myDB ?? await openDB();
//     return myDB!;
//   }
//
//   Future<Database> openDB() async {
//     Directory appDir = await getApplicationDocumentsDirectory();
//     String dbPath = join(appDir.path, "nodeDB.db");
//
//     return await openDatabase(
//       dbPath,
//       version: 2, // Bump version for migration
//       onCreate: (db, version) {
//         db.execute("""
//           CREATE TABLE $TABLE_NOTE (
//             $COLUMN_NOTE_SNO INTEGER PRIMARY KEY AUTOINCREMENT,
//             $COLUMN_NOTE_TITLE TEXT,
//             $COLUMN_NOTE_DESC TEXT,
//             $COLUMN_NOTE_CREATED_AT TEXT,
//             $COLUMN_NOTE_IS_PINNED INTEGER DEFAULT 0,
//           )
//         """);
//       },
//       onUpgrade: (db, oldVersion, newVersion) async {
//         if (oldVersion < 2) {
//           await db.execute("ALTER TABLE $TABLE_NOTE ADD COLUMN $COLUMN_NOTE_CREATED_AT TEXT");
//         }
//       },
//     );
//   }
//
//   // Add this method to toggle pin status
//   Future<bool> togglePinNote({required int sno, required bool isPinned}) async {
//     Database db = await getDB();
//     int rowsEffected = await db.update(
//       TABLE_NOTE,
//       {
//         COLUMN_NOTE_IS_PINNED: isPinned ? 1 : 0,
//         'modifiedDate': DateTime.now().toIso8601String(),
//       },
//       where: '$COLUMN_NOTE_SNO = ?',
//       whereArgs: [sno],
//     );
//     return rowsEffected > 0;
//   }
//
//   /// insertion
//   Future<bool> addNote({required String mTitle, required String mDesc}) async {
//     var db = await getDB();
//     String now = DateTime.now().toIso8601String(); // Add timestamp
//     int rowsEffected = await db.insert(TABLE_NOTE, {
//       COLUMN_NOTE_TITLE: mTitle,
//       COLUMN_NOTE_DESC: mDesc,
//       COLUMN_NOTE_CREATED_AT: now, // Save created_at
//     });
//     return rowsEffected > 0;
//   }
//
//   /// reading all data
//   Future<List<Map<String, dynamic>>> getAllNotes() async {
//     var db = await getDB();
//     List<Map<String, dynamic>> mData = await db.query(TABLE_NOTE);
//     return mData;
//   }
//
//   /// update data
//   Future<bool> updateNote({
//     required String mTitle,
//     required String mDesc,
//     required int sno,
//   }) async {
//     var db = await getDB();
//     int rowsEffected = await db.update(
//       TABLE_NOTE,
//       {
//         COLUMN_NOTE_TITLE: mTitle,
//         COLUMN_NOTE_DESC: mDesc,
//         // Not updating created_at (only for creation)
//       },
//       where: "$COLUMN_NOTE_SNO = $sno",
//     );
//     return rowsEffected > 0;
//   }
//
//   /// delete data
//   Future<bool> deleteNote({required int sno}) async {
//     var db = await getDB();
//     int rowsEffected = await db.delete(
//       TABLE_NOTE,
//       where: "$COLUMN_NOTE_SNO = ?",
//       whereArgs: ['$sno'],
//     );
//     return rowsEffected > 0;
//   }
// }











// import 'dart:io';
// import 'package:path/path.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:sqflite/sqflite.dart';
//
// class DBHelper {
//
//   // singleton constructor
//   DBHelper._();
//
//   static final DBHelper getInstance = DBHelper._();
//
//   // table note
//   static final String TABLE_NOTE = "note";
//   static final String COLUMN_NOTE_SNO = "s_no";
//   static final String COLUMN_NOTE_TITLE = "title";
//   static final String COLUMN_NOTE_DESC = "desc";
//
//   Database? myDB;
//
//   /// db open (path -> if exists then open else create db)
//
//   Future<Database> getDB() async{
//
//     myDB = myDB ?? await openDB();
//     return myDB!;
//
//     // if(myDB!=null){
//     //   return myDB!;
//     // }else{
//     //   myDB = await openDB();
//     //   return myDB!;
//     // }
//   }
//
//   Future<Database> openDB() async{
//     Directory appDir = await getApplicationDocumentsDirectory();
//     String dbPath = join(appDir.path, "nodeDB.db");
//     return await openDatabase(dbPath, onCreate: (db, version){
//       /// create all your tables here
//       db.execute("create table $TABLE_NOTE ($COLUMN_NOTE_SNO integer primary key autoincrement, $COLUMN_NOTE_TITLE text, $COLUMN_NOTE_DESC text)");
//       //
//       //
//       //
//
//     }, version: 1);
//   }
//
//   /// all queries
//   /// insertion
//   Future<bool> addNote({required String mTitle, required String mDesc}) async{
//     var db = await getDB();
//     int rowsEffected = await db.insert(TABLE_NOTE, {
//       COLUMN_NOTE_TITLE : mTitle,
//       COLUMN_NOTE_DESC : mDesc
//     });
//     return rowsEffected>0;
//   }
//
//   /// reading all data
//   Future<List<Map<String, dynamic>>> getAllNotes() async{
//     var db = await getDB();
//     List<Map<String, dynamic>> mData = await db.query(TABLE_NOTE,);
//     // print("raw data: $mData");
//     return mData;
//   }
//
//   /// update data
//   Future<bool> updateNote({required String mTitle, required String mDesc, required int sno}) async{
//     var db = await getDB();
//     int rowsEffected = await db.update(TABLE_NOTE, {
//       COLUMN_NOTE_TITLE : mTitle,
//       COLUMN_NOTE_DESC : mDesc
//     }, where: "$COLUMN_NOTE_SNO = $sno");
//     return rowsEffected>0;
//   }
//
//
//   /// delete data
//   Future<bool> deleteNote({required int sno}) async{
//     var db = await getDB();
//     int rowsEffected = await db.delete(TABLE_NOTE, where:"$COLUMN_NOTE_SNO = ?", whereArgs: ['$sno']);
//     return rowsEffected>0;
//   }
// }