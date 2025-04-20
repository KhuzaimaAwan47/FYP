import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shimmer/shimmer.dart';

import 'edit_profile.dart';


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {

  // Constants
final double coverHeight = 150;
final double profileHeight = 130;
int totalReviews = 0;
double averageRating = 0;

// User data variables
  String firstName = '';
  String lastName = '';
  String location = '';
  double? hourlyRate ;
  String description = '';
  String headline = '';
  String skills = '';
  String? imageUrl;
  String? profileUrl;
  String? coverUrl;

// Initialize Firebase Services
final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;
final ImagePicker _imagePicker = ImagePicker();

// Project data
int totalProjectsByUser = 0;
int totalProposals = 0;
int totalGroupsByUser = 0;
int totalOffersSent = 0;
int totalOffersReceived = 0;
Map<String, int> _projectStatusCounts = {};


@override
void initState() {
  super.initState();
  loadUserData();
  loadProjects();
  loadGroups();
  loadBids();
  loadOffers();
}

/* --------------------------- Data Loading Methods --------------------------- */

  Future<void> loadProjects() async {
    // Get the current user
    User? user = _auth.currentUser;
    if (user == null) return;

    try {
      // Query the 'users' collection to find the user document
      QuerySnapshot userQuerySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: user.email)
          .get();

      // Check if the user document exists
      if (userQuerySnapshot.docs.isEmpty) {
        print('User not found in Firestore.');
        return;
      }

      // Extract the username from the user document
      Map<String, dynamic>? userData =
      userQuerySnapshot.docs.first.data() as Map<String, dynamic>?;
      String? username = userData?['username'];
      if (username == null) {
        print('Username not found in Firestore.');
        return;
      }

      // Query the 'projects' collection for projects assigned to the user
      QuerySnapshot projectQuerySnapshot = await _firestore
          .collection('projects')
          .where('assigned_to', isEqualTo: username)
          .get();
      // Query the 'projects' collection for projects owned by the user
      QuerySnapshot ownedProjectsSnapshot = await _firestore
          .collection('projects')
          .where('owner_name', isEqualTo: username)
          .get();
      // Initialize counts for project statuses
      Map<String, int> counts = {
        'Ongoing': 0,
        'Pending': 0,
        'Completed': 0,
        'Cancelled': 0,
      };

      // Iterate through the project documents and count statuses
      for (var doc in projectQuerySnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>?;
        if (data != null) {
          String? status = data['project_status'];
          if (status != null && counts.containsKey(status)) {
            counts[status] = counts[status]! + 1;
          }
        }
      }

      // Update the state
      if (mounted) {
        setState(() {
          _projectStatusCounts = counts;
          totalProjectsByUser = ownedProjectsSnapshot.docs.length;
        });
      }

      print('Project Status Counts: $_projectStatusCounts');
      print('Total Projects by User: $totalProjectsByUser');
    } catch (e) {
      // Handle errors gracefully
      print('Error loading projects: $e');
    }
  }


  Future<void> loadOffers() async {
    // Get the current user
    User? user = _auth.currentUser;
    if (user == null) return;

    try {
      // Query the 'users' collection to find the user document
      QuerySnapshot userQuerySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: user.email)
          .get();

      // Check if the user document exists
      if (userQuerySnapshot.docs.isEmpty) {
        print('User not found in Firestore.');
        return;
      }

      // Extract the username from the user document
      Map<String, dynamic>? userData =
      userQuerySnapshot.docs.first.data() as Map<String, dynamic>?;
      String? username = userData?['username'];
      if (username == null) {
        print('Username not found in Firestore.');
        return;
      }

      // Query the 'projects' collection for projects assigned to the user
      QuerySnapshot receivedOfferQuerySnapshot = await _firestore
          .collection('offers')
          .where('assigned_to', isEqualTo: username)
          .get();
      // Query the 'projects' collection for projects owned by the user
      QuerySnapshot sentOfferSnapshot = await _firestore
          .collection('offers')
          .where('owner_name', isEqualTo: username)
          .get();


      // Update the state
      if (mounted) {
        setState(() {
          totalOffersSent = sentOfferSnapshot.docs.length;
          totalOffersReceived = receivedOfferQuerySnapshot.docs.length;
        });
      }
      print('Total Offers Sent: $totalOffersSent');
      print('Total Offers Received: $totalOffersReceived');
    } catch (e) {
      // Handle errors gracefully
      print('Error loading offers: $e');
    }
  }


  Future<void> loadBids() async{
    User? user = _auth.currentUser;
    if (user == null) return;
    try {

      QuerySnapshot userQuerySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: user.email)
          .get();

      Map<String, dynamic>? userData =
      userQuerySnapshot.docs.first.data() as Map<String, dynamic>?;
      String? username = userData?['username'];

      QuerySnapshot bidderQuerySnapshot = await _firestore.collection('bids')
          .where('bidder_name', isEqualTo: username)
          .get();
      setState(() {
        totalProposals = bidderQuerySnapshot.docs.length;
      });
      print('Total Proposals: $totalProposals');

    } catch (e) {
      print('Error loading bids: $e');
    }
  }

  Future<void> loadGroups() async {
    User? user = _auth.currentUser;
    if (user == null) return;

    try {
      QuerySnapshot groupQuerySnapshot = await _firestore
          .collection('groups')
          .where('created_by', isEqualTo: user.uid)
          .get();

      // Update state regardless of result
      setState(() {
        totalGroupsByUser = groupQuerySnapshot.docs.length;
      });

      print('Groups by user: $totalGroupsByUser');

    } catch (e) {
      print('Error loading groups: $e');
    }
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
          averageRating = userDoc['averageRating'] ;
          totalReviews = userDoc['totalReviews'];
        });
      //  print('User data loaded: $firstName, $lastName, $location, $hourlyRate,$profileUrl,$coverUrl');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No data found for the current user!')),
        );
      }
    } catch (e) {}
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No user logged in!')),
    );
  }
}

/* ---------------------------Cover Image Upload Method --------------------------- */


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

/* --------------------------- Profile Image Upload Method --------------------------- */

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

/* --------------------------- Main Build Widget --------------------------- */

  @override
  Widget build(BuildContext context) {
    final top = coverHeight - profileHeight / 2;
    var screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar:  AppBar(
        title: const Text('DashBoard'),
        automaticallyImplyLeading: false,
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
                                width: 120,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(4),
                                ),
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
                                height: 24,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: headline.isNotEmpty
                            ? Text(
                          headline,
                          textAlign: TextAlign.justify,
                          style: const TextStyle(fontSize: 18),
                        )
                            : Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(
                            width: double.infinity,
                            height: 22,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 16.0),
                            child: location.isNotEmpty
                                ? Row(
                              children: [
                                const Icon(Icons.location_pin, size: 20, color: Colors.indigoAccent),
                                const SizedBox(width: 4),
                                Text(
                                  location,
                                  style: const TextStyle(fontSize: 17, color: Colors.black54),
                                ),
                              ],
                            )
                                : Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: Row(
                                children: [
                                  Container(
                                    width: 17,
                                    height: 17,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Container(
                                    width: 100,
                                    height: 17,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          hourlyRate != null
                              ? Row(
                            children: [
                              const Icon(Icons.attach_money, size: 20, color: Colors.indigoAccent),
                              const SizedBox(width: 4),
                              Text(
                                '\$$hourlyRate/hr',
                                style: const TextStyle(fontSize: 17, color: Colors.black54),
                              ),
                            ],
                          )
                              : Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Row(
                              children: [
                                Container(
                                  width: 17,
                                  height: 17,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Container(
                                  width: 80,
                                  height: 17,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0,top: 5),
                        child: skills.isNotEmpty
                            ? Row(
                          children: [
                            const Icon(Icons.stars, size: 20, color: Colors.indigoAccent),
                            const SizedBox(width: 4),
                            Text(
                              skills,
                              style: TextStyle(fontSize: 17, color: Colors.black54),
                            ),
                          ],
                        )
                            : Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Row(
                            children: [
                              Container(
                                width: 17,
                                height: 17,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Container(
                                width: 120,
                                height: 17,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0, right: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            averageRating != 0
                                ? Row(
                              children: [
                                Icon(Icons.star_rate, color: Colors.amber, size: 20),
                                SizedBox(width: 4),
                                Text(
                                  'Average Rating: ${averageRating.toStringAsFixed(1)}',
                                  style: TextStyle(fontSize: 16, color: Colors.black54),
                                ),
                              ],
                            )
                                : Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: Row(
                                children: [
                                  Container(
                                    width: 17,
                                    height: 17,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Container(
                                    width: 100,
                                    height: 17,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 5),
                            totalReviews != 0
                                ? Row(
                              children: [
                                Icon(Icons.reviews, color: Colors.indigoAccent, size: 20),
                                SizedBox(width: 4),
                                Text(
                                  'Total Reviews: $totalReviews',
                                  style: TextStyle(fontSize: 16, color: Colors.black54),
                                ),
                              ],
                            )
                                : Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: Row(
                                children: [
                                  Container(
                                    width: 17,
                                    height: 17,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Container(
                                    width: 80,
                                    height: 17,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: description.isNotEmpty
                            ? Text(
                          description,
                          textAlign: TextAlign.justify,
                          style: const TextStyle(fontSize: 16, color: Colors.black54),
                        )
                            : Column(
                          children: List.generate(
                            3,
                                (index) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Shimmer.fromColors(
                                baseColor: Colors.grey[300]!,
                                highlightColor: Colors.grey[100]!,
                                child: Container(
                                  width: double.infinity,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),

                      //-------------------Cards Section------------------
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
                                  Expanded(child: projectCard('Ongoing Projects', _projectStatusCounts['Ongoing'] ?? 0, Colors.blue)),
                                  Expanded(child: projectCard('Pending Projects', _projectStatusCounts['Pending'] ?? 0, Colors.orange)),
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(child: projectCard('Completed Projects',_projectStatusCounts['Completed'] ?? 0, Colors.green)),
                                  Expanded(child: projectCard('Cancelled Projects',_projectStatusCounts['Cancelled'] ?? 0, Colors.red)),
                                ],
                              ),
                              SizedBox(height: 10),
                              // Additional Info Cards
                              infoCard('Offers Received', totalOffersReceived ?? 0, Icons.local_offer),
                              infoCard('No of Bided Projects',totalProposals ?? 0, Icons.gavel),
                              infoCard('No of Groups', totalGroupsByUser ?? 0, Icons.group),
                              infoCard('No of Posted Projects', totalProjectsByUser ?? 0, Icons.library_books),
                              infoCard('Offers Sent', totalOffersSent ?? 0, Icons.send),
                            ],
                          ),
                        ),
                      ),

                    ],
                  ),
                 // SizedBox(height: 20), // Spacing
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

  /* --------------------------- Project Cards Widget --------------------------- */

  Widget projectCard(String title, int count, Color color) {
    return Card(
      elevation: 2,
      color: Colors.grey[50],
      child: Container(
        height: 100,
        padding: EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
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

  /* --------------------------- Info Cards Widget --------------------------- */

  Widget infoCard(String title, int count, IconData icon) {
    return Card(
      color: Colors.grey[50],
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 5),
      child: ListTile(
        leading: Icon(icon, color: Colors.indigoAccent),
        title: Text(title),
        trailing: Text(
          count.toString(),
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  /* --------------------------- Cover Image Widget --------------------------- */

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

  /* --------------------------- Profile Image Widget --------------------------- */

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
