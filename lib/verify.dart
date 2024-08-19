import 'package:flutter/material.dart';
import 'package:my_fyp/p_updated.dart';


class verify extends StatefulWidget{
  @override
  State<verify> createState() => _verifyState();
}

class _verifyState extends State<verify> {
  final TextEditingController passText = TextEditingController();
  final TextEditingController confirmpassText = TextEditingController();
  bool isPasswordVisible = false;
  bool isCPasswordVisible = false;
  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
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
            Text('NEW CREDENTIALS',style: TextStyle(fontSize: 50,fontWeight: FontWeight.w400,color: Colors.black54),textAlign: TextAlign.center),
            Text('Your Email has been verified set your new password',style: TextStyle(fontSize: 20,fontWeight: FontWeight.w500,color: Colors.black54),textAlign: TextAlign.center,),
            SizedBox(height: screenHeight*0.01,),
            TextFormField(
              controller: passText,
              obscureText: !isPasswordVisible,
              obscuringCharacter: '*',
              decoration: InputDecoration(
                hintText: 'New Password',
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
            SizedBox(height: screenHeight*0.01,),
            TextFormField(
              controller: confirmpassText,
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
            SizedBox(height: screenHeight * 0.01),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                padding: EdgeInsets.symmetric(horizontal: 135, vertical: 15),
              ),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => passwordUpdated()));
              },
              child: Text(
                'UPDATE',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}