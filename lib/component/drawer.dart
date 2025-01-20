import 'package:db_practice/loading_animation.dart';
import 'package:db_practice/settings_page.dart';
import 'package:flutter/material.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {

    double screenWidth = MediaQuery.of(context).size.width;

    return Drawer(
      // backgroundColor: Colors.grey.shade300,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                DrawerHeader(
                    child: Center(
                      child: Icon(
                        Icons.account_circle,
                        color: Colors.grey.shade300,
                        size: 110,
                      ),
                    )),

                /// home list title
                Padding(
                  padding: const EdgeInsets.only(left: 25.0),
                  child: ListTile(
                    title: Text("H o m e", style: TextStyle(fontWeight: FontWeight.bold),),
                    leading: Icon(Icons.home),
                    onTap: (){
                      Navigator.pop(context);
                    },
                  ),
                ),

                /// settings list title
                Padding(
                  padding: const EdgeInsets.only(left: 25.0),
                  child: ListTile(
                    title: Text("S e t t i n g s", style: TextStyle(fontWeight: FontWeight.bold),),
                    leading: Icon(Icons.settings),
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsPage(),
                      ));
                    },
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(left: 25.0),
                  child: ListTile(
                    title: Text("A n i m a t i o n", style: TextStyle(fontWeight: FontWeight.bold),),
                    leading: Icon(Icons.animation),
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => LoadingAnimation(),
                      ));
                    },
                  ),
                ),

              ],
            )
          ],
        ),
      ),
      // child: Text('home'),
    );
  }
}
