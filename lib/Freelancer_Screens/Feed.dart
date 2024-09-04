import 'package:flutter/material.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});
  final double coverHeight = 150;
  final double profileHeight = 130;

  @override
  Widget build(BuildContext context) {
    final top = coverHeight - profileHeight / 2;


    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
          title: const Text('Feed Screen'),
      ),
      body: Container(),
    );
  }
}