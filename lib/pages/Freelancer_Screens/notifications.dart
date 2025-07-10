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
  String? userType;
  bool? _isClient;
  Map<int, bool> isHoverMap = {};
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
              userType = querySnapshot.docs.first['userType'];
              _isClient = userType == 'client';
              _currentIndex = _isClient! ? 0 : 0;
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
    List<int> allowedIndices = _isClient ?? false ? [0, 1, 4] : [0, 1, 2, 3, 4];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Notifications')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            if (isLoadingUser)
              const SizedBox(
                height: 40,
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.indigoAccent,
                    ),
                  ),
                ),
              )
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                    allowedIndices.length,
                    (index) {
                      int originalIndex = allowedIndices[index];
                      return InkWell(
                        onTap: () =>
                            setState(() => _currentIndex = originalIndex),
                        onHover: (value) =>
                            setState(() => isHoverMap[originalIndex] = value),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeIn,
                          height: 40,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          alignment: Alignment.center,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _currentIndex == originalIndex
                                  ? Colors.indigoAccent
                                  : Colors.grey,
                            ),
                            color: _currentIndex == originalIndex
                                ? Colors.indigoAccent
                                : (isHoverMap[originalIndex] ?? false)
                                    ? Colors.indigoAccent
                                    : null,
                          ),
                          child: Text(
                            [
                              'All',
                              'Received Bids',
                              'Sent Bids',
                              'Received Offers',
                              'Sent Offers'
                            ][originalIndex],
                            style: TextStyle(
                              fontSize: 16,
                              color: _currentIndex == originalIndex
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
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
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
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Received Offer Details',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                            color: _getStatusColor(offer['project_status'])
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: Navigator.of(context).pop,
                    ),
                  ],
                ),
                // Offer Details
                ListTile(
                  leading: Icon(
                    Icons.assignment_outlined,
                    size: 30,
                      color: _getStatusColor(offer['project_status']),
                  ),
                  title: Text(
                    offer['project_name'] ?? 'Unknown Project',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text('Project Name'),
                ),
                ListTile(
                  leading: Icon(
                    Icons.person_outline,
                    size: 30,
                    color: _getStatusColor(offer['project_status']),
                  ),
                  title: Text(
                    offer['owner_name'] ?? 'Unknown',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text('Offered By'),
                ),
                ListTile(
                  leading: Icon(
                    Icons.attach_money,
                    size: 30,
                    color: _getStatusColor(offer['project_status']),
                  ),
                  title: Text(
                    '\$${offer['budget']}',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text('Budget'),
                ),
                ListTile(
                  leading: Icon(
                    Icons.timer_outlined,
                    size: 30,
                    color: _getStatusColor(offer['project_status']),
                  ),
                  title: Text(
                    offer['estimated_time'] ?? 'Unknown',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text('Estimated Time'),
                ),
                ListTile(
                  leading: Icon(
                    Icons.info_outline,
                    size: 30,
                    color: _getStatusColor(offer['project_status']),
                  ),
                  title: Text(
                    offer['project_status'] ?? 'Unknown Status',
                    style: TextStyle(
                      color: _getStatusColor(offer['project_status']),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text('Project Status'),
                ),
                Text('${offer['description']}',
                  textAlign: TextAlign.justify,
                  style: TextStyle(
                  color: Colors.grey[700],
                ),),
                Divider(),
                Text('Inform the client about your project status.',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 5),
                // Status Buttons using Wrap to avoid overflow issues

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        dropdownColor: Colors.grey[200],
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        value: null, // No initial selection
                        hint: const Text('Change Project Status'),
                        items: ['Ongoing', 'Pending', 'Cancelled', 'Completed'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? selectedValue) {
                          if (selectedValue != null) {
                            _updateOfferStatus(selectedValue);
                          }
                        },
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
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
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
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Sent Offer Details',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: _getStatusColor(offer['project_status']),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: Navigator.of(context).pop,
                  ),
                ],
              ),
              // Offer details
              ListTile(
                leading: Icon(
                  Icons.assignment_outlined,
                  size: 30,
                  color: _getStatusColor(offer['project_status']),
                ),
                title: Text(
                  '${offer['project_name']}',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text('Project Name'),
              ),
              ListTile(
                leading: Icon(
                  Icons.person_outlined,
                  size: 30,
                  color: _getStatusColor(offer['project_status']),
                ),
                title: Text(
                  '${offer['assigned_to']}',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text('Offered To'),
              ),
              ListTile(
                leading: Icon(
                  Icons.attach_money,
                  size: 30,
                  color: _getStatusColor(offer['project_status']),
                ),
                title: Text(
                  '${offer['budget']}',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text('Budget'),
              ),
              ListTile(
                leading: Icon(
                  Icons.timer_outlined,
                  size: 30,
                  color: _getStatusColor(offer['project_status']),
                ),
                title: Text(
                  '${offer['estimated_time']}',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text('Estimated Time'),
              ),
              ListTile(
                leading: Icon(
                  Icons.info_outline,
                  size: 30,
                  color: _getStatusColor(offer['project_status']),
                ),
                title: Text(
                  offer['project_status'] ?? 'Unknown',
                  style: TextStyle(
                    color: _getStatusColor(offer['project_status']),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text('Project Status',style: TextStyle(
                  fontWeight: FontWeight.w500,
                ),),
              ),
              Divider(),
              Text('${offer['description']}',
                textAlign: TextAlign.justify,
                style: TextStyle(
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // show Received Bids details
  Future<void> _showNotificationPopup(
      BuildContext context, QueryDocumentSnapshot notification) async {
    final currentStatus = notification['status'] ?? 'Not Started';
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
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
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Received Bid Details',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: _getStatusColor(currentStatus),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: Navigator.of(context).pop,
                    ),
                  ],
                ),
                Text(
                  'You received a bid from ${notification['bidder_name']}.',
                  style: TextStyle(color: Colors.black87, fontSize: 15),
                ),
                ListTile(
                  leading: Icon(
                    Icons.assignment_outlined,
                    size: 30,
                    color: _getStatusColor(currentStatus),
                  ),
                  title: Text(
                    notification['project_name'] ?? 'Unknown Project',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text('Project Name'),
                ),
                ListTile(
                  leading: Icon(
                    Icons.attach_money,
                    size: 30,
                    color: _getStatusColor(currentStatus),
                  ),
                  title: Text(
                    '\$${notification['bid_amount']}',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text('Bid Amount'),
                ),
                ListTile(
                  leading: Icon(
                    Icons.timer_outlined,
                    size: 30,
                    color: _getStatusColor(currentStatus),
                  ),
                  title: Text(
                    notification['estimated_time'] ?? 'Unknown Time',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text('Estimated Time'),
                ),
                ListTile(
                  leading: Icon(
                    Icons.info_outline,
                    size: 30,
                    color: _getStatusColor(currentStatus),
                  ),
                  title: Text(
                    notification['status'] ?? 'Unknown Status',
                    style: TextStyle(
                      color: _getStatusColor(currentStatus),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text('Bid Status'),
                ),
                SizedBox(
                  height: 10,
                ),
                if (notification['message'] != null)
                  Text(
                    '${notification['message']}'
                  ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => _updateNotificationStatus(
                          notification.id, 'Rejected'),
                      child: const Text('Reject',
                          style: TextStyle(color: Colors.redAccent)),
                    ),
                    TextButton(
                      onPressed: () => _updateNotificationStatus(
                          notification.id, 'Accepted'),
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

  // update Project Status
  Future<void> _updateProjectStatus(
      QueryDocumentSnapshot notification, String newStatus) async {
    final projectId = notification['project_id'];
    final notificationId = notification.id;

    final WriteBatch batch = _firestore.batch();

    final projectRef = _firestore.collection('projects').doc(projectId);
    final notificationRef = _firestore.collection('notifications').doc(notificationId);

    batch.update(projectRef, {'project_status': newStatus});
    batch.update(notificationRef, {'project_status': newStatus});

    showSuccessSnackbar(context, 'Status updated to $newStatus');
    await _loadAllBids();
    try {
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to update both project and notification: $e');
    }
  }

  // Show status update popup for Accepted Sent Bids
  void _showStatusUpdatePopup(
      BuildContext context, QueryDocumentSnapshot notification) async {
    try {
      final projectId = notification['project_id'];
      final projectSnapshot =
      await _firestore.collection('projects').doc(projectId).get();
      final currentStatus = projectSnapshot['project_status'] ?? 'Not Started';

      showDialog(
        context: context,
        builder: (context) => Dialog(
          backgroundColor: Colors.white,
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
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Sent Bid Details',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                            color: _getStatusColor(currentStatus),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: Navigator.of(context).pop,
                      ),
                    ],
                  ),
                  Text(
                    'Congrats🎉 your bid is accepted by ${notification['owner_name']}.',
                    style: TextStyle(color: Colors.black87, fontSize: 15),
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.assignment_outlined,
                      size: 30,
                      color: _getStatusColor(currentStatus),
                    ),
                    title: Text(
                      notification['project_name'] ?? 'Unknown Project',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text('Project Name'),
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.attach_money,
                      size: 30,
                      color: _getStatusColor(currentStatus),
                    ),
                    title: Text('\$ ${notification['bid_amount']}',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,),
                    ),
                    subtitle: Text('Bid Amount'),
                  ),

                  ListTile(
                    leading: Icon(
                      Icons.timer_outlined,
                      size: 30,
                      color: _getStatusColor(currentStatus),
                    ),
                    title: Text(
                      notification['estimated_time'] ?? 'Unknown Time',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text('Estimated Time'),
                  ),

                  ListTile(
                    leading: Icon(
                      Icons.info_outline,
                      size: 30,
                      color: _getStatusColor(currentStatus),
                    ),
                    subtitle: Text(
                      'Project Status',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    title: Text(currentStatus,style: TextStyle(
                      color: _getStatusColor(currentStatus),
                      fontWeight: FontWeight.bold
                    ),),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Inform the client about project status.',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          dropdownColor: Colors.grey[200],
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey[200],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                          ),
                          value: null, // No initial selection
                          hint: const Text('Change Project Status'),
                          items: ['Pending', 'Ongoing', 'Cancelled', 'Completed'].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) async {
                            if (newValue != null) {
                              try {
                                await _updateProjectStatus(notification, newValue);
                                Navigator.of(context).pop();
                              } catch (e) {
                                showErrorSnackbar(context, 'Error updating status: $e');
                              }
                            }
                          },
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
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
      ),
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
  Widget _buildNotificationItem(
      QueryDocumentSnapshot notification, bool isReceived) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
      ),
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
  Future<void> _updateNotificationStatus(
      String notificationId, String status) async {
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
