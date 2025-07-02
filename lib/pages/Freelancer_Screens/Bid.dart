import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_fyp/utlis/snack_bars.dart';

class BidForm extends StatefulWidget {
  final String projectName;
  final String projectId;
  final String ownerName;

  const BidForm(
      {super.key,
      required this.projectName,
      required this.ownerName,
      required this.projectId});

  @override
  State<BidForm> createState() => _BidFormState();
}

class _BidFormState extends State<BidForm> {
  // Controllers
  final TextEditingController amountController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController messageController = TextEditingController();

  // user state
  String? userName = '';

  // Firebase services
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // form validation
  final _formKey = GlobalKey<FormState>();

/* --------------------------- Data Loading Methods --------------------------- */

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
        } else {
          showErrorSnackbar(context, 'Username not found');
        }
      } catch (e) {
        showErrorSnackbar(context, 'Error loading username: $e');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    loadCurrentUser();
  }

  /* --------------------------- Submitting bid Method --------------------------- */

  Future<void> _submitBid() async {
    FocusScope.of(context).unfocus(); //keyboard closes when button is pressed.
    if (_formKey.currentState!.validate()) {
      try {
        final querySnapshot = await _firestore
            .collection('notifications')
            .where('project_name', isEqualTo: widget.projectName)
            .where('bidder_name', isEqualTo: userName)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          // Bid already exists
          showWarningSnackbar(
              context, "You have already submitted a bid for this project");
          return;
        }
        await _firestore.collection('notifications').add({
          'project_id': widget.projectId,
          'project_name': widget.projectName,
          'owner_name': widget.ownerName,
          'bidder_name': userName,
          'notification_message':
              'A new bid has been submitted for your project "${widget.projectName}" by $userName.',
          'bid_amount': amountController.text,
          'estimated_time': timeController.text,
          'created_at': FieldValue.serverTimestamp(),
          'message': messageController.text,
          // Status to track whether the notification is read
          'status': "Pending",
          // Status to set by project owner if bid is accepted or rejected
        });
        showSuccessSnackbar(context, 'Bid submitted successfully!');
        Navigator.pop(context);
      } catch (e) {
        showErrorSnackbar(context, 'Error submitting bid: $e');
      }
    }
  }

  /* --------------------------- Main Build Widget --------------------------- */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Bid Now'),
        ),
        body: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.gavel,
                  size: 150,
                  color: Colors.indigoAccent,
                  shadows: [
                    BoxShadow(
                      color: Colors.grey,
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    )
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: amountController,
                  decoration: InputDecoration(
                    hintText: 'Bid Amount (\$)',
                    prefixIcon: Icon(
                      Icons.account_balance_outlined,
                      color: Colors.grey,
                    ),
                    hintStyle: TextStyle(
                        color: Colors.grey, fontWeight: FontWeight.normal),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14.0),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '*This field is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: timeController,
                  decoration: InputDecoration(
                    hintText: 'Estimated Time',
                    prefixIcon: Icon(
                      Icons.timelapse_outlined,
                      color: Colors.grey,
                    ),
                    hintStyle: TextStyle(
                        color: Colors.grey, fontWeight: FontWeight.normal),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14.0),
                    ),
                  ),
                  keyboardType: TextInputType.text,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '*This field is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: messageController,
                  decoration: InputDecoration(
                      label: Text(
                        'Message(Optional)',
                        style: TextStyle(color: Colors.grey),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14.0),
                      )),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
        // Elevated Button
        bottomNavigationBar: Padding(
          padding: EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigoAccent,
              elevation: 2.0,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: _submitBid,
            icon: const Icon(
              Icons.send,
              color: Colors.white,
            ),
            label: const Text(
              'Submit ',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
        ));
  }
}
