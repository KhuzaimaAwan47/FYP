import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_fyp/forgot.dart';
import 'package:my_fyp/signup_page.dart';
import 'package:my_fyp/f_navigator.dart';



class LoginPage extends StatefulWidget {
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

  //--------------------------------------Functions for handling authentication-------------------------------------------

  Future<void> signInUser() async {
    try {
      // Attempt to sign in the user
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Navigate to the HomePage after successful sign-in
      Navigator.push( context, MaterialPageRoute(builder: (context) => const F_navigator()),
    );
    } on FirebaseAuthException catch (e) {
      // Handle FirebaseAuth-specific errors and show an error dialog
      String errorMessage = _handleFirebaseAuthError(e);
      _showErrorDialog(errorMessage);
    } catch (e) {
      // Handle other exceptions (e.g., network errors) and show an error dialog
      _showErrorDialog('An unexpected error occurred. Please try again.');
     print("Error occurred: $e"); // Log the actual error for debugging purposes
    }
  }

// Error handling function (same as in the signUpUser function)
  String _handleFirebaseAuthError(FirebaseAuthException e) {
    if (e.code == 'user-not-found') {
      return 'Email not found. Please check your email and try again.';
    } else if (e.code == 'invalid-credential') {
      return 'Incorrect password. Please try again.';
    }else if (e.code == 'too-many-requests'){
      return 'We have blocked all requests from this device due to unusual activity. Try again later.  Access to this account has been temporarily disabled due to many failed login attempts. You can immediately restore it by resetting your password or you can try again later.';
    } else if (e.code == 'invalid-email') {
      return 'The email address is not valid. Please enter a correct email.';
    }else if (e.code == 'channel-error'){
      return 'Please provide a valid email or password.';
    } else {
      print('Unhandled FirebaseAuthException code: ${e.code}');
      return 'Connection Timed Out.... Please try again later.';
    }
  }

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
            child: const Text('OK' ,style: TextStyle(color: Colors.indigo),),
          ),
        ],
      ),
    );
}

//Note the "const" keyword is used to improve performance. Not to be confused to seen "const" keyword along widgets.
  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;

    // PopScope block user to leave screen such as swapback or going back.

    return PopScope(
      canPop: false,
      onPopInvoked : (didPop){
        // logic
      },
      child: Scaffold(
        appBar: null,
        body: SingleChildScrollView(
          child: Container(
            height: screenHeight,
            width: screenWidth,
            color: Colors.indigo.shade50,
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
            child: Column(
              children: [
                const SizedBox(height: 240,),
                const  Text(
                  'Welcome back',
                  style: TextStyle(
                      fontSize: 45,
                      fontWeight: FontWeight.w400,
                      color: Colors.black45),
                  textAlign: TextAlign.center,
                ),
                const Text(
                  'Login to your acccount',
                  style: TextStyle(
                      color: Colors.black54,
                      fontSize: 18,
                      fontWeight: FontWeight.w500),
                ),
                Padding(
                  padding: const EdgeInsets.all(0),//this padding is used to  add formkey.
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        SizedBox( height: screenHeight*0.02,),

                        //---------------------------------------------Email-----------------------------------------------------

                        TextFormField(
                          controller: emailController,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                          decoration: InputDecoration(
                            hintText: 'Email',
                            hintStyle: const TextStyle(color: Colors.grey,),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                color: Colors.indigo,
                                width: 1.5,
                              ),
                            ),
                            prefixIcon: const Icon(Icons.email_outlined,color: Colors.black54,),
                          ),
                            validator: (value)
                        {
                            final RegExp emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                            if (!emailRegex.hasMatch(value!)) {
                              return 'Please enter a valid email address';
                            }
                            return null;
                            },
                          keyboardType: TextInputType.emailAddress,
                        ),
                        SizedBox(height: screenWidth*0.01,),

                        //------------------------------------------------Password-----------------------------------------------

                        TextFormField(
                          style: const TextStyle(fontWeight: FontWeight.w500),
                          controller: passwordController,
                          obscureText: !isPasswordVisible,
                          obscuringCharacter: '*',
                          decoration: InputDecoration(
                            hintText: 'Password',
                            hintStyle: const TextStyle(color: Colors.grey,),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                color: Colors.indigo,
                                width: 1.5,
                              ),
                            ),
                            prefixIcon: const Icon(Icons.password,color: Colors.black54,),
                            suffixIcon: IconButton(
                              icon: Icon(isPasswordVisible ? Icons.visibility:Icons.visibility_off,color: Colors.black54,),
                              onPressed: ()
                              {
                                setState((){
                                  isPasswordVisible  =  !isPasswordVisible;
                                });

                              },),
                          ),
                          keyboardType: TextInputType.text,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter a password';
                            }
                            return null;
                          },
                        ),
                       const SizedBox(height: 10,),

                        //---------------------------------------------Button---------------------------------------------------

                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            elevation: 3.0,
                            backgroundColor: Colors.indigo,
                            padding:  EdgeInsets.symmetric(
                              horizontal: MediaQuery.of(context).size.width * 0.35, // 35% of the screen width
                              vertical: 10,
                            ),
                          ),
                          onPressed: (){
                            if (_formKey.currentState!.validate()){
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Checking credetials...')),);
                            }
                            signInUser();
                          },
                          child: const Text(
                            'Login',
                            style: TextStyle(fontSize: 15, color: Colors.white,),
                          ),
                        ),

                        //-------------------------------------------Text Button------------------------------------------------

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "    Don't have an account?",
                              style: TextStyle(
                                  fontWeight: FontWeight.w400, color: Colors.black),
                              textAlign: TextAlign.center,
                            ),
                            TextButton(
                                onPressed: () {
                                  Navigator.push( context, MaterialPageRoute( builder: (context) => const SignupPage(),));
                                },
                                child: const Text('Signup',style: TextStyle(color: Colors.indigo,),)),
                          ],
                        ),

                        //-------------------------------------------Text Button------------------------------------------------

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton(onPressed: (){
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => forgot(),
                                  ));
                            },
                                child: const Text('Forgot Password?',style: TextStyle(color: Colors.indigo),))],
                        )

                      ],
                    ),
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




