import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:my_fyp/auth/verify.dart';

class OtpPage extends StatefulWidget {
  @override
  _OtpPageState createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final otpControllers = List.generate(6, (index) => TextEditingController());
  final otpFocusNodes = List.generate(6, (index) => FocusNode());

  void onOtpChanged(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      FocusScope.of(context).requestFocus(otpFocusNodes[index + 1]);
    } else if (value.isEmpty && index > 0) {
      FocusScope.of(context).requestFocus(otpFocusNodes[index - 1]);
    }
  }

  String get _otp {
    return otpControllers.map((controller) => controller.text).join();
  }

  @override
  void dispose() {
    for (var controller in otpControllers) {
      controller.dispose();
    }
    for (var focusNode in otpFocusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

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
          child: Column(
            children: [
              SizedBox(height: screenHeight * 0.15),
              const Text('CODE',
                style: TextStyle( fontSize: 100, fontWeight: FontWeight.w400, color: Colors.black54,),
                textAlign: TextAlign.center,
              ),
              const Text( 'VERIFICATION',
                style: TextStyle( fontSize: 30, fontWeight: FontWeight.w500, color: Colors.black54,),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: screenHeight * 0.01),

              //----------------------------OTP Section----------------------------

              SizedBox(
                height: 50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, (index) {
                    return SizedBox(
                      width: 50,
                      child: TextFormField(
                        style: const TextStyle(fontWeight: FontWeight.w600),
                        controller: otpControllers[index],
                        focusNode: otpFocusNodes[index],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        decoration: InputDecoration(
                          counterText: "",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Colors.indigo,
                              width: 1.5,
                            ),
                          ),
                        ),
                        onChanged: (value) => onOtpChanged(index, value),
                      ),
                    );
                  }),
                ),
              ),
              SizedBox(height: screenHeight * 0.05),

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
                  print("Entered OTP: $_otp");
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => verify(),
                    ),
                  );
                },
                child: const AutoSizeText('Verify Code', style: TextStyle(fontSize: 20, color: Colors.white)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
