import 'package:flutter/material.dart';
import 'package:my_fyp/main.dart';
void main(){
  runApp(MyApp());
}
class MyApp extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "FlutterApp",
      theme: ThemeData(
          primarySwatch: Colors.deepPurple,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue, // Explicitly set AppBar color
        ),
      ),
      home:Myhomepage(),
    );

  }
}
class Myhomepage extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        title: Text("Practice"),
      ),
      body: SingleChildScrollView(
        child: Container(
          //width: double.infinity,
          //height: double.infinity,
          color: Colors.blue.shade200,
          child: Center(
              child: Column(
                children: [
                  Container(
                    width: 150,
                    height: 150,
                    margin: EdgeInsets.only(top: 10,bottom: 10),
        
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30)
                    ),
                          ),
                  Container(
                    width: 150,
                    height: 150,
                    //margin: EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.only(bottomRight: Radius.circular(30), topLeft: Radius.circular(30)),
                    ),
                  ),
                  Container(
                    width: 150,
                    height: 150,
                    margin: EdgeInsets.only(bottom: 10,top: 10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: const[
                          Colors.purpleAccent,
                          Colors.amberAccent,
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors:const[
                          Colors.black,
                          Colors.white,
                        ]
                      )
                    ),
                  ),
                  Container(
                    width: 150,
                    height: 150,
                    margin: EdgeInsets.only(top: 10, bottom: 10),
                    decoration: BoxDecoration(
                      gradient: SweepGradient(
                        colors: const[
                          Colors.blue,
                          Colors.green,
                          Colors.yellow,
                          Colors.red,
                          Colors.blue,
                        ]
                      ),
                    ),
                  ),
                  Container(
                    width: 150,
                    height: 150,
                    margin: EdgeInsets.only(bottom: 10),
                    foregroundDecoration: BoxDecoration(
                      backgroundBlendMode: BlendMode.exclusion,
                      gradient: LinearGradient(
                        colors: const[
                          Colors.red,
                          Colors.blue,
                        ]
                      )
                    ),
                  ),
                  SizedBox(
                      width: 400,
                      height: 40,

                      child: ElevatedButton(onPressed: (){}, child: Text('button')))
                ],
              )
          ),
        ),
      ),

    );

  }
}