import 'package:flutter/material.dart';
import 'package:my_fyp/forgot.dart';
import 'package:my_fyp/signup_page.dart';
import 'package:my_fyp/home_page.dart';


class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailText = TextEditingController();
  final TextEditingController passText = TextEditingController();
  bool isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: null,
      body: SingleChildScrollView(
        child: Container(
          height: screenHeight,
          width: screenWidth,
          color: Colors.indigo.shade50,
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
          child: Column(
            children: [
              SizedBox(height: 240,),
              Text(
                'Welcome back',
                style: TextStyle(
                    fontSize: 45,
                    fontWeight: FontWeight.w400,
                    color: Colors.black45),
                textAlign: TextAlign.center,
              ),
              Text(
                'Login to your acccount',
                style: TextStyle(
                    color: Colors.black54,
                    fontSize: 18,
                    fontWeight: FontWeight.w500),
              ),
              Column(
                children: [
                  SizedBox(
                    height: screenHeight*0.02,
                  ),
                  TextFormField(
                    controller: emailText,
                    decoration: InputDecoration(
                      hintText: 'Enter your email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: Colors.indigo,
                          width: 1.5,
                        ),
                      ),
                      prefixIcon: Icon(Icons.email_outlined),
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
                  TextFormField(
                    controller: passText,
                    obscureText: !isPasswordVisible,
                    obscuringCharacter: '*',
                    decoration: InputDecoration(
                      hintText: 'Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: Colors.indigo,
                          width: 1.5,
                        ),
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
                    keyboardType: TextInputType.text,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter a password';
                      } else if (value.length < 6) {
                        return 'Password must be at least 6 characters long';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10,),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      padding: EdgeInsets.symmetric(
                        horizontal: 150,
                        vertical: 15,
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HomePage(),
                          ));
                    },
                    child: Text(
                      'Login',
                      style: TextStyle(fontSize: 15, color: Colors.white),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '    Dont have an account?',
                        style: TextStyle(
                            fontWeight: FontWeight.w400, color: Colors.black),
                        textAlign: TextAlign.center,
                      ),
                      TextButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SignupPage(),
                                ));
                          },
                          child: Text('Signup',style: TextStyle(color: Colors.indigo),)),
                    ],
                  ),
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
                          child: Text('Forgot Password?',style: TextStyle(color: Colors.indigo),))],)

                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}




