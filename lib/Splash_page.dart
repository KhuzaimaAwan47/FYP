import 'package:flutter/material.dart';
import 'package:my_fyp/widget_tree.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();

}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
     Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => WidgetTree(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
      width: screenWidth,
      height: screenHeight,
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
         SizedBox(
           child: Image.asset(
              'assets/images/logo1.png',
              width: screenWidth * (250 / screenWidth),
              height: screenHeight * (250 / screenHeight),
              fit: BoxFit.fill,
             alignment: Alignment.center,
           ),
         ),

          const Text(
            'Unity Gig',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          )
        ],
      ),
    ),
    );
  }
}