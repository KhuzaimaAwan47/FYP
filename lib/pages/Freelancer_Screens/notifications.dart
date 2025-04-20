import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_fyp/utlis/snack_bars.dart';

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  // Initialize Firebase services
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // State management
  late List<bool> isHoverList = [false, false, false, false, false];
  int _currentIndex =
  0; // 0: All, 1: Received, 2: Sent, 3: Received Offers, 4: Sent Offers
  String? userName;
  bool isLoadingUser = true;
  bool isLoadingNotifications = false;

  // List to store notifications
  List<QueryDocumentSnapshot> receivedNotifications = [];
  List<QueryDocumentSnapshot> sentNotifications = [];
  List<QueryDocumentSnapshot> receivedOffers = [];
  List<QueryDocumentSnapshot> sentOffers = [];

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  /* --------------------------- Fetching Current-user Method --------------------------- */

  Future<void> _loadCurrentUser() async {
    setState(() => isLoadingUser = true);
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        QuerySnapshot querySnapshot = await _firestore
            .collection('users')
            .where('email', isEqualTo: user.email)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          if (mounted) {
            setState(() {
              userName = querySnapshot.docs.first['username'];
              isLoadingUser = false;
            });
            await Future.wait([_loadAllBids(), _loadAllOffers()]);
          }
        } else {
          if (mounted) setState(() => isLoadingUser = false);
          showErrorSnackbar(context, 'User name not found!');
        }
      } catch (e) {
        if (mounted) setState(() => isLoadingUser = false);
        showErrorSnackbar(context, 'Error loading user: $e');
      }
    }
  }

/* ----------------------------- Main Build Widget ----------------------------- */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Tab Bar
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  5,
                      (index) {
                    return InkWell(
                      onTap: () => setState(() => _currentIndex = index),
                      onHover: (value) =>
                          setState(() => isHoverList[index] = value),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeIn,
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        alignment: Alignment.center,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        // spacing between tabs
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _currentIndex == index
                                ? Colors.indigoAccent
                                : Colors.grey,
                          ),
                          color: _currentIndex == index
                              ? Colors.indigoAccent // Selected fill
                              : isHoverList[index]
                              ? Colors.indigoAccent
                              .withOpacity(0.1) // Hover fill
                              : null, // Transparent otherwise
                        ),
                        child: Text(
                          [
                            'All',
                            'Received Bids',
                            'Sent Bids',
                            'Received Offers',
                            'Sent Offers'
                          ][index],
                          style: TextStyle(
                            fontSize: 16,
                            color: _currentIndex == index
                                ? Colors.white
                                : Colors.black87,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Content Area
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  /* --------------------------- Tab Bar Content --------------------------- */

  Widget _buildContent() {
    if (isLoadingUser || isLoadingNotifications) {
      return const Center(
          child: CircularProgressIndicator(color: Colors.indigo));
    }

    List<Widget> content = [];

    if (_currentIndex == 0) {
      // All
      if (receivedNotifications.isEmpty && sentNotifications.isEmpty) {
        return const Center(
            child: Text('No bids available', style: TextStyle(fontSize: 16)));
      }
      content.addAll([
        if (receivedNotifications.isNotEmpty) ...[
          _buildSectionHeader('Received Bids'),
          ...receivedNotifications.map((n) => _buildNotificationItem(n, true)),
        ],
        if (sentNotifications.isNotEmpty) ...[
          _buildSectionHeader('Sent Bids'),
          ...sentNotifications.map((n) => _buildNotificationItem(n, false)),
        ],
        if (receivedOffers.isNotEmpty) ...[
          _buildSectionHeader('Received Offers'),
          ...receivedOffers.map((o) => _buildOfferItem(o, true)),
        ],
        if (sentOffers.isNotEmpty) ...[
          _buildSectionHeader('Sent Offers'),
          ...sentOffers.map((o) => _buildOfferItem(o, false)),
        ]
      ]);
    } else if (_currentIndex == 1) {
      content.addAll([
        if (receivedNotifications.isNotEmpty) ...[
          _buildSectionHeader('Received Bids'),
          ...receivedNotifications.map((n) => _buildNotificationItem(n, true)),
        ],
      ]);
    } else if (_currentIndex == 2) {
      content.addAll([
        if (sentNotifications.isNotEmpty) ...[
          _buildSectionHeader('Sent Bids'),
          ...sentNotifications.map((n) => _buildNotificationItem(n, false)),
        ]
      ]);
    } else if (_currentIndex == 3) {
      content.addAll([
        if (receivedOffers.isNotEmpty) ...[
          _buildSectionHeader('Received Offers'),
          ...receivedOffers.map((o) => _buildOfferItem(o, true)),
        ]
      ]);
    } else {
      // Sent
      content.addAll([
        if (sentOffers.isNotEmpty) ...[
          _buildSectionHeader('Sent Offers'),
          ...sentOffers.map((o) => _buildOfferItem(o, false)),
        ]
      ]);
    }

    return ListView(
      //padding: const EdgeInsets.all(8),
      children: content,
    );
  }

/* --------------------------- Helper Methods --------------------------- */

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'Accepted':
        return Colors.green;
      case 'Rejected':
        return Colors.red;
      case 'Pending':
        return Colors.orange;
      case 'Cancelled':
        return Colors.red;
      case 'Ongoing':
        return Colors.blue;
      case 'Completed':
        return Colors.green;
      default:
        return Colors.orange;
    }
  }

  // Header
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.indigo,
        ),
      ),
    );
  }

  /* --------------------------- Data Loading Methods --------------------------- */

  // Function to Load all offers
  Future<void> _loadAllOffers() async {
    if (userName == null) return;
    setState(() => isLoadingNotifications = true);
    try {
      await Future.wait([_loadReceivedOffers(), _loadSentOffers()]);
    } catch (e) {
      showErrorSnackbar(context, 'Error loading offers: $e');
    } finally {
      if (mounted) setState(() => isLoadingNotifications = false);
    }
  }

  // Function to load Received Offers
  Future<void> _loadReceivedOffers() async {
    QuerySnapshot snapshot = await _firestore
        .collection('offers')
        .where('assigned_to', isEqualTo: userName)
        .orderBy('offer_created_at', descending: true)
        .get();
    if (mounted) setState(() => receivedOffers = snapshot.docs);
  }

  // Function to load Sent Offers
  Future<void> _loadSentOffers() async {
    QuerySnapshot snapshot = await _firestore
        .collection('offers')
        .where('owner_name', isEqualTo: userName)
        .orderBy('offer_created_at', descending: true)
        .get();
    if (mounted) setState(() => sentOffers = snapshot.docs);
  }

  //Load all Bids
  Future<void> _loadAllBids() async {
    if (userName == null) return;
    setState(() => isLoadingNotifications = true);
    try {
      await Future.wait([_loadReceivedBids(), _loadSentBids()]);
    } catch (e) {
      showErrorSnackbar(context, 'Error loading bids: $e');
    } finally {
      if (mounted) setState(() => isLoadingNotifications = false);
    }
  }

// Function to load Received Bids
  Future<void> _loadReceivedBids() async {
    QuerySnapshot snapshot = await _firestore
        .collection('notifications')
        .where('owner_name', isEqualTo: userName)
        .orderBy('created_at', descending: true)
        .get();
    if (mounted) setState(() => receivedNotifications = snapshot.docs);
  }

  // Function to load Sent Bids
  Future<void> _loadSentBids() async {
    QuerySnapshot snapshot = await _firestore
        .collection('notifications')
        .where('bidder_name', isEqualTo: userName)
        .orderBy('created_at', descending: true)
        .get();
    if (mounted) setState(() => sentNotifications = snapshot.docs);
  }

  /* --------------------------- Dialogs Popup Methods --------------------------- */

  // Show received offer details and status update dialog
  void _showOfferPopup(BuildContext context, QueryDocumentSnapshot offer) {
    showDialog(
      context: context,
      builder: (context) =>
          Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dialog Title
                    Center(
                      child: Text(
                        'Received Offer Details',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: Colors.indigoAccent,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Offer Details
                    RichText(
                      textAlign: TextAlign.justify,
                      text: TextSpan(
                        style: const TextStyle(
                            color: Colors.black87, fontSize: 14),
                        children: [
                          TextSpan(
                            text: '${offer['project_name'] ??
                                'Unknown Project'}\n',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.indigoAccent,
                              fontSize: 16,
                            ),
                          ),
                          const TextSpan(
                              text: '\nOffered by: ',
                              style: TextStyle(color: Colors.black87)),
                          TextSpan(
                            text: '${offer['owner_name']}\n',
                            style: const TextStyle(
                              color: Colors.indigo,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const TextSpan(
                              text: '\nBudget: ',
                              style: TextStyle(color: Colors.black87)),
                          TextSpan(
                            text: '\$${offer['budget']}\n',
                            style: const TextStyle(
                              color: Colors.indigo,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const TextSpan(
                              text: '\nEstimated Time: ',
                              style: TextStyle(color: Colors.black87)),
                          TextSpan(
                            text: '${offer['estimated_time']}\n',
                            style: const TextStyle(
                              color: Colors.indigo,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const TextSpan(
                              text: '\nDescription: ',
                              style: TextStyle(color: Colors.black87)),
                          TextSpan(
                            text: '\n${offer['description']}\n',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          const TextSpan(
                              text: '\nCurrent Project Status: ',
                              style: TextStyle(color: Colors.black87)),
                          TextSpan(
                            text: '${offer['project_status']}\n',
                            style: TextStyle(
                              color: _getStatusColor(offer['project_status']),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: '\nInform the client about your project status.',
                            style: TextStyle(
                                color: Colors.redAccent,
                                fontWeight: FontWeight.w500),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Status Buttons using Wrap to avoid overflow issues
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              _updateOfferStatus('Ongoing');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Ongoing',
                              style: TextStyle(
                                  fontSize: 14, color: Colors.white),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 8.0,
                        ),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              _updateOfferStatus('Pending');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orangeAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Pending',
                              style: TextStyle(
                                  fontSize: 14, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              _updateOfferStatus('Cancelled');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Cancelled',
                              style: TextStyle(
                                  fontSize: 14, color: Colors.white),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 8.0,
                        ),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              _updateOfferStatus('Completed');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Completed',
                              style: TextStyle(
                                  fontSize: 14, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }


  // Show sent offer details
  void _showSentOfferPopup(BuildContext context, QueryDocumentSnapshot offer) {
    showDialog(
      context: context,
      builder: (context) =>
          Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Center(
                    child: Text(
                      'Sent Offer Details',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: Colors.indigoAccent,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Offer details
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                          color: Colors.black87, fontSize: 14),
                      children: [
                        TextSpan(
                          text: '${offer['project_name'] ??
                              'Unknown Project'}\n',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo,
                            fontSize: 16,
                          ),
                        ),
                        const TextSpan(
                          text: '\nProject offered to: ',
                          style: TextStyle(color: Colors.black87),
                        ),
                        TextSpan(
                          text: '${offer['assigned_to']}\n',
                          style: const TextStyle(
                            color: Colors.indigoAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const TextSpan(
                          text: '\nProject Budget: ',
                          style: TextStyle(color: Colors.black87),
                        ),
                        TextSpan(
                          text: '${offer['budget']}\n',
                          style: const TextStyle(
                            color: Colors.indigoAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const TextSpan(
                          text: '\nEstimated time: ',
                          style: TextStyle(color: Colors.black87),
                        ),
                        TextSpan(
                          text: '${offer['estimated_time']}\n',
                          style: const TextStyle(
                            color: Colors.indigoAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const TextSpan(
                          text: '\nProject Status: ',
                          style: TextStyle(color: Colors.black87),
                        ),
                        TextSpan(
                          text: '${offer['project_status']}\n',
                          style: TextStyle(
                            color: _getStatusColor(offer['project_status']),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Close button
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.indigoAccent,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Close',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }


  // show Received Bids details
  void _showNotificationPopup(BuildContext context,
      QueryDocumentSnapshot notification) {
    showDialog(
      context: context,
      builder: (context) =>
          Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Text(
                        'Received Bid Details',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: Colors.indigoAccent,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      'You received a bid from ${notification['bidder_name']}.',
                      style: TextStyle(color: Colors.black87, fontSize: 15),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      'Project Name: ${notification['project_name']}',
                      style: TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                          fontSize: 14),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      'Bid Amount: \$${notification['bid_amount']}',
                      style: TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                          fontSize: 14),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      'Estimated Time: ${notification['estimated_time']}',
                      style: TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                          fontSize: 14),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        TextButton(
                          onPressed: () {},
                          child: const Text('Message',
                              style: TextStyle(color: Colors.indigoAccent)),
                        ),
                        TextButton(
                          onPressed: () =>
                              _updateNotificationStatus(
                                  notification.id,'Rejected'),
                          child: const Text('Reject',
                              style: TextStyle(color: Colors.redAccent)),
                        ),
                        TextButton(
                          onPressed: () =>
                              _updateNotificationStatus(
                                  notification.id,'Accepted'),
                          child: const Text('Accept',
                              style: TextStyle(color: Colors.green)),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
    );
  }


// Show status update popup for Accepted Sent Bids
  void _showStatusUpdatePopup(BuildContext context,
      QueryDocumentSnapshot notification) async {
    try {
      final projectId = notification['project_id'];
      final projectSnapshot =
      await _firestore.collection('projects').doc(projectId).get();
      final currentStatus = projectSnapshot['project_status'] ?? 'Not Started';

      showDialog(
        context: context,
        builder: (context) =>
            Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(
                        child: Text(
                          'Sent Bid Details',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            color: Colors.indigoAccent,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        'Congrats🎉 your bid is accepted by ${notification['owner_name']}.',
                        style: TextStyle(color: Colors.black87, fontSize: 15),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        'Project Name: ${notification['project_name']}',
                        style: TextStyle(
                            color: Colors.black45,
                            fontWeight: FontWeight.w500,
                            fontSize: 14),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        'Bid Amount: \$${notification['bid_amount']}',
                        style: TextStyle(
                            color: Colors.black45,
                            fontWeight: FontWeight.w500,
                            fontSize: 14),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        'Estimated Time: ${notification['estimated_time']}',
                        style: TextStyle(
                            color: Colors.black45,
                            fontWeight: FontWeight.w500,
                            fontSize: 14),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      RichText(
                        text: TextSpan(
                          text: 'Current Status: ',
                          style: TextStyle(
                            color: Colors.black45,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                          children: [
                            TextSpan(
                              text: currentStatus,
                              style: TextStyle(
                                color: _getStatusColor(currentStatus),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        'Inform the client about project status.',
                        style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 15,
                            fontWeight: FontWeight.w500),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () =>
                                  _updateProjectStatus(notification, 'Pending'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orangeAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text('Pending',
                                  style:
                                  TextStyle(color: Colors.white, fontSize: 16)),
                            ),
                          ),
                          SizedBox(
                            width: 8.0,
                          ),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () =>
                                  _updateProjectStatus(notification, 'Ongoing'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text('Ongoing',
                                  style:
                                  TextStyle(color: Colors.white, fontSize: 16)),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () =>
                                  _updateProjectStatus(
                                      notification, 'Cancelled'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text('Cancelled',
                                  style:
                                  TextStyle(color: Colors.white, fontSize: 16)),
                            ),
                          ),
                          SizedBox(
                            width: 8.0,
                          ),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () =>
                                  _updateProjectStatus(
                                      notification, 'Completed'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text('Completed',
                                  style:
                                  TextStyle(color: Colors.white, fontSize: 16)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
      );
    } catch (e) {
      showErrorSnackbar(context, 'Error fetching project status: $e');
    }
  }


  /* --------------------------- Offers List Widget --------------------------- */

  // Build offer list item
  Widget _buildOfferItem(QueryDocumentSnapshot offer, bool isReceived) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8,),
      child: Card(
        color: Colors.grey[100],
        elevation: 0,
        child: ListTile(
          title: Text(
            offer['project_name'] ?? 'Unknown Project',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                'Budget: \$${offer['budget']}',
                style: TextStyle(color: Colors.grey[700]),
              ),
              Text(
                'Estimated Time: ${offer['estimated_time']}',
                style: TextStyle(color: Colors.grey[700]),
              ),
            ],
          ),
          trailing: Text(
            offer['project_status'] ?? 'Pending',
            style: TextStyle(
              color: _getStatusColor(offer['project_status']),
              fontWeight: FontWeight.w500,
            ),
          ),
          onTap: isReceived
              ? () => _showOfferPopup(context, offer)
              : () => _showSentOfferPopup(context, offer),
        ),
      ),
    );
  }

/* --------------------------- Bids List Widget --------------------------- */

  // Build notification list i.e received bids
  Widget _buildNotificationItem(QueryDocumentSnapshot notification,
      bool isReceived) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8,),
      child: Card(
        color: Colors.grey[100],
        elevation: 0,
        child: ListTile(
          title: Text(
            notification['project_name'] ?? 'Unknown Project',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                'Bid Amount: \$${notification['bid_amount']}',
                style: TextStyle(color: Colors.grey[700]),
              ),
              Text(
                'Estimated Time: ${notification['estimated_time']}',
                style: TextStyle(color: Colors.grey[700]),
              ),
            ],
          ),
          trailing: Text(
            notification['status'] ?? 'Pending',
            style: TextStyle(
              color: _getStatusColor(notification['status']),
              fontWeight: FontWeight.w500,
            ),
          ),
          onTap: isReceived
              ? () => _showNotificationPopup(context, notification)
              : notification['status'] == 'Accepted'
              ? () => _showStatusUpdatePopup(context, notification)
              : null,
        ),
      ),
    );
  }


  /* --------------------------- Methods for updating status of bids,projects & offers --------------------------- */


  //update accepted bid status
  Future<void> _updateNotificationStatus(String notificationId,
      String status) async {
    try {
      // Update the notification status
      await _firestore.collection('notifications').doc(notificationId).update({
        'status': status,
      });

      // If the bid is accepted, update the project's assigned_to field
      if (status == 'Accepted') {
        // Fetch the notification data
        DocumentSnapshot notificationSnapshot = await _firestore
            .collection('notifications')
            .doc(notificationId)
            .get();

        if (notificationSnapshot.exists) {
          String projectId = notificationSnapshot['project_id'];
          String bidderName = notificationSnapshot['bidder_name'];

          // Update the project document
          await _firestore
              .collection('projects')
              .doc(projectId)
              .update({'assigned_to': bidderName});
        }
      }
      if (status == 'Rejected') {
        String projectId = receivedNotifications.first['project_id'];
        await _firestore
            .collection('projects')
            .doc(projectId)
            .update({'assigned_to': null});
      }

      if (mounted) {
        showSuccessSnackbar(context, 'Bid is $status');
        Navigator.of(context).pop();
        await _loadAllBids();
      }
    } catch (e) {
      showErrorSnackbar(context, 'Error updating bid status: $e');
    }
  }

  // update Project Status
  Future<void> _updateProjectStatus(QueryDocumentSnapshot notification,
      String newStatus) async {
    try {
      final projectId = notification['project_id'];
      await _firestore.collection('projects').doc(projectId).update({
        'project_status': newStatus,
        'last_updated': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.of(context).pop();
        showSuccessSnackbar(context, 'Status updated to $newStatus');
        await _loadAllBids(); // Refresh the list after updating the status
      }
    } catch (e) {
        showErrorSnackbar(context, 'Error updating status: $e');
    }
  }

  // update Received offer status
  Future<void> _updateOfferStatus(String newStatus) async {
    try {
      // Query Firestore for offers assigned to the current user
      final querySnapshot = await _firestore
          .collection('offers')
          .where('assigned_to',
          isEqualTo: userName) // Replace with your user name variable
          .get();

      if (querySnapshot.docs.isEmpty) {
        showSuccessSnackbar(context, 'No offers found assigned to $userName');
        return;
      }

      // Assuming only one offer is assigned to the user; adjust if multiple exist
      final offerDoc = querySnapshot.docs.first;
      final offerId = offerDoc.id;

      // Update the offer's status
      await _firestore.collection('offers').doc(offerId).update({
        'project_status': newStatus,
        'last_updated': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.of(context).pop();
        showSuccessSnackbar(context, 'Status updated to $newStatus');
        await _loadAllOffers(); // Refresh the list if needed
      }
    } catch (e) {
      showErrorSnackbar(context, 'Error updating status: $e');
    }
  }
}
