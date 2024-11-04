import 'package:flutter/material.dart';
import 'package:custom_navigation_bar/custom_navigation_bar.dart';
import 'package:my_fyp/Freelancer_Screens/Home.dart';
import 'package:my_fyp/Freelancer_Screens/Chat.dart';
import 'package:my_fyp/Freelancer_Screens/Feed.dart';
import 'package:my_fyp/Freelancer_Screens/Dashboard.dart';

//F_navigator class is a navigator used for freelancer bottom naviagtion.

class F_navigator extends StatefulWidget {
  const F_navigator({super.key});

  @override
  State<F_navigator> createState() => _HomePageState();
}

class _HomePageState extends State<F_navigator> {
  final PageController _pageController = PageController();
  int selectedIndex = 0;
  final List<Widget> _screens= [
    const HomeScreen(),
    ChatsScreen(),
    const FeedScreen(),
    const DashboardScreen(),
  ];

void _onPageChanged(int index){
setState(() {
  selectedIndex = index;
});
}

void _onItemTapped(int i){
  _pageController.jumpToPage(i);
}

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body:PageView(
          controller: _pageController,
          onPageChanged: _onPageChanged,
          physics: const NeverScrollableScrollPhysics(),
          children: _screens,
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.only(bottom: 10,top: 10),
          child: CustomNavigationBar(
            isFloating: true,
            elevation: 4,
            iconSize: 30.0,

            //Colors in hexadecimal form in Flutter using the Color class and the 0xFF prefix,

            borderRadius: const Radius.circular(20),
            selectedColor: Colors.indigo,
            unSelectedColor: Colors.grey,
            backgroundColor: Colors.white,
            strokeColor: Colors.indigo,

            items: [
              CustomNavigationBarItem(
                  icon: selectedIndex == 0 ?  Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.indigo.shade50, // Background color of the circle
                      ),
                      child: const Icon (Icons.home_filled,)) : const Icon(Icons.home_outlined),
                title: selectedIndex == 0 ? const Text('Home',style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold,)) : const Text('Home'),
              ),
              CustomNavigationBarItem(
                  icon: selectedIndex == 1 ?  Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.indigo.shade50,
                      ),
                      child: const Icon(Icons.message)) : const Icon(Icons.message_outlined),
                title: selectedIndex == 1 ? const Text('Messages',style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold,)) : const Text('Messages'),
              ),
              CustomNavigationBarItem(
                  icon: selectedIndex == 2 ? Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.indigo.shade50,
                      ),
                      child: const Icon(Icons.feed)) : const Icon(Icons.feed_outlined),
                title: selectedIndex == 2 ? const Text('Feed',style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold,)) : const Text('Feed'),
              ),
              CustomNavigationBarItem(
                  icon: selectedIndex == 3 ? Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.indigo.shade50,
                      ),
                      child: const Icon(Icons.dashboard)) : const Icon(Icons.dashboard_outlined),
                title: selectedIndex == 3 ? const Text('Dashboard',style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold,)) : const Text('Dashboard'),
              ),
            ],
            onTap: _onItemTapped,
            currentIndex: selectedIndex,
                  ),
      ),
    ),
    );
  }
}





