import 'package:flutter/material.dart';

class ChatsScreen extends StatefulWidget{
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {

  final List<Map<String, String>> users = [
    {'name': 'Ali', 'profileUrl': 'https://t4.ftcdn.net/jpg/05/49/98/39/360_F_549983970_bRCkYfk0P6PP5fKbMhZMIb07mCJ6esXL.jpg'},
    {'name': 'Ayesha', 'profileUrl': 'https://t4.ftcdn.net/jpg/05/49/98/39/360_F_549983970_bRCkYfk0P6PP5fKbMhZMIb07mCJ6esXL.jpg'},
    {'name': 'Bilal', 'profileUrl': 'https://t4.ftcdn.net/jpg/05/49/98/39/360_F_549983970_bRCkYfk0P6PP5fKbMhZMIb07mCJ6esXL.jpg'},
  ];

  @override
  Widget build(BuildContext context) {
   return Scaffold(
     backgroundColor: Colors.white,
     appBar: AppBar(
       automaticallyImplyLeading: false,
       title: Text('Messages'),
     ),
     body: ListView.builder(
       itemCount: users.length,
       itemBuilder: (context, index) {
         final user = users[index];
         return ListTile(
           leading: CircleAvatar(
             radius: 25,
             backgroundImage: NetworkImage(user['profileUrl']!),
           ),
           title: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: [
               Text(user['name']!),
               Text('6:43 PM',textAlign: TextAlign.right,style: TextStyle(color: Colors.grey,fontSize: 13),)
             ],
           ),
           subtitle: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: [
               Text("Hey,I'm using Unity Gig",style: TextStyle(color: Colors.grey),),
               Badge(
                 backgroundColor: Colors.indigoAccent,
                 label: Text('5',textAlign: TextAlign.end, style: TextStyle(color: Colors.white)),
                 //child: Icon(Icons.circle_outlined), // Or any other widget
               ),
             ],
           ),
           onTap: () {
             Navigator.push(
               context,
               MaterialPageRoute(
                 builder: (context) => MessagePage(),
               ),
             );
           },
         );
       },
     ),
     floatingActionButton: FloatingActionButton(
       backgroundColor: Colors.indigoAccent,
       shape: CircleBorder(),
       onPressed: (){},
       tooltip: 'Start New chat',
       child: Icon(Icons.chat,color: Colors.white,),),

   );
  }
}

class MessagePage extends StatefulWidget {

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage>{

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
    appBar: AppBar(
      title: GestureDetector(
        onDoubleTap: (){},
        child: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage('https://t4.ftcdn.net/jpg/05/49/98/39/360_F_549983970_bRCkYfk0P6PP5fKbMhZMIb07mCJ6esXL.jpg'),
            ),
            SizedBox(width:15,),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Chat with userName',style: TextStyle(fontSize: 19),),
                Text("Hey,I'm using Unity Gig",style: TextStyle(color: Colors.grey,fontSize: 15),)
              ],
            ),
          ],
        ),
      ),
    ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Card(
                    elevation: 4.0,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              prefixIcon: IconButton(
                                onPressed: () {},
                                icon: Icon(Icons.emoji_emotions, color: Colors.indigoAccent),
                              ),
                              hintText: "Type something...",
                              hintStyle: TextStyle(color: Colors.indigoAccent),
                              border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.camera_alt, color: Colors.indigoAccent),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.image, color: Colors.indigoAccent),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Material(
                  elevation: 4.0, // Adds the same elevation as the Card
                  shape: CircleBorder(),
                  color: Colors.indigoAccent,
                  child: InkWell(
                    onTap: () {},
                    borderRadius: BorderRadius.circular(20), // Ensures ripple effect stays within circle
                    child: Container(
                      width: 45,
                      height: 45,
                      alignment: Alignment.center,
                      child: Icon(Icons.send, size: 30, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      )
    );

  }

}

// class StartNewChat extends StatefulWidget {
//
//   @override
//    _StartNewChatState createState() => _StartNewChatState();
//
// }
// class _StartNewChatState extends State<StartNewChat> {
//   @override
//   Widget build(BuildContext context) {
//     return Padding(padding: EdgeInsets.all(16.0),
//     child:Text('hello') ,
//     );
//   }
//
// }