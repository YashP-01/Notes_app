import 'package:db_practice/home_page.dart';
import 'package:db_practice/introduction_screen.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:another_flutter_splash_screen/another_flutter_splash_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FlutterSplashScreen(
      useImmersiveMode: false,
      duration: Duration(seconds: 6),   /// have to make changes for different time duration
      nextScreen: AppWrapper(),
      backgroundColor: Theme.of(context).colorScheme.surface,
      splashScreenBody: Center(
        child: Lottie.asset(
          'assets/animation/notes_icon.json',
           repeat: false,
        ),
        ),
    );
  }
}




// import 'package:db_practice/home_page.dart';
// import 'package:flutter/material.dart';
// import 'package:animated_splash_screen/animated_splash_screen.dart';
// import 'package:lottie/lottie.dart';
// import 'package:another_flutter_splash_screen/another_flutter_splash_screen.dart';
//
// class SplashScreen extends StatelessWidget {
//   const SplashScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     // Set the floating-point duration
//     double seconds = 6.5; // Example: 6.5 seconds
//     return FlutterSplashScreen(
//       useImmersiveMode: true,
//       duration: Duration(milliseconds: (seconds * 1000).toInt()), // Convert to milliseconds
//       nextScreen: HomePage(), // Redirect to HomePage after animation
//       backgroundColor: Colors.white,
//       splashScreenBody: Center(
//         child: Lottie.asset(
//           'assets/animation/notes_icon.json',
//           repeat: false,
//         ),
//       ),
//     );
//   }
// }
