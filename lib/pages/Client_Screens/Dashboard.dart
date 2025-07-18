import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_fyp/pages/Freelancer_Screens/no_of_receivedBids.dart';
import '../Freelancer_Screens/edit_profile.dart';
import '../Freelancer_Screens/no_of_postedProjects.dart';
import '../Freelancer_Screens/offers_sent.dart';


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {

  final double profileHeight = 130;

  // User data variables
  String firstName = '';
  String lastName = '';
  String? profileUrl;

  // Initialize Firebase Services
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _imagePicker = ImagePicker();

  // Project data
  int totalProjectsByUser = 0;
  int totalProposalsReceived  = 0;
  int totalOffersSent = 0;

  List<Map<String, dynamic>> ownedProjects = [];
  List<Map<String, dynamic>> receivedBidsList = [];
  List<Map<String, dynamic>> offersSentList = [];

  @override
  void initState() {
    super.initState();
    loadUserData();
    loadProjects();
    loadReceivedBids();
    loadOffers();
  }

  /* --------------------------- Data Loading Methods --------------------------- */

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
            profileUrl = userDoc['profileUrl'];

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
      // Query the 'projects' collection for projects owned by the user
      QuerySnapshot ownedProjectsSnapshot = await _firestore
          .collection('projects')
          .where('owner_name', isEqualTo: username)
          .get();

      // Update the state
      if (mounted) {
        setState(() {
          ownedProjects = ownedProjectsSnapshot.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();
        });
        totalProjectsByUser = ownedProjectsSnapshot.docs.length;
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
        totalProposalsReceived = bidderQuerySnapshot.docs.length;
        receivedBidsList = bidderQuerySnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
      });
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

      // Query the 'projects' collection for projects owned by the user
      QuerySnapshot sentOfferSnapshot = await _firestore
          .collection('offers')
          .where('owner_name', isEqualTo: username)
          .get();

      // Update the state
      if (mounted) {
        setState(() {
          totalOffersSent = sentOfferSnapshot.docs.length;
          offersSentList = sentOfferSnapshot.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();

        });
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Dashboard'),
        automaticallyImplyLeading: false,
        actions: [
          PopupMenuButton<String>(
            color: Colors.white,
            onSelected: (value) {
              if (value == 'item1') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FullScreenForm()),
                );
              }
            },
            itemBuilder: (context) {
              List<PopupMenuEntry<String>> items = [
                const PopupMenuItem<String>(
                  value: 'item1',
                  child: Text('Edit Profile'),
                ),
              ];
              return items;
            },
            offset: const Offset(0, kToolbarHeight),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                children: [
                  buildProfileImage(profileUrl),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(firstName,style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),),
                      SizedBox(width: 5,),
                      Text(lastName,style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: accountCard(
                        'Available Balance',
                        Colors.green,
                        Icon(Icons.account_balance_outlined,
                          color: Colors.green,
                          size: 35,
                        )
                    ),
                  ),

                  Expanded(
                    child: accountCard('Withdrawn Balance',
                      Colors.orange,
                      Icon(Icons.account_balance_wallet_outlined,
                        color: Colors.orange,
                        size: 35,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              infoCard(
                  'Offers Sent', totalOffersSent, Icons.send,
                  OffersSent(offers: offersSentList,)),
              infoCard('No of Bids Received on Projects', totalProposalsReceived,
                  Icons.gavel,
                  NoOfBidsReceived(bids: receivedBidsList,
                  )),
              infoCard('No of Posted Projects',
                  totalProjectsByUser, Icons.library_books,
                  NoOfPostedProjects(projects: ownedProjects,)),
            ],
          ),
        ),
      ),
    );
  }




  /* --------------------------- Profile Image Widget --------------------------- */

  Widget buildProfileImage(String? profileUrl) => Stack(
    children: [
      CircleAvatar(
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
              color: Colors.indigoAccent,
            ),
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

}