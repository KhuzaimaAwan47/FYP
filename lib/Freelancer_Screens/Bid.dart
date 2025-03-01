import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BidForm extends StatefulWidget {
  final String projectName;
  final String projectId;
  final String ownerName;



  const BidForm({Key? key, required this.projectName, required this.ownerName, required this.projectId})
      : super(key: key);

  @override
  State<BidForm> createState() => _BidFormState();
}

class _BidFormState extends State<BidForm> {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  String? userName = '';




  //Function to load current user
  Future<void> loadCurrentUser() async {
    User? user = _auth.currentUser;
    if(user != null){
      try{
        QuerySnapshot querySnapshot = await _firestore.collection('users')
            .where('email',isEqualTo: user.email)
            .get();
        if(querySnapshot.docs.isNotEmpty){
          DocumentSnapshot userDoc = querySnapshot.docs.first;
          setState(() {
            userName = userDoc['username'];
          });
          //print('user: $userName');
        }else{
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('user name not found!')),
          );
        }
      }
      catch (e) {
        // Handle any errors that occur during the process
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'),
            ));
        print('loaded: $userName');
        //print('Error loading current user: $e');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    loadCurrentUser(); // Fetch userName when the widget initializes
  }

  Future<void> _submitBid() async {
    FocusScope.of(context).unfocus(); //keyboard closes when button is pressed.
    if (_formKey.currentState!.validate()){
      try {
        final querySnapshot = await _firestore
            .collection('bids')
            .where('project_name', isEqualTo: widget.projectName)
            .where('bidder_name', isEqualTo: userName)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          // Bid already exists
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You have already submitted a bid for this project.'),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating, // Floating above default position
              margin: EdgeInsets.only(bottom: 30,left: 16,right: 16),
            ),
          );
          return;
        }


        // Add bid details to Firestore
        await _firestore.collection('bids').add({
          'project_id':widget.projectId,
          'project_name': widget.projectName,
          'owner_name': widget.ownerName,
          'bidder_name': userName,
          'bid_amount': double.tryParse(amountController.text) ?? 0.0,
          'estimated_time':timeController.text,
          'message': messageController.text,
          'status': 'pending', // Initial status
          'created_at': FieldValue.serverTimestamp(),
        });
        await _firestore.collection('notifications').add({
          'project_id':widget.projectId,
          'project_name':widget.projectName,
          'owner_name': widget.ownerName,
          'bidder_name': userName,
          'notification_message':
          'A new bid has been submitted for your project "${widget.projectName}" by $userName.',
          'bid_amount':amountController.text,
          'estimated_time':timeController.text,
          'created_at': FieldValue.serverTimestamp(),
          'read': false, // Status to track whether the notification is read
          'status': "Pending", // Status to set by project owner if bid is accepted or rejected
        });


        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bid submitted successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating, // Floating above default position
            margin: EdgeInsets.only(bottom: 30,left: 16,right: 16),
          ),
        );


        Navigator.pop(context);
      } catch (e) {
        print('Error submitting bid: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting bid: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating, // Floating above default position
            margin: EdgeInsets.only(bottom: 30,left: 16,right: 16),
          ),
        );
      }
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Bid Now'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextFormField(
                  controller: amountController,
                  decoration: InputDecoration(
                      hintText: 'Bid Amount (\$)',
                      prefixIcon: Icon(Icons.account_balance_outlined,color: Colors.grey,),
                      hintStyle: TextStyle(color: Colors.grey,fontWeight: FontWeight.normal),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14.0),
                      ),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value){
                    if(value == null || value.isEmpty){
                      return'*This field is required';
                    }
                    return null;
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextFormField(
                  controller: timeController,
                  decoration: InputDecoration(
                    hintText: 'Estimated Time',
                    prefixIcon: Icon(Icons.timelapse_outlined,color: Colors.grey,),
                    hintStyle: TextStyle(color: Colors.grey,fontWeight: FontWeight.normal),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14.0),
                    ),
                  ),
                  keyboardType: TextInputType.text,
                  validator: (value){
                    if(value == null || value.isEmpty){
                      return'*This field is required';
                    }
                    return null;
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextFormField(
                  controller: messageController,
                  decoration: InputDecoration(
                  label: Text('Message(Optional)',style: TextStyle(color: Colors.grey),),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14.0),
                  )
                  ),
                  maxLines: 3,
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigoAccent,
                      elevation: 2.0,
                      minimumSize: Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: _submitBid,
                    child: const Text('Submit ',style: TextStyle(color: Colors.white,fontSize: 18),),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
