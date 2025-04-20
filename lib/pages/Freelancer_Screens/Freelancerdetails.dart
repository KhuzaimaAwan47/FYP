import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:my_fyp/utlis/snack_bars.dart';
import 'package:shimmer/shimmer.dart';
import '../Freelancer_Screens//Chat.dart';
import 'OfferNow.dart';


class FreelancerDetails extends StatefulWidget {
  final Map<String, dynamic> freelancer;

  const FreelancerDetails({
    super.key,
    required this.freelancer,
  });

  @override
  State<FreelancerDetails> createState() => _FreelancerDetailsState();
  }


class _FreelancerDetailsState extends State<FreelancerDetails> {

  // Initialize Firebase Services
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Constants
  final double coverHeight = 150;
  final double profileHeight = 130;

  // State variable
  double userRating = 0;
  int totalReviews = 0;
  double averageRating = 0;
  Map<String, int> _projectStatusCounts = {};

  /* --------------------------- Lifecycle Methods --------------------------- */

  @override
  void initState() {
    super.initState();
    loadFreelancerDetails();
    loadProjects();
  }

  /* --------------------------- Data Loading Methods --------------------------- */

  Future<void> loadProjects() async {
    try {
      User? currentUser = _auth.currentUser;
      if (currentUser == null) return;

      String freelancerUsername = widget.freelancer['username'];
      QuerySnapshot projectsQuery = await _firestore
          .collection('projects')
          .where('assigned_to', isEqualTo: freelancerUsername)
          .get();

      Map<String, int> counts = {
        'Ongoing': 0,
        'Pending': 0,
        'Completed': 0,
        'Cancelled': 0,
      };

      for (var doc in projectsQuery.docs) {
        var data = doc.data() as Map<String, dynamic>;
        String? status = data['project_status'];
        if (status != null && counts.containsKey(status)) {
          counts[status] = counts[status]! + 1;
        }
      }

      setState(() {
        _projectStatusCounts = counts;
      });
      print('Project Status Counts: $_projectStatusCounts');
    } catch (e) {
      print('Error: $e');
    }
  }

  // Load freelancer ratings
  void loadFreelancerDetails() async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) return;
    String freelancerUid = widget.freelancer['uid'];
    String userId = currentUser.uid;

    QuerySnapshot freelancerQuery = await _firestore
        .collection('users')
        .where('uid', isEqualTo: freelancerUid)
        .limit(1)
        .get(GetOptions(source: Source.server));

    if (freelancerQuery.docs.isEmpty) return;

    DocumentSnapshot freelancerSnapshot = freelancerQuery.docs.first;
    Map<String, dynamic>? freelancerData =
        freelancerSnapshot.data() as Map<String, dynamic>?;

    if (freelancerData != null) {
      Map<String, dynamic> ratings =
          Map<String, dynamic>.from(freelancerData['ratings'] ?? {});
      double totalRating = ratings.values.fold(0, (sum, item) => sum + item);
      int totalReviews = ratings.length;
      double previousRating = ratings[userId]?.toDouble() ?? 0;

      setState(() {
        averageRating = totalReviews > 0 ? totalRating / totalReviews : 0;
        this.totalReviews = totalReviews;
        userRating = previousRating;
      });
      print('User Rating Loaded: $userRating');
    }
  }

  // updating ratings
  void onRatingUpdate(double rating) async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) return;

    String freelancerUid = widget.freelancer['uid']; // Freelancer UID
    String userId = currentUser.uid; // Current user UID

    try {
      // Finding Freelancer document using uid
      QuerySnapshot freelancerQuery = await _firestore
          .collection('users')
          .where('uid', isEqualTo: freelancerUid)
          .limit(1)
          .get();

      if (freelancerQuery.docs.isEmpty) return;

      DocumentReference freelancerRef = freelancerQuery.docs.first.reference;
      DocumentSnapshot freelancerSnapshot = await freelancerRef.get();

      Map<String, dynamic>? freelancerData =
      freelancerSnapshot.data() as Map<String, dynamic>?;
      if (freelancerData != null) {
        Map<String, dynamic> ratings =
        Map<String, dynamic>.from(freelancerData['ratings'] ?? {});

        ratings[userId] = rating; // User first rating update

        double totalRating = ratings.values.fold(0, (sum, item) => sum + item);
        int totalReviews = ratings.length; // Unique users rating count

        double averageRating = double.parse((totalRating / totalReviews).toStringAsFixed(1));

        await freelancerRef.update({
          'ratings': ratings,
          'averageRating': averageRating,
          'totalReviews': totalReviews
        });

        setState(() {
          userRating = rating;
          this.averageRating = averageRating;
          this.totalReviews = totalReviews;
        });
      }
    } catch (e) {
      showErrorSnackbar(context, 'Error updating rating: $e');
    }
  }

  /* --------------------------- Main Build Widget --------------------------- */

  @override
  Widget build(BuildContext context) {
    final top = coverHeight - profileHeight / 2;
    var screenWidth = MediaQuery.of(context).size.width;

    // Extract freelancer details from the widget
    final freelancer = widget.freelancer;
    final String firstName = freelancer['first_name'] ?? 'N/A';
    final String lastName = freelancer['last_name'] ?? 'N/A';
    final String headline = freelancer['headline'] ?? 'N/A';
    final String location = freelancer['location'] ?? 'N/A';
    final String skills = freelancer['skills'] ?? 'N/A';
    final String hourlyRate = freelancer['hourly_rate'].toString();
    final String description =
        freelancer['description'] ?? 'No description available';
    final String profileUrl = freelancer['profileUrl'] ??
        'https://t4.ftcdn.net/jpg/05/49/98/39/360_F_549983970_bRCkYfk0P6PP5fKbMhZMIb07mCJ6esXL.jpg'; // Placeholder profile image url
    final String coverUrl = freelancer['coverUrl'] ??
        'https://reactplay.io/static/media/placeholder_cover.ea7b18e0704561775829.jpg'; // Placeholder cover image url

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Freelancer Details'),
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
              margin: EdgeInsets.only(top: 215),
              width: screenWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 16.0, right: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              firstName,
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w500),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              lastName,
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            RatingBar.builder(
                              initialRating: userRating,
                              minRating: 0,
                              direction: Axis.horizontal,
                              itemCount: 5,
                              itemSize: 25,
                              itemBuilder: (context, _) => Icon(
                                Icons.star,
                                color: Colors.amber,
                              ),
                              onRatingUpdate: (rating) {
                                onRatingUpdate(rating);
                                setState(
                                    () {}); // Trigger a rebuild to update the UI
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: EdgeInsets.only(left: 16.0, right: 16),
                    child: Text(headline,
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                          fontSize: 18,
                        )),
                  ),
                  const SizedBox(height: 5),
                  Padding(
                    padding: EdgeInsets.only(left: 16.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_pin,
                          size: 20,
                          color: Colors.indigoAccent,
                        ),
                        Text(
                          location,
                          style: TextStyle(fontSize: 17, color: Colors.black54),
                        ),
                        SizedBox(width: 10),
                        Icon(
                          Icons.attach_money,
                          size: 20,
                          color: Colors.indigoAccent,
                        ),
                        Text(
                          '\$$hourlyRate /hr.',
                          style: TextStyle(fontSize: 17, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                  Padding(
                    padding: EdgeInsets.only(left: 16.0, right: 16.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.stars,
                          size: 20,
                          color: Colors.indigoAccent,
                        ),
                        Text(skills,
                            style:
                                TextStyle(fontSize: 17, color: Colors.black54)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, right: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.star_rate, color: Colors.amber, size: 20),
                            SizedBox(width: 4),
                            Text(
                              'Average Rating: ${averageRating.toStringAsFixed(1)}',
                              style: TextStyle(fontSize: 16, color: Colors.black54),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            Icon(Icons.reviews, color: Colors.indigoAccent, size: 20),
                            SizedBox(width: 4),
                            Text(
                              'Total Reviews: $totalReviews',
                              style: TextStyle(fontSize: 16, color: Colors.black54),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 16.0, right: 16.0),
                    child: Text(
                      description,
                      textAlign: TextAlign.justify,
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, right: 16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: projectCard(
                                  'Ongoing Projects',
                                  _projectStatusCounts['Ongoing'] ?? 0,
                                  Colors.blue),
                            ),
                            Expanded(
                              child: projectCard(
                                  'Pending Projects',
                                  _projectStatusCounts['Pending'] ?? 0,
                                  Colors.orange),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: projectCard(
                                  'Completed Projects',
                                  _projectStatusCounts['Completed'] ?? 0,
                                  Colors.green),
                            ),
                            Expanded(
                              child: projectCard(
                                  'Cancelled Projects',
                                  _projectStatusCounts['Cancelled'] ?? 0,
                                  Colors.red),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              elevation: 2.0,
                              backgroundColor: Colors.indigoAccent,
                              padding: EdgeInsets.symmetric(
                                horizontal:
                                    MediaQuery.of(context).size.width * 0.13,
                                vertical:
                                    MediaQuery.of(context).size.height * 0.01,
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MessagePage(
                                    freelancerUid: widget.freelancer['uid'],
                                    freelancerUsername: widget.freelancer['username'],
                                    profileImageUrl: widget.freelancer['profileUrl'] ??
                                        'https://t4.ftcdn.net/jpg/05/49/98/39/360_F_549983970_bRCkYfk0P6PP5fKbMhZMIb07mCJ6esXL.jpg',
                                  ),
                                ),
                              );
                            },
                            child: const Text(
                              'Contact Me',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                elevation: 2.0,
                                backgroundColor: Colors.indigoAccent,
                                padding: EdgeInsets.symmetric(
                                  horizontal:
                                      MediaQuery.of(context).size.width * 0.13,
                                  vertical:
                                      MediaQuery.of(context).size.height * 0.01,
                                )),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => OfferNow(
                                      freelancerUsername:
                                          widget.freelancer['username']),
                                ),
                              );
                            },
                            child: const Text(
                              'Offer Now',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
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

/* --------------------------- Cover Image Widget --------------------------- */

  Widget buildCoverImage(String coverUrl) {
    return FutureBuilder(
      future: precacheImage(NetworkImage(coverUrl), context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: coverHeight,
              width: double.infinity,
              color: Colors.grey[300],
            ),
          );
        } else {
          return GestureDetector(
            onTap: () {
              // Navigate to a full-screen view of the cover photo
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CoverPhoto(coverUrl: coverUrl),
                ),
              );
            },
            child: Container(
              height: coverHeight,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                image: DecorationImage(
                  image: NetworkImage(coverUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        }
      },
    );
  }

  /* --------------------------- Profile Image Widget --------------------------- */

  Widget buildProfileImage(String profileUrl) => Padding(
        padding: const EdgeInsets.only(left: 10.0),
        child: GestureDetector(
          onTap: () {
            // Navigate to a full-screen view of the profile photo
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfilePhoto(imageUrl: profileUrl),
              ),
            );
          },
          child: CircleAvatar(
            radius: profileHeight / 2,
            backgroundImage: NetworkImage(profileUrl),
          ),
        ),
      );
}

/* --------------------------- Profile Photo full Screen Display --------------------------- */

class ProfilePhoto extends StatelessWidget {
  final String imageUrl;

  const ProfilePhoto({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text('Profile Photo'),
        ),
        body: Center(
          child: InteractiveViewer(
            child: CircleAvatar(
              backgroundImage: Image.network(imageUrl).image,
              radius: 200,
            ),
          ),
        ));
  }
}

/* --------------------------- Cover Photo full Screen Display --------------------------- */

class CoverPhoto extends StatelessWidget {
  final String coverUrl;

  const CoverPhoto({super.key, required this.coverUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Cover photo'),
      ),
      body: Center(
        child: InteractiveViewer(
          child: Image.network(
            coverUrl,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}