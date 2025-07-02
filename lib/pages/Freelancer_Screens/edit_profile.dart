import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_fyp/utlis/snack_bars.dart';
import '../../auth/validators.dart';

class FullScreenForm extends StatefulWidget {
  const FullScreenForm({super.key});

  @override
  State<FullScreenForm> createState() => _FullScreenFormState();
}

class _FullScreenFormState extends State<FullScreenForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  // Controllers
  final TextEditingController firstnameController = TextEditingController();
  final TextEditingController lastnameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController rateController = TextEditingController();
  final TextEditingController skillsController = TextEditingController();
  final TextEditingController headlineController = TextEditingController();

  // Initialize Firebase Services
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _userType;

  @override
  void dispose() {
    firstnameController.dispose();
    lastnameController.dispose();
    descriptionController.dispose();
    locationController.dispose();
    rateController.dispose();
    headlineController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

/* --------------------------- Saving data Method --------------------------- */

  // Future<void> saveData() async {
  //   FocusScope.of(context).unfocus(); //keyboard closes when button is pressed.
  //   // Validate the form before proceeding
  //   if (!_formKey.currentState!.validate()) {
  //     // If the form is not valid, show an error message and return
  //     showErrorSnackbar(context, 'Please fill out all required fields.');
  //     return; // Don't proceed with saving if the form is invalid
  //   }
  //
  //   User? user = _auth.currentUser;
  //
  //   if (user != null) {
  //     try {
  //       // Query to find the document where email or username matches
  //       QuerySnapshot querySnapshot = await _firestore
  //           .collection('users')
  //           .where('email',
  //               isEqualTo:
  //                   user.email)
  //           .get();
  //
  //       if (querySnapshot.docs.isNotEmpty) {
  //         DocumentReference userDoc = querySnapshot.docs.first.reference;
  //
  //         await userDoc.update({
  //           'first_name': firstnameController.text,
  //           'last_name': lastnameController.text,
  //           'location': locationController.text,
  //           'hourly_rate': double.parse(rateController.text),
  //           'description': descriptionController.text,
  //           'skills': skillsController.text,
  //           'headline': headlineController.text,
  //         });
  //         showSuccessSnackbar(context, 'Profile Info added Successfully!');
  //         Navigator.pop(context);
  //       } else {
  //         return;
  //       }
  //     } catch (e) {
  //       return;
  //     }
  //   } else {
  //     return;
  //   }
  // }
  Future<void> saveData() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      showErrorSnackbar(context, 'Please fill out all required fields.');
      return;
    }

    User? user = _auth.currentUser;
    if (user != null) {
      try {
        QuerySnapshot querySnapshot = await _firestore
            .collection('users')
            .where('email', isEqualTo: user.email)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          DocumentReference userDoc = querySnapshot.docs.first.reference;

          Map<String, dynamic> updateData = {
            'first_name': firstnameController.text,
            'last_name': lastnameController.text,
          };

          if (_userType != 'client') {
            updateData.addAll({
              'location': locationController.text,
              'hourly_rate': double.parse(rateController.text),
              'description': descriptionController.text,
              'skills': skillsController.text,
              'headline': headlineController.text,
            });
          }

          await userDoc.update(updateData);
          showSuccessSnackbar(context, 'Profile Info added Successfully!');
          Navigator.pop(context);
        }
      } catch (e) {
        // Handle error
      }
    }
  }

  /* --------------------------- Data Loading Method --------------------------- */

  // Future<void> loadUserData() async {
  //   User? user = _auth.currentUser;
  //
  //   if (user != null) {
  //     try {
  //       // Query to find the document where email matches
  //       QuerySnapshot querySnapshot = await _firestore
  //           .collection('users')
  //           .where('email', isEqualTo: user.email)
  //           .get();
  //
  //       if (querySnapshot.docs.isNotEmpty) {
  //         DocumentSnapshot userDoc = querySnapshot.docs.first;
  //
  //         setState(() {
  //           // Populate the controllers if data exists in Firestore
  //           _userType = userDoc['userType'];
  //           firstnameController.text = userDoc['first_name'] ?? '';
  //           lastnameController.text = userDoc['last_name'] ?? '';
  //           locationController.text = userDoc['location'] ?? '';
  //           rateController.text = userDoc['hourly_rate']?.toString() ?? '';
  //           skillsController.text = userDoc['skills'] ?? '';
  //           descriptionController.text = userDoc['description'] ?? '';
  //           headlineController.text = userDoc['headline'] ?? '';
  //         });
  //       } else {
  //         // If no data is found, leave fields empty (user will input them)
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(content: Text('Please complete you profile!')),
  //         );
  //       }
  //     } catch (e) {
  //       print('Error: $e');
  //     }
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('No user logged in!')),
  //     );
  //   }
  // }
  Future<void> loadUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        QuerySnapshot querySnapshot = await _firestore
            .collection('users')
            .where('email', isEqualTo: user.email)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          DocumentSnapshot userDoc = querySnapshot.docs.first;
          String? userType = userDoc['userType'] ?? '';

          setState(() {
            // Always load common fields
            firstnameController.text = userDoc['first_name'] ?? '';
            lastnameController.text = userDoc['last_name'] ?? '';

            // Only load non-client fields if the user is not a client
            if (userType != 'client') {
              locationController.text = userDoc['location'] ?? '';
              rateController.text = userDoc['hourly_rate']?.toString() ?? '';
              descriptionController.text = userDoc['description'] ?? '';
              skillsController.text = userDoc['skills'] ?? '';
              headlineController.text = userDoc['headline'] ?? '';
            } else {
              // Reset non-client fields for clients
              locationController.text = '';
              rateController.text = '';
              descriptionController.text = '';
              skillsController.text = '';
              headlineController.text = '';
            }

            _userType = userType;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please complete your profile!')),
          );
        }
      } catch (e) {
        print('Error: $e');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No user logged in!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Add Profile Info'),
      ),
      body: _userType == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // First Name
              Padding(
                padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
                child: TextFormField(
                  controller: firstnameController,
                  decoration: InputDecoration(
                    hintText: 'First Name',
                    hintStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: const Icon(Icons.account_circle_outlined, color: Colors.grey),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  autocorrect: true,
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.words,
                  maxLines: 1,
                  validator: Validators.validateFirstName,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(20),
                    FilteringTextInputFormatter.allow(RegExp("[a-zA-Z ]")),
                  ],
                ),
              ),
              // Last Name
              Padding(
                padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
                child: TextFormField(
                  controller: lastnameController,
                  decoration: InputDecoration(
                    hintText: 'Last Name',
                    hintStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: const Icon(Icons.account_circle_outlined, color: Colors.grey),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.words,
                  maxLines: 1,
                  validator: Validators.validateLastName,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(20),
                    FilteringTextInputFormatter.allow(RegExp("[a-zA-Z ]")),
                  ],
                ),
              ),
              // Conditional Fields (Non-Clients Only)
              if (_userType != 'client') ...[
                // Location
                Padding(
                  padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
                  child: TextFormField(
                    controller: locationController,
                    decoration: InputDecoration(
                      hintText: 'Your Location',
                      hintStyle: const TextStyle(color: Colors.grey),
                      prefixIcon: const Icon(Icons.location_on_outlined, color: Colors.grey),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.words,
                    maxLines: 1,
                    validator: Validators.validateLocation,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(20),
                    ],
                  ),
                ),
                // Hourly Rate
                Padding(
                  padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
                  child: TextFormField(
                    controller: rateController,
                    decoration: InputDecoration(
                      hintText: '\$ Hourly rate',
                      hintStyle: const TextStyle(color: Colors.grey),
                      prefixIcon: const Icon(Icons.attach_money_outlined, color: Colors.grey),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    keyboardType: TextInputType.number,
                    maxLines: 1,
                    validator: Validators.validateHourlyRate,
                  ),
                ),
                // Skills
                Padding(
                  padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
                  child: TextFormField(
                    controller: skillsController,
                    decoration: InputDecoration(
                      hintText: 'Your Skills',
                      hintStyle: const TextStyle(color: Colors.grey),
                      prefixIcon: const Icon(Icons.lightbulb_outline, color: Colors.grey),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.words,
                    validator: Validators.validateSkills,
                  ),
                ),
                // Headline
                Padding(
                  padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
                  child: TextFormField(
                    controller: headlineController,
                    decoration: InputDecoration(
                      hintText: 'Headline',
                      hintStyle: const TextStyle(color: Colors.grey),
                      prefixIcon: const Icon(Icons.view_headline_outlined, color: Colors.grey),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.words,
                    validator: Validators.validateHeadline,
                    maxLines: 1,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(100),
                    ],
                  ),
                ),
                // Description
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
                  child: SizedBox(
                    height: 200,
                    child: TextFormField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        label: const Text('Description (max 100 words)'),
                        hintText: 'Description (max 100 words)',
                        hintStyle: const TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      keyboardType: TextInputType.text,
                      textCapitalization: TextCapitalization.sentences,
                      validator: Validators.validateDescription,
                      maxLines: 10,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(600),
                        FilteringTextInputFormatter.allow(RegExp("[a-zA-Z ]")),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            elevation: 3.0,
            backgroundColor: Colors.indigoAccent,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          onPressed: saveData,
          icon: const Icon(Icons.save, color: Colors.white),
          label: const Text(
            'Save',
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
