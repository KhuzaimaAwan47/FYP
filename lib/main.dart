
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_fyp/widget_tree.dart';
import 'package:my_fyp/widgets/bottom_navigation/f_navigator.dart';
import 'auth/login_page.dart';
import 'auth/signup_page.dart';
import 'splash_page.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();



  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FlutterApp',
      theme: ThemeData(
        primaryColor: Colors.indigo,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.indigoAccent,
          foregroundColor: Colors.white,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.light,
            systemNavigationBarColor: Colors.white,
            systemNavigationBarIconBrightness: Brightness.dark,
          ),
        ),
      ),
    //  home: WidgetTree(),
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        //'/login': (context) => LoginPage(),
        //'/signup': (context) => const SignupPage(),
        '/home': (context) => const WidgetTree(),
      },
    );
  }
}
