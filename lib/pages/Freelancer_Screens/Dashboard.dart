import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_fyp/pages/Freelancer_Screens/no_of_receivedBids.dart';
import 'package:shimmer/shimmer.dart';
import 'assigned_project_status.dart';
import 'edit_profile.dart';
import 'no_of_biddedProjects.dart';
import 'no_of_groups.dart';
import 'no_of_postedProjects.dart';
import 'offers_received.dart';
import 'offers_sent.dart';

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
  double? hourlyRate;
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
  int totalProposalReceived = 0;
  int totalGroupsByUser = 0;
  int totalOffersSent = 0;
  int totalOffersReceived = 0;
  Map<String, int> _projectStatusCounts = {};

  List<Map<String, dynamic>> assignedProjects = [];
  List<Map<String, dynamic>> ownedProjects = [];
  List<Map<String, dynamic>> userGroups = [];
  List<Map<String, dynamic>> bidsList = [];
  List<Map<String, dynamic>> receivedBidsList = [];
  List<Map<String, dynamic>> offersSentList = [];
  List<Map<String, dynamic>> offersReceivedList = [];


  @override
  void initState() {
    super.initState();
    loadUserData();
    loadProjects();
    loadGroups();
    loadBids();
    loadOffers();
    loadReceivedBids();
  }

/* --------------------------- Data Loading Methods --------------------------- */



  // load Bids received on projects
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
        return;
      }

      // Extract the username from the user document
      Map<String, dynamic>? userData =
          userQuerySnapshot.docs.first.data() as Map<String, dynamic>?;
      String? username = userData?['username'];
      if (username == null) {
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
          assignedProjects = projectQuerySnapshot.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();
          ownedProjects = ownedProjectsSnapshot.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();
        });
      }
    } catch (e) {
      return;
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
        return;
      }

      // Extract the username from the user document
      Map<String, dynamic>? userData =
          userQuerySnapshot.docs.first.data() as Map<String, dynamic>?;
      String? username = userData?['username'];
      if (username == null) {
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
          offersSentList = sentOfferSnapshot.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();
          offersReceivedList = receivedOfferQuerySnapshot.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();
        });
      }
    } catch (e) {
      return;
    }
  }

  Future<void> loadReceivedBids() async {
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

      QuerySnapshot bidderQuerySnapshot = await _firestore
          .collection('notifications')
          .where('owner_name', isEqualTo: username)
          .get();
      setState(() {
        totalProposalReceived = bidderQuerySnapshot.docs.length;
        receivedBidsList = bidderQuerySnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
      });
    } catch (e) {
      return;
    }
  }

  Future<void> loadBids() async {
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

      QuerySnapshot bidderQuerySnapshot = await _firestore
          .collection('notifications')
          .where('bidder_name', isEqualTo: username)
          .get();
      setState(() {
        totalProposals = bidderQuerySnapshot.docs.length;
        bidsList = bidderQuerySnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
      });
    } catch (e) {
      return;
    }
  }

  Future<void> loadGroups() async {
    User? user = _auth.currentUser;
    if (user == null) return;

    try {
      QuerySnapshot groupQuerySnapshot = await _firestore
          .collection('groups')
          .where('created_by', isEqualTo: user.uid)
      .orderBy('created_at', descending: true)
          .get();
      List<Map<String, dynamic>> groupsList = groupQuerySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
      // Update state regardless of result
      setState(() {
        totalGroupsByUser = groupQuerySnapshot.docs.length;
        userGroups = groupsList;
      });
    } catch (e) {
      return;
    }
  }

  Future<void> loadUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        // Query to find the document where email matches
        QuerySnapshot querySnapshot = await _firestore
            .collection('users')
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
            averageRating = userDoc['averageRating'];
            totalReviews = userDoc['totalReviews'];
          });
        } else {
          return;
        }
      } catch (e) {
        return;
      }
    } else {
      return;
    }
  }

/* ---------------------------Cover Image Upload Method --------------------------- */

  Future<void> pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      XFile? res = await picker.pickImage(source: ImageSource.gallery);

      if (res == null) return; // Exit if user cancels image selection

      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Crop the image
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: res.path,
        uiSettings: [
          AndroidUiSettings(
            aspectRatioPresets: [
              CropAspectRatioPreset.ratio16x9,
              CropAspectRatioPreset.original,
            ],
            toolbarTitle: 'Crop Cover Image',
            toolbarColor: Colors.indigoAccent,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
          ),
          IOSUiSettings(
            title: 'Crop Cover Image',
          ),
        ],
      );

      if (croppedFile == null) {
        // User canceled cropping
        Navigator.of(context).pop(); // Dismiss dialog
        return;
      }

      // Upload the cropped image
      await uploadImageToFirebase(File(croppedFile.path));

      // Dismiss dialog after successful upload
      Navigator.of(context).pop();
    } catch (e) {
      // Dismiss dialog on error and rethrow exception
      Navigator.of(context).pop();
      rethrow; // Optional: Handle error appropriately
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

        // Update the state to reflect the new image URL
        setState(() {});

        // Additional logic to update the profileUrl based on email or username
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: currentUser.email)
            .get();
        if (querySnapshot.docs.isNotEmpty) {
          DocumentReference userDoc = querySnapshot.docs.first.reference;
          await userDoc.update({
            'coverUrl': imageUrl,
          });
        }
        await loadUserData();
      } else {
        return;
      }
    } catch (e) {
      return;
    }
  }

/* --------------------------- Profile Image Upload Method --------------------------- */

  Future<void> pickProfileImage() async {
    XFile? res;
    try {
      res = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (res == null) return; // Exit if user cancels image selection

      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Crop the image
      final croppedFile = await ImageCropper().cropImage(
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

      if (croppedFile == null) {
        // User canceled cropping
        Navigator.of(context).pop(); // Dismiss dialog
        return;
      }

      // Upload the cropped image
      await uploadProfileImageToFirebase(File(croppedFile.path));

      // Dismiss dialog after successful upload
      Navigator.of(context).pop();
    } catch (e) {
      // Ensure dialog is dismissed on error
      if (res != null) Navigator.of(context).pop();
      rethrow; // Propagate error for proper handling
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

        // Update the state to reflect the new image URL
        setState(() {});

        // Additional logic to update the profileUrl based on email or username
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('email',
                isEqualTo: currentUser
                    .email) // Use currentUser.email to find the document
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          DocumentReference userDoc = querySnapshot.docs.first.reference;
          await userDoc.update({
            'profileUrl': profileUrl, // Update the profileUrl field
          });
        }
        await loadUserData(); // This will call the func after the new image is uploaded.
      } else {
        return;
      }
    } catch (e) {
      return;
    }
  }

/* --------------------------- Main Build Widget --------------------------- */

  @override
  Widget build(BuildContext context) {
    final top = coverHeight - profileHeight / 2;
    var screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
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
                            if (firstName.isNotEmpty)
                              Text(
                                firstName,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            if (firstName.isNotEmpty) const SizedBox(width: 5),
                            if (lastName.isNotEmpty)
                              Text(
                                lastName,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (headline.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            headline,
                            textAlign: TextAlign.justify,
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          if (location.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(left: 16.0),
                              child: Row(
                                children: [
                                  const Icon(Icons.location_pin,
                                      size: 20, color: Colors.indigoAccent),
                                  const SizedBox(width: 4),
                                  Text(
                                    location,
                                    style: const TextStyle(fontSize: 17, color: Colors.black54),
                                  ),
                                ],
                              ),
                            ),
                          if (location.isNotEmpty && hourlyRate != null) const SizedBox(width: 10),
                          if (hourlyRate != null)
                            Row(
                              children: [
                                const Icon(Icons.attach_money,
                                    size: 20, color: Colors.indigoAccent),
                                const SizedBox(width: 4),
                                Text(
                                  '\$$hourlyRate/hr',
                                  style: const TextStyle(fontSize: 17, color: Colors.black54),
                                ),
                              ],
                            ),
                        ],
                      ),
                      if (skills.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0, top: 5),
                          child: Row(
                            children: [
                              const Icon(Icons.stars, size: 20, color: Colors.indigoAccent),
                              const SizedBox(width: 4),
                              Text(
                                skills,
                                style: const TextStyle(fontSize: 17, color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 5),
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0, right: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (averageRating != 0)
                              Row(
                                children: [
                                  Icon(Icons.star_rate, color: Colors.amber, size: 20),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Average Rating: ${averageRating.toStringAsFixed(1)}',
                                    style: const TextStyle(fontSize: 16, color: Colors.black54),
                                  ),
                                ],
                              ),
                            const SizedBox(height: 5),
                            if (totalReviews != 0)
                              Row(
                                children: [
                                  Icon(Icons.reviews, color: Colors.indigoAccent, size: 20),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Total Reviews: $totalReviews',
                                    style: const TextStyle(fontSize: 16, color: Colors.black54),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (description.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            description,
                            textAlign: TextAlign.justify,
                            style: const TextStyle(fontSize: 16, color: Colors.black54),
                          ),
                        ),
                      SizedBox(height: 10),
                      //-------------------Projects Cards Section------------------
                      Container(
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              // Cards for Ongoing, Cancelled, Completed Projects, Available Balance and Withdrawn balance
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Expanded(
                                      child: accountCard(
                                    'Available Balance',
                                    Colors.green,
                                    Icon(Icons.account_balance_wallet_outlined,
                                        color: Colors.green,
                                    size: 35,
                                    ),
                                  )),
                                  Expanded(
                                      child: accountCard(
                                    'Withdrawn Balance',
                                    Colors.orange,
                                    Icon(
                                      Icons.arrow_circle_down_outlined,
                                      color: Colors.orange,
                                      size: 35,
                                    ),
                                  )),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Expanded(
                                      child: projectCard(
                                          'Ongoing Projects',
                                          _projectStatusCounts['Ongoing'] ?? 0,
                                          Colors.blue,
                                          'Ongoing')),
                                  Expanded(
                                      child: projectCard(
                                          'Pending Projects',
                                          _projectStatusCounts['Pending'] ?? 0,
                                          Colors.orange,
                                          'Pending')),
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                      child: projectCard(
                                          'Completed Projects',
                                          _projectStatusCounts['Completed'] ??
                                              0,
                                          Colors.green,
                                          'Completed')),
                                  Expanded(
                                      child: projectCard(
                                          'Cancelled Projects',
                                          _projectStatusCounts['Cancelled'] ??
                                              0,
                                          Colors.red,
                                          'Cancelled')),
                                ],
                              ),
                              SizedBox(height: 10),
                              // Additional Info Cards
                              infoCard(
                                  'Offers Sent', totalOffersSent, Icons.send,
                                  OffersSent(offers: offersSentList,)),
                              infoCard('Offers Received', totalOffersReceived,
                                  Icons.local_offer,
                                  OffersReceived(offers: offersReceivedList,)),
                              infoCard('No of Groups Created', totalGroupsByUser,
                                  Icons.group,
                                  NoOfGroups(groups: userGroups)),
                              infoCard('No of Bids Sent on Projects', totalProposals,
                                  Icons.gavel,
                                  NoOfBiddedProjects(bids: bidsList,)),
                              infoCard('No of Bids Received on Projects', totalProposalReceived,
                                  Icons.check_circle,
                                  NoOfBidsReceived(bids: receivedBidsList,)),
                              infoCard('No of Posted Projects',
                                  totalProjectsByUser, Icons.library_books,
                                  NoOfPostedProjects(projects: ownedProjects,)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
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
                              MaterialPageRoute(
                                  builder: (context) => const FullScreenForm()),
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

  /* --------------------------- Account Cards Widget --------------------------- */


  Widget accountCard(String title, Color color,icon) {
    return Card(
      elevation: 0,
      color: Colors.grey[50],
      child: Container(
        height: 120,
        padding: EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            icon,
            Text('\$0.00',
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

  /* --------------------------- Project Cards Widget --------------------------- */

  Widget projectCard(String title, int count, Color color, String status) {
    return GestureDetector(
      onTap: () {
        List<Map<String, dynamic>> filtered = assignedProjects
            .where((p) => p['project_status'] == status)
            .toList();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProjectStatus(status: status, projects: filtered,),
          ),
        );
      },
      child: Card(
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
      ),
    );
  }

  /* --------------------------- Info Cards Widget --------------------------- */

  Widget infoCard(String title, int count, IconData icon, Widget screen) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      },
      child: Card(
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
                  child: Text(
                    'Upload a cover image here.',
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
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
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: CircleAvatar(
              radius: profileHeight / 2,
              backgroundColor: Colors.grey[200],
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl: (profileUrl != null && profileUrl.isNotEmpty)
                      ? profileUrl
                      :'https://t4.ftcdn.net/jpg/05/49/98/39/360_F_549983970_bRCkYfk0P6PP5fKbMhZMIb07mCJ6esXL.jpg',
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  errorWidget: (context, url, error) => const Icon(Icons.error_outline),
                ),
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
                    shape: BoxShape.circle, color: Colors.indigoAccent),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(
                    Icons.add_circle_outlined,
                    size: 22,
                    color: Colors.white,
                  ),
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
