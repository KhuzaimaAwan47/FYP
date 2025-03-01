import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shimmer/shimmer.dart';


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
String? profileUrl;
String? coverUrl;

// User data variables
String firstName = '';
String lastName = '';
String location = '';
double? hourlyRate ;
String description = '';
String headline = '';
String skills = '';

@override
void initState() {
  super.initState();
  loadUserData();// Call to load data from Firestore when the form is initialized
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
          headline = userDoc['headline'];
          skills = userDoc['skills'];
          profileUrl = userDoc['profileUrl'];
          coverUrl = userDoc['coverUrl'];
        });
        print('User data loaded: $firstName, $lastName, $location, $hourlyRate,$profileUrl,$coverUrl');
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

//--------------------------------------------Function to upload cover image to fire storage-------------------------------------

  Future<void> pickImage() async {
    try {
      // Pick image from gallery
      final ImagePicker _picker = ImagePicker();
      XFile? res = await _picker.pickImage(source: ImageSource.gallery);

      if (res != null) {
        // Crop Image
        CroppedFile? croppedFile = await ImageCropper().cropImage(
          sourcePath: res.path,

          uiSettings: [
            AndroidUiSettings(
              aspectRatioPresets: [
                CropAspectRatioPreset.ratio16x9,
                CropAspectRatioPreset.original,
              ],
              toolbarTitle: 'Crop Cover Image',
              toolbarColor: Colors.blueAccent,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false,
            ),
            IOSUiSettings(
              title: 'Crop Cover Image',
            ),
          ],
        );

        if (croppedFile != null && croppedFile.path.isNotEmpty) {
          // Upload cropped image
          await uploadImageToFirebase(File(croppedFile.path));
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Error: $e'),
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

        // Update the state to reflect the new image URL
        setState(() {
        });

        // Additional logic to update the profileUrl based on email or username
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('users')
        .where('email',isEqualTo: currentUser.email).get();
        if(querySnapshot.docs.isNotEmpty){
          DocumentReference userDoc = querySnapshot.docs.first.reference;
          await userDoc.update({
            'coverUrl': imageUrl,
          });
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating, // Floating above default position
            margin: EdgeInsets.only(bottom: 50,left: 16,right: 16),
            content: Text('Cover image uploaded successfully!'),
          ),
        );
        await loadUserData();
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


//--------------------------------------------Function to upload profile image to fire storage-------------------------------------

  Future<void> pickProfileImage() async {
    try {
      XFile? res = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (res != null) {

        CroppedFile? croppedFile = await ImageCropper().cropImage(
          sourcePath: res.path,

          uiSettings: [
            AndroidUiSettings(
              aspectRatioPresets: [
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.original,
              ],
              toolbarTitle: 'Crop Profile Image',
              toolbarColor: Colors.indigoAccent,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false,
            ),
            IOSUiSettings(
              title: 'Crop Profile Image',
            ),
          ],
        );

        if (croppedFile != null && croppedFile.path.isNotEmpty) {
          // Upload cropped image
          await uploadProfileImageToFirebase(File(croppedFile.path));
        }
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

        // Update the state to reflect the new image URL
        setState(() {
        });

        // Additional logic to update the profileUrl based on email or username
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: currentUser.email) // Use currentUser.email to find the document
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          DocumentReference userDoc = querySnapshot.docs.first.reference;
          await userDoc.update({
            'profileUrl': profileUrl, // Update the profileUrl field
          });
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating, // Floating above default position
            margin: EdgeInsets.only(bottom: 80, left: 16, right: 16),
            content: Text('Profile image uploaded successfully!'),
          ),
        );
        await loadUserData(); // This will call the func after the new image is uploaded.
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


  @override
  Widget build(BuildContext context) {
    final top = coverHeight - profileHeight / 2;
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
      body: SingleChildScrollView(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            buildCoverImage(coverUrl),
            Positioned(
              top: top,
                child: buildProfileImage(profileUrl),
            ),
        
            //--------------------------------------------Display Info Section-----------------------------------------------------
        
            Container(
              margin: const EdgeInsets.only(top: 215),
              width: screenWidth,
              color: Colors.white,
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: Row(
                          children: [
                            firstName.isNotEmpty
                                ? Text(
                              firstName,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            )
                                : Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: Container(
                                width: 100,
                                height: 20,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 5),
                            lastName.isNotEmpty
                                ? Text(
                              lastName,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            )
                                : Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: Container(
                                width: 100,
                                height: 20,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10,),
                      Padding(
                          padding: EdgeInsets.only(left: 16,right: 16),
                        child:headline.isNotEmpty
                          ? Text(headline,textAlign: TextAlign.justify,style: TextStyle(fontSize: 18,),
                        )
                            : Shimmer.fromColors(
                            baseColor: Colors.grey[300]!, highlightColor: Colors.grey[100]!,
                            child: Container(
                              width: 200,
                              height: 18,
                              color: Colors.white,
                            ))
                      ),

                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 16.0),
                            child: location.isNotEmpty
                                ? Row(
                              children: [
                                Icon(Icons.location_pin,size: 17,color: Colors.indigoAccent,),
                                Text( location,
                                  style: const TextStyle( fontSize: 17, color: Colors.black54,),
                                ),
                              ],
                            )
                                : Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: Container(
                                width: 100,
                                height: 17,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          hourlyRate != null
                              ? Row(
                            children: [
                              Icon(Icons.attach_money,size: 17,color: Colors.indigoAccent,),
                              Text('\$$hourlyRate/hr',
                                style: const TextStyle(fontSize: 17, color: Colors.black54,
                                ),
                              ),
                            ],
                          )
                              : Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(
                              width: 100,
                              height: 17,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: skills.isNotEmpty
                            ? Row(
                          children: [
                            Icon(Icons.stars,size: 17,color: Colors.indigoAccent,),
                            Text(skills,style: TextStyle(fontSize: 17,color: Colors.black54),
                            ),
                          ],
                        )
                            : Shimmer.fromColors(baseColor: Colors.grey[300]!, highlightColor: Colors.grey[100]!, child: Container(width: 100,height: 17,color: Colors.white,)),
                      ),
                      SizedBox(height: 10,),
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0, right: 16),
                        child: description.isNotEmpty
                            ? Text(
                          description,
                          textAlign: TextAlign.justify,
                          style: const TextStyle(fontSize: 16,color: Colors.black54),
                        )
                            : Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(
                            width: 200,
                            height: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),


                      SizedBox(height: 20), // Spacing

                      //-------------------Card Widgets------------------

                      Container(
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              // Cards for Ongoing, Cancelled, and Completed Projects
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  projectCard('Ongoing Projects', 12, Colors.blue.withOpacity(0.8)),
                                  projectCard('Pending Projects', 5, Colors.orange.withOpacity(0.8)),
                                  projectCard('Completed Projects', 20, Colors.green.withOpacity(0.8)),
                                ],
                              ),
                              SizedBox(height: 20),
                              // Additional Info Cards
                              infoCard('Offers Received', 30),
                              infoCard('No of Bided Projects', 15),
                              infoCard('No of Groups', 8),
                              infoCard('No of Posted Projects', 25),
                              infoCard('Offers Sent', 22),
                            ],
                          ),
                        ),
                      ),

                    ],
                  ),
                  SizedBox(height: 20), // Spacing
                  //Edit Button
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 15.0),
                      child: Container(
                        alignment: Alignment.topRight,
                        width: 30,
                        height: 30,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.indigoAccent,
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const FullScreenForm()),
                            );
                          },
                          icon: const Icon(
                            Icons.edit,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget projectCard(String title, int count, Color color) {
    return Card(
      elevation: 4,
      color: Colors.grey[50],
      //color: color.withOpacity(0.1),
      child: Container(
        width: 100,
        height: 100,
        padding: EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: 5),
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Function to create additional info cards
  Widget infoCard(String title, int count) {
    return Card(
      color: Colors.grey[50],
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(Icons.info, color: Colors.blueAccent),
        title: Text(title),
        trailing: Text(
          count.toString(),
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }


//--------------------------------------------Cover Image-----------------------------------------------------


  Widget buildCoverImage(String? coverUrl) {
    return Container(
      height: coverHeight,
      width: double.infinity,
      color: Colors.grey[300],
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Display the image if imageUrl is not null, otherwise show a placeholder
          coverUrl != null
              ? Image.network(
            coverUrl,
            fit: BoxFit.cover,
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
                    color: Colors.indigoAccent,
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

  Widget buildProfileImage(String? profileUrl) => Stack(
    children:[
      Padding(
        padding: const EdgeInsets.only(left: 10.0),
        child: CircleAvatar(
          radius: profileHeight / 2,
          backgroundImage: profileUrl != null && profileUrl.isNotEmpty
              ? NetworkImage(profileUrl)
              : const NetworkImage('https://t4.ftcdn.net/jpg/05/49/98/39/360_F_549983970_bRCkYfk0P6PP5fKbMhZMIb07mCJ6esXL.jpg'
          ),
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
              color: Colors.indigoAccent
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.add_circle_outlined,size: 22,color: Colors.white,),
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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController firstnameController = TextEditingController();
  final TextEditingController lastnameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController rateController = TextEditingController();
  final TextEditingController skillsController = TextEditingController();
  final TextEditingController headlineController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;



  @override
  void dispose() {
    firstnameController.dispose();
    lastnameController.dispose();
    descriptionController.dispose();
    locationController.dispose();
    rateController.dispose();
    headlineController.dispose();
    super.dispose();
  }


  //--------------------------------------------Function to save data to firestore-------------------------------------

  Future<void> saveData() async {
    FocusScope.of(context).unfocus(); //keyboard closes when button is pressed.
    // Validate the form before proceeding
    if (!_formKey.currentState!.validate()) {
      // If the form is not valid, show an error message and return
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill out all required fields correctly.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(bottom: 80.0, left: 16.0, right: 16.0),
        ),
      );
      return; // Don't proceed with saving if the form is invalid
    }

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
            'skills': skillsController.text,
            'headline' :headlineController.text,
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating, // Make it float
                margin: EdgeInsets.only(bottom: 80.0, left: 16.0, right: 16.0),
                duration: Duration(seconds: 3),
                content: Text('Profile Info added Successfully!'),),
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




  //--------------------------------------------Full Screen Form for editing user record-----------------------------------------------------


  @override
  void initState() {
    super.initState();
    loadUserData(); // Load user data when the page opens
  }

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
            // Populate the controllers if data exists in Firestore
            firstnameController.text = userDoc['first_name'] ?? '';
            lastnameController.text = userDoc['last_name'] ?? '';
            locationController.text = userDoc['location'] ?? '';
            rateController.text = userDoc['hourly_rate']?.toString() ?? '';
            skillsController.text = userDoc['skills'] ?? '';
            descriptionController.text = userDoc['description'] ?? '';
            headlineController.text = userDoc['headline'] ?? '';
          });

          print('User data loaded: ${firstnameController.text}, ${lastnameController.text}, ${locationController.text}, ${rateController.text}, ${skillsController.text}, ${descriptionController.text}');
        } else {
          // If no data is found, leave fields empty (user will input them)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please complete you profile!')),
          );
        }
      } catch (e) {
        print('Error: $e');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No user logged in!')),
      );
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Add Profile Info'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.pop(context); // Closes the form and returns to the previous screen
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 16.0,left: 16.0,right: 16.0),
                child: TextFormField(
                  controller: firstnameController,
                  decoration:  InputDecoration(
                    hintText: 'First Name',
                    hintStyle: const TextStyle(
                      color: Colors.grey,
                    ),
                    prefixIcon: const Icon(Icons.account_circle_outlined,color: Colors.grey,),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  autocorrect: true,
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.words,
                  maxLines: 1,
                  validator: (value){
                    if(value == null ||  value.isEmpty){
                      return 'This field is required.';
                    }
                  },
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(20), // Limits input to 20 characters
                    FilteringTextInputFormatter.allow(RegExp("[a-zA-Z ]")), // Only allows letters and spaces
                    //FirstLetterCapitalFormatter(),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0,left: 16.0,right: 16.0),
                child: TextFormField(
                  controller: lastnameController,
                  decoration:  InputDecoration(
                    hintText: 'Last Name',
                    hintStyle: const TextStyle(
                      color: Colors.grey,
                    ),
                    prefixIcon: const Icon(Icons.account_circle_outlined,color: Colors.grey,),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.words,
                  maxLines: 1,
                  validator: (value){
                    if(value == null ||  value.isEmpty){
                      return 'This field is required.';
                    }
                  },
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(20), // Limits input to 20 characters
                    FilteringTextInputFormatter.allow(RegExp("[a-zA-Z ]")), // Only allows letters and spaces
                  ],// Allows for multi-line input
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0,left: 16.0,right: 16.0),
                child: TextFormField(
                  controller: locationController,
                  decoration: InputDecoration(
                    hintText: 'Your Location',
                    hintStyle: const TextStyle(
                      color: Colors.grey,
                    ),
                    prefixIcon: const Icon(Icons.location_on_outlined,color: Colors.grey,),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.words,
                  maxLines: 1,
                  validator: (value){
                    if(value == null ||  value.isEmpty){
                      return 'This field is required.';
                    }
                  },
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(20), // Limits input to 20 characters
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0,left: 16.0,right: 16.0),
                child: TextFormField(
                  controller: rateController,
                  decoration: InputDecoration(
                    hintText: '\$ Hourly rate',
                    hintStyle: const TextStyle(
                      color: Colors.grey,
                    ),
                    prefixIcon: const Icon(Icons.attach_money_outlined,color: Colors.grey,),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  maxLines: 1,
                  validator: (value){
                    if(value == null ||  value.isEmpty){
                      return 'This field is required.';
                    }
                  },
                ),
              ),
              Padding(padding: const EdgeInsets.only(top: 16.0,left: 16.0,right: 16.0),
              child: TextFormField(
                controller: skillsController,
                decoration: InputDecoration(
                  hintText: 'Your Skills',
                  hintStyle: const TextStyle(
                    color: Colors.grey,
                  ),
                  prefixIcon: const Icon(Icons.lightbulb_outline,color: Colors.grey,),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  )
                ),
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.words,
                validator: (value){
                  if(value == null ||  value.isEmpty){
                    return 'This field is required.';
                  }
                },
              ),
              ),

              Padding(
                padding: const EdgeInsets.only(top: 16.0,left: 16.0,right: 16.0),
                child: TextFormField(
                  controller: headlineController,
                  decoration: InputDecoration(
                    hintText: 'Headline',
                    hintStyle: const TextStyle(
                      color: Colors.grey,
                    ),
                    prefixIcon: const Icon(Icons.view_headline_outlined,color: Colors.grey,),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.words,
                  validator: (value){
                    if(value == null ||  value.isEmpty){
                      return 'This field is required.';
                    }
                  },
                  maxLines: 1, // Allows for multi-line input
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(100), // Limits input to 100 characters or 20 words
                    //FilteringTextInputFormatter.allow(RegExp("[a-zA-Z ]")),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(left: 16.0,right: 16.0,top: 16.0),
                child: SizedBox(
                  height: 200,
                  child: TextFormField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      label: Text('Description (max 100 words)'),
                      hintText: 'Description (max 100 words)',
                      hintStyle: const TextStyle(
                        color: Colors.grey,
                      ),
                      //prefixIcon: const Icon(Icons.description_outlined,color: Colors.grey,),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.sentences,
                    validator: (value){
                      if(value == null ||  value.isEmpty){
                        return 'This field is required.';
                      }
                    },
                    maxLines: 10, // Allows for multi-line input
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(600), // Limits input to 600 characters or 100 words
                      FilteringTextInputFormatter.allow(RegExp("[a-zA-Z ]")),
                    ],
                  ),
                ),
              ),
               Center(
                 child: Padding(
                  padding: const EdgeInsets.only(left: 16.0,right: 16.0,top: 32),
                               child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 3.0,
                      backgroundColor: Colors.indigoAccent,
                      minimumSize: Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: (){
                      saveData();
                    },
                    child: const Text('Save',style: TextStyle(fontSize: 18,color: Colors.white),)
                               )
                               ),
               ),
            ],
          ),
        ),
      ),
    );
  }
}
