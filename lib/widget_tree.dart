import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_fyp/widgets/bottom_navigation/c_navigator.dart';
import 'package:my_fyp/widgets/bottom_navigation/f_navigator.dart';

import 'auth/auth.dart';
import 'auth/login_page.dart';

class WidgetTree extends StatefulWidget{
  const WidgetTree({super.key});

  @override
  State<StatefulWidget> createState() => WidgetTreeState();

}

class WidgetTreeState extends State<WidgetTree>{



  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: Auth().authStateChanges,
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const LoadingScreen(); // Custom loading screen
        }

        if (!authSnapshot.hasData) {
          return LoginPage();
        }

        final user = authSnapshot.data!;

        return FutureBuilder<QuerySnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .where('email', isEqualTo: user.email)
              .get(),
          builder: (context, dataSnapshot) {
            if (dataSnapshot.connectionState == ConnectionState.waiting) {
              return const LoadingScreen();
            }

            if (dataSnapshot.hasError || !dataSnapshot.hasData) {
              return LoginPage();
            }

            final querySnapshot = dataSnapshot.data!;
            if (querySnapshot.docs.isEmpty) {
              return LoginPage();
            }

            final userData = querySnapshot.docs.first;
            final String? userType = userData.get('userType');

            if (userType == 'freelancer') {
              return F_navigator();
            } else {
              return C_navigator();
            }
          },
        );
      },
    );
  }
}

// Custom Loading Screen
class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Prevent black screen
      body: Center(
        child: CircularProgressIndicator(
          color: Colors.indigoAccent,
        ),
      ),
      //
    );
  }
}