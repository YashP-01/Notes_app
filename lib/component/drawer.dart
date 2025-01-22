import 'package:db_practice/edit_profile.dart';
import 'package:db_practice/loading_animation.dart';
import 'package:db_practice/settings_page.dart';
import 'package:flutter/material.dart';

class MyDrawer extends StatefulWidget {
  const MyDrawer({Key? key}) : super(key: key);

  @override
  _MyDrawerState createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  String _name = "Zero";
  String _gender = "Male";
  int _avatarIndex = 2;

  final List<String> avatars = [
    'assets/profile_avatar/avatar1.png',
    'assets/profile_avatar/avatar2.png',
    'assets/profile_avatar/avatar3.png',
    'assets/profile_avatar/avatar4.png',
    'assets/profile_avatar/avatar5.png',
  ];

  void _updateProfile(String name, int avatarIndex, String gender) {
    setState(() {
      _name = name;
      _avatarIndex = avatarIndex;
      _gender = gender;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: SingleChildScrollView(
        child: Column(
          children: [
            DrawerHeader(
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    backgroundImage: AssetImage(avatars[_avatarIndex]),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _name,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(_gender, style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditProfile(
                            currentName: _name,
                            currentAvatar: _avatarIndex,
                            currentGender: _gender,
                            onUpdateProfile: _updateProfile,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text("Home"),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Settings"),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SettingsPage()),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.animation),
              title: const Text("Animation"),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => LoadingAnimation()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
