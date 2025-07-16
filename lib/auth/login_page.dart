import 'package:flutter/material.dart';
import 'package:my_fyp/auth/signup_page.dart';
import 'package:my_fyp/auth/validators.dart';
import '../widgets/bottom_navigation/c_navigator.dart';
import '../widgets/bottom_navigation/f_navigator.dart';
import 'auth.dart';
import 'forgot.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isPasswordVisible = false;
  bool? isSignIn = false;


  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  /* --------------------------- Authentication Method --------------------------- */

  void _signIn() async {
    // Close keyboard
    FocusScope.of(context).unfocus();

    final String email = emailController.text.trim();
    final String password = passwordController.text.trim();

    try {
      final Auth authController = Auth();
      final String role = await authController.signInUser(email, password);

      // Navigate based on role
      if (role == 'freelancer') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const F_navigator()),
        );
      } else if (role == 'client') {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const C_navigator()),
        );
      } else {
        _showErrorDialog('Unknown user role.');
      }
    } catch (e) {
      _showErrorDialog(e.toString());
    }
  }

  /* --------------------------- Error Dialog Method --------------------------- */

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Error !'),
        backgroundColor: Colors.indigo.shade50,
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK',
              style: TextStyle(color: Colors.indigo),
            ),
          ),
        ],
      ),
    );
  }

/* --------------------------- Main Build Widget --------------------------- */

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;

    // PopScope block user to leave screen such as swipe back or going back.

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: null,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                SizedBox(
                  height: screenHeight * 0.15,
                ),
                Image.asset(
                  'assets/images/Signin.png',
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                const Text(
                  'Welcome back!',
                  style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
                const Text(
                  'Login to your account',
                  style: TextStyle(
                      color: Colors.black54,
                      fontSize: 18,
                      fontWeight: FontWeight.w500),
                ),
                SizedBox(
                  height: screenHeight * 0.03,
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      SizedBox(
                        height: screenHeight * 0.02,
                      ),

                      /* --------------------------- Email --------------------------- */

                      TextFormField(
                        controller: emailController,
                        style: const TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 16),
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
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 18),
                        ),
                        validator: Validators.validateEmail,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      SizedBox(
                        height: screenWidth * 0.02,
                      ),

                      /* --------------------------- Password --------------------------- */

                      TextFormField(
                        style: const TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 16),
                        controller: passwordController,
                        obscureText: !isPasswordVisible,
                        obscuringCharacter: '*',
                        decoration: InputDecoration(
                          hintText: 'Password',
                          filled: true,
                          fillColor: Colors.indigo.shade50,
                          hintStyle: const TextStyle(
                            color: Colors.black54,
                          ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none),
                          prefixIcon: const Icon(
                            Icons.lock_outline,
                            color: Colors.black54,
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 18),
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
                        keyboardType: TextInputType.text,
                      ),
                      SizedBox(height: 24),

                      /* --------------------------- Elevated Button --------------------------- */

                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 2.0,
                          backgroundColor: Colors.indigo,
                          minimumSize: Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _signIn();
                          }
                        },
                        child: const Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      /* --------------------------- Text Button --------------------------- */

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Don't have an account?",
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                          TextButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const SignupPage(),
                                    ));
                              },
                              child: const Text(
                                'Signup',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.indigo,
                                ),
                              )),
                        ],
                      ),

                      /* --------------------------- Text Button --------------------------- */

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => forgot(),
                                    ));
                              },
                              child: const Text(
                                'Forgot Password?',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.indigo),
                              ))
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
