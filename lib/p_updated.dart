import 'package:flutter/material.dart';
import 'package:my_fyp/login_page.dart';

class passwordUpdated extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
  return Scaffold(
    appBar: AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.indigo.shade50,
    ),
    body: Container(
      width: screenWidth,
      height: screenHeight,
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
      color: Colors.indigo.shade50,
      child: Column(
        children: [
          SizedBox(height: screenHeight*0.09,),
          Text('PASSWORD UPDATED',style: TextStyle(fontSize: 50,fontWeight: FontWeight.w400,color: Colors.black87),textAlign: TextAlign.center),
          SizedBox(height: screenHeight*0.01,),
          Icon(Icons.check_circle,color: Colors.black87,size: 200,),
          SizedBox(height: screenHeight*0.01,),
          Text('Your password has been updated',style: TextStyle(fontSize: 20,fontWeight: FontWeight.w500,color: Colors.black54),textAlign: TextAlign.center,),
          SizedBox(height: screenHeight*0.01,),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black87,
              padding: EdgeInsets.symmetric(horizontal: 135, vertical: 15),
            ),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
            },
            child: Text(
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