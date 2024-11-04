import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'splash_page.dart';
import 'login_page.dart';
import 'signup_page.dart';
import 'f_navigator.dart';

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
       // primarySwatch: Colors.indigo,
        appBarTheme: AppBarTheme(
          //backgroundColor: Colors.indigo.withOpacity(0.2),
          foregroundColor: Colors.black87,
          backgroundColor: Colors.white,
          systemOverlayStyle: SystemUiOverlayStyle(
            //statusBarColor: Colors.indigo[100],
            statusBarColor: Colors.white,
            statusBarIconBrightness: Brightness.dark,
          )
        )
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/login': (context) => LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/home': (context) => const F_navigator(),
      },
    );
  }
}