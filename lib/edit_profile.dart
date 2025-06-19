import 'package:db_practice/sample_template.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfile extends StatefulWidget {
  final String currentName;
  final int currentAvatar;
  final String currentGender;
  final Function(String, int, String) onUpdateProfile;

  const EditProfile({
    Key? key,
    required this.currentName,
    required this.currentAvatar,
    required this.currentGender,
    required this.onUpdateProfile,
  }) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfile> {
  late TextEditingController _nameController;
  late int _selectedAvatarIndex;
  late String _selectedGender;

  final List<String> avatars = [
    'assets/profile_avatar/avatar1.png',
    'assets/profile_avatar/avatar2.png',
    'assets/profile_avatar/avatar3.png',
    'assets/profile_avatar/avatar4.png',
    'assets/profile_avatar/avatar5.png',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
    _selectedAvatarIndex = widget.currentAvatar;
    _selectedGender = widget.currentGender;
  }

  void _updateProfile() async {
    final String name = _nameController.text.trim();

    if (name.isNotEmpty && _selectedAvatarIndex >= 0 && _selectedGender.isNotEmpty) {
      // Save data to SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('name', name);
      await prefs.setInt('avatarIndex', _selectedAvatarIndex);
      await prefs.setString('gender', _selectedGender);

      // Call the parent method to notify about the update
      widget.onUpdateProfile(name, _selectedAvatarIndex, _selectedGender);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully!")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please complete all fields.")),
      );
    }
  }

  Widget _buildGenderOption(String gender, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGender = gender;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey[200],
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Text(
          gender,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarOption(String avatar, int index, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedAvatarIndex = index;
        });
      },
      child: CircleAvatar(
        radius: 30,
        backgroundColor: isSelected ? Colors.blue : Colors.grey[200],
        child: CircleAvatar(
          radius: 28,
          backgroundImage: AssetImage(avatar),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Update Profile",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              const Text("Name", style: TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Enter your new name",
                ),
              ),
              const SizedBox(height: 24),
              const Text("Select your gender:", style: TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildGenderOption("Male", _selectedGender == "Male"),
                  const SizedBox(width: 16),
                  _buildGenderOption("Female", _selectedGender == "Female"),
                  const SizedBox(width: 16),
                  _buildGenderOption("Other", _selectedGender == "Other"),
                ],
              ),
              const SizedBox(height: 24),
              const Text("Select your avatar:", style: TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: avatars.asMap().entries.map((entry) {
                  final int index = entry.key;
                  final String avatar = entry.value;
                  return _buildAvatarOption(avatar, index, _selectedAvatarIndex == index);
                }).toList(),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _updateProfile,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    "Update Profile",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              SizedBox(height: 16,),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => SampleTemplate() ));
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    "Sample template",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
