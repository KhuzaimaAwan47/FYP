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
      backgroundColor: Colors.indigo.shade50,
      appBar: AppBar(
      automaticallyImplyLeading: true,
      backgroundColor: Colors.indigo.shade50,
        iconTheme: IconThemeData(color: Colors.black54),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
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
                      style: const TextStyle(fontWeight: FontWeight.w500),
                      controller: emailController,
                      decoration: InputDecoration(
                      hintText: 'Email',
                      hintStyle: const TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: Colors.indigo,
                          width: 1.5,
                        ),
                      ),
                      prefixIcon: const Icon(Icons.email_outlined,color: Colors.grey,),
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
                    minimumSize: Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
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