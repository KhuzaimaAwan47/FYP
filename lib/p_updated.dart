import 'package:flutter/material.dart';
import 'package:my_fyp/login_page.dart';

class passwordUpdated extends StatelessWidget{
  const passwordUpdated({super.key});

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
  return Scaffold(
    appBar: null,
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          SizedBox(height: 200,),
          const Icon(Icons.check_circle,color: Colors.green,size: 200,),
          SizedBox(height: screenHeight*0.01,),
          const Text('PASSWORD UPDATED',style: TextStyle(fontSize: 40,fontWeight: FontWeight.w500,color: Colors.green),textAlign: TextAlign.center),
          SizedBox(height: screenHeight*0.01,),
          const Text('Your password has been updated',style: TextStyle(fontSize: 20,fontWeight: FontWeight.w500,color: Colors.black54),textAlign: TextAlign.center,),
          SizedBox(height: screenHeight*0.01,),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              minimumSize: Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
            },
            child: const Text(
              'Login',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        ],
      ),
    ),
  );
  }

}