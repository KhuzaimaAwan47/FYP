import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../widgets/freelancer_list.dart';
import '../../widgets/group_list.dart';
import '../../widgets/project_list.dart';
import '../../widgets/section_header.dart';
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

      if (groupName.isEmpty || groupDescription.isEmpty || groupRules.isEmpty ) {
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
        'group_admin': [userEmail],
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
