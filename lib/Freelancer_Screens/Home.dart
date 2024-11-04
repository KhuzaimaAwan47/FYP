import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'Freelancerdetails.dart';
import 'Projectdetails.dart';

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



  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            showModalBottomSheet(context: context,
              builder: (context) => const AdvancedSearchFilters(),
            );
          }, icon: const Icon(Icons.search_outlined)),
          IconButton(onPressed: (){
            Navigator.push(
              context, MaterialPageRoute(builder: (context) => const PostProject(),),);
          }, icon: const Icon(Icons.add))
        ],
        title: const Text('Unity Gig',style: TextStyle(
          fontWeight: FontWeight.w500,color: Colors.indigo,fontSize: 27,),),
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
    // Filter out the logged-in user
    List<Map<String, dynamic>> freelancers = snapshot.docs
        .where((doc) => doc['email'] != loggedInUser?.email) // Exclude the logged-in user
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();

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
            return const Center(child: CircularProgressIndicator(color: Colors.indigo,));
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
                skills: freelancers[index]['skills'],
                hourlyRate: freelancers[index]['hourly_rate'].toString(),
                imageUrl:freelancer['profileUrl'],
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
  final String skills;
  final String hourlyRate;
  final String imageUrl;
  final Map<String, dynamic> freelancer;

  const FreelancerCard({
    required this.firstName,
    required this.lastName,
    required this.skills,
    required this.hourlyRate,
    required this.imageUrl,
    required this.freelancer,

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
                        RichText(
                          text: TextSpan(
                            children: <TextSpan>[
                              TextSpan(
                                text: 'Price: ',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              TextSpan(
                                text: '\$$hourlyRate/hr',
                                style: TextStyle(
                                  color: Colors.indigoAccent,
                                  fontWeight: FontWeight.w500, // And make it bold
                                ),
                              ),
                            ],
                          ),
                        )
                        //Text('Review')
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                ' $skills',
                maxLines: 1,
                overflow: TextOverflow.visible,
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
                  Container(
                      width: 50,
                      height: 50,
                      child: Image.network('https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQQ0-PF3nQlSxFcXA2NdKlfsjg1atj1w5ZOWQ&s')),
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
                        Text('Budget: \$${budget.toStringAsFixed(2)}',style: TextStyle(color: Colors.grey[700]),),
                      ],
                    ),
                  ),

                ],
              ),
              const SizedBox(height: 5),
              Text('Posted By: $ownerName',style: TextStyle(color: Colors.grey[600]),),
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
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 10, // Replace with actual data
        itemBuilder: (context, index) {
          return const GroupCard(); // Group card layout
        },
      ),
    );
  }
}

// Group Card Widget
class GroupCard extends StatelessWidget {
  const GroupCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      //color: const Color(0xFFDECFDA),
      color: Colors.grey[50],
      shadowColor: Colors.grey[300],
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      margin: const EdgeInsets.all(8.0),
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Pakistan Flutter Interns', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,)),
            Text('Members: 4',style: TextStyle(color: Colors.grey[600]),),
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

//--------------------------------------------Function to save project to firestore-------------------------------------

  Future<void> publishProject() async {
    try {
      // Retrieve form data
      String projectName = nameController.text;
      String ownerName = ownerController.text;
      String description = descriptionController.text;
      double? budget = double.tryParse(budgetController.text); // Parse budget as double

      // Check for empty fields
      if (projectName.isEmpty || ownerName.isEmpty || description.isEmpty || budget == null) {
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
        'owner_name': ownerName,
        'description': description,
        'budget': budget,
        'project_created_at': FieldValue.serverTimestamp(), // Timestamp for project creation
        'posted_by': user.uid,
      });

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
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                  width: 150,
                  height: 150,
                  child: Image.network('https://cdn-icons-png.flaticon.com/512/1205/1205515.png')),
            ),
            Padding(padding: const EdgeInsets.all(16.0),
              child: TextFormField(
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
                  prefixIcon: const Icon(Icons.abc_sharp,),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                textCapitalization: TextCapitalization.words,
                keyboardType: TextInputType.text,
              ),
            ),
            Padding(padding: const EdgeInsets.all(16.0),
              child: TextFormField(
                autocorrect: true,
                style: const TextStyle(fontWeight: FontWeight.w500),
                controller: ownerController,
                decoration: InputDecoration(
                  hintText: 'Owner Name',
                  hintStyle: const TextStyle(
                    color: Colors.grey,
                  ),
                  prefixIcon: const Icon(Icons.perm_identity_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                textCapitalization: TextCapitalization.words,
              ),
            ),
            Padding(padding: const EdgeInsets.all(16.0),
            child: TextFormField(
              style: const TextStyle(
                  fontWeight: FontWeight.w500
              ),
              controller: budgetController,
              decoration: InputDecoration(
                hintText: '\$ Budget',
                hintStyle: const TextStyle(
                  color: Colors.grey,
                ),
                prefixIcon: const Icon(Icons.money_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            ),

            Padding(padding: const EdgeInsets.all(16.0),
              child: TextField(
                autocorrect: true,
                style: const TextStyle(fontWeight: FontWeight.w500),
                controller: descriptionController,
                decoration: InputDecoration(
                  hintText: 'Description max (100 words)',
                  hintStyle: const TextStyle(
                    color: Colors.grey,
                  ),
                  prefixIcon: const Icon(Icons.description_outlined),
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
            ),
            const SizedBox(height: 30,),
            Padding(padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigoAccent,
                  elevation: 2.0,
                  padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.35, // 35% of the screen width
                    vertical: 10,
                  ),
                ),
                onPressed: (){
                  publishProject();
                }, child: const Text('Publish',style: TextStyle(fontSize: 18,color: Colors.white),)),)
          ],
        ),
      ),
    );
  }
  }
 

  
