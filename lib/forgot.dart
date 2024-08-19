import 'package:flutter/material.dart';
import 'package:my_fyp/otp.dart';

class forgot extends StatelessWidget{
  final TextEditingController emailText = TextEditingController();
  final TextEditingController passText = TextEditingController();
  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
      automaticallyImplyLeading: true,
      backgroundColor: Colors.indigo.shade50,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            width: screenWidth,
            height: screenHeight,
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
            color: Colors.indigo.shade50,
            child: Column(
              children: [
                SizedBox(height: screenHeight*0.09,),
                Icon(Icons.lock,color: Colors.black45,size: 200,),
                SizedBox(height: screenHeight*0.01,),
                Text('Forgot Password',style: TextStyle(fontSize: 45,fontWeight: FontWeight.w400,color: Colors.black45),),
                Text('Provide your account Email for which you want to reset your password',style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500,color: Colors.black45),textAlign: TextAlign.center,),
                SizedBox(height: screenHeight*0.01,),
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
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(
                  height: screenHeight*0.01,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    padding: EdgeInsets.symmetric(horizontal: 145, vertical: 10,),
                  ),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OtpPage(),
                        ));
                  },
                  child: Text(
                    'NEXT',
                    style: TextStyle(fontSize:18, color: Colors.white),
                  ),
                )
              ]
        
        
        
        
        
            ),
          ),
        ),
      ),
    );
  }
}