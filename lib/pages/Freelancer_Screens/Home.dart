import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_fyp/pages/Freelancer_Screens/search.dart';
import 'create_group.dart';
import 'create_project.dart';
import 'notifications.dart';
import '../../widgets/freelancer_list.dart';
import '../../widgets/group_list.dart';
import '../../widgets/project_list.dart';
import '../../widgets/section_header.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? userName = '';
  String? profileUrl;
  String? userType;

  // Freelancers fetched once
  List<Map<String, dynamic>> _freelancers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      // Fetch current user details
      await loadCurrentUser();

      // Fetch freelancers once
      final freelancersFuture = _fetchFreelancers();

      // Wait for freelancers to load
      final freelancers = await freelancersFuture;

      setState(() {
        _freelancers = freelancers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
    }
  }

  Future<void> loadCurrentUser() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        QuerySnapshot querySnapshot = await _firestore
            .collection('users')
            .where('email', isEqualTo: user.email)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          DocumentSnapshot userDoc = querySnapshot.docs.first;
          setState(() {
            userName = userDoc['username'];
            profileUrl = userDoc['profileUrl'];
            userType = userDoc['userType'];
          });
        } else {}
      } catch (e) {
        return;
      }
    }
  }

  Future<List<Map<String, dynamic>>> _fetchFreelancers() async {
    User? loggedInUser = _auth.currentUser;
    QuerySnapshot snapshot = await _firestore
        .collection('users')
        .where('userType', isEqualTo: 'freelancer')
        .get();

    return snapshot.docs
        .where((doc) => doc['email'] != loggedInUser?.email)
        .map((doc) {
      var data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text(
            'Unity Gig',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.white,
              fontSize: 27,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Notifications()),
                );
              },
              icon: const Icon(Icons.notifications_none),
            ),
            PopupMenuButton<String>(
              color: Colors.white,
              onSelected: (value) {
                if (value == 'item1') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PostProject()),
                  );
                } else if (value == 'item2') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CreateGroup()),
                  );
                } else if (value == 'item3') {
                  _auth.signOut();
                }
              },
              itemBuilder: (context) {
                List<PopupMenuEntry<String>> items = [
                  const PopupMenuItem<String>(
                    value: 'item1',
                    child: Text('New Project'),
                  ),
                ];

                // Only show "New Group" if user is a freelancer
                if (userType == 'freelancer') {
                  items.add(
                    const PopupMenuItem<String>(
                      value: 'item2',
                      child: Text('New Group'),
                    ),
                  );
                }

                items.add(
                  const PopupMenuItem<String>(
                    value: 'item3',
                    child: Text('Sign out'),
                  ),
                );

                return items;
              },
              offset: const Offset(0, kToolbarHeight),
            )
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0),
            ),
            Expanded(
              child: ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Row(
                      children: [
                        const Text(
                          'Welcome, ',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 25,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '$userName',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            foreground: Paint()
                              ..shader = LinearGradient(
                                colors: [
                                  const Color(0xFF007FFF),
                                  const Color(0xFF00FFFF),
                                  const Color(0xFFFF00FF),
                                  const Color(0xFFFF0000),
                                ],
                                stops: const [0.0, 0.3, 0.7, 1.0],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ).createShader(
                                Rect.fromLTWH(0, 0, 200, 50),
                              ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, bottom: 10),
                    child: const Text(
                      'Explore and Discover',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 25,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                    child: GestureDetector(
                      onTap: () {
                        final userEmail = _auth.currentUser?.email;
                        if(userEmail != null){
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Search(
                                    userEmail: userEmail
                                )),
                          );
                        }
                      },
                      child: Container(
                        height: 50.0,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 12.0),
                        child: const Row(
                          children: [
                            Icon(Icons.search, color: Colors.grey,size: 30),
                            SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                "Search freelancers, groups, & projects",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: SectionHeader(title: 'Freelancers'),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0, right: 10),
                    child: FreelancerList(freelancers: _freelancers),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: SectionHeader(title: 'Projects'),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0, right: 10),
                    child: ProjectList(),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: SectionHeader(title: 'Groups'),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0, right: 10),
                    child: GroupList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}