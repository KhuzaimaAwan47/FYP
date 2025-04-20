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

  Future<void> saveData() async {
    FocusScope.of(context).unfocus(); //keyboard closes when button is pressed.
    // Validate the form before proceeding
    if (!_formKey.currentState!.validate()) {
      // If the form is not valid, show an error message and return
      showErrorSnackbar(context, 'Please fill out all required fields.');
      return; // Don't proceed with saving if the form is invalid
    }

    User? user = _auth.currentUser;

    if (user != null) {
      try {
        // Query to find the document where email or username matches
        QuerySnapshot querySnapshot = await _firestore
            .collection('users')
            .where('email',
                isEqualTo:
                    user.email)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          DocumentReference userDoc = querySnapshot.docs.first.reference;

          await userDoc.update({
            'first_name': firstnameController.text,
            'last_name': lastnameController.text,
            'location': locationController.text,
            'hourly_rate': double.parse(rateController.text),
            'description': descriptionController.text,
            'skills': skillsController.text,
            'headline': headlineController.text,
          });
          showSuccessSnackbar(context, 'Profile Info added Successfully!');
          Navigator.pop(context);
        } else {
          print('No matching document found');
        }
      } catch (e) {
        print('Error: $e');
      }
    } else {
      print('No user logged in');
    }
  }

  /* --------------------------- Data Loading Method --------------------------- */

  Future<void> loadUserData() async {
    User? user = _auth.currentUser;

    if (user != null) {
      try {
        // Query to find the document where email matches
        QuerySnapshot querySnapshot = await _firestore
            .collection('users')
            .where('email', isEqualTo: user.email)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          DocumentSnapshot userDoc = querySnapshot.docs.first;

          setState(() {
            // Populate the controllers if data exists in Firestore
            firstnameController.text = userDoc['first_name'] ?? '';
            lastnameController.text = userDoc['last_name'] ?? '';
            locationController.text = userDoc['location'] ?? '';
            rateController.text = userDoc['hourly_rate']?.toString() ?? '';
            skillsController.text = userDoc['skills'] ?? '';
            descriptionController.text = userDoc['description'] ?? '';
            headlineController.text = userDoc['headline'] ?? '';
          });
        } else {
          // If no data is found, leave fields empty (user will input them)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please complete you profile!')),
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
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.pop(
                context); // Closes the form and returns to the previous screen
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
                child: TextFormField(
                  controller: firstnameController,
                  decoration: InputDecoration(
                    hintText: 'First Name',
                    hintStyle: const TextStyle(
                      color: Colors.grey,
                    ),
                    prefixIcon: const Icon(
                      Icons.account_circle_outlined,
                      color: Colors.grey,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  autocorrect: true,
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.words,
                  maxLines: 1,
                  validator: Validators.validateFirstName,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(20),
                    // Limits input to 20 characters
                    FilteringTextInputFormatter.allow(RegExp("[a-zA-Z ]")),
                    // Only allows letters and spaces
                    //FirstLetterCapitalFormatter(),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
                child: TextFormField(
                  controller: lastnameController,
                  decoration: InputDecoration(
                    hintText: 'Last Name',
                    hintStyle: const TextStyle(
                      color: Colors.grey,
                    ),
                    prefixIcon: const Icon(
                      Icons.account_circle_outlined,
                      color: Colors.grey,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.words,
                  maxLines: 1,
                  validator: Validators.validateLastName,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(20),
                    // Limits input to 20 characters
                    FilteringTextInputFormatter.allow(RegExp("[a-zA-Z ]")),
                    // Only allows letters and spaces
                  ], // Allows for multi-line input
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
                child: TextFormField(
                  controller: locationController,
                  decoration: InputDecoration(
                    hintText: 'Your Location',
                    hintStyle: const TextStyle(
                      color: Colors.grey,
                    ),
                    prefixIcon: const Icon(
                      Icons.location_on_outlined,
                      color: Colors.grey,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.words,
                  maxLines: 1,
                  validator: Validators.validateLocation,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(20),
                    // Limits input to 20 characters
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
                child: TextFormField(
                  controller: rateController,
                  decoration: InputDecoration(
                    hintText: '\$ Hourly rate',
                    hintStyle: const TextStyle(
                      color: Colors.grey,
                    ),
                    prefixIcon: const Icon(
                      Icons.attach_money_outlined,
                      color: Colors.grey,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  maxLines: 1,
                  validator: Validators.validateHourlyRate,
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
                child: TextFormField(
                  controller: skillsController,
                  decoration: InputDecoration(
                      hintText: 'Your Skills',
                      hintStyle: const TextStyle(
                        color: Colors.grey,
                      ),
                      prefixIcon: const Icon(
                        Icons.lightbulb_outline,
                        color: Colors.grey,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      )),
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.words,
                  validator: Validators.validateSkills,
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
                child: TextFormField(
                  controller: headlineController,
                  decoration: InputDecoration(
                    hintText: 'Headline',
                    hintStyle: const TextStyle(
                      color: Colors.grey,
                    ),
                    prefixIcon: const Icon(
                      Icons.view_headline_outlined,
                      color: Colors.grey,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.words,
                  validator: Validators.validateHeadline,
                  maxLines: 1,
                  // Allows for multi-line input
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(100),
                    // Limits input to 100 characters or 20 words
                    //FilteringTextInputFormatter.allow(RegExp("[a-zA-Z ]")),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
                child: SizedBox(
                  height: 200,
                  child: TextFormField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      label: Text('Description (max 100 words)'),
                      hintText: 'Description (max 100 words)',
                      hintStyle: const TextStyle(
                        color: Colors.grey,
                      ),
                      //prefixIcon: const Icon(Icons.description_outlined,color: Colors.grey,),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.sentences,
                    validator: Validators.validateDescription,
                    maxLines: 10,
                    // Allows for multi-line input
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(600),
                      // Limits input to 600 characters or 100 words
                      FilteringTextInputFormatter.allow(RegExp("[a-zA-Z ]")),
                    ],
                  ),
                ),
              ),
              Center(
                child: Padding(
                    padding:
                        const EdgeInsets.only(left: 16.0, right: 16.0, top: 32),
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
                          saveData();
                        },
                        child: const Text(
                          'Save',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
