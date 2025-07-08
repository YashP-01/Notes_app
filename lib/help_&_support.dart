import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Help & Support',
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),

            // FAQ Section
            Card(
              elevation: 2,
              child: Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  leading: Icon(Icons.help_outline, color: Colors.teal[400]),
                  title: Text(
                    'Frequently Asked Questions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Smooch',
                    ),
                  ),
                  children: [
                    _buildFAQItem(
                      'How do I create a new note?',
                      'Tap the floating action button (+) at the bottom right of the screen to create a new note.',
                    ),
                    _buildFAQItem(
                      'How do I delete multiple notes?',
                      'Long press on any note to enter multi-select mode, then tap on other notes to select them. Use the delete button in the app bar.',
                    ),
                    _buildFAQItem(
                      'How do I search for notes?',
                      'Tap the search icon in the app bar and type your search term. The app will filter notes based on title and content.',
                    ),
                    _buildFAQItem(
                      'How do I switch between grid and list view?',
                      'Use the view toggle button in the app bar to switch between grid and list layouts.',
                    ),
                    _buildFAQItem(
                      'Can I recover deleted notes?',
                      'Currently, deleted notes cannot be recovered. Please be careful when deleting notes.',
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // How to Use Section
            Card(
              elevation: 2,
              child: Theme(
                /// removes the top & bottom dividers added by ExpansionTile
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  leading: Icon(Icons.info_outline, color: Colors.teal[400]),
                  title: const Text(
                    'How to Use',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Smooch',
                    ),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHowToItem(
                            Icons.add_circle_outline,
                            'Creating Notes',
                            'Tap the + button and fill in the title and description fields.',
                          ),
                          _buildHowToItem(
                            Icons.edit_outlined,
                            'Editing Notes',
                            'Tap on any note to open it in edit mode.',
                          ),
                          _buildHowToItem(
                            Icons.select_all,
                            'Multi-Select',
                            'Long press on a note to enter selection mode.',
                          ),
                          _buildHowToItem(
                            Icons.refresh,
                            'Refresh',
                            'Pull down on the notes list to refresh.',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),


            SizedBox(height: 20),

            // Contact Support Section
            Card(
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.support_agent, color: Colors.teal[400]),
                        SizedBox(width: 12),
                        Text(
                          'Contact Support',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Smooch',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Need help? We\'re here to assist you!',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Roboto',
                      ),
                    ),
                    SizedBox(height: 16),

                    // Email Support
                    _buildContactItem(
                      Icons.email_outlined,
                      'Email Support',
                      'support@notesapp.com',
                          () => _launchEmail(),
                    ),

                    // Report Bug
                    _buildContactItem(
                      Icons.bug_report_outlined,
                      'Report a Bug',
                      'Found an issue? Let us know!',
                          () => _reportBug(context),
                    ),

                    // Feature Request
                    _buildContactItem(
                      Icons.lightbulb_outline,
                      'Feature Request',
                      'Suggest new features',
                          () => _featureRequest(context),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // App Info Section
            Card(
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: Colors.teal[400]),
                        SizedBox(width: 12),
                        Text(
                          'App Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Smooch',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    _buildInfoRow('Version', '1.0.1'),
                    _buildInfoRow('Last Updated', 'June 2025'),
                    _buildInfoRow('Platform', 'Android & iOS'),
                    _buildInfoRow('Size', '< 30 MB'),
                  ],
                ),
              ),
            ),

            SizedBox(height: 30),

            // Footer
            Center(
              child: Text(
                'Thank you for using Notes!',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontFamily: 'BethEllen',
                ),
              ),
            ),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'Roboto',
            ),
          ),
          SizedBox(height: 8),
          Text(
            answer,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              fontFamily: 'Roboto',
            ),
          ),
          SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildHowToItem(IconData icon, String title, String description) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: Colors.teal[400]),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Roboto',
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    fontFamily: 'Roboto',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: Colors.teal[400]),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Roboto',
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontFamily: 'Roboto',
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Roboto',
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontFamily: 'Roboto',
            ),
          ),
        ],
      ),
    );
  }

  void _launchEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'support@notesapp.com',
      query: 'subject=Notes App Support Request',
    );

    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    }
  }

  void _reportBug(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Report a Bug'),
        content: Text('Please describe the issue you encountered and we\'ll look into it.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _launchEmail();
            },
            child: Text('Send Email'),
          ),
        ],
      ),
    );
  }

  void _featureRequest(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Feature Request'),
        content: Text('We\'d love to hear your ideas for improving the app!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _launchEmail();
            },
            child: Text('Send Email'),
          ),
        ],
      ),
    );
  }
}