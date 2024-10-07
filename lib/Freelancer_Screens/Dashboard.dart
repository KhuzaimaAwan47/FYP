import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
final double coverHeight = 150;
final double profileHeight = 130;
final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

final ImagePicker _imagePicker = ImagePicker();
String? imageUrl;
String? _uploadedImageUrl;
String? _profileImageUrl;
String? profileUrl;

// User data variables
String firstName = '';
String lastName = '';
String location = '';
double? hourlyRate ;
String description = '';

@override
void initState() {
  super.initState();
  loadUserData();// Call to load data from Firestore when the form is initialized
  _loadImageFromFirestore(); //fetch cover image
  _loadprofileImageFromFirestore(); //fetch profile image
}

//--------------------------------------------Function to Load data from firestore-------------------------------------




Future<void> loadUserData() async {
  User? user = _auth.currentUser;

  if (user != null) {
    try {
      // Query to find the document where email matches
      QuerySnapshot querySnapshot = await _firestore.collection('users')
          .where('email', isEqualTo: user.email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot userDoc = querySnapshot.docs.first;

        setState(() {
          firstName = userDoc['first_name'];
          lastName = userDoc['last_name'];
          location = userDoc['location'];
          hourlyRate = userDoc['hourly_rate'] != null
              ? (userDoc['hourly_rate'] is int
              ? (userDoc['hourly_rate'] as int).toDouble()
              : userDoc['hourly_rate'])
              : null;
          description = userDoc['description'];
        });
        print('User data loaded: $firstName, $lastName, $location, $hourlyRate, $description');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No data found for the current user!')),
        );
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Alert'),
          content: const Text('Please complete your profile. '), //$e
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      print('Error: $e');
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No user logged in!')),
    );
  }
}

//--------------------------------------------Function to upload & display cover image from fire storage-------------------------------------


  Future<void> pickImage() async {
    try {
      XFile? res = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (res != null) {
        await uploadImageToFirebase(File(res.path));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Image not selected: $e'),
        ),
      );
    }
  }

  Future<void> uploadImageToFirebase(File image) async {
    try {
      User? currentUser = _auth.currentUser; // Get the current user
      if (currentUser != null) {
        String userId = currentUser.uid;
        Reference reference = FirebaseStorage.instance
            .ref()
            .child("user_coverImages/$userId/cover_image.png");

        // Upload the image
        await reference.putFile(image);

        // Get the download URL
        String imageUrl = await reference.getDownloadURL();
        print("Cover image URL: $imageUrl"); // Print the URL for verification

        // Save image URL to Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .set({'imageUrl': imageUrl}, SetOptions(merge: true));

        // Update the state to reflect the new image URL
        setState(() {
          _uploadedImageUrl = imageUrl;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating, // Floating above default position
            margin: EdgeInsets.only(bottom: 80,left: 16,right: 16),
            content: Text('Image uploaded successfully'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text('No user is logged in!'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Failed to upload image: $e'),
        ),
      );
    }
  }

 //Load image from Firestore
  Future<void> _loadImageFromFirestore() async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        String userId = currentUser.uid;
        DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();

        if (snapshot.exists && snapshot.data() != null) {
          String? imageUrl = snapshot.data()!['imageUrl'];
          if (imageUrl != null) {

            setState(() {
              _uploadedImageUrl = imageUrl;
              print(" Cover Image URL: $imageUrl");
            });
            // Force image reload (example using CachedNetworkImage)
            ImageProvider imageProvider = CachedNetworkImageProvider(imageUrl);
            imageProvider.evict(); // Clear cache for this image
          }
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Failed to load image: $e'),
        ),
      );
    }
  }

//--------------------------------------------Function to upload & display profile image from fire storage-------------------------------------

  Future<void> pickProfileImage() async {
    try {
      XFile? res = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (res != null) {
        await uploadProfileImageToFirebase(File(res.path));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Image not selected: $e'),
        ),
      );
    }
  }
  Future<void> uploadProfileImageToFirebase(File image) async {
    try {
      User? currentUser = _auth.currentUser; // Get the current user
      if (currentUser != null) {
        String userId = currentUser.uid;
        Reference reference = FirebaseStorage.instance
            .ref()
            .child("user_profileImages/$userId/profile_image.png");

        // Upload the image
        await reference.putFile(image);

        // Get the download URL
        String profileUrl = await reference.getDownloadURL();
        print("Profile Image URL: $profileUrl"); // Print the URL for verification

        // Save image URL to Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .set({'profileUrl': profileUrl}, SetOptions(merge: true));

        // Update the state to reflect the new image URL
        setState(() {
          _profileImageUrl = profileUrl;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating, // Floating above default position
            margin: EdgeInsets.only(bottom: 80,left: 16,right: 16),
            content: Text('Profile image uploaded successfully.'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text('No user is logged in!'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Failed to upload image: $e'),
        ),
      );
    }
  }
  //Load image from Firestore
  Future<void> _loadprofileImageFromFirestore() async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        String userId = currentUser.uid;
        DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();

        if (snapshot.exists && snapshot.data() != null) {
          String? profileUrl = snapshot.data()!['profileUrl'];
          if (profileUrl != null) {

            setState(() {
              _profileImageUrl = profileUrl;
              print(" Profile Image URL: $profileUrl");
            });
            // Force image reload (example using CachedNetworkImage)
            ImageProvider imageProvider = CachedNetworkImageProvider(profileUrl);
            imageProvider.evict(); // Clear cache for this image
          }
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Failed to load image: $e'),
        ),
      );
    }
  }




  @override
  Widget build(BuildContext context) {
    final top = coverHeight - profileHeight / 2;
    final bottom = profileHeight / 2;
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar:  AppBar(

        title: const Text('DashBoard'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(onPressed: (){}, icon: const Icon(Icons.dehaze))
        ],
      ),
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          buildCoverImage(),
          Positioned(
            top: top,

              child: buildProfileImage(),
          ),

          //--------------------------------------------Display Info Section-----------------------------------------------------

        Container(
          margin: const EdgeInsets.only(top: 215),
          width: screenWidth,
          height: 250,
          //color: Colors.black12,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 15.0),
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black87
                    ),
                    child: IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: (){
                          Navigator.push(
                            context, MaterialPageRoute(builder: (context) => const FullScreenForm(),),);
                        },
                        icon: const Icon(Icons.edit,size: 20,color: Colors.white,),),
                  ),
                ),
              ),

               Padding(
                padding: const EdgeInsets.only(left: 10.0,),
                child: Row(
                  children: [
                    Text(firstName.isNotEmpty ? firstName : 'Your first',style: const TextStyle(fontSize: 20,fontWeight: FontWeight.w500),),
                    const SizedBox(width: 5,),
                    Text(lastName.isNotEmpty ? lastName : '& last name shown here',style: const TextStyle(fontSize: 20,fontWeight: FontWeight.w500),),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Text(description.isNotEmpty ? description : 'description',style: const TextStyle(fontSize: 18,)),
              ),
               Padding(
                  padding: const EdgeInsets.only(left: 10.0),
              child:  Text( location.isNotEmpty ? location : 'location',style: const TextStyle(fontSize: 17,color: Colors.black54),),
              ),
               Padding(padding: const EdgeInsets.only(left: 10.0),
              child:  Text(hourlyRate == null ?'hourly rate in \$':'$hourlyRate \$/hour.',style: const TextStyle(fontSize: 17,color: Colors.black54),)
              ),

            ],
          ),
        )

        ],
      ),
    );
  }


//--------------------------------------------Cover Image-----------------------------------------------------


  Widget buildCoverImage() {
    return Container(
      height: coverHeight,
      width: double.infinity,
      color: Colors.grey[300],
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Display the image if imageUrl is not null, otherwise show a placeholder
          _uploadedImageUrl != null
              ? Image.network(
            _uploadedImageUrl!,
            fit: BoxFit.cover,
            //width: 300,
            //height: 300,
          )
              : const Center(
            child: Text('Upload a cover image here.', style: TextStyle(fontSize: 16, color: Colors.black54),),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 15),
              child: SizedBox(
                width: 30,
                height: 30,
                child: Container(
                  padding: const EdgeInsets.all(1.0),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black87,
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(
                      Icons.add_a_photo,
                      size: 20,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      pickImage();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  //--------------------------------------------Profile Image-----------------------------------------------------

  Widget buildProfileImage() => Stack(
    children:[
      Padding(
        padding: const EdgeInsets.only(left: 10.0),
        child: CircleAvatar(
          radius: profileHeight / 2,
          backgroundImage: _profileImageUrl != null ? CachedNetworkImageProvider(_profileImageUrl!)
         : const NetworkImage('https://t4.ftcdn.net/jpg/05/49/98/39/360_F_549983970_bRCkYfk0P6PP5fKbMhZMIb07mCJ6esXL.jpg'),
        ),
      ),
      Positioned(
        top: 10,
        right: 1,
        bottom: 10,
        child: SizedBox(
          width: 25,
          height: 25,
          child: Container(
            padding: const EdgeInsets.all(1.0),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.add_circle_outlined,size: 20,color: Colors.white,),
              onPressed: () {
                pickProfileImage();
              },
            ),
          ),
        ),
      ),
    ],
  );
}



class FullScreenForm extends StatefulWidget {
  const FullScreenForm({super.key});


  @override
  State<FullScreenForm> createState() => _FullScreenFormState();
}

class _FullScreenFormState extends State<FullScreenForm> {
  final TextEditingController firstnameController = TextEditingController();
  final TextEditingController lastnameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController rateController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;



  @override
  void dispose() {
    firstnameController.dispose();
    lastnameController.dispose();
    descriptionController.dispose();
    locationController.dispose();
    rateController.dispose();
    super.dispose();
  }


  //--------------------------------------------Function to save data to firestore-------------------------------------

  Future<void> saveData() async {
    User? user = _auth.currentUser;

    if (user != null) {
      try {
        // Query to find the document where email or username matches
        QuerySnapshot querySnapshot = await _firestore.collection('users')
            .where('email', isEqualTo: user.email) // or 'username', isEqualTo: 'someUsername'
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          DocumentReference userDoc = querySnapshot.docs.first.reference;

          await userDoc.update({
            'first_name': firstnameController.text,
            'last_name': lastnameController.text,
            'location': locationController.text,
            'hourly_rate': double.parse(rateController.text),
            'description': descriptionController.text,
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Data updated successfully!')),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No document found for the current user!')),
          );
        }
      } catch (e) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text('Failed to update Data: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No user logged in!')),
      );
    }
  }



  //--------------------------------------------Full Screen Form-----------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Intro'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.pop(context); // Closes the form and returns to the previous screen
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextFormField(
                autofocus: true,
                controller: firstnameController,
                decoration:  InputDecoration(
                  hintText: 'Enter First Name',
                  hintStyle: const TextStyle(
                    color: Colors.grey,
                  ),
                  prefixIcon: const Icon(Icons.account_circle_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                keyboardType: TextInputType.text,
                maxLines: 1,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(20), // Limits input to 20 characters
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextFormField(
                controller: lastnameController,
                decoration:  InputDecoration(
                  hintText: 'Enter Last Name',
                  hintStyle: const TextStyle(
                    color: Colors.grey,
                  ),
                  prefixIcon: const Icon(Icons.account_circle_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                keyboardType: TextInputType.text,
                maxLines: 1,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(20), // Limits input to 20 characters
                ],// Allows for multi-line input
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextFormField(
                controller: locationController,
                decoration: InputDecoration(
                  hintText: 'Your location',
                  hintStyle: const TextStyle(
                    color: Colors.grey,
                  ),
                  prefixIcon: const Icon(Icons.location_on),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                keyboardType: TextInputType.text,
                maxLines: 1,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(20), // Limits input to 20 characters
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextFormField(
                controller: rateController,
                decoration: InputDecoration(
                  hintText: 'Hourly rate',
                  hintStyle: const TextStyle(
                    color: Colors.grey,
                  ),
                  prefixIcon: const Icon(Icons.money),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                keyboardType: TextInputType.number,
                maxLines: 1,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                height: 200,
                child: TextFormField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    hintText: 'Description in max 100 words',
                    hintStyle: const TextStyle(
                      color: Colors.grey,
                    ),
                    prefixIcon: const Icon(Icons.description),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  keyboardType: TextInputType.text,
                  maxLines: null, // Allows for multi-line input
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(600), // Limits input to 600 characters or 100 words
                  ],
                ),
              ),
            ),
             Padding(
              padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  padding:  EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.35, // 35% of the screen width
                    vertical: 10,
                  ),
                ),
                onPressed: (){
                  saveData();
                },
                child: const Text('Save',style: TextStyle(fontSize: 18,color: Colors.white),)
            )
            ),
          ],
        ),
      ),
    );
  }
}