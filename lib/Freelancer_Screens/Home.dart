import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_fyp/Freelancer_Screens/Groupdetails.dart';
import 'Freelancerdetails.dart';
import 'Projectdetails.dart';
import 'notifications.dart';

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


  @override
  void initState(){
    super.initState();
  loadCurrentUser();
  }

  //Function to load current user
  Future<void> loadCurrentUser() async {
    User? user = _auth.currentUser;
    if(user != null){
      try{
        QuerySnapshot querySnapshot = await _firestore.collection('users')
            .where('email',isEqualTo: user.email)
            .get();
        if(querySnapshot.docs.isNotEmpty){
          DocumentSnapshot userDoc = querySnapshot.docs.first;
          setState(() {
            userName = userDoc['username'];
            profileUrl = userDoc['profileUrl'];
          });
          //print('user: $userName');
        }else{
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('user name not found!')),
          );
        }
      }
      catch (e) {
        // Handle any errors that occur during the process
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'),
            ));
        //print('Error loading current user: $e');
      }
    }
  }


  //rating




  @override
  Widget build(BuildContext context) {

    return PopScope(
      canPop: false,
      child: Scaffold(
        //backgroundColor:Color(0xFFEAE9E7),    //logic for writing color code: Color(0xFF-your-code),
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: Padding(padding: EdgeInsets.only(left: 16.0),
          child: GestureDetector(
            onDoubleTap: (){},
            child: CircleAvatar(
                backgroundImage:profileUrl != null
                    ? NetworkImage(profileUrl!):
                NetworkImage('https://t4.ftcdn.net/jpg/05/49/98/39/360_F_549983970_bRCkYfk0P6PP5fKbMhZMIb07mCJ6esXL.jpg'),
            radius: 20,
                  ),
          ),
          ),
          actions: [
            IconButton(onPressed: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Notifications()),
              );
            },
                icon: const Icon(Icons.notifications_none)),
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
                  Navigator.pop(context,);
                }
              },
              itemBuilder: (BuildContext context) {
                return [
                  PopupMenuItem<String>(
                    value: 'item1',
                    child: Text('New Project'),
                  ),
                  PopupMenuItem<String>(
                    value: 'item2',
                    child: Text('New Group'),
                  ),
                  PopupMenuItem<String>(
                    value: 'item3',
                    child: Text('Sign out'),
                  ),
                ];
              },
              offset:  Offset(0, kToolbarHeight),   // This places the dropdown slightly below the app bar.
            )
          ],
          title: const Text('Unity Gig',style: TextStyle(
            fontWeight: FontWeight.w500,color: Colors.white,fontSize: 27,),),
          centerTitle: true,
        ),
        body: Column(
          children: [
            //Divider(color: Colors.grey[200],thickness: 2,height: 1,),
            const Padding(padding: EdgeInsets.only(bottom: 8.0,left: 8.0,right: 8.0),

            ),
          Expanded(child:ListView(
            children:  [
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Row(
                  children: [
                    Text('Welcome, ',style: TextStyle(color: Colors.black87,fontSize: 25,fontWeight: FontWeight.w600),),
                    Text('$userName',style: TextStyle(
                      fontSize: 25,fontWeight: FontWeight.bold,
                        foreground: Paint()..shader = LinearGradient(
                            colors: [Color(0xFF007FFF),Color(0xFFFF0000),],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight)
                            .createShader(Rect.fromLTWH(100,0,200,0))
                    ))
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16.0,bottom: 10),
                child: Text('Explore and Discover',style: TextStyle(
                    color: Colors.black87,fontSize: 25,fontWeight: FontWeight.w600,
                ),),
              ),
              Padding(padding: EdgeInsets.only(left: 16.0,right: 16),
                child: TextFormField(
                  decoration: InputDecoration(
                    prefixIcon: IconButton(onPressed: (){}, icon: Icon(Icons.search,color: Colors.black45,size: 30,),),
                      suffixIcon: IconButton(onPressed: ()
                      {
                        showModalBottomSheet(context: context,
                          builder: (context) => const AdvancedSearchFilters(),
                        );
                      }, icon: Icon(Icons.filter_list,color: Colors.black45,)),
                      hintText: 'Search freelancers, groups, & projects',
                      hintStyle: TextStyle(color: Colors.black38),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none),
                      fillColor: Colors.grey.shade200,
                      filled: true,
                  ),

                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10.0),
                child: SectionHeader(title: 'Freelancers'),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10.0,right: 10),
                child: FreelancerList(),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10.0),
                child: SectionHeader(title: 'Projects'),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10.0,right: 10),
                child: ProjectList(),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10.0),
                child: SectionHeader(title: 'Groups'),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10.0,right: 10),
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




// Section Header Widget
class SectionHeader extends StatelessWidget {
  final String title;

  const SectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}

// Freelancer List Widget
class FreelancerList extends StatelessWidget {
  const FreelancerList({super.key});

  Future<List<Map<String, dynamic>>> _fetchFreelancers() async {
    // Get the current logged-in user
    User? loggedInUser = FirebaseAuth.instance.currentUser;

    // Fetch the list of freelancers from Firestore
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('userType', isEqualTo: 'freelancer')
        .get();
    // Filter out the current logged-in user
    List<Map<String, dynamic>> freelancers = snapshot.docs
        .where((doc) => doc['email'] != loggedInUser?.email)
        .map((doc) {
      var data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id; // Add document ID
      return data;
    }).toList();
    return freelancers;
  }


  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchFreelancers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.indigoAccent,));
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error loading freelancers'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No freelancers found'));
          }

          // Display the list of freelancer cards
          final freelancers = snapshot.data!;
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: freelancers.length,
            itemBuilder: (context, index) {
              final freelancer = freelancers[index];

              return FreelancerCard(
                firstName: freelancers[index]['first_name'],
                lastName: freelancers[index]['last_name'],
                headline: freelancers[index]['headline'],
                hourlyRate: freelancers[index]['hourly_rate'].toString(),
                imageUrl:freelancer['profileUrl'],
                averageRating: freelancers[index]['averageRating'].toString(),
                totalReviews: freelancers[index]['totalReviews'].toString(),
                location: freelancers[index]['location'],
                freelancer: freelancer,
              );
            },
          );
        },
      ),
    );
  }
}

// Freelancer Card Widget
class FreelancerCard extends StatelessWidget {
  final String firstName;
  final String lastName;
  final String headline;
  final String hourlyRate;
  final String imageUrl;
  final String averageRating;
  final String totalReviews;
  final String location;
  final Map<String, dynamic> freelancer;

  const FreelancerCard({
    required this.firstName,
    required this.lastName,
    required this.headline,
    required this.hourlyRate,
    required this.imageUrl,
    required this.freelancer,
    required this.averageRating,
    required this.totalReviews,
    required this.location,

    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FreelancerDetails(freelancer: freelancer),
          ),
        );
      },
      child: Card(
        color: Colors.grey[50],
        shadowColor: Colors.grey[300],
        elevation: 4.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        margin: const EdgeInsets.all(8.0),
        child: Container(
          width: 200,
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ClipOval(
                    child: Image.network(
                      imageUrl, // Use the imageUrl here
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey[300],
                          ),
                          child: const Icon(Icons.person, color: Colors.white),
                        );
                      },
                    ),
                  ),
                  SizedBox(width: 5,),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$firstName $lastName',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold,),
                        ),
                        Row(
                          children: [
                            Icon(Icons.attach_money,color: Colors.indigoAccent,size: 18,),
                            Text('\$$hourlyRate/hr',style: TextStyle(color: Colors.grey[600
                            ]),),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(Icons.location_on,color: Colors.indigoAccent,size: 18,),
                            Text(location,style: TextStyle(color: Colors.grey[600]),)
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  Icon(Icons.star,size: 18,color: Colors.amber,),
                  RichText(
                    text: TextSpan(
                        children: <TextSpan>[
                          TextSpan(
                              text: averageRating,
                              style: TextStyle(
                                color: Colors.grey[600],
                              )
                          ),
                          TextSpan(
                              text: '/5',
                              style: TextStyle(color: Colors.grey[600],fontSize: 12)
                          ),
                          TextSpan(
                            text: (" ($totalReviews Review)"),
                            style: TextStyle(color: Colors.blue),
                          )
                        ]
                    ),
                  )
                ],
              ),
              Text(
                ' $headline',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Project List Widget
class ProjectList extends StatelessWidget {
  const ProjectList({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('projects').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No projects available'));
          }

          final projectDocs = snapshot.data!.docs;

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: projectDocs.length,
            itemBuilder: (context, index) {
              var projectData = projectDocs[index].data() as Map<String, dynamic>;

              String projectId = projectDocs[index].id;

              // Handling possible null values with fallback default strings
              String projectName = projectData['project_name'] ?? 'Unnamed Project';
              String description = projectData['description'] ?? 'No Description';
              String ownerName = projectData['owner_name'] ?? 'Unknown';

              double budget = (projectData['budget'] is int)
                  ? (projectData['budget'] as int).toDouble()
                  : projectData['budget'] ?? 0.0;

              String postedById = projectData['posted_by'] ?? 'Unknown User';



              return ProjectCard(
                projectName: projectName,
                budget: budget,
                description: description,
                projectId: projectId,
                postedById: postedById,
                ownerName: ownerName,
              );
            },
          );
        },
      ),
    );
  }
}


// Project Card Widget
class ProjectCard extends StatelessWidget {
  final String projectName;
  final double budget;
  final String description;
  final String projectId;
  final String postedById;
  final String ownerName;

  const ProjectCard({
    super.key,
    required this.projectName,
    required this.budget,
    required this.description,
    required this.projectId,
    required this.postedById,
    required this.ownerName,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to ProjectDetails page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProjectDetails(
              projectId: projectId,
              postedById: postedById,
              projectName: projectName,
            ),
          ),
        );
      },
      child: Card(
        //color: const Color(0xFFEED3D9),
        color:Colors.grey[50],
        shadowColor: Colors.grey[400],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        elevation: 4.0,
        margin: const EdgeInsets.all(8.0),
        child: Container(
          width: 200,
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.assignment,size: 50,color: Colors.black87,),
                  SizedBox(width: 10,),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          projectName,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: [
                            Icon(Icons.account_balance_wallet,size: 15,color: Colors.grey[700],),
                            Text('Budget: \$${budget.toStringAsFixed(2)}',style: TextStyle(color: Colors.grey[700]),),
                          ],
                        ),
                      ],
                    ),
                  ),

                ],
              ),
              Divider(color: Colors.grey[300],thickness: 1,height: 1,),
              const SizedBox(height: 5),
              Row(
                children: [
                  Icon(Icons.person_2_rounded,size: 15,color: Colors.grey[700],),
                  Text('Posted By: $ownerName',style: TextStyle(color: Colors.grey[600]),),
                ],
              ),
              Text(
                description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,style: TextStyle(color:Colors.grey[600] ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Group List Widget
class GroupList extends StatelessWidget {
  const GroupList({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('groups').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No groups available'));
          }

          final projectDocs = snapshot.data!.docs;

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: projectDocs.length,
            itemBuilder: (context, index) {
              var groupData = projectDocs[index].data() as Map<String, dynamic>;

              // Handling possible null values with fallback default strings
              String groupName = groupData['group_name'] ?? 'Unnamed Group';
              String description = groupData['description'] ?? 'No Description';
              String ownerName = groupData['creator_name'] ?? 'Unknown';
              String postedById = groupData['created_by'] ?? 'Unknown User';
              String profileImage = groupData['profile_image'];
              String members = (groupData['members'] as List<dynamic>?)?.length.toString() ?? '0';


              return GroupCard(
                groupId :projectDocs[index].id,
                groupName: groupName,
                description: description,
                postedById: postedById,
                ownerName: ownerName,
                profileImage: profileImage,
                members: members,
              );
            },
          );
        },
      ),
    );
  }
}

// Group Card Widget
class GroupCard extends StatelessWidget {
  final String groupId;
  final String groupName;
  final String description;
  final String postedById;
  final String ownerName;
  final String profileImage;
  final String members;

  const GroupCard({
    super.key,
    required this.groupId,
    required this.groupName,
    required this.description,
    required this.postedById,
    required this.ownerName,
    required this.profileImage,
    required this.members,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GroupDetails(groupId: groupId),
          ),
        );
      },
      child: Card(
        //color: const Color(0xFFEED3D9),
        color:Colors.grey[50],
        shadowColor: Colors.grey[400],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        elevation: 4.0,
        margin: const EdgeInsets.all(8.0),
        child: Container(
          width: 200,
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ClipOval(
                    child: Image.network(
                      profileImage, // Use the imageUrl here
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey[300],
                          ),
                          child: const Icon(Icons.person, color: Colors.white),
                        );
                      },
                    ),
                  ),
                  SizedBox(width: 10,),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          groupName,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: [
                            Icon(Icons.group,size: 15,color: Colors.grey[700],),
                            Text('Members: $members',style: TextStyle(color: Colors.grey[600]),)
                          ],
                        ),
                      ],
                    ),
                  ),

                ],
              ),
              Divider(color: Colors.grey[300],thickness: 1,height: 1,),
              const SizedBox(height: 5),
              Row(
                children: [
                  Icon(Icons.person_2_rounded,size: 15,color: Colors.grey[700],),
                  Text('Created By: $ownerName',style: TextStyle(color: Colors.grey[600]),),
                ],
              ),
              Text(
                description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,style: TextStyle(color:Colors.grey[600] ),
              ),
            ],
          ),
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
          const Text('Advanced Search', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),

          // Search Freelancers by Hourly Rate (Slider)
          Text('Search Freelancers by Hourly Rate: \$${hourlyRate.toStringAsFixed(2)}'),
          Slider(
            value: hourlyRate,
            min: minHourlyRate,
            max: maxHourlyRate,
            divisions: 100, // You can define divisions for more precise values
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
          Text('Search Projects by Budget: \$${projectBudget.toStringAsFixed(0)}'),
          Slider(
            value: projectBudget,
            min: minBudget,
            max: maxBudget,
            divisions: 100, // You can define divisions for more precise values
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
              print('Hourly Rate: $hourlyRate, Skills: $skills, Budget: $projectBudget, Group Members: $groupMembers');
              Navigator.pop(context);
            },
            child: const Text('Search', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
class PostProject extends StatefulWidget {
  const PostProject({super.key});

  @override
  State<StatefulWidget> createState() => _PostProjectState ();
}

class _PostProjectState extends State<PostProject> {
final TextEditingController nameController = TextEditingController();
final TextEditingController descriptionController = TextEditingController();
final TextEditingController budgetController = TextEditingController();
final TextEditingController ownerController = TextEditingController();


final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final FirebaseAuth _auth = FirebaseAuth.instance;
String? userName = '';

@override
void initState(){
  super.initState();
  loadCurrentUser();
  publishProject();
}

//Function to load current user
Future<void> loadCurrentUser() async {
  User? user = _auth.currentUser;
  if(user != null){
    try{
      QuerySnapshot querySnapshot = await _firestore.collection('users')
          .where('email',isEqualTo: user.email)
          .get();
      if(querySnapshot.docs.isNotEmpty){
        DocumentSnapshot userDoc = querySnapshot.docs.first;
        setState(() {
          userName = userDoc['username'];
        });
        //print('user: $userName');
      }else{
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('user name not found!')),
        );
      }
    }
    catch (e) {
      // Handle any errors that occur during the process
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'),
          ));
      //print('Error loading current user: $e');
    }
  }
}






//--------------------------------------------Function to save project to firestore-------------------------------------

  Future<void> publishProject() async {
    try {
      // Retrieve form data
      String projectName = nameController.text;
      String description = descriptionController.text;
      double? budget = double.tryParse(budgetController.text); // Parse budget as double

      // Check for empty fields
      if (projectName.isEmpty || description.isEmpty || budget == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating, // Make it float
              margin: EdgeInsets.only(bottom: 80.0, left: 16.0, right: 16.0),
              duration: Duration(seconds: 3),
              content: Text('Please fill all fields')),
        );
        return;
      }
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No user is logged in!')),
        );
        return;
      }
      // Create a new document in the "projects" collection
      await _firestore.collection('projects').add({
        'project_name': projectName,
        'owner_name': userName,
        'description': description,
        'budget': budget,
        'project_created_at': FieldValue.serverTimestamp(), // Timestamp for project creation
        'posted_by': user.uid,
        'project_status': 'Not Started',
      });
      print('owner name: $userName');
      // Show success message and clear the form
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating, // Make it float
            margin: EdgeInsets.only(bottom: 80.0, left: 16.0, right: 16.0),
            duration: Duration(seconds: 3),

            content: Text('Project published successfully!')),
      );
      Navigator.pop(context);
    } catch (e) {
      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            backgroundColor: Colors.red,
            content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build (buildContext){
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Publish a Project'),
        leading: IconButton(onPressed: (){
          Navigator.pop(context);
        }, icon: const Icon(Icons.close)),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(Icons.assignment_outlined,color: Colors.indigoAccent,size: 150,),
            TextFormField(
              style: const TextStyle(
                fontWeight: FontWeight.w500
              ),
              autofocus: false,
              autocorrect: true,
              controller: nameController,
              decoration: InputDecoration(
                hintText: 'Project Name',
                hintStyle: const TextStyle(
                  color: Colors.grey
                ),
                focusColor: Colors.white,
                prefixIcon: const Icon(Icons.work_outline,color: Colors.grey,),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              textCapitalization: TextCapitalization.words,
              keyboardType: TextInputType.text,
            ),
            SizedBox(height: 16,),
            TextFormField(
              style: const TextStyle(
                  fontWeight: FontWeight.w500
              ),
              controller: budgetController,
              decoration: InputDecoration(
                hintText: '\$ Budget',
                hintStyle: const TextStyle(
                  color: Colors.grey,
                ),
                prefixIcon: const Icon(Icons.account_balance_outlined,color: Colors.grey,),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16,),
            TextField(
              autocorrect: true,
              style: const TextStyle(fontWeight: FontWeight.w500),
              controller: descriptionController,
              minLines: 5,
              decoration: InputDecoration(
                labelText: 'Description max (100 words)',
                labelStyle: const TextStyle(
                  color: Colors.grey,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  //borderSide: BorderSide.none,
                ),
              ),
              textCapitalization: TextCapitalization.sentences,
              keyboardType: TextInputType.text,
              maxLines: null,
              inputFormatters: [
                LengthLimitingTextInputFormatter(600), // Limits input to 600 characters or 100 words
              ],
            ),
            const SizedBox(height: 30,),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigoAccent,
                  elevation: 2.0,
                  minimumSize: Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: (){
                  publishProject();
                }, child: const Text('Publish',style: TextStyle(fontSize: 18,color: Colors.white),))
          ],
        ),
      ),
    );
  }
  }

class CreateGroup extends StatefulWidget {
  const CreateGroup({super.key});

  @override
  State<StatefulWidget> createState() => _CreateGroupState();
}

class _CreateGroupState extends State<CreateGroup> {
  final TextEditingController groupNameController = TextEditingController();
  final TextEditingController groupDescriptionController = TextEditingController();
  final TextEditingController groupRulesController = TextEditingController();
  final TextEditingController groupMembersController = TextEditingController();
  File? _profileImage;
  String? imageUrl;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? userName = '';
  String userEmail = '';
  List<String> groupMembers = [];
  List<Map<String, dynamic>> freelancersList = [];
  List<String> selectedFreelancerEmails = [];
  List<String> selectedFreelancerUsernames = [];

  @override
  void initState() {
    super.initState();
    loadCurrentUser();
    _fetchFreelancers();
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
            userEmail = userDoc ['email'];
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

  Future _fetchFreelancers() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('userType', isEqualTo: 'freelancer')
          .get();

      List<Map<String, String>> freelancers = [];
      User? currentUser = _auth.currentUser;

      for (var doc in snapshot.docs) {
        Map data = doc.data() as Map;
        String email = data['email'];
        String username = data['username'];

        // Exclude the current user from the list
        if (currentUser != null && email != currentUser.email) {
          freelancers.add({
            'email': email,
            'username': username,
          });
        }
      }

      setState(() {
        freelancersList = freelancers;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching freelancers: $e')),
      );
    }
  }

  Future<void> createGroup() async {
    try {
      String groupName = groupNameController.text;
      String groupDescription = groupDescriptionController.text;
      String groupRules = groupRulesController.text;

      if (groupName.isEmpty || groupDescription.isEmpty || groupRules.isEmpty  ) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(bottom: 16.0,left: 16.0,right: 16.0),
            duration: Duration(seconds: 3),
            content: Text('Please fill all fields!'),
          ),
        );
        return;
      }

      User? user = _auth.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No user is logged in!')),
        );
        return;
      }

      Set<String> allMembers = Set.from(selectedFreelancerEmails.where((email) => userEmail.isNotEmpty));
      if (userEmail.isNotEmpty) {
        allMembers.add(userEmail);
      }
      groupMembers = allMembers.toList();



      if (_profileImage != null) {
        // Upload image to Firebase Storage and get the URL
        // Add Firebase Storage implementation here if needed
        imageUrl = await uploadGroupImage(_profileImage!); // Replace this with actual URL after upload
      }

      await _firestore.collection('groups').add({
        'group_name': groupName,
        'description': groupDescription,
        'rules': groupRules,
        'members': groupMembers,
        'created_by': user.uid,
        'creator_name': userName,
        'group_admin': userEmail,
        'profile_image': imageUrl,
        'created_at': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(bottom: 16.0,left: 16.0,right: 16.0),
          content: Text('Group created successfully!'),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Error: $e'),
        ),
      );
    }
  }

  Future<void> pickProfileImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);

      });
    }
  }

  Future<String?>uploadGroupImage(File image)async {
    try{
      User? currentUser = _auth.currentUser; // Get the current user
      if (currentUser != null) {
        String userId = currentUser.uid;
        Reference reference = FirebaseStorage.instance
            .ref()
            .child("group_profileImages/$userId/Group_Profile.png");
        await reference.putFile(image);
         return await reference.getDownloadURL();

      }
      else{
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text('No user is logged in!'),
          ),
        );
      }
    }
    catch(e){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Failed to upload image: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create a Group'),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.close),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: pickProfileImage,
              child: CircleAvatar(
                backgroundColor: Colors.indigo.shade50,
                radius: 60,
                backgroundImage: _profileImage != null
                    ? FileImage(_profileImage!)
                    : null,
                child: _profileImage == null
                    ? const Icon(
                  Icons.camera_alt,
                  size: 40,
                  color: Colors.grey,
                )
                    : null,
              ),
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              style: TextStyle(fontWeight: FontWeight.w500),
              controller: groupNameController,
              decoration: InputDecoration(
                hintText: 'Group Name',
                hintStyle: TextStyle(color: Colors.grey,fontWeight: FontWeight.normal),
                prefixIcon: Icon(Icons.group_add_outlined,color: Colors.grey,),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: groupDescriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                label: Text('Group Description'),
                labelStyle: TextStyle(color: Colors.grey,),
                hintText: 'Group Description',
                hintStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: groupRulesController,
              maxLines: 3,
              decoration: InputDecoration(
                label: Text('Group Rules'),
                labelStyle: TextStyle(color: Colors.grey),
                hintText: 'Group Rules',
                hintStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 8.0),
            const Text('Select Members:', style: TextStyle(fontSize: 16)),
            SingleChildScrollView(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(width: 1.0,color: Colors.grey),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: freelancersList.length,
                  itemBuilder: (context, index) => CheckboxListTile(
                    title: Text(freelancersList[index]['email']),
                    value: selectedFreelancerEmails.contains(freelancersList[index]['email']),
                    onChanged: (value) => setState(() {
                      if (value!) {
                        selectedFreelancerEmails.add(freelancersList[index]['email']);
                      } else {
                        selectedFreelancerEmails.remove(freelancersList[index]['email']);
                      }
                    }),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8.0),
            Column(
              children: [
                if (userEmail.isNotEmpty || selectedFreelancerEmails.isNotEmpty) // Conditionally render Wrap
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: [
                      if (userEmail.isNotEmpty) // Display current user's email
                        Chip(label: Text(userEmail)),
                      ...selectedFreelancerEmails.map((email) => Chip(
                        label: Text(email),
                        onDeleted: () => setState(() => selectedFreelancerEmails.remove(email)),
                      )).toList(),
                    ],
                  ),
              ],
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigoAccent,
                minimumSize: Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: createGroup,
              child: const Text(
                'Create',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
