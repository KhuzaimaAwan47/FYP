import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User name not found!')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
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
                  Navigator.pop(context);
                }
              },
              itemBuilder: (BuildContext context) {
                return [
                  const PopupMenuItem<String>(
                    value: 'item1',
                    child: Text('New Project'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'item2',
                    child: Text('New Group'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'item3',
                    child: Text('Sign out'),
                  ),
                ];
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
                    padding: const EdgeInsets.only(left: 16.0, right: 16),
                    child: TextFormField(
                      decoration: InputDecoration(
                        prefixIcon: IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.search,
                            color: Colors.black45,
                            size: 30,
                          ),
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (context) =>
                              const AdvancedSearchFilters(),
                            );
                          },
                          icon: const Icon(
                            Icons.filter_list,
                            color: Colors.black45,
                          ),
                        ),
                        hintText: 'Search freelancers, groups, & projects',
                        hintStyle: const TextStyle(color: Colors.black38),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        fillColor: Colors.grey.shade200,
                        filled: true,
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

// Advanced Search Filters Widget
class AdvancedSearchFilters extends StatefulWidget {
  const AdvancedSearchFilters({super.key});

  @override
  _AdvancedSearchFiltersState createState() => _AdvancedSearchFiltersState();
}

class _AdvancedSearchFiltersState extends State<AdvancedSearchFilters> {
  // State variables for sliders and text fields
  double hourlyRate = 50; // Default hourly rate value
  double minHourlyRate = 0;
  double maxHourlyRate = 100;

  double projectBudget = 5000; // Default project budget
  double minBudget = 0;
  double maxBudget = 10000;

  double groupMembers = 50; // Default group members
  double minMembers = 1;
  double maxMembers = 100;

  String skills = ""; // Skills input

  // UI widget
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Advanced Search Title
          const Text('Advanced Search',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),

          // Search Freelancers by Hourly Rate (Slider)
          Text(
              'Search Freelancers by Hourly Rate: \$${hourlyRate.toStringAsFixed(2)}'),
          Slider(
            value: hourlyRate,
            min: minHourlyRate,
            max: maxHourlyRate,
            divisions: 100,
            // You can define divisions for more precise values
            label: '\$${hourlyRate.toStringAsFixed(2)}',
            onChanged: (value) {
              setState(() {
                hourlyRate = value;
              });
            },
          ),

          // Search Freelancers by Skills (TextField)
          const Text('Search Freelancers by Skills:'),
          TextField(
            decoration: const InputDecoration(hintText: 'Enter skills...'),
            onChanged: (value) {
              setState(() {
                skills = value;
              });
            },
          ),
          const SizedBox(height: 10),

          // Search Projects by Budget (Slider)
          Text(
              'Search Projects by Budget: \$${projectBudget.toStringAsFixed(0)}'),
          Slider(
            value: projectBudget,
            min: minBudget,
            max: maxBudget,
            divisions: 100,
            // You can define divisions for more precise values
            label: '\$${projectBudget.toStringAsFixed(0)}',
            onChanged: (value) {
              setState(() {
                projectBudget = value;
              });
            },
          ),
          const SizedBox(height: 10),

          // Search Groups by Members (Slider)
          Text('Search Groups by Members: ${groupMembers.toInt()}'),
          Slider(
            value: groupMembers,
            min: minMembers,
            max: maxMembers,
            divisions: 100,
            label: '${groupMembers.toInt()} Members',
            onChanged: (value) {
              setState(() {
                groupMembers = value;
              });
            },
          ),
          const SizedBox(height: 20),

          // Search Button
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              padding: const EdgeInsets.symmetric(
                horizontal: 35,
                vertical: 10,
              ),
            ),
            onPressed: () {
              // Perform search action with filters applied
              print(
                  'Hourly Rate: $hourlyRate, Skills: $skills, Budget: $projectBudget, Group Members: $groupMembers');
              Navigator.pop(context);
            },
            child: const Text('Search', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}