// import 'package:flutter/material.dart';
// import 'package:my_fyp/signup_page.dart';
// import 'package:my_fyp/f_navigator.dart';
//
// void main(){
//
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget{
//   @override
//   Widget build(BuildContext context){
//     return MaterialApp(
//       debugShowCheckedModeBanner: false, // this removes debug tag from app bar
//       title: "FlutterApp",
//       theme: ThemeData(
//           primarySwatch: Colors.deepPurple,
//       ),
//       home: Myhomepage() ,
//     );
//   }
// }
//
// class Myhomepage extends StatefulWidget{
//   @override
//   State<Myhomepage> createState() => _MyHomepageState();
// }
//
// class _MyHomepageState extends State<Myhomepage> {
//
//   final TextEditingController emailText = TextEditingController();
//   final TextEditingController passText = TextEditingController();
//
//   @override
//   Widget build(BuildContext context){
//     return Scaffold(
//       appBar: null,
//       body: Container(
//         height: double.infinity,
//         width: double.infinity,
//         color:Colors.indigo.shade50,
//         child: Column(
//           children: [
//             SizedBox(height: 200,),
//             Text('Welcome back',style: TextStyle(fontSize: 45,fontWeight: FontWeight.w400,color: Colors.black45),textAlign: TextAlign.center,),
//             Text('Login to your acccount',style: TextStyle(color: Colors.black54,fontSize: 16,fontWeight: FontWeight.w500),),
//
//             Container(
//               width: 350,
//               height: 305,
//               margin: EdgeInsets.only(left: 10,right: 10,top: 30),
//               //color: Colors.white60,
//               child: Column(
//                 children: [
//                   SizedBox(height: 20,),
//                   TextFormField(
//                     controller: emailText,
//                     decoration: InputDecoration(
//                       hintText: 'Enter your email',
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(14),
//                         borderSide: BorderSide(color: Colors.blue,width: 1.5,),
//
//                       ),
//                       prefixIcon: Icon(Icons.email_outlined),
//                     ),
//                     keyboardType: TextInputType.emailAddress,
//                   ),
//                   SizedBox(height: 10.0,),
//                   TextFormField(
//                     controller: passText,
//                     obscureText: true,
//                     obscuringCharacter: '*',
//                     decoration: InputDecoration(
//                       hintText: 'Password',
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(14),
//                         borderSide: BorderSide(color: Colors.indigo,width: 1.5,),
//                       ),
//                       prefixIcon: Icon(Icons.password),
//                       suffixIcon: IconButton(icon: Icon(Icons.remove_red_eye_outlined),
//                       onPressed: (){}
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 60,),
//                   ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.indigo,
//                         padding:EdgeInsets.symmetric(horizontal: 150,vertical: 15,),),
//
//                     onPressed: (){Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage(),));},
//                       child: Text('Login',style: TextStyle(fontSize: 20,color: Colors.white),),
//                   ),
//                   //SizedBox(height: 5,),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text('Dont have an account?',style: TextStyle(fontWeight: FontWeight.w400,color: Colors.black),textAlign: TextAlign.center,),
//                       TextButton(
//                           onPressed: (){
//                           //Navigator.push(context, MaterialPageRoute(builder: (context) => (),));
//                         },
//                           child: Text('Signup_page')
//                       )
//                     ],
//                   ),
//
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
