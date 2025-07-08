import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AboutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'About',
          style: TextStyle(fontFamily: 'BethEllen'),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),

            // App Icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.teal[400],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.note_alt_rounded,
                size: 60,
                color: Colors.white,
              ),
            ),

            SizedBox(height: 20),

            // App Name
            Text(
              'Notes',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                fontFamily: 'BethEllen',
              ),
            ),

            SizedBox(height: 8),

            // Version
            Text(
              'Version 1.0.0',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontFamily: 'Roboto',
              ),
            ),

            SizedBox(height: 30),

            // Description Card
            Card(
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'About Notes',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Smooch',
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'A simple and elegant note-taking app designed to help you capture your thoughts, ideas, and reminders effortlessly. Create, edit, and organize your notes with ease.',
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // Features Card
            Card(
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Features',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Smooch',
                      ),
                    ),
                    SizedBox(height: 12),
                    _buildFeatureItem(Icons.note_add, 'Create & Edit Notes'),
                    _buildFeatureItem(Icons.search, 'Search Notes'),
                    _buildFeatureItem(Icons.view_agenda, 'Grid & List View'),
                    _buildFeatureItem(Icons.delete, 'Multi-Select Delete'),
                    _buildFeatureItem(Icons.refresh, 'Pull to Refresh'),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // Developer Info Card
            Card(
              elevation: 4, // Slightly higher elevation for better shadow effect
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12), // Rounded corners for modern look
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20), // Increased vertical padding for better balance
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start, // Align text to top for consistent look
                  children: [
                    // Developer Section
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Developer', // Main Title
                            style: TextStyle(
                              fontSize: 22, // Slightly larger for prominence
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Smooch',
                              color: Colors.black87, // Dark text for better contrast
                            ),
                          ),
                          SizedBox(height: 12), // Spacing between text elements
                          Text(
                            'yp (Zero)', // Name of the Developer
                            style: TextStyle(
                              fontSize: 18, // Slightly larger for prominence
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.w600, // Semi-bold for better focus
                              color: Colors.black87, // Ensure readability
                            ),
                          ),
                          SizedBox(height: 8), // Spacing between text elements
                          Text(
                            '© 2025 Notes App', // Copyright Text
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600], // Slightly muted to not overpower the other text
                              fontFamily: 'Roboto',
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Optionally add a profile icon or image on the right side (optional)
                    // You can replace the Icon with an actual image if needed
                    SizedBox(width: 16), // Space between text and optional icon
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.blueAccent, // Circle color
                      child: Image.asset("assets/app_icon/app_icon.png"), // Optional: you can replace this with an actual image
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 30),

            // Build Info
            Text(
              'Build: 1.0.0+1',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
                fontFamily: 'Roboto',
              ),
            ),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: Colors.teal[400],
          ),
          SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Roboto',
            ),
          ),
        ],
      ),
    );
  }
}