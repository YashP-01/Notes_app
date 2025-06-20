import 'dart:convert';
import 'dart:io';

import 'package:db_practice/themes/theme_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'data/local/db_helper.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'package:path/path.dart' as p;
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';



class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  List<Map<String, dynamic>> filteredNotes = [];
  List<Map<String, dynamic>> allNotes = [];
  DBHelper? dbRef;

  @override
  void initState() {
    super.initState();
    dbRef = DBHelper.getInstance;
    getNotes();
  }


  Future<void> getNotes() async {
    allNotes = await dbRef!.getAllNotes();
    setState(() {
      filteredNotes = allNotes; // Set the initial list to all notes
    });
  }

  Future<void> _exportNotes(BuildContext context) async {
    try {
      if (Platform.isAndroid) {
        var status = await Permission.storage.request();
        if (!status.isGranted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Storage permission denied')),
          );
          return;
        }
      }

      final notes = await dbRef!.getAllNotes();

      final buffer = StringBuffer();
      int index = 1;
      for (var note in notes) {
        final title = note['title'];
        final deltaJson = note['desc'];

        String content;
        try {
          final delta = Delta.fromJson(jsonDecode(deltaJson));
          final doc = quill.Document.fromDelta(delta);
          content = doc.toPlainText().trim();
        } catch (e) {
          content = '[Error parsing content]';
        }

        buffer.writeln('Note no: $index');
        buffer.writeln('Title: $title');
        buffer.writeln('Description: $content');
        buffer.writeln('---*---*---\n');

        index++;
      }


      // Write to public Downloads folder
      final manualPath = '/storage/emulated/0/Download'; // Android-specific
      final filePath = p.join(manualPath, 'exported_notes.txt');
      final file = File(filePath);
      await file.writeAsString(buffer.toString());

      print("Notes exported successfully to $filePath");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Notes exported to $filePath')),
      );
    } catch (e) {
      print('Export failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to export notes')),
      );
    }
  }


  Future<void> _importNotes(BuildContext context) async {
    try {
      // 1. Pick a .txt file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt'],
      );

      if (result == null || result.files.single.path == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No file selected')),
        );
        return;
      }

      final file = File(result.files.single.path!);
      final content = await file.readAsString();

      // 2. Parse notes from text
      final notes = content.split('---*---*---').where((note) => note.trim().isNotEmpty);

      int importedCount = 0;
      for (var rawNote in notes) {
        final lines = rawNote.trim().split('\n');

        String title = '';
        String description = '';

        for (var line in lines) {
          if (line.startsWith('Title:')) {
            title = line.replaceFirst('Title:', '').trim();
          } else if (line.startsWith('Description:')) {
            description = line.replaceFirst('Description:', '').trim();
          } else {
            description += '\n' + line.trim(); // In case multi-line descriptions exist
          }
        }

        // 3. Convert plain text description to Delta JSON
        final delta = Delta()..insert(description + '\n');
        final quillDoc = quill.Document.fromDelta(delta);
        final jsonDelta = jsonEncode(quillDoc.toDelta().toJson());

        // 4. Save to database
        await dbRef!.addNote(mTitle: title, mDesc: jsonDelta);
        importedCount++;
      }

      // 5. Notify and refresh notes
      await getNotes(); // This should reload the home screen list
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$importedCount notes imported successfully')),
      );
    } catch (e) {
      print('Import failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to import notes')),
      );
    }
  }

  // Future<void> _exportNotes(BuildContext context) async {
  //   try {
  //     if (Platform.isAndroid) {
  //       var status = await Permission.storage.request();
  //       if (!status.isGranted) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(content: Text('Storage permission denied')),
  //         );
  //         return;
  //       }
  //     }
  //
  //     print("starting fetching...");
  //     final notes = await dbRef!.getAllNotes();
  //     print("raw data from settings screen: $notes");
  //
  //     final buffer = StringBuffer();
  //     for (var note in notes) {
  //       final title = note['title'];
  //       final deltaJson = note['desc'];
  //
  //       String content;
  //       try {
  //         final delta = Delta.fromJson(jsonDecode(deltaJson));
  //         final doc = quill.Document.fromDelta(delta);
  //         content = doc.toPlainText().trim();
  //       } catch (e) {
  //         content = '[Error parsing content]';
  //       }
  //
  //       buffer.writeln('Title: $title\nDescription: $content\n---\n');
  //     }
  //
  //     final dir = await getDownloadsDirectory();
  //     if (dir == null) {
  //       throw Exception('External storage directory not available');
  //     }
  //
  //     final filePath = '${dir.path}/exported_notes.txt';
  //     final file = File(filePath);
  //     await file.writeAsString(buffer.toString());
  //
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Notes exported to $filePath')),
  //     );
  //   } catch (e) {
  //     print('Export failed: $e');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Failed to export notes')),
  //     );
  //   }
  // }



  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Theme Section
          _buildSettingsSection(
            context,
            title: 'Appearance',
            children: [
              _buildSwitchTile(
                context,
                title: 'Dark Mode',
                subtitle: 'Switch between light and dark theme',
                value: isDark,
                onChanged: (value) => themeProvider.toggleTheme(value),
                icon: isDark ? Icons.dark_mode : Icons.light_mode,
              ),
              _buildListTile(
                context,
                title: 'Font Size',
                subtitle: 'Adjust text size for better readability',
                icon: Icons.text_fields,
                onTap: () => _showFontSizeDialog(context),
              ),
              _buildListTile(
                context,
                title: 'Font Family',
                subtitle: 'Choose your preferred font',
                icon: Icons.font_download,
                onTap: () => _showFontFamilyDialog(context),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Notes Section
          _buildSettingsSection(
            context,
            title: 'Notes',
            children: [
              _buildListTile(
                context,
                title: 'Default Note Format',
                subtitle: 'Plain text, Markdown, or Rich text',
                icon: Icons.format_align_left,
                onTap: () => _showFormatDialog(context),
              ),
              _buildSwitchTile(
                context,
                title: 'Auto-save',
                subtitle: 'Automatically save notes while typing',
                value: true, // You'll need to implement this state
                onChanged: (value) {
                  // Implement auto-save toggle
                },
                icon: Icons.save,
              ),
              _buildListTile(
                context,
                title: 'Default Sort Order',
                subtitle: 'How notes are sorted in the list',
                icon: Icons.sort,
                onTap: () => _showSortDialog(context),
              ),
              _buildSwitchTile(
                context,
                title: 'Show Note Preview',
                subtitle: 'Display first few lines in note list',
                value: true, // You'll need to implement this state
                onChanged: (value) {
                  // Implement preview toggle
                },
                icon: Icons.preview,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Backup & Sync Section
          _buildSettingsSection(
            context,
            title: 'Backup & Sync',
            children: [
              _buildListTile(
                context,
                title: 'Export Notes',
                subtitle: 'Export all notes to file',
                icon: Icons.file_download,
                onTap: () => _exportNotes(context),
              ),
              _buildListTile(
                context,
                title: 'Import Notes',
                subtitle: 'Import notes from file',
                icon: Icons.file_upload,
                onTap: () => _importNotes(context),
              ),
              _buildListTile(
                context,
                title: 'Backup to Cloud',
                subtitle: 'Google Drive, iCloud, or Dropbox',
                icon: Icons.cloud_upload,
                onTap: () => _showCloudBackupOptions(context),
              ),
              _buildSwitchTile(
                context,
                title: 'Auto Backup',
                subtitle: 'Automatically backup notes daily',
                value: false, // You'll need to implement this state
                onChanged: (value) {
                  // Implement auto backup toggle
                },
                icon: Icons.backup,
              ),
            ],
          ),

          const SizedBox(height: 16),

          /// Security Section
          // _buildSettingsSection(
          //   context,
          //   title: 'Security',
          //   children: [
          //     _buildSwitchTile(
          //       context,
          //       title: 'App Lock',
          //       subtitle: 'Require PIN/biometric to open app',
          //       value: false, // You'll need to implement this state
          //       onChanged: (value) {
          //         // Implement app lock toggle
          //       },
          //       icon: Icons.lock,
          //     ),
          //     _buildListTile(
          //       context,
          //       title: 'Change PIN',
          //       subtitle: 'Update your app PIN',
          //       icon: Icons.pin,
          //       onTap: () => _changePIN(context),
          //     ),
          //     _buildSwitchTile(
          //       context,
          //       title: 'Biometric Authentication',
          //       subtitle: 'Use fingerprint or face unlock',
          //       value: false, // You'll need to implement this state
          //       onChanged: (value) {
          //         // Implement biometric toggle
          //       },
          //       icon: Icons.fingerprint,
          //     ),
          //   ],
          // ),

          const SizedBox(height: 16),

          // Other Section
          _buildSettingsSection(
            context,
            title: 'Other',
            children: [
              _buildListTile(
                context,
                title: 'Clear Cache',
                subtitle: 'Free up storage space',
                icon: Icons.cleaning_services,
                onTap: () => _clearCache(context),
              ),
              _buildListTile(
                context,
                title: 'About',
                subtitle: 'App version and information',
                icon: Icons.info,
                onTap: () => _showAboutDialog(context),
              ),
              _buildListTile(
                context,
                title: 'Help & Support',
                subtitle: 'Get help or contact support',
                icon: Icons.help,
                onTap: () => _showHelp(context),
              ),
              _buildListTile(
                context,
                title: 'Rate App',
                subtitle: 'Rate us on the app store',
                icon: Icons.star,
                onTap: () => _rateApp(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            blurRadius: 3,
            spreadRadius: 1.5,
            color: Colors.grey.withOpacity(0.3),
          )
        ],
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Theme.of(context).colorScheme.primary // or any dark mode color
                    : Colors.teal,
                // color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile(BuildContext context, {
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    IconData? icon,
  }) {
    return ListTile(
      leading: icon != null ? Icon(icon) : null,
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: CupertinoSwitch(
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildListTile(BuildContext context, {
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    return ListTile(
      leading: icon != null ? Icon(icon) : null,
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  // Dialog and action methods
  void _showFontSizeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Font Size'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Small'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: const Text('Medium'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: const Text('Large'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showFontFamilyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Font Family'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('System Default'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: const Text('Roboto'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: const Text('Open Sans'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showFormatDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Default Note Format'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Plain Text'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: const Text('Markdown'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: const Text('Rich Text'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showSortDialog(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sort Order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Date Modified (Newest)'),
              onTap: () async {
                await prefs.setString('sortOrder', 'newest');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Date Modified (Oldest)'),
              onTap: () async {
                await prefs.setString('sortOrder', 'oldest');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Alphabetical (A-Z)'),
              onTap: () async {
                await prefs.setString('sortOrder', 'az');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Alphabetical (Z-A)'),
              onTap: () async {
                await prefs.setString('sortOrder', 'za');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }



  // void _showSortDialog(BuildContext context) {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: const Text('Sort Order'),
  //       content: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           ListTile(
  //             title: const Text('Date Modified (Newest)'),
  //             onTap: () => Navigator.pop(context),
  //           ),
  //           ListTile(
  //             title: const Text('Date Modified (Oldest)'),
  //             onTap: () => Navigator.pop(context),
  //           ),
  //           ListTile(
  //             title: const Text('Alphabetical (A-Z)'),
  //             onTap: () => Navigator.pop(context),
  //           ),
  //           ListTile(
  //             title: const Text('Alphabetical (Z-A)'),
  //             onTap: () => Navigator.pop(context),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  void _showCloudBackupOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cloud Backup'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.android),
              title: const Text('Google Drive'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.apple),
              title: const Text('iCloud'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.cloud),
              title: const Text('Dropbox'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  // void _exportNotes(BuildContext context) {
  //   // Implement export functionality
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     const SnackBar(content: Text('Export feature coming soon!')),
  //   );
  // }

  // void _importNotes(BuildContext context) {
  //   // Implement import functionality
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     const SnackBar(content: Text('Import feature coming soon!')),
  //   );
  // }

  void _changePIN(BuildContext context) {
    // Implement PIN change functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('PIN change feature coming soon!')),
    );
  }

  void _clearCache(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text('Are you sure you want to clear the app cache?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache cleared successfully!')),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Notes App',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2024 Your Company Name',
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 15),
          child: Text('A simple and elegant notes application.'),
        ),
      ],
    );
  }

  void _showHelp(BuildContext context) {
    // Implement import functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Help & Support coming soon!')),
    );
  }

  // void _showHelp(BuildContext context) {
  void _rateApp(BuildContext context) {
    // Implement app rating functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Redirecting to app store...')),
    );
  }
}









// import 'package:db_practice/themes/theme_provider.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// class SettingsPage extends StatelessWidget {
//   const SettingsPage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final themeProvider = Provider.of<ThemeProvider>(context);
//     final isDark = themeProvider.themeMode == ThemeMode.dark;
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Settings'),
//         centerTitle: true,
//       ),
//       body: Container(
//         decoration: BoxDecoration(
//           boxShadow: [
//             BoxShadow(
//               blurRadius: 3,
//               spreadRadius: 1.5,
//               color: Colors.grey,
//             )
//           ],
//           color: Theme.of(context).cardColor,
//           borderRadius: const BorderRadius.only(
//             topLeft: Radius.circular(12),
//             bottomRight: Radius.circular(12),
//           ),
//         ),
//         margin: const EdgeInsets.all(20),
//         padding: const EdgeInsets.all(16),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               'Dark Mode',
//               style: TextStyle(
//                 color: Theme.of(context).textTheme.bodyMedium?.color,
//               ),
//             ),
//             CupertinoSwitch(
//               value: isDark,
//               onChanged: (value) {
//                 themeProvider.toggleTheme(value);
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }










// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
//
// class SettingsPage extends StatelessWidget {
//   const SettingsPage({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Settings'),
//         centerTitle: true,
//       ),
//       body: Container(
//         decoration: BoxDecoration(
//           boxShadow: [BoxShadow(
//             blurRadius: 3,
//             spreadRadius: 1.5,
//             color: Colors.grey
//           )],
//           color: Colors.grey.shade200,
//               borderRadius: BorderRadius.only(
//                   topLeft: Radius.circular(12),
//                   bottomRight: Radius.circular(12))
//         ),
//         margin: const EdgeInsets.all(20),
//         padding: const EdgeInsets.all(16),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text('Dark Mode'),
//
//             CupertinoSwitch(value: false, onChanged: (value){}),
//           ],
//         ),
//       )
//     );
//   }
// }
