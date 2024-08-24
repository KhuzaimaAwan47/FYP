import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_fyp/login_page.dart';


class SignupPage extends StatefulWidget {

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmpasswordControllerText = TextEditingController();
  // final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool? isSignIn = false;
  bool isClientChecked = false;
  bool isfreelancerChecked = false;
  bool isPasswordVisible = false;
  bool isCPasswordVisible = false;

  @override
  void dispose(){
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmpasswordControllerText.dispose();
    super.dispose();
  }

  Future signUpUser() async {
    setState(() {
      isSignIn = true;
    });
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      ).then((value) {
        setState(() {
          isSignIn = false;
        });
      });
      Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
    } catch (e) {
      print("error occured $e");
    }
  }







  @override
  Widget build(BuildContext context) {
    // Get screen height and width
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: null,
      body: SingleChildScrollView(
        child: Container(
          height: screenHeight,
          width: screenWidth,
          color: Colors.indigo.shade50,
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1), // Add horizontal padding based on screen width
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Register',
                style: TextStyle(fontSize: 60, fontWeight: FontWeight.w400, color: Colors.black45),
                textAlign: TextAlign.center,
              ),
              Text(
                'Create your account',
                style: TextStyle(color: Colors.black54, fontSize: 20, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: screenHeight * 0.05), // Add vertical space based on screen height
              TextFormField(
                controller: usernameController,
                decoration: InputDecoration(
                  hintText: 'Username',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.blue, width: 1.5),
                  ),
                  prefixIcon: Icon(Icons.account_circle_outlined),
                ),
                keyboardType: TextInputType.name,
                validator: (value){
                  if(value!.isEmpty){
                    return 'Enter your username';
                  }
                  else if(value!.length<6){
                    return'Username must be atleast 6 chracter long';
                  }
                },
              ),
              SizedBox(height: screenHeight * 0.01), // Add vertical space based on screen height
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  hintText: 'Enter your email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.blue, width: 1.5),
                  ),
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value){
                  final RegExp emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                  if (!emailRegex.hasMatch(value!)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              SizedBox(height: screenHeight * 0.01), // Add vertical space based on screen height
              TextFormField(
                controller: passwordController,
                obscureText: !isPasswordVisible,
                obscuringCharacter: '*',
                decoration: InputDecoration(
                  hintText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.indigo, width: 1.5),
                  ),
                  prefixIcon: Icon(Icons.password),
                  suffixIcon: IconButton(
                    icon: Icon(isPasswordVisible ? Icons.visibility:Icons.visibility_off,),
                    onPressed: ()
                    {
                      setState((){
                        isPasswordVisible  =  !isPasswordVisible;
                      });

                    },),
                ),
              ),
              SizedBox(height: screenHeight * 0.01), // Add vertical space based on screen height
              TextFormField(
                controller: confirmpasswordControllerText,
                obscureText: !isCPasswordVisible,
                obscuringCharacter: '*',
                decoration: InputDecoration(
                  hintText: 'Confirm Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.indigo, width: 1.5),
                  ),
                  prefixIcon: Icon(Icons.password),
                  suffixIcon: IconButton(
                    icon: Icon(isCPasswordVisible ? Icons.visibility:Icons.visibility_off,),
                    onPressed: ()
                    {
                      setState((){
                        isCPasswordVisible  =  !isCPasswordVisible;
                      });

                    },),
                ),
              ),
              SizedBox(height: screenHeight * 0.01), // Add vertical space based on screen height

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Mention yourself as:'),
                  Checkbox(
                    value: isClientChecked,
                    onChanged: (bool? newValue) {
                      setState(() {
                        isClientChecked = newValue!;
                        isfreelancerChecked = !newValue;
                      });
                    },
                    activeColor: Colors.indigo,
                  ),
                  Text('Client'),
                  Checkbox(value: isfreelancerChecked, onChanged: (bool? newValue){
                    setState(() {
                      isfreelancerChecked = newValue!;
                      isClientChecked = !newValue; // uncheck the other
                    });
                  },
                    activeColor: Colors.indigo,
                  ),
                  Text('Freelancer'),
                ],
              ),
              SizedBox(height: screenHeight * 0.01),

              SizedBox(
                height: 1,
              ),
              // isSignIn == true
              //     ? Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     Text("Please wait..."),
              //     SizedBox(
              //       width: 10,
              //     ),
              //     CircularProgressIndicator()
              //   ],
              // )
              //     : Container(),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  padding: EdgeInsets.symmetric(horizontal: 135, vertical: 15),
                ),
                onPressed:() {
                  signUpUser();
                },
                child: Text(
                  'Register',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already, have an account?',
                    style: TextStyle(fontWeight: FontWeight.w400, color: Colors.black),
                    textAlign: TextAlign.center,
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
                    },
                    child: Text('Sign in',style: TextStyle(color: Colors.indigo),),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}