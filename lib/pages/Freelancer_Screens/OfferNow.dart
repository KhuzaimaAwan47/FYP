import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../utlis/snack_bars.dart';

class OfferNow extends StatefulWidget {
  final String freelancerUsername;

  const OfferNow({super.key, required this.freelancerUsername});

  @override
  State<OfferNow> createState() => _OfferNowState();
}

class _OfferNowState extends State<OfferNow> {
  // Initialize Firebase services
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // User state
  String? userName = '';

  // Controllers
  final TextEditingController projectNameController = TextEditingController();
  final TextEditingController budgetController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController projectDescriptionController =
      TextEditingController();

// Function to load current user's username from Firestore
  Future<void> loadCurrentUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: user.email)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          DocumentSnapshot userDoc = querySnapshot.docs.first;
          setState(() {
            userName = userDoc['username'];
          });
        } else {
          return;
        }
      } catch (e) {
        return;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    loadCurrentUser();
  }

  /* --------------------------- Data Saving Method --------------------------- */

// publish offer
  Future<void> publishOffer() async {
    try {
      String projectName = projectNameController.text;
      String description = projectDescriptionController.text;
      String time = timeController.text;
      double? budget = double.tryParse(budgetController.text);

      // Validate input fields
      if (projectName.isEmpty ||
          description.isEmpty ||
          budget == null ||
          time.isEmpty) {
        showWarningSnackbar(context, 'Please fill all fields');
        return;
      }

      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No user is logged in!')),
        );
        return;
      }

      // Check if an offer with the same project name and user ID already exists
      QuerySnapshot querySnapshot = await _firestore
          .collection('offers')
          .where('project_name', isEqualTo: projectName)
          .where('offered_by', isEqualTo: user.uid)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Offer already exists for this project and user
        showErrorSnackbar(
            context, 'You have already sent an offer for this project!');
        return;
      }

      // Add the new offer to Firestore
      await _firestore.collection('offers').add({
        'project_name': projectName,
        'description': description,
        'budget': budget,
        'estimated_time': time,
        'offer_created_at': FieldValue.serverTimestamp(),
        'offered_by': user.uid,
        'owner_name': userName,
        'project_status': 'Not Started',
        'assigned_to': widget.freelancerUsername,
      });

      // Show success message
      showSuccessSnackbar(context, 'Offer sent successfully!');
    } catch (e) {
      // Handle any errors
      showErrorSnackbar(context, 'Error sending offer: $e');
    }
  }

  /* --------------------------- Main Build Widget --------------------------- */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Offer Now'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Icon(Icons.card_giftcard, color: Colors.indigoAccent, size: 150),
              TextFormField(
                style: TextStyle(fontWeight: FontWeight.w500),
                controller: projectNameController,
                decoration: InputDecoration(
                  hintText: 'Project Name',
                  hintStyle: TextStyle(
                      color: Colors.grey, fontWeight: FontWeight.normal),
                  prefixIcon: Icon(Icons.work_outline, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              SizedBox(height: 15),
              TextFormField(
                style: TextStyle(fontWeight: FontWeight.w500),
                controller: budgetController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Budget',
                  hintStyle: TextStyle(
                      color: Colors.grey, fontWeight: FontWeight.normal),
                  prefixIcon:
                      Icon(Icons.account_balance_outlined, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              SizedBox(height: 15),
              TextFormField(
                style: TextStyle(fontWeight: FontWeight.w500),
                controller: timeController,
                decoration: InputDecoration(
                  hintText: 'Estimated time',
                  hintStyle: TextStyle(
                      color: Colors.grey, fontWeight: FontWeight.normal),
                  prefixIcon:
                      Icon(Icons.access_time_outlined, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              SizedBox(height: 15),
              TextFormField(
                controller: projectDescriptionController,
                maxLines: 5,
                decoration: InputDecoration(
                  label: Text('Description'),
                  labelStyle: TextStyle(color: Colors.grey),
                  hintText: 'Description',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(padding: EdgeInsets.all(16),
      child: ElevatedButton.icon(
        onPressed: () {
          publishOffer();
          FocusScope.of(context).unfocus();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.indigoAccent,
          elevation: 2.0,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        label: Text(
          'Offer Now',
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
          icon: Icon(Icons.local_offer, color: Colors.white)
      )
      ),
    );
  }
}
