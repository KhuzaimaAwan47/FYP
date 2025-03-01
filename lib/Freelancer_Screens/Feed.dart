import 'package:flutter/material.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  @override
  Widget build(BuildContext context) {



    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
          title: const Text('Feed'),
      ),
      body: Container(
        child: Column(
          children: [
            Center(
              child: Text('Hello, Khuziama',style: TextStyle(
                fontSize: 50,
                  fontWeight: FontWeight.bold,
                  foreground: Paint()..shader = LinearGradient(
                      colors: [Color(0xFF007FFF),Color(0xFFFF0000)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight)
                      .createShader(Rect.fromLTWH(100,0,200,0))
              ),),
            ),
            Text('Hamza',style: TextStyle(
              fontWeight: FontWeight.bold,
                fontSize: 50,
                foreground: Paint()..shader = LinearGradient(
                    colors: [Colors.lightGreen,Colors.blue],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight)
                    .createShader(Rect.fromLTWH(100,0,200,30))
            ),)
          ],
        ),
      ),
    );
  }
}