import 'package:flutter/material.dart';
import 'package:my_fyp/p_updated.dart';


class verify extends StatefulWidget{
  @override
  State<verify> createState() => _verifyState();
}

class _verifyState extends State<verify> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmpasswordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(.0), //this padding is used to  add formkey.
            child: Form(
              key: _formKey,
              child: Column(
          
                //----------------------------Text Section----------------------------
          
                children: [
                  SizedBox(height: screenHeight*0.09,),
                  const Text('NEW CREDENTIALS',style: TextStyle(fontSize: 50,fontWeight: FontWeight.w400,color: Colors.black54),textAlign: TextAlign.center),
                  const Text('Your Email has been verified set your new password',style: TextStyle(fontSize: 20,fontWeight: FontWeight.w500,color: Colors.black54),textAlign: TextAlign.center,),
                  SizedBox(height: screenHeight*0.01,),
          
                  //----------------------------Password Section----------------------------
          
                  TextFormField(
                    controller: passwordController,
                    obscureText: !isPasswordVisible,
                    obscuringCharacter: '*',
                    decoration: InputDecoration(
                      hintText: 'New Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: Colors.indigo,
                          width: 1.5,
                        ),
                      ),
                      prefixIcon: const Icon(Icons.password),
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
          
                  //----------------------------Confirm Password Section----------------------------
          
                  TextFormField(
                    controller: confirmpasswordController,
                    obscureText: !isCPasswordVisible,
                    obscuringCharacter: '*',
                    decoration: InputDecoration(
                      hintText: 'Confirm Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Colors.indigo, width: 1.5),
                      ),
                      prefixIcon: const Icon(Icons.password),
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
          
                  //----------------------------Button Section----------------------------
          
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.30, // 30% of the screen width
                          vertical: 10),
                    ),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => passwordUpdated()));
                    },
                    child: const Text( 'UPDATE', style: TextStyle(fontSize: 17, color: Colors.white),
                    ),
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