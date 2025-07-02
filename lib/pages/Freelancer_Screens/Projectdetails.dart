import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../utlis/snack_bars.dart';
import 'Bid.dart';

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
  // Project data
  String projectName = '';
  String description = '';
  String ownerName = '';
  double budget = 0.0;
  int totalProjectsByUser = 0;
  int totalProposals = 0;

  // User state
  String? currentUserId;
  String? userType;
  bool isOwner = false;
  bool _isLoading = true;

  // Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController budgetController = TextEditingController();
  final TextEditingController ownerController = TextEditingController();

  // Initialize Firebase services
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /* --------------------------- Data Loading Methods --------------------------- */

  // load data
  Future<void> _loadData() async {
    try {
      await Future.wait([
        loadUserData(),
        loadProjectDetails(),
        loadProposals(),
      ]);
    } catch (e) {
      return;
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Fetch the current user data
  // Future<void> loadUserData() async {
  //   User? user = _auth.currentUser;
  //
  //   if (user != null) {
  //     setState(() {
  //       currentUserId = user.uid; // Get the current user's UID
  //     });
  //
  //     // Compare if the current user is the project owner
  //     if (currentUserId == widget.postedById) {
  //       setState(() {
  //         isOwner = true; // Set the flag if the current user is the owner
  //       });
  //     }
  //   } else {
  //     return;
  //   }
  // }

  Future<void> loadUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      setState(() {
        currentUserId = user.uid;
      });

      // Compare if the current user is the project owner
      if (currentUserId == widget.postedById) {
        setState(() {
          isOwner = true;
        });
      }

      // Fetch userType
      try {
        QuerySnapshot querySnapshot = await _firestore
            .collection('users')
            .where('email', isEqualTo: user.email)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          DocumentSnapshot userDoc = querySnapshot.docs.first;
          setState(() {
            userType = userDoc['userType'];
          });
        }
      } catch (e) {
        // Handle error if needed
      }
    }
  }



  // Fetch project details from Firestore
  Future<void> loadProjectDetails() async {
    try {
      DocumentSnapshot projectDoc =
          await _firestore.collection('projects').doc(widget.projectId).get();

      if (projectDoc.exists) {
        setState(() {
          projectName = projectDoc['project_name'];
          description = projectDoc['description'];
          ownerName = projectDoc['owner_name'];
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
      return;
    }
  }

  //loadProposals
  Future<void> loadProposals() async {
    try {
      // Find the specific document using the `project_name`
      QuerySnapshot bidSnapshot = await _firestore
          .collection('bids')
          .where('project_name',
              isEqualTo: widget.projectName) // Match based on project name
          .get();

      if (bidSnapshot.docs.isNotEmpty) {
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
      }
    } catch (e) {
      return;
    }
  }

  /* --------------------------- Crud Methods --------------------------- */

  //delete project
  Future<void> _deleteProject() async {
    //Show a confirmation dialog
    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this project?'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
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
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    // Proceed with deletion if confirmed
    if (confirmDelete == true) {
      try {
        await _firestore.collection('projects').doc(widget.projectId).delete();
        Navigator.pop(context); // Go back to the previous screen
        showSuccessSnackbar(context, 'Project deleted successfully!');
      } catch (e) {
        return;
      }
    }
  }


// Edit project
  Future<void> _editProject() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Project'),
          content: SingleChildScrollView(
            // Wrap with SingleChildScrollView
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController..text = projectName,
                  // Pre-fill with existing data
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
                  maxLines: 7, // Allow multiple lines
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.red),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2.0,
                backgroundColor: Colors.indigo,
              ),
              onPressed: () async {
                // Update Firestore document
                try {
                  await _firestore
                      .collection('projects')
                      .doc(widget.projectId)
                      .update({
                    'project_name': nameController.text,
                    'description': descriptionController.text,
                    'budget': double.tryParse(budgetController.text) ?? 0.0,
                    // Handle parsing
                  });

                  //  Update the UI with the new values
                  setState(() {
                    projectName = nameController.text;
                    description = descriptionController.text;
                    budget = double.tryParse(budgetController.text) ?? 0.0;
                  });

                  Navigator.of(context).pop(); // Close the dialog
                  showSuccessSnackbar(context, 'Project updated successfully!');
                } catch (e) {
                  showErrorSnackbar(context, 'Error updating project: $e');
                }
              },
              child: const Text(
                'Save',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  /* --------------------------- Main Build Widget --------------------------- */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Project Details'),
      ),
      body: _isLoading
        ? Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                projectName,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    'Budget: \$${budget.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        color: Colors.indigoAccent),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                description,
                textAlign: TextAlign.justify,
                style: TextStyle(
                    fontSize: 16, height: 1.5, color: Colors.grey[800]),
              ),
              Divider(
                color: Colors.grey[300],
                thickness: 1,
              ),
              SizedBox(height: 16),
              Card(
                elevation: 0,
                color: Colors.grey[50],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade200, width: 1),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.assignment,color: Colors.indigo,),
                          SizedBox(width: 4),
                          Text(
                            'Posted By: $ownerName',
                            style: TextStyle(fontSize: 14, color: Colors.blueGrey[900]),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Icon(Icons.library_books,color: Colors.indigo,),
                          SizedBox(width: 4),
                          Text(
                            'Total Projects Posted: $totalProjectsByUser',
                            style: TextStyle(fontSize: 14, color: Colors.blueGrey[900]),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Icon(Icons.gavel,color: Colors.indigo,),
                          SizedBox(width: 4),
                          Text(
                            'Total Proposals(Bids) Received: $totalProposals',
                            style: TextStyle(fontSize: 14, color: Colors.blueGrey[900]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      // Show Edit/Delete button for owner, Bid for others
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: isOwner
            ? Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigoAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  minimumSize: const Size(double.infinity, 56),
                ),
                onPressed: _editProject,
                icon: const Icon(Icons.edit, color: Colors.white),
                label: const Text(
                  'Edit',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  minimumSize: const Size(double.infinity, 56),
                ),
                onPressed: _deleteProject,
                icon: const Icon(Icons.delete, color: Colors.white),
                label: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          ],
        )
            : (userType == 'freelancer'
            ? ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigoAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BidForm(
                  projectName: projectName,
                  ownerName: ownerName,
                  projectId: widget.projectId,
                ),
              ),
            );
          },
          icon: const Icon(Icons.gavel, color: Colors.white),
          label: const Text(
            'Bid Now',
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        )
            : const SizedBox.shrink()), // Hide Bid Now for clients who are not owners
      ),
    );
  }
}
