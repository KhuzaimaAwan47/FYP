import 'package:flutter/material.dart';
import 'package:my_fyp/login_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // this removes debug tag from app bar
      title: "FlutterApp",
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: Myhomepage(),
    );
  }
}

class Myhomepage extends StatefulWidget {
  @override
  State<Myhomepage> createState() => _MyHomepageState();
}

class _MyHomepageState extends State<Myhomepage> {
  final TextEditingController emailText = TextEditingController();
  final TextEditingController passText = TextEditingController();

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
                style: TextStyle(fontSize: 45, fontWeight: FontWeight.w400, color: Colors.black45),
                textAlign: TextAlign.center,
              ),
              Text(
                'Create your account',
                style: TextStyle(color: Colors.black54, fontSize: 16, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: screenHeight * 0.05), // Add vertical space based on screen height
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'Username',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.blue, width: 1.5),
                  ),
                  prefixIcon: Icon(Icons.account_circle_outlined),
                ),
                keyboardType: TextInputType.name,
              ),
              SizedBox(height: screenHeight * 0.02), // Add vertical space based on screen height
              TextFormField(
                controller: emailText,
                decoration: InputDecoration(
                  hintText: 'Enter your email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.blue, width: 1.5),
                  ),
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: screenHeight * 0.02), // Add vertical space based on screen height
              TextFormField(
                controller: passText,
                obscureText: true,
                obscuringCharacter: '*',
                decoration: InputDecoration(
                  hintText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.indigo, width: 1.5),
                  ),
                  prefixIcon: Icon(Icons.password),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.remove_red_eye_outlined),
                    onPressed: () {},
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02), // Add vertical space based on screen height
              TextFormField(
                controller: passText,
                obscureText: true,
                obscuringCharacter: '*',
                decoration: InputDecoration(
                  hintText: 'Confirm Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.indigo, width: 1.5),
                  ),
                  prefixIcon: Icon(Icons.password),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.remove_red_eye_outlined),
                    onPressed: () {},
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.05), // Add vertical space based on screen height
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.2, vertical: 15),
                ),
                onPressed: () {},
                child: Text(
                  'Register',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
              SizedBox(height: screenHeight * 0.02), // Add vertical space based on screen height
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
                      //Navigator.push(context, MaterialPageRoute(builder: (context) => ));
                      },
                    child: Text('Sign in'),
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
