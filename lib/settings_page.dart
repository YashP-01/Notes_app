import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          boxShadow: [BoxShadow(
            blurRadius: 3,
            spreadRadius: 1.5,
            color: Colors.grey
          )],
          color: Colors.grey.shade200,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12))
        ),
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Dark Mode'),

            CupertinoSwitch(value: false, onChanged: (value){}),
          ],
        ),
      )
    );
  }
}
