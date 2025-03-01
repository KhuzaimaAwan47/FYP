import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_fyp/Freelancer_Screens/Bid.dart';



class ProjectDetails extends StatefulWidget {
  final String projectId;
  final String projectName;
  final String postedById; // This is the user ID of the project owner
  const ProjectDetails({
    super.key,
    required this.projectId,
    required this.projectName,
    required this.postedById,
  });

  @override
  _ProjectDetailsState createState() => _ProjectDetailsState();
}

class _ProjectDetailsState extends State<ProjectDetails> {
  String projectName = '';
  String description = '';
  String ownerName = '';
  double budget = 0.0;
  int totalProjectsByUser = 0;
  int totalProposals = 0;
  String? currentUserId;
  bool isOwner = false; // Flag to check if the current user is the owner of the project
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController budgetController = TextEditingController();
  final TextEditingController ownerController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    loadUserData();
    loadProjectDetails();
    loadProposals();
  }

  // Fetch the current user data
  Future<void> loadUserData() async {
    User? user = _auth.currentUser;

    if (user != null) {
      setState(() {
        currentUserId = user.uid; // Get the current user's UID
      });

      // Compare if the current user is the project owner
      if (currentUserId == widget.postedById) {
        setState(() {
          isOwner = true; // Set the flag if the current user is the owner
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No user logged in!')),
      );
    }
  }

  // Fetch project details from Firestore
  Future<void> loadProjectDetails() async {
    try {
      DocumentSnapshot projectDoc = await _firestore
          .collection('projects')
          .doc(widget.projectId)
          .get();

      if (projectDoc.exists) {
        setState(() {
          projectName = projectDoc['project_name'];
          description = projectDoc['description'];
          ownerName =projectDoc['owner_name'];
          budget = projectDoc['budget'];
        });


        // Fetch the total number of projects posted by the user
        QuerySnapshot userProjects = await _firestore
            .collection('projects')
            .where('posted_by', isEqualTo: widget.postedById)
            .get();


        setState(() {
          totalProjectsByUser = userProjects.docs.length;
        });
      }
    } catch (e) {
      print('Error loading project details: $e');
    }
  }
  //loadProposals
  Future<void> loadProposals() async {
    try {
      // Find the specific document using the `project_name`
      QuerySnapshot bidSnapshot = await _firestore
          .collection('bids')
          .where('project_name', isEqualTo: widget.projectName) // Match based on project name
          .get();

      if (bidSnapshot.docs.isNotEmpty) {
        // Get the first matching document (if multiple, update logic as needed)
        DocumentSnapshot bidDoc = bidSnapshot.docs.first;

        setState(() {
          ownerName = bidDoc['owner_name'];
          projectName = bidDoc['project_name'];
        });

        // Count total proposals for this project
        QuerySnapshot userBids = await _firestore
            .collection('bids')
            .where('project_name', isEqualTo: widget.projectName)
            .get();

        setState(() {
          totalProposals = userBids.docs.length;
        });

        print('bids loaded: $totalProposals, for $ownerName');
      } else {
        print('No bids found for the project.');
      }
    } catch (e) {
      print('Error loading proposals: $e');
    }
  }

  //delete project
  Future<void>_deleteProject() async {
    //Show a confirmation dialog
    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this project?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0),),
        elevation: 5.0,
        actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Return false if canceled
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Return true if confirmed
              },
              child: const Text('Delete',style: TextStyle(color: Colors.red),),
            ),
          ],
        );
      },
    );

    // Proceed with deletion if confirmed
    if (confirmDelete== true) {
      try {
        await _firestore.collection('projects').doc(widget.projectId).delete();
        Navigator.pop(context); // Go back to the previous screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Project deleted successfully!')),
        );
      } catch (e) {
        print('Error deleting project: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting project: $e')),
        );
      }
    }
  }

  //---------------------------------------------Edit project-------------------------------------------

  Future<void> _editProject() async {
    // Show a dialog or navigate to a new screen for editing
    // Here, we'll use a dialog for simplicity
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Project'),
          content: SingleChildScrollView( // Wrap with SingleChildScrollView
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController..text = projectName, // Pre-fill with existing data
                  decoration: const InputDecoration(labelText: 'Project Name'),
                ),
                TextFormField(
                  controller: budgetController..text = budget.toString(),
                  decoration: const InputDecoration(labelText: 'Budget'),
                  keyboardType: TextInputType.number,
                ),
                TextFormField(
                  controller: descriptionController..text = description,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: null, // Allow multiple lines
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
              child: const Text('Cancel',style: TextStyle(color: Colors.red),),
            ),
            TextButton(
              onPressed: () async {
                // Update Firestore document
                try {
                  await _firestore.collection('projects').doc(widget.projectId).update({
                    'project_name': nameController.text,
                    'owner_name': ownerController.text,
                    'description': descriptionController.text,
                    'budget': double.tryParse(budgetController.text) ?? 0.0, // Handle parsing
                  });

                  //  Update the UI with the new values
                  setState(() {
                    projectName = nameController.text;
                    ownerName = ownerController.text;
                    description = descriptionController.text;
                    budget = double.tryParse(budgetController.text) ?? 0.0;
                  });

                  Navigator.of(context).pop(); // Close the dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating, // Make it float
                        margin: EdgeInsets.only(bottom: 80.0, left: 16.0, right: 16.0),
                        duration: Duration(seconds: 3),
                        content: Text('Project updated successfully!')),
                  );
                } catch (e) {
                  print('Error updating project: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating, // Make it float
                        margin: const EdgeInsets.only(bottom: 80.0, left: 16.0, right: 16.0),
                        duration: const Duration(seconds: 3),
                        content: Text('Error updating project: $e')),
                  );
                }
              },
              child: const Text('Save',style: TextStyle(color: Colors.green),),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Project Details'),
        centerTitle: true,
        actions: [
          IconButton(onPressed: (){}, icon: Icon(Icons.info)
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                projectName,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  // const Icon(Icons.attach_money,color: Colors.purple,),
                  // const SizedBox(width: 0,),
                  Text(
                    'Budget: \$${budget.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 24,fontWeight: FontWeight.w500,color: Colors.indigoAccent),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                description,
                textAlign: TextAlign.justify,
                style: TextStyle(fontSize: 16,height: 1.5,color: Colors.grey[800]),
              ),
              const SizedBox(height: 16),
              Divider(color: Colors.grey[300],thickness: 1,),
              Text(
                'Posted By: $ownerName'
                    '', // Display owner name here
                style: TextStyle(fontSize: 14,color: Colors.grey[600]),
              ),
              const SizedBox(height: 5),
              Text(
                'Total Projects Posted: $totalProjectsByUser',
                style: TextStyle(fontSize: 14,color: Colors.grey[600]),
              ),
              const SizedBox(height: 5),
              Text(
                'Total Proposals(Bids) Received: $totalProposals',
                style: TextStyle(fontSize: 14,color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),
              // Conditionally show Edit/Delete for owner, Bid for others
              isOwner
                  ? Row(mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 2.0,
                      backgroundColor: Colors.indigo,
                  padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.17,
                    vertical: 10,
                  )
                    ),
                    onPressed: () {
                      _editProject();
                    },
                    child: const Text('Edit',style: TextStyle(color: Colors.white),),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _deleteProject,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                        elevation: 2.0,
                        padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * 0.15,
                          vertical: 10,
                        )
                    ),
                    child: const Text('Delete',style: TextStyle(color: Colors.white),),
                  ),
                ],
              )
                  : Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 3.0,
                        backgroundColor: Colors.indigoAccent,
                        minimumSize: Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BidForm(
                              projectName:projectName,
                              ownerName: ownerName,
                              projectId: widget.projectId,
                            ),
                          ),
                        );
                      },
                      child: const Text('Bid Now',style: TextStyle(fontSize: 18,color: Colors.white),),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}



