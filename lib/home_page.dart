import 'package:flutter/material.dart';

//this is a home page of freelancers. when freelancer login this page displays.

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;
  final List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    ChatsScreen(),
    UsersScreen(),
    FeedScreen(),
    DashboardScreen(),
  ];
  final List<String> _appBarTitles = [
    'Home',
    'Chats',
    'Users',
    'Feed',
    'Dashboard',
  ];
  void _onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_appBarTitles[selectedIndex],),//Set the appbar title based on selected index
        automaticallyImplyLeading: false,// removes the default back arrow icon from appbar
        backgroundColor: Colors.white,

      ),
      body: Container(
        child: _widgetOptions.elementAt(selectedIndex),

      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message_outlined),
            label: 'Chats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt_outlined),
            label: 'users',
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.feed_outlined),
            label: 'Feed',
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              label:'Dashboard'
          )
        ],
        currentIndex: selectedIndex,
        selectedItemColor: Colors.indigoAccent,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> projects = [];
  List<Map<String, dynamic>> groups = [];
  List<Map<String, dynamic>> freelancers = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Database se data load karein
    // Example:
    projects = await _fetchProjectsFromDatabase();
    groups = await _fetchGroupsFromDatabase();
    freelancers = await _fetchFreelancersFromDatabase();
    setState(() {});
  }

  // Database se projects fetch karne ka function
  Future<List<Map<String, dynamic>>> _fetchProjectsFromDatabase() async {
    // Yahan database interaction ka code likhein
    // Example:
    return [
      {'image': 'assets/project1.png', 'name': 'Project 1', 'description': 'Description 1'},
      {'image': 'assets/project2.png', 'name': 'Project 2', 'description': 'Description 2'},
      {'image': 'assets/project3.png', 'name': 'Project 3', 'description': 'Description 3'},
      {'image': 'assets/project4.png', 'name': 'Project 4', 'description': 'Description 4'},
    ];
  }

  // Database se groups fetch karne ka function
  Future<List<Map<String, dynamic>>> _fetchGroupsFromDatabase() async {
    // Yahan database interaction ka code likhein
    // Example:
    return [
      {'image': 'assets/group1.png', 'name': 'Group 1', 'description': 'Description 1'},
      {'image': 'assets/group2.png', 'name': 'Group 2', 'description': 'Description 2'},
      {'image': 'assets/group3.png', 'name': 'Group 3', 'description': 'Description 3'},
      {'image': 'assets/group4.png', 'name': 'Group 4', 'description': 'Description 4'},
    ];
  }// Database se freelancers fetch karne ka function
  Future<List<Map<String, dynamic>>> _fetchFreelancersFromDatabase() async {
    // Yahan database interaction ka code likhein
    // Example:
    return [
      {'image': 'assets/freelancer1.png', 'name': 'Freelancer 1', 'description': 'Description 1'},
      {'image': 'assets/freelancer2.png', 'name': 'Freelancer 2', 'description': 'Description 2'},
      {'image': 'assets/freelancer3.png', 'name': 'Freelancer 3', 'description': 'Description 3'},
      {'image': 'assets/freelancer4.png', 'name': 'Freelancer 4', 'description': 'Description 4'},
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: ListView(
        children: [
          _buildSection('Projects', projects),
          _buildSection('Groups', groups),
          _buildSection('Freelancers', freelancers),
        ],
      ),
    );
  }
  Widget _buildSection(String title, List<Map<String, dynamic>> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            title,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 200, // Adjust height as needed
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: data.length,
            itemBuilder: (context, index) {
              return _buildItem(data[index]);
            },
          ),
        ),
      ],
    );
  }
  Widget _buildItem(Map<String, dynamic> item) {
    return InkWell(
      onTap: ()
      {

      },
      child: Card(
        child: Container(
          width: 200, // Adjust width as needed
          child: Column(
            children: [
              Image.asset(item['image']),
              Text(item['name']),
              Text(item['description']),
            ],
          ),
        ),
      ),
    );
  }
}










class ChatsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text('Chats Screen');
  }
}

class UsersScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text('Users Screen');
  }
}

class FeedScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text('Feed Screen');
  }
}

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text('Dashboard Screen');
  }
}