import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'Projectdetails.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
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
        title: const Text('Home Screen',style: TextStyle(fontWeight: FontWeight.w500),),
      ),
      body: Column(
        children: [
          const Padding(padding: EdgeInsets.all(8.0),

          ),
        Expanded(child:ListView(
          children: const [
            SectionHeader(title: 'Freelancers'),
            FreelancerList(),
            SectionHeader(title: 'Projects'),
            ProjectList(),
            SectionHeader(title: 'Groups'),
            GroupList(),
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

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 10, // Replace with actual data
        itemBuilder: (context, index) {
          return const FreelancerCard(); // Freelancer card layout
        },
      ),
    );
  }
}

// Freelancer Card Widget
class FreelancerCard extends StatelessWidget {
  const FreelancerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[100],
      shadowColor: Colors.grey[300],
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      margin: EdgeInsets.all(8.0),
      child: Container(
        width: 200,
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Khuzaima Awan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text('Skills: Flutter, Firebase',style: TextStyle(color: Colors.grey[600]),),
            Text('Hourly Rate: \$50',style: TextStyle(color: Colors.grey[600]),),
          ],
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

  const ProjectCard({
    super.key,
    required this.projectName,
    required this.budget,
    required this.description,
    required this.projectId,
    required this.postedById,
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
          color:Colors.lightBlue[50],
          shadowColor: Colors.grey[400],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        elevation: 2.0,
        margin: const EdgeInsets.all(8.0),
        child: Container(
          width: 200,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                projectName,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Text('Budget: \$,${budget.toStringAsFixed(2)}',style: TextStyle(color: Colors.grey[700]),),
              const SizedBox(height: 5),
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
          return GroupCard(); // Group card layout
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
      color: Colors.green[50],
      shadowColor: Colors.grey[300],
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
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
          const SnackBar(content: Text('Please fill in all fields')),
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
            Padding(padding: const EdgeInsets.all(16.0),
              child: TextFormField(
                style: const TextStyle(
                  fontWeight: FontWeight.w500
                ),
                autofocus: true,
                controller: nameController,
                decoration: InputDecoration(
                  hintText: 'Project Name',
                  hintStyle: const TextStyle(
                    color: Colors.grey
                  ),
                  focusColor: Colors.white,
                  prefixIcon: const Icon(Icons.abc_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                keyboardType: TextInputType.text,
              ),
            ),
            Padding(padding: const EdgeInsets.all(16.0),
              child: TextFormField(
                style: const TextStyle(fontWeight: FontWeight.w500),
                autofocus: true,
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
              ),
            ),
            Padding(padding: const EdgeInsets.all(16.0),
            child: TextFormField(
              style: const TextStyle(
                  fontWeight: FontWeight.w500
              ),
              autofocus: true,
              controller: budgetController,
              decoration: InputDecoration(
                hintText: 'Budget in \$',
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
              child: TextFormField(
                style: const TextStyle(fontWeight: FontWeight.w500),
                autofocus: true,
                controller: descriptionController,
                decoration: InputDecoration(
                  hintText: 'Description',
                  hintStyle: const TextStyle(
                    color: Colors.grey,
                  ),
                  prefixIcon: const Icon(Icons.description),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                keyboardType: TextInputType.text,
                maxLines: null,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(600), // Limits input to 600 characters or 100 words
                ],
              ),
            ),
            const SizedBox(height: 50,),
            Padding(padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
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
 

  
