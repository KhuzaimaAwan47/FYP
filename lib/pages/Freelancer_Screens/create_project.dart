import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PostProject extends StatefulWidget {
  const PostProject({super.key});

  @override
  State<StatefulWidget> createState() => _PostProjectState();
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
  void initState() {
    super.initState();
    loadCurrentUser();
    publishProject();
  }

//Function to load current user
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
          });
          //print('user: $userName');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('user name not found!')),
          );
        }
      } catch (e) {
        // Handle any errors that occur during the process
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: $e'),
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
      double? budget =
          double.tryParse(budgetController.text); // Parse budget as double

      // Check for empty fields
      if (projectName.isEmpty || description.isEmpty || budget == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
              // Make it float
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
        'project_created_at': FieldValue.serverTimestamp(),
        // Timestamp for project creation
        'posted_by': user.uid,
        'project_status': 'Not Started',
      });
      print('owner name: $userName');
      // Show success message and clear the form
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            // Make it float
            margin: EdgeInsets.only(bottom: 80.0, left: 16.0, right: 16.0),
            duration: Duration(seconds: 3),
            content: Text('Project published successfully!')),
      );
      Navigator.pop(context);
    } catch (e) {
      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Colors.red, content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(buildContext) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Publish a Project'),
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.close)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(
              Icons.assignment_outlined,
              color: Colors.indigoAccent,
              size: 150,
            ),
            TextFormField(
              style: const TextStyle(fontWeight: FontWeight.w500),
              autofocus: false,
              autocorrect: true,
              controller: nameController,
              decoration: InputDecoration(
                hintText: 'Project Name',
                hintStyle: const TextStyle(color: Colors.grey),
                focusColor: Colors.white,
                prefixIcon: const Icon(
                  Icons.work_outline,
                  color: Colors.grey,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              textCapitalization: TextCapitalization.words,
              keyboardType: TextInputType.text,
            ),
            SizedBox(
              height: 16,
            ),
            TextFormField(
              style: const TextStyle(fontWeight: FontWeight.w500),
              controller: budgetController,
              decoration: InputDecoration(
                hintText: '\$ Budget',
                hintStyle: const TextStyle(
                  color: Colors.grey,
                ),
                prefixIcon: const Icon(
                  Icons.account_balance_outlined,
                  color: Colors.grey,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(
              height: 16,
            ),
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
                LengthLimitingTextInputFormatter(600),
                // Limits input to 600 characters or 100 words
              ],
            ),
            const SizedBox(
              height: 30,
            ),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigoAccent,
                  elevation: 2.0,
                  minimumSize: Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {
                  publishProject();
                },
                child: const Text(
                  'Publish',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ))
          ],
        ),
      ),
    );
  }
}