import 'package:flutter/material.dart';
import 'package:my_fyp/otp.dart';

class forgot extends StatelessWidget{
  final TextEditingController emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  forgot({super.key});

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

                //----------------------------Icon Section----------------------------

            child: Column(
              children: [
                SizedBox(height: screenHeight*0.09,),
                const Icon(Icons.lock,color: Colors.black45,size: 200,),
                SizedBox(height: screenHeight*0.01,),

                //----------------------------Text Section----------------------------

                const Text('Forgot Password',style: TextStyle(fontSize: 45,fontWeight: FontWeight.w400,color: Colors.black45),),
                const Text('Provide your account Email for which you want to reset your password',
                  style: TextStyle(fontSize: 16,fontWeight: FontWeight.w500,color: Colors.black45),textAlign: TextAlign.center,),
                SizedBox(height: screenHeight*0.01,),
                Form(
                  key: _formKey,
                  child: TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                      hintText: 'Enter your email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: Colors.indigo,
                          width: 1.5,
                        ),
                      ),
                      prefixIcon: const Icon(Icons.email_outlined),

                    ),
                    keyboardType: TextInputType.emailAddress,
                      validator: (value)
                      {
                        final RegExp emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                        if (!emailRegex.hasMatch(value!)) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      }
                  ),
                ),
                SizedBox(height: screenHeight*0.01,),

                //----------------------------Button Section----------------------------

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.35, // 35% of the screen width
                      vertical: 10,),
                  ),
                  onPressed: () {
                    Navigator.push( context, MaterialPageRoute( builder: (context) => OtpPage(),));
                  },
                  child: const Text(
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