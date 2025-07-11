import 'package:db_practice/splash_screen.dart';
import 'package:db_practice/themes/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

Future <void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // await MobileAds.instance.updateRequestConfiguration(
    // RequestConfiguration(
      // testDeviceIds: ["BC86D04C0210CB920538FF80032D05A2"], // Your test device ID
      // You can also set maxAdContentRating and tagForChildDirectedTreatment here if needed
      // maxAdContentRating: MaxAdContentRating.pg,
      // tagForChildDirectedTreatment: TagForChildDirectedTreatment.yes,
    // ),
  // );

  /// await MobileAds.instance.initialize();

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

// void main() {
//   runApp(const MyApp());
// }

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        quill.FlutterQuillLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('es'),
        Locale('fr'),
        // ... etc
      ],

      debugShowCheckedModeBanner: false,
      title: 'Notes',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: themeProvider.themeMode,
      // theme: ThemeData(
      //   colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      //   useMaterial3: true,
      // ),
      home: SplashScreen(),
    );
  }
}
