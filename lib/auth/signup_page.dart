import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/services.dart';
import 'package:my_fyp/auth/validators.dart';

import 'login_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmpasswordControllerText =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isClientChecked = false;
  bool isfreelancerChecked = false;
  bool isPasswordVisible = false;
  bool isCPasswordVisible = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // Hide status bar and other system overlays for an immersive experience.
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmpasswordControllerText.dispose();
    super.dispose();
  }

  bool passwordConfirmed() {
    return passwordController.text.trim() ==
        confirmpasswordControllerText.text.trim();
  }

  Future<void> signUpUser() async {
    FocusScope.of(context).unfocus(); //keyboard closes when button is pressed.
    try {
      if (passwordConfirmed()) {
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );
        String uid = userCredential.user!.uid;
        // Add user details to Firestore
        addUserDetails(
          uid,
          usernameController.text.trim(),
          emailController.text.trim(),
          isClientChecked ? 'client' : 'freelancer',
          passwordController.text.trim(),
        );
        // Navigate to the Login Page
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      } else {
        _showErrorDialog('Passwords do not match.');
      }
    } on FirebaseAuthException catch (e) {
      // Handle FirebaseAuth errors and show an error dialog
      String errorMessage = _handleFirebaseAuthError(e);
      _showErrorDialog(errorMessage);
    } catch (e) {
      // Handle other errors and show an error dialog
      _showErrorDialog('An unexpected error occurred. Please try again.');
    } finally {}
  }

  String _handleFirebaseAuthError(FirebaseAuthException e) {
    if (e.code == 'email-already-in-use') {
      return 'This email is already in use. Please use a different email.';
    } else if (e.code == 'weak-password') {
      return 'The password provided is too weak. Please use a stronger password.';
    } else if (e.code == 'invalid-email') {
      return 'The email address is not valid. Please enter a correct email.';
    } else {
      return 'An unexpected error occurred. Please try again.';
    }
  } // SignUpUser

  Future addUserDetails(
    String uid,
    String username,
    String email,
    String userType,
    String password,
  ) async {
    await FirebaseFirestore.instance.collection('users').add({
      'uid': uid,
      'username': username,
      'userType': userType,
      'email': email,
      'passowrd': password,
      'first_name': 'first_name',
      'last_name': 'last_name',
      'location': 'None',
      'hourly_rate': 0,
      'description': 'No description',
      'headline': 'No headline',
      'skills': 'None',
      'rating': 0,
      'averageRating': 'averageRating',
      'totalReviews': 'totalReviews',
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get screen height
    var screenHeight = MediaQuery.of(context).size.height;

    // PopScope block user to leave screen such as swapback or going back.
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: null,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: screenHeight * 0.05),
                  Image.asset(
                    'assets/images/Signup.png',
                    width: double.infinity,
                    height: screenHeight * 0.3,
                    fit: BoxFit.cover,
                  ),
                  const Text(
                    'Join Unity Gig Today ',
                    style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                  const Text(
                    'Your journey to productivity starts here',
                    style: TextStyle(
                        color: Colors.black54,
                        fontSize: 18,
                        fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  // Add vertical space based on screen height

                  //----------Username----------

                  TextFormField(
                    style: const TextStyle(
                        fontWeight: FontWeight.w500, fontSize: 16),
                    controller: usernameController,
                    decoration: InputDecoration(
                      hintText: 'Username',
                      fillColor: Colors.indigo.shade50,
                      filled: true,
                      hintStyle: const TextStyle(
                        color: Colors.black54,
                      ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none),
                      prefixIcon: const Icon(
                        Icons.account_circle_outlined,
                        color: Colors.black54,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                    keyboardType: TextInputType.name,
                    validator: Validators.validateUsername,
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  // Add vertical space based on screen height

                  //----------Email----------

                  TextFormField(
                    style: const TextStyle(
                        fontWeight: FontWeight.w500, fontSize: 16),
                    controller: emailController,
                    decoration: InputDecoration(
                      hintText: 'Email',
                      filled: true,
                      fillColor: Colors.indigo.shade50,
                      hintStyle: const TextStyle(
                        color: Colors.black54,
                      ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none),
                      prefixIcon: const Icon(
                        Icons.email_outlined,
                        color: Colors.black54,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.validateEmail,
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  // Add vertical space based on screen height

                  //----------Password----------

                  TextFormField(
                    style: const TextStyle(
                        fontWeight: FontWeight.w500, fontSize: 16),
                    controller: passwordController,
                    obscureText: !isPasswordVisible,
                    validator: Validators.validatePassword,
                    obscuringCharacter: '*',
                    decoration: InputDecoration(
                      hintText: 'Password',
                      hintStyle: const TextStyle(
                        color: Colors.black54,
                      ),
                      filled: true,
                      fillColor: Colors.indigo.shade50,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none),
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: Colors.black54,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 18),
                      suffixIcon: IconButton(
                        icon: Icon(
                          isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.black54,
                        ),
                        onPressed: () {
                          setState(() {
                            isPasswordVisible = !isPasswordVisible;
                          });
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  // Add vertical space based on screen height

                  //----------Confirm Password----------

                  TextFormField(
                    style: const TextStyle(
                        fontWeight: FontWeight.w500, fontSize: 16),
                    controller: confirmpasswordControllerText,
                    obscureText: !isCPasswordVisible,
                    validator: (value) => Validators.validateConfirmPassword(
                        value, passwordController.text),
                    obscuringCharacter: '*',
                    decoration: InputDecoration(
                      hintText: 'Confirm Password',
                      hintStyle: const TextStyle(
                        color: Colors.black54,
                      ),
                      filled: true,
                      fillColor: Colors.indigo.shade50,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none),
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: Colors.black54,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 18),
                      suffixIcon: IconButton(
                        icon: Icon(
                          isCPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.black54,
                        ),
                        onPressed: () {
                          setState(() {
                            isCPasswordVisible = !isCPasswordVisible;
                          });
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  // Add vertical space based on screen height

                  //----------Check Box----------

                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      // Scale down the content to fit the available space
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Mention yourself as:'),
                          Checkbox(
                            value: isClientChecked,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5)),
                            onChanged: (bool? newValue) {
                              setState(() {
                                isClientChecked = newValue!;
                                isfreelancerChecked = !newValue;
                              });
                            },
                            activeColor: Colors.indigo,
                          ),
                          const Text('Client'),
                          Checkbox(
                            value: isfreelancerChecked,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5)),
                            onChanged: (bool? newValue) {
                              setState(() {
                                isfreelancerChecked = newValue!;
                                isClientChecked =
                                    !newValue; // uncheck the other
                              });
                            },
                            activeColor: Colors.indigo,
                          ),
                          const Text('Freelancer'),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  const SizedBox(
                    height: 1,
                  ),

                  //----------Button----------

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      minimumSize: Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Processing Data...')),
                        );
                        signUpUser();
                      }
                    },
                    child: const AutoSizeText('Register',
                        style: TextStyle(fontSize: 20, color: Colors.white)),
                  ),

                  //----------Text Button----------

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Already, have an account?',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                        textAlign: TextAlign.center,
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoginPage()));
                        },
                        child: const Text(
                          'Login',
                          style: TextStyle(
                              color: Colors.indigo,
                              fontSize: 16,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
